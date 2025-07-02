// lib/services/pose_service.dart

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:typed_data';

class PoseService {
  Interpreter? _interpreter;

  PoseService();

  // Memuat model secara async dari buffer
  Future<void> loadModelFromBuffer(Uint8List modelBytes) async {
    try {
      print('Loading model from buffer');

      // Memuat interpreter dengan opsi
      var interpreterOptions = InterpreterOptions()
        ..threads = 4 // Sesuaikan dengan perangkat Anda
        ..useNnApiForAndroid = true; // Gunakan NNAPI untuk optimasi pada perangkat Android

      _interpreter = Interpreter.fromBuffer(modelBytes, options: interpreterOptions);
      print('MoveNet model loaded successfully');

      // Cetak bentuk input dan output model
      printModelShapes(_interpreter!);
    } catch (e) {
      print('Error loading model: $e');
      rethrow; // Mengembalikan error agar bisa ditangani di tempat pemanggilan
    }
  }

  // Menjalankan inferensi
  Future<List<List<double>>?> predict(img.Image image) async {
    if (_interpreter == null) return null;

    const int inputSize = 192; // Sesuaikan dengan ukuran input model Anda
    img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);

    // Membuat buffer input sebagai nested List dengan bentuk [1, 192, 192, 3]
    List<List<List<List<int>>>> input = [
      List.generate(inputSize, (y) {
        return List.generate(inputSize, (x) {
          int pixel = resizedImage.getPixel(x, y);
          int r = img.getRed(pixel);
          int g = img.getGreen(pixel);
          int b = img.getBlue(pixel);
          return [r, g, b];
        });
      })
    ];

    // Membuat buffer output sesuai dengan bentuk output model [1,1,17,3]
    var outputShape = _interpreter!.getOutputTensor(0).shape;
    print('Output Shape: $outputShape');

    // Memastikan outputShape adalah [1,1,17,3]
    if (outputShape.length != 4 ||
        outputShape[0] != 1 ||
        outputShape[1] != 1 ||
        outputShape[2] != 17 ||
        outputShape[3] != 3) {
      print('Unexpected output shape: $outputShape');
      return null;
    }

    // Membuat buffer output sebagai nested List dengan bentuk [1, 1, 17, 3]
    List<List<List<List<double>>>> output = List.generate(
      outputShape[0],
      (_) => List.generate(
        outputShape[1],
        (_) => List.generate(
          outputShape[2],
          (_) => List.generate(
            outputShape[3],
            (_) => 0.0,
          ),
        ),
      ),
    );

    try {
      // Menjalankan inferensi
      _interpreter!.run(input, output);
      print('Inference run successfully');

      // Mengonversi output menjadi List<List<double>>
      List<List<double>> pose = [];
      for (int i = 0; i < 17; i++) {
        double y = output[0][0][i][0];
        double x = output[0][0][i][1];
        double score = output[0][0][i][2];
        pose.add([y, x, score]); // Urutan [y, x, score]
      }

      return pose;
    } catch (e) {
      print('Error during inference: $e');
      return null;
    }
  }

  // Menutup interpreter
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }

  // Fungsi untuk mencetak bentuk tensor input dan output
  void printModelShapes(Interpreter interpreter) {
    var inputShape = interpreter.getInputTensor(0).shape;
    var inputType = interpreter.getInputTensor(0).type;
    var outputShape = interpreter.getOutputTensor(0).shape;
    var outputType = interpreter.getOutputTensor(0).type;
    print('Input Shape: $inputShape, Type: $inputType');
    print('Output Shape: $outputShape, Type: $outputType');
  }
}
