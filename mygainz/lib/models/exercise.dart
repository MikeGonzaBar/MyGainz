class Exercise {
  final String id; // Document ID
  final String userId;
  final String exerciseName;
  final List<String> targetMuscles;
  final List<String> equipment;

  Exercise({
    required this.id,
    required this.userId,
    required this.exerciseName,
    required this.targetMuscles,
    required this.equipment,
  });
}
