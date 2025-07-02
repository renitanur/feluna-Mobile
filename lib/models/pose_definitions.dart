// lib/models/pose_definitions.dart

class PoseDefinition {
  final String name;
  final List<PoseRule> rules;

  PoseDefinition({required this.name, required this.rules});
}

class PoseRule {
  final int keypointIndex;
  final String axis; // 'x' atau 'y'
  final double target;
  final double tolerance;
  final String condition; // 'greater', 'less', 'equal'

  PoseRule({
    required this.keypointIndex,
    required this.axis,
    required this.target,
    required this.tolerance,
    required this.condition,
  });
}

// Indeks keypoints sesuai dengan MoveNet
const Map<String, int> keypointMap = {
  'nose': 0,
  'left_eye': 1,
  'right_eye': 2,
  'left_ear': 3,
  'right_ear': 4,
  'left_shoulder': 5,
  'right_shoulder': 6,
  'left_elbow': 7,
  'right_elbow': 8,
  'left_wrist': 9,
  'right_wrist': 10,
  'left_hip': 11,
  'right_hip': 12,
  'left_knee': 13,
  'right_knee': 14,
  'left_ankle': 15,
  'right_ankle': 16,
};

List<PoseDefinition> poseDefinitions = [
  // Child Pose
  PoseDefinition(
    name: 'Child',
    rules: [
      // Hidung berada di bawah bahu
      PoseRule(
        keypointIndex: keypointMap['nose']!,
        axis: 'y',
        target: 0.8,
        tolerance: 0.15,
        condition: 'greater',
      ),
      // Bahu kiri berada di bawah pinggul kiri
      PoseRule(
        keypointIndex: keypointMap['left_shoulder']!,
        axis: 'y',
        target: 0.7,
        tolerance: 0.15,
        condition: 'greater',
      ),
      // Bahu kanan berada di bawah pinggul kanan
      PoseRule(
        keypointIndex: keypointMap['right_shoulder']!,
        axis: 'y',
        target: 0.7,
        tolerance: 0.15,
        condition: 'greater',
      ),
      // Elbow kiri berada di bawah bahu kiri
      PoseRule(
        keypointIndex: keypointMap['left_elbow']!,
        axis: 'y',
        target: 0.75,
        tolerance: 0.15,
        condition: 'greater',
      ),
      // Elbow kanan berada di bawah bahu kanan
      PoseRule(
        keypointIndex: keypointMap['right_elbow']!,
        axis: 'y',
        target: 0.75,
        tolerance: 0.15,
        condition: 'greater',
      ),
      // Pergelangan tangan kiri berada di bawah bahu kiri
      PoseRule(
        keypointIndex: keypointMap['left_wrist']!,
        axis: 'y',
        target: 0.75,
        tolerance: 0.15,
        condition: 'greater',
      ),
      // Pergelangan tangan kanan berada di bawah bahu kanan
      PoseRule(
        keypointIndex: keypointMap['right_wrist']!,
        axis: 'y',
        target: 0.75,
        tolerance: 0.15,
        condition: 'greater',
      ),
      // Pinggul kiri dan kanan sejajar
      PoseRule(
        keypointIndex: keypointMap['left_hip']!,
        axis: 'y',
        target: 0.7,
        tolerance: 0.15,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_hip']!,
        axis: 'y',
        target: 0.7,
        tolerance: 0.15,
        condition: 'greater',
      ),
    ],
  ),
  // Corpse Pose
  PoseDefinition(
    name: 'Corpse',
    rules: [
      // Hidung berada di sangat atas (dalam layar)
      PoseRule(
        keypointIndex: keypointMap['nose']!,
        axis: 'y',
        target: 0.1,
        tolerance: 0.15,
        condition: 'less',
      ),
      // Bahu kiri berada di atas pinggul kiri
      PoseRule(
        keypointIndex: keypointMap['left_shoulder']!,
        axis: 'y',
        target: 0.2,
        tolerance: 0.15,
        condition: 'less',
      ),
      // Bahu kanan berada di atas pinggul kanan
      PoseRule(
        keypointIndex: keypointMap['right_shoulder']!,
        axis: 'y',
        target: 0.2,
        tolerance: 0.15,
        condition: 'less',
      ),
      // Lutut kiri dan kanan lurus
      PoseRule(
        keypointIndex: keypointMap['left_knee']!,
        axis: 'y',
        target: 0.8,
        tolerance: 0.1,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_knee']!,
        axis: 'y',
        target: 0.8,
        tolerance: 0.1,
        condition: 'greater',
      ),
      // Ankle kiri dan kanan lurus
      PoseRule(
        keypointIndex: keypointMap['left_ankle']!,
        axis: 'y',
        target: 0.9,
        tolerance: 0.1,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_ankle']!,
        axis: 'y',
        target: 0.9,
        tolerance: 0.1,
        condition: 'greater',
      ),
      // Elbow kiri dan kanan berada di samping tubuh
      PoseRule(
        keypointIndex: keypointMap['left_elbow']!,
        axis: 'x',
        target: 0.4,
        tolerance: 0.15,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_elbow']!,
        axis: 'x',
        target: 0.6,
        tolerance: 0.15,
        condition: 'less',
      ),
    ],
  ),
  // Cat Pose
  PoseDefinition(
    name: 'Cat',
    rules: [
      // Hidung berada di bawah bahu
      PoseRule(
        keypointIndex: keypointMap['nose']!,
        axis: 'y',
        target: 0.6,
        tolerance: 0.1,
        condition: 'greater',
      ),
      // Bahu kiri berada di bawah pinggul kiri
      PoseRule(
        keypointIndex: keypointMap['left_shoulder']!,
        axis: 'y',
        target: 0.5,
        tolerance: 0.1,
        condition: 'greater',
      ),
      // Bahu kanan berada di bawah pinggul kanan
      PoseRule(
        keypointIndex: keypointMap['right_shoulder']!,
        axis: 'y',
        target: 0.5,
        tolerance: 0.1,
        condition: 'greater',
      ),
      // Punggung melengkung ke atas (keypoints hip dan shoulders harus sejajar)
      PoseRule(
        keypointIndex: keypointMap['left_hip']!,
        axis: 'y',
        target: 0.6,
        tolerance: 0.1,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_hip']!,
        axis: 'y',
        target: 0.6,
        tolerance: 0.1,
        condition: 'greater',
      ),
      // Lutut dan pergelangan kaki berada di bawah bahu
      PoseRule(
        keypointIndex: keypointMap['left_knee']!,
        axis: 'y',
        target: 0.7,
        tolerance: 0.15,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_knee']!,
        axis: 'y',
        target: 0.7,
        tolerance: 0.15,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['left_ankle']!,
        axis: 'y',
        target: 0.8,
        tolerance: 0.1,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_ankle']!,
        axis: 'y',
        target: 0.8,
        tolerance: 0.1,
        condition: 'greater',
      ),
    ],
  ),
  // Cow Pose
  PoseDefinition(
    name: 'Cow',
    rules: [
      // Hidung berada di atas bahu
      PoseRule(
        keypointIndex: keypointMap['nose']!,
        axis: 'y',
        target: 0.4,
        tolerance: 0.1,
        condition: 'less',
      ),
      // Bahu kiri berada di atas pinggul kiri
      PoseRule(
        keypointIndex: keypointMap['left_shoulder']!,
        axis: 'y',
        target: 0.3,
        tolerance: 0.1,
        condition: 'less',
      ),
      // Bahu kanan berada di atas pinggul kanan
      PoseRule(
        keypointIndex: keypointMap['right_shoulder']!,
        axis: 'y',
        target: 0.3,
        tolerance: 0.1,
        condition: 'less',
      ),
      // Punggung melengkung ke bawah
      PoseRule(
        keypointIndex: keypointMap['left_hip']!,
        axis: 'y',
        target: 0.4,
        tolerance: 0.1,
        condition: 'less',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_hip']!,
        axis: 'y',
        target: 0.4,
        tolerance: 0.1,
        condition: 'less',
      ),
      // Lutut dan pergelangan kaki berada di atas bahu
      PoseRule(
        keypointIndex: keypointMap['left_knee']!,
        axis: 'y',
        target: 0.6,
        tolerance: 0.15,
        condition: 'less',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_knee']!,
        axis: 'y',
        target: 0.6,
        tolerance: 0.15,
        condition: 'less',
      ),
      PoseRule(
        keypointIndex: keypointMap['left_ankle']!,
        axis: 'y',
        target: 0.7,
        tolerance: 0.1,
        condition: 'less',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_ankle']!,
        axis: 'y',
        target: 0.7,
        tolerance: 0.1,
        condition: 'less',
      ),
    ],
  ),
  // Reclining Twist Pose
  PoseDefinition(
    name: 'Reclining Twist',
    rules: [
      // Bahu kiri dan kanan berada di samping tubuh
      PoseRule(
        keypointIndex: keypointMap['left_shoulder']!,
        axis: 'x',
        target: 0.6,
        tolerance: 0.15,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_shoulder']!,
        axis: 'x',
        target: 0.4,
        tolerance: 0.15,
        condition: 'less',
      ),
      // Lutut kiri berada di atas lutut kanan (atau sebaliknya, tergantung sisi twist)
      PoseRule(
        keypointIndex: keypointMap['left_knee']!,
        axis: 'x',
        target: 0.6,
        tolerance: 0.15,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_knee']!,
        axis: 'x',
        target: 0.4,
        tolerance: 0.15,
        condition: 'less',
      ),
      // Pergelangan tangan kiri berada di bawah bahu kiri
      PoseRule(
        keypointIndex: keypointMap['left_wrist']!,
        axis: 'y',
        target: 0.7,
        tolerance: 0.15,
        condition: 'greater',
      ),
      // Pergelangan tangan kanan berada di atas kepala atau di samping tubuh
      PoseRule(
        keypointIndex: keypointMap['right_wrist']!,
        axis: 'y',
        target: 0.4,
        tolerance: 0.15,
        condition: 'less',
      ),
      // Punggung sedikit berputar (indikasi twist)
      PoseRule(
        keypointIndex: keypointMap['left_hip']!,
        axis: 'x',
        target: 0.5,
        tolerance: 0.15,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_hip']!,
        axis: 'x',
        target: 0.5,
        tolerance: 0.15,
        condition: 'less',
      ),
    ],
  ),
  // Cobra Pose
  PoseDefinition(
    name: 'Cobra',
    rules: [
      // Hidung berada di atas bahu
      PoseRule(
        keypointIndex: keypointMap['nose']!,
        axis: 'y',
        target: 0.3,
        tolerance: 0.15,
        condition: 'less',
      ),
      // Bahu kiri berada di atas pinggul kiri
      PoseRule(
        keypointIndex: keypointMap['left_shoulder']!,
        axis: 'y',
        target: 0.4,
        tolerance: 0.15,
        condition: 'less',
      ),
      // Bahu kanan berada di atas pinggul kanan
      PoseRule(
        keypointIndex: keypointMap['right_shoulder']!,
        axis: 'y',
        target: 0.4,
        tolerance: 0.15,
        condition: 'less',
      ),
      // Elbow kiri berada di atas lutut kiri
      PoseRule(
        keypointIndex: keypointMap['left_elbow']!,
        axis: 'y',
        target: 0.3,
        tolerance: 0.1,
        condition: 'less',
      ),
      // Elbow kanan berada di atas lutut kanan
      PoseRule(
        keypointIndex: keypointMap['right_elbow']!,
        axis: 'y',
        target: 0.3,
        tolerance: 0.1,
        condition: 'less',
      ),
      // Punggung melengkung ke atas
      PoseRule(
        keypointIndex: keypointMap['left_hip']!,
        axis: 'y',
        target: 0.4,
        tolerance: 0.15,
        condition: 'less',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_hip']!,
        axis: 'y',
        target: 0.4,
        tolerance: 0.15,
        condition: 'less',
      ),
      // Pergelangan tangan berada di bawah bahu
      PoseRule(
        keypointIndex: keypointMap['left_wrist']!,
        axis: 'y',
        target: 0.5,
        tolerance: 0.15,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_wrist']!,
        axis: 'y',
        target: 0.5,
        tolerance: 0.15,
        condition: 'greater',
      ),
      // Lutut lurus dan sedikit terangkat dari lantai
      PoseRule(
        keypointIndex: keypointMap['left_knee']!,
        axis: 'y',
        target: 0.7,
        tolerance: 0.1,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_knee']!,
        axis: 'y',
        target: 0.7,
        tolerance: 0.1,
        condition: 'greater',
      ),
      // Ankle berada di bawah lutut (seharusnya)
      PoseRule(
        keypointIndex: keypointMap['left_ankle']!,
        axis: 'y',
        target: 0.8,
        tolerance: 0.1,
        condition: 'greater',
      ),
      PoseRule(
        keypointIndex: keypointMap['right_ankle']!,
        axis: 'y',
        target: 0.8,
        tolerance: 0.1,
        condition: 'greater',
      ),
    ],
  ),
];
