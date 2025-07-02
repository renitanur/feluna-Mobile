import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:feluna/services/pose_service.dart';

void main() {
  group('PoseService Widget Test', () {
    late PoseService poseService;

    setUp(() {
      poseService = PoseService();
    });

    testWidgets('should display pose classification result', (WidgetTester tester) async {
      final image = img.Image(192, 192); // Gambar kosong

      // Membuat widget untuk menampilkan hasil inferensi
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FutureBuilder<List<List<double>>?>(
            future: poseService.predict(image),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final pose = snapshot.data;
                if (pose != null && pose.isNotEmpty) {
                  return Text('Pose detected: ${pose.length} keypoints');
                } else {
                  return Text('No pose detected');
                }
              } else {
                return Text('No data available');
              }
            },
          ),
        ),
      ));

      // Verifikasi widget yang sesuai ditampilkan
      await tester.pumpAndSettle();
      expect(find.text('No pose detected'), findsOneWidget);
    });
  });
}
