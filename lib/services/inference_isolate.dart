// lib/services/inference_isolate.dart

import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:typed_data';
import 'pose_service.dart'; // Pastikan path ini sesuai

// Fungsi entry point untuk isolate
void _inferenceEntry(List<dynamic> args) async {
  SendPort sendPort = args[0];
  Uint8List modelBytes = args[1];
  img.Image image = args[2];

  PoseService poseService = PoseService();
  await poseService.loadModelFromBuffer(modelBytes); // Memuat model dari buffer

  List<List<double>>? pose = await poseService.predict(image);
  sendPort.send(pose);

  poseService.dispose(); // Menutup interpreter setelah inferensi
}

// Fungsi untuk menjalankan inferensi di isolate
Future<List<List<double>>?> runInferenceInIsolate(Uint8List modelBytes, img.Image image) async {
  final ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(_inferenceEntry, [receivePort.sendPort, modelBytes, image]);
  return await receivePort.first;
}
