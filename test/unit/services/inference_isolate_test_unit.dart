import 'dart:typed_data';
import 'dart:convert';
import 'package:feluna/services/inference_isolate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:feluna/services/pose_service.dart';
import 'package:image/image.dart' as img;

// Mocking PoseService
class MockPoseService extends Mock implements PoseService {}

void main() {
  group('runInferenceInIsolate', () {
    late MockPoseService mockPoseService;

    setUp(() {
      mockPoseService = MockPoseService();
    });

    test('should return predicted pose from isolate', () async {
      // Membuat mock data
      final modelBytes = Uint8List.fromList(utf8.encode('mock model data'));
      final image = img.Image(100, 100); // Membuat image dummy
      final expectedPose = [
        [1.0, 2.0, 3.0], // Contoh pose
        [4.0, 5.0, 6.0],
      ];

      // Mocking behavior pada PoseService
      when(mockPoseService.loadModelFromBuffer(modelBytes))
          .thenAnswer((_) async {});
      when(mockPoseService.predict(image)).thenAnswer((_) async => expectedPose);
      
      // Menggunakan Isolate untuk menjalankan inferensi
      final result = await runInferenceInIsolate(modelBytes, image);

      expect(result, expectedPose); // Memastikan hasil sesuai dengan yang diharapkan
    });

    test('should return null if pose prediction fails', () async {
      // Membuat mock data
      final modelBytes = Uint8List.fromList(utf8.encode('mock model data'));
      final image = img.Image(100, 100); // Membuat image dummy

      // Mocking behavior jika prediction gagal
      when(mockPoseService.loadModelFromBuffer(modelBytes))
          .thenAnswer((_) async {});
      when(mockPoseService.predict(image)).thenAnswer((_) async => null);

      // Menggunakan Isolate untuk menjalankan inferensi
      final result = await runInferenceInIsolate(modelBytes, image);

      expect(result, null); // Memastikan hasil null ketika prediksi gagal
    });
  });
}
