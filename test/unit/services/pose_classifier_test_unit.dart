import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:feluna/services/pose_classifier.dart';
import 'package:feluna/models/pose_definitions.dart';

class MockPoseDefinition extends Mock implements PoseDefinition {}

void main() {
  group('PoseClassifier', () {
    late PoseClassifier poseClassifier;

    setUp(() {
      // Setup mock data
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

    test('should classify pose correctly based on rules', () {
      // Deteksi pose yang sesuai dengan aturan
      final detectedPose = [
        [0.0, 0.2] // Posisi x dan y pada keypoint index 0
      ];

      final result = poseClassifier.classifyPose(detectedPose);

      // Memastikan hasil yang dikembalikan sesuai dengan nama pose
      expect(result, 'Tadasana');
    });

    test('should return null for unmatched pose', () {
      // Deteksi pose yang tidak sesuai dengan aturan
      final detectedPose = [
        [1.0, 0.2]
      ];

      final result = poseClassifier.classifyPose(detectedPose);

      // Memastikan tidak ada pose yang cocok
      expect(result, null);
    });
  });
}
