import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feluna/services/pose_classifier.dart';
import 'package:feluna/models/pose_definitions.dart';

void main() {
  group('PoseClassifier Widget Test', () {
    late PoseClassifier poseClassifier;

    setUp(() {
      final poseDefinition = PoseDefinition(
        name: 'Tadasana',
        rules: [
          PoseRule(
            keypointIndex: 0, 
            axis: 'x', 
            target: 0.0, 
            tolerance: 0.1, 
            condition: 'equal'
          ),
        ]
      );
      poseClassifier = PoseClassifier(poseDefinitions: [poseDefinition]);
    });

    testWidgets('should display classified pose name when pose is detected', (WidgetTester tester) async {
      final detectedPose = [
        [0.0, 0.2] // Posisi x dan y pada keypoint index 0
      ];

      // Membuat widget untuk menampilkan hasil pose
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(poseClassifier.classifyPose(detectedPose) ?? 'No pose detected'),
          ),
        ),
      ));

      // Verifikasi bahwa 'Tadasana' ditampilkan setelah deteksi pose
      expect(find.text('Tadasana'), findsOneWidget);
    });

    testWidgets('should display "No pose detected" when no pose is detected', (WidgetTester tester) async {
      final detectedPose = [
        [1.0, 0.2]
      ];

      // Membuat widget untuk menampilkan hasil pose
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(poseClassifier.classifyPose(detectedPose) ?? 'No pose detected'),
          ),
        ),
      ));

      // Verifikasi bahwa "No pose detected" ditampilkan
      expect(find.text('No pose detected'), findsOneWidget);
    });
  });
}
