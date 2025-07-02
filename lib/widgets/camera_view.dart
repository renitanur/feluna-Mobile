// lib/widgets/camera_view.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:feluna/services/inference_isolate.dart'; // Import fungsi isolate
import 'pose_painter.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;
import '../services/pose_classifier.dart';
import '../models/pose_definitions.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isDetecting = false;
  List<List<double>>? _pose;
  int _frameCount = 0;
  final int _frameInterval = 10;
  double _rotation = 0; // Rotasi dalam derajat
  bool _isFrontCamera = false; // Menentukan apakah kamera depan
  final String _modelPath = 'assets/models/4.tflite'; // Path model
  Uint8List? _modelBytes; // Byte buffer model

  PoseClassifier? _poseClassifier;
  String? _currentPose;
  String _feedbackMessage = '';
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
    _poseClassifier = PoseClassifier(poseDefinitions: poseDefinitions);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final orientation = MediaQuery.of(context).orientation;
    setState(() {
      if (orientation == Orientation.portrait) {
        _rotation = 0;
      } else if (orientation == Orientation.landscape) {
        _rotation = 90;
      }
    });
    super.didChangeMetrics();
  }

  Future<void> _initialize() async {
    try {
      // Memuat byte buffer model di main isolate
      ByteData modelData = await rootBundle.load(_modelPath);
      _modelBytes = modelData.buffer.asUint8List();
      print('Model loaded from assets');

      // Inisialisasi kamera setelah model dimuat
      _initializeCamera();
    } catch (e) {
      print('Error saat memuat model: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      // Memilih kamera depan
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first, // Jika tidak ada kamera depan, pilih kamera pertama
      );

      _isFrontCamera = frontCamera.lensDirection == CameraLensDirection.front;

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium, // Gunakan resolusi sedang untuk kualitas yang baik
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      print('Kamera depan berhasil diinisialisasi');

      // Mulai image stream
      _cameraController!.startImageStream((CameraImage image) async {
        _frameCount++;
        if (_frameCount % _frameInterval != 0) {
          return; // Lewati frame ini
        }

        if (!_isDetecting && _modelBytes != null) {
          _isDetecting = true;

          try {
            // Convert CameraImage ke img.Image
            img.Image? convertedImage = _convertCameraImage(image);

            if (convertedImage != null) {
              // Jalankan inferensi di isolate
              List<List<double>>? pose = await runInferenceInIsolate(_modelBytes!, convertedImage);
              if (pose != null) {
                // Rotasi dan mirroring pose points berdasarkan rotasi kamera dan jenis kamera
                List<List<double>> transformedPose = _rotateAndMirrorPose(pose, _rotation, _isFrontCamera);

                // Menambahkan log detail pose
                print('Panjang Data Pose: ${transformedPose.length}');
                for (int i = 0; i < transformedPose.length; i++) {
                  print('Transformed Keypoint $i: y=${transformedPose[i][0]}, x=${transformedPose[i][1]}, score=${transformedPose[i][2]}');
                }

                // Klasifikasi pose
                String? detectedPose = _poseClassifier?.classifyPose(transformedPose);

                if (detectedPose != null) {
                  _feedbackMessage = 'Pose Terdeteksi: $detectedPose';
                  _speak('Pose $detectedPose terdeteksi dengan benar');
                  print(_feedbackMessage);
                } else {
                  _feedbackMessage = 'Pose Tidak Dikenali';
                  print(_feedbackMessage);
                }

                setState(() {
                  _pose = transformedPose;
                  _currentPose = detectedPose;
                });
                print('Pose berhasil dideteksi dan diupdate ke UI');
              } else {
                print('Inferensi gagal atau pose tidak terdeteksi');
              }
            } else {
              print('Konversi gambar gagal');
            }
          } catch (e) {
            print('Error saat proses image stream: $e');
          } finally {
            _isDetecting = false;
          }
        }
      });

      setState(() {});
    } catch (e) {
      print('Error saat menginisialisasi kamera: $e');
    }
  }

  Future<void> _speak(String message) async {
    await flutterTts.speak(message);
  }

  // Fungsi untuk mengubah rotasi dan mirroring pose points
  List<List<double>> _rotateAndMirrorPose(List<List<double>> pose, double rotation, bool isFrontCamera) {
    return pose.map((keypoint) {
      double y = keypoint[0];
      double x = keypoint[1];
      double score = keypoint[2];
      double rotatedX, rotatedY;

      // Rotasi berdasarkan rotasi kamera
      if (rotation == 90) {
        // Rotasi 90 derajat ke kanan (landscape)
        rotatedX = y;
        rotatedY = 1.0 - x;
      } else if (rotation == 180) {
        // Rotasi 180 derajat
        rotatedX = 1.0 - x;
        rotatedY = 1.0 - y;
      } else if (rotation == 270) {
        // Rotasi 270 derajat ke kanan
        rotatedX = 1.0 - y;
        rotatedY = x;
      } else {
        // Tanpa rotasi (portrait)
        rotatedX = x;
        rotatedY = y;
      }

      // Jika kamera depan, lakukan mirroring pada sumbu x
      if (isFrontCamera) {
        rotatedX = 1.0 - rotatedX;
      }

      return [rotatedY, rotatedX, score];
    }).toList();
  }

  img.Image? _convertCameraImage(CameraImage cameraImage) {
    try {
      // Menggunakan metode bawaan paket image untuk konversi YUV420 ke RGB
      final imgImage = _yuv420ToImage(cameraImage);
      print('Konversi gambar berhasil');
      return imgImage;
    } catch (e) {
      print('Error saat mengonversi gambar: $e');
      return null;
    }
  }

  img.Image _yuv420ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final img.Image imgImage = img.Image(width, height);

    final Plane yPlane = cameraImage.planes[0];
    final Plane uPlane = cameraImage.planes[1];
    final Plane vPlane = cameraImage.planes[2];

    final Uint8List yBytes = yPlane.bytes;
    final Uint8List uBytes = uPlane.bytes;
    final Uint8List vBytes = vPlane.bytes;

    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
        if (uvIndex >= uBytes.length || y * width + x >= yBytes.length) continue;

        final int yValue = yBytes[y * width + x];
        final int uValue = uBytes[uvIndex];
        final int vValue = vBytes[uvIndex];

        // Konversi YUV ke RGB
        double r = yValue + 1.370705 * (vValue - 128);
        double g = yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128);
        double b = yValue + 1.732446 * (uValue - 128);

        // Klamping nilai ke rentang [0, 255]
        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        imgImage.setPixelRgba(x, y, r.toInt(), g.toInt(), b.toInt());
      }
    }

    return imgImage;
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Preview Kamera Full-Screen dengan AspectRatio dan BoxFit.cover
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize!.height,
                height: _cameraController!.value.previewSize!.width,
                child: Transform.rotate(
                  angle: _rotation * math.pi / 180,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),
          ),
          // Overlay PosePainter dengan Transform.rotate
          if (_pose != null)
            Positioned.fill(
              child: Transform.rotate(
                angle: math.pi / 2, // Rotasi 90 derajat berlawanan arah jarum jam
                alignment: Alignment.center,
                child: CustomPaint(
                  painter: PosePainter(
                    _pose!,
                    Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                  ),
                ),
              ),
            ),
          // Umpan Balik Pose
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _currentPose != null ? Icons.check_circle : Icons.cancel,
                    color: _currentPose != null ? Colors.green : Colors.red,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _currentPose != null
                          ? Colors.greenAccent.withOpacity(0.7)
                          : Colors.redAccent.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _feedbackMessage,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}