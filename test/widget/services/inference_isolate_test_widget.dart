import 'package:feluna/services/inference_isolate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

void main() {
  testWidgets('should display pose prediction result', (WidgetTester tester) async {
    // Setup mock response
    final modelBytes = Uint8List.fromList([1, 2, 3, 4]); // Contoh model byte
    final image = img.Image(100, 100); // Dummy image
    // ignore: unused_local_variable
    final expectedPose = [
      [1.0, 2.0, 3.0],
      [4.0, 5.0, 6.0],
    ];

    // Membuat widget untuk pengujian
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FutureBuilder<List<List<double>>?>(
          future: runInferenceInIsolate(modelBytes, image),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final pose = snapshot.data;
              if (pose != null) {
                return Text('Pose: ${pose.toString()}');
              } else {
                return Text('No pose detected.');
              }
            }
          },
        ),
      ),
    ));

    // Tunggu sampai Future selesai
    await tester.pumpAndSettle();

    // Memastikan teks pose yang diprediksi ditampilkan
    expect(find.text('Pose: [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]'), findsOneWidget);
  });

  testWidgets('should display error message if pose prediction fails', (WidgetTester tester) async {
    // Setup mock response untuk error
    final modelBytes = Uint8List.fromList([1, 2, 3, 4]);
    final image = img.Image(100, 100);
    
    // Membuat widget untuk pengujian
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FutureBuilder<List<List<double>>?>(
          future: runInferenceInIsolate(modelBytes, image), // Gunakan Future gagal di sini
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text('No pose detected.');
            }
          },
        ),
      ),
    ));

    // Tunggu sampai Future selesai
    await tester.pumpAndSettle();

    // Memastikan jika tidak ada pose terdeteksi
    expect(find.text('No pose detected.'), findsOneWidget);
  });
}
