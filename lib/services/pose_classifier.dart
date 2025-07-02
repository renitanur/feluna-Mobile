// lib/services/pose_classifier.dart
import '../models/pose_definitions.dart';

class PoseClassifier {
  final List<PoseDefinition> poseDefinitions;

  PoseClassifier({required this.poseDefinitions});

  String? classifyPose(List<List<double>> detectedPose) {
    for (var poseDef in poseDefinitions) {
      bool isMatch = true;
      for (var rule in poseDef.rules) {
        if (rule.keypointIndex >= detectedPose.length) {
          isMatch = false;
          break;
        }
        // Ambil nilai koordinat yang relevan
        double detectedValue =
            rule.axis == 'x' ? detectedPose[rule.keypointIndex][1] : detectedPose[rule.keypointIndex][0];
        double target = rule.target;
        double tolerance = rule.tolerance;

        // Terapkan kondisi aturan
        switch (rule.condition) {
          case 'greater':
            if (detectedValue < (target - tolerance)) {
              isMatch = false;
            }
            break;
          case 'less':
            if (detectedValue > (target + tolerance)) {
              isMatch = false;
            }
            break;
          case 'equal':
            if ((detectedValue - target).abs() > tolerance) {
              isMatch = false;
            }
            break;
          default:
            isMatch = false;
        }

        if (!isMatch) break;
      }
      if (isMatch) {
        return poseDef.name;
      }
    }
    return null;
  }
}
