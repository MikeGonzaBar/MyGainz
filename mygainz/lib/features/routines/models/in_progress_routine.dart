import 'package:hive/hive.dart';
import '../../exercises/models/workout_set.dart';

part 'in_progress_routine.g.dart';

@HiveType(typeId: 1)
class InProgressRoutine extends HiveObject {
  @HiveField(0)
  final String id; // Unique identifier for the in-progress routine

  @HiveField(1)
  final String routineId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final List<String> targetMuscles;

  @HiveField(4)
  final DateTime lastUpdated;

  @HiveField(5)
  final List<InProgressExercise> exercises;

  @HiveField(6)
  final bool orderIsRequired;

  InProgressRoutine({
    required this.id,
    required this.routineId,
    required this.name,
    required this.targetMuscles,
    required this.lastUpdated,
    required this.exercises,
    this.orderIsRequired = false,
  });
}

@HiveType(typeId: 2)
class InProgressExercise extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseId;

  @HiveField(2)
  final String exerciseName;

  @HiveField(3)
  final List<String> targetMuscles;

  @HiveField(4)
  final String equipment;

  @HiveField(5)
  final List<WorkoutSetData> sets;

  @HiveField(6)
  final DateTime lastUpdated;

  InProgressExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.targetMuscles,
    required this.equipment,
    required this.sets,
    required this.lastUpdated,
  });
}
