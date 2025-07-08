import 'package:flutter/foundation.dart';
import '../models/personal_record.dart';
import '../models/workout_set.dart';
import '../services/personal_record_service.dart';
import '../services/workout_firestore_service.dart';

class LoggedExercise {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final List<String> targetMuscles;
  final String equipment;
  final DateTime date;

  // Individual sets data (preferred)
  final List<WorkoutSetData>? individualSets;

  // Legacy aggregated data (for backward compatibility)
  final int? sets;
  final double? weight;
  final int? reps;

  // Cardio-specific fields (nullable for strength)
  final double? distance; // km/miles
  final Duration? duration; // minutes
  final double? pace; // min/km or min/mile
  final int? calories;
  final double? speed; // km/h or mph
  final int? heartRate; // bpm

  LoggedExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.targetMuscles,
    required this.equipment,
    required this.date,
    this.individualSets,
    // Legacy fields for backward compatibility
    this.sets,
    this.weight,
    this.reps,
    // Cardio fields
    this.distance,
    this.duration,
    this.pace,
    this.calories,
    this.speed,
    this.heartRate,
  });

  // Computed properties for backward compatibility
  int get totalSets => individualSets?.length ?? sets ?? 0;

  double? get averageWeight {
    if (individualSets != null && individualSets!.isNotEmpty) {
      final totalWeight =
          individualSets!.fold<double>(0, (sum, set) => sum + set.weight);
      return totalWeight / individualSets!.length;
    }
    return weight;
  }

  int? get averageReps {
    if (individualSets != null && individualSets!.isNotEmpty) {
      final totalReps =
          individualSets!.fold<int>(0, (sum, set) => sum + set.reps);
      return (totalReps / individualSets!.length).round();
    }
    return reps;
  }

  // Helper to get the best set (highest weight × reps)
  WorkoutSetData? get bestSet {
    if (individualSets == null || individualSets!.isEmpty) return null;

    return individualSets!.reduce((a, b) {
      final aScore = a.weight * a.reps;
      final bScore = b.weight * b.reps;
      return aScore > bScore ? a : b;
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'targetMuscles': targetMuscles,
      'equipment': equipment,
      'date': date.toIso8601String(),

      // Individual sets (preferred)
      'individualSets': individualSets?.map((set) => set.toJson()).toList(),

      // Legacy fields (for backward compatibility)
      'sets': sets,
      'weight': weight,
      'reps': reps,

      // Cardio fields
      'distance': distance,
      'duration': duration?.inMinutes,
      'pace': pace,
      'calories': calories,
      'speed': speed,
      'heartRate': heartRate,
    };
  }

  factory LoggedExercise.fromJson(Map<String, dynamic> json) {
    // Parse individual sets if available
    List<WorkoutSetData>? individualSets;
    if (json['individualSets'] != null) {
      final setsData = json['individualSets'] as List;
      individualSets = setsData
          .map((setData) =>
              WorkoutSetData.fromJson(setData as Map<String, dynamic>))
          .toList();
    }

    return LoggedExercise(
      id: json['id'],
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      targetMuscles: List<String>.from(json['targetMuscles']),
      equipment: json['equipment'],
      date: DateTime.parse(json['date']),

      // Individual sets
      individualSets: individualSets,

      // Legacy fields
      sets: json['sets'],
      weight: json['weight']?.toDouble(),
      reps: json['reps'],

      // Cardio fields
      distance: json['distance']?.toDouble(),
      duration:
          json['duration'] != null ? Duration(minutes: json['duration']) : null,
      pace: json['pace']?.toDouble(),
      calories: json['calories'],
      speed: json['speed']?.toDouble(),
      heartRate: json['heartRate'],
    );
  }

  // Helper method to determine if this is a cardio exercise
  bool get isCardio {
    return weight == null &&
        averageWeight == null &&
        (distance != null || duration != null);
  }

  // Helper method to determine if this is a strength exercise
  bool get isStrength {
    return averageWeight != null && averageReps != null;
  }
}

class LoggedRoutine {
  final String id;
  final String routineId;
  final String name;
  final List<String> targetMuscles;
  final DateTime date;
  final List<LoggedExercise> exercises;
  final bool orderIsRequired;

  LoggedRoutine({
    required this.id,
    required this.routineId,
    required this.name,
    required this.targetMuscles,
    required this.date,
    required this.exercises,
    this.orderIsRequired = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routineId': routineId,
      'name': name,
      'targetMuscles': targetMuscles,
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'orderIsRequired': orderIsRequired,
    };
  }

  factory LoggedRoutine.fromJson(Map<String, dynamic> json) {
    return LoggedRoutine(
      id: json['id'],
      routineId: json['routineId'],
      name: json['name'],
      targetMuscles: List<String>.from(json['targetMuscles']),
      date: DateTime.parse(json['date']),
      exercises: (json['exercises'] as List)
          .map((e) => LoggedExercise.fromJson(e))
          .toList(),
      orderIsRequired: json['orderIsRequired'] ?? false,
    );
  }
}

class WorkoutProvider with ChangeNotifier {
  List<LoggedExercise> _loggedExercises = [];
  List<LoggedRoutine> _loggedRoutines = [];
  List<PersonalRecord> _personalRecords = [];
  List<Achievement> _achievements = [];
  bool _isLoading = false;

  final WorkoutFirestoreService _workoutFirestoreService =
      WorkoutFirestoreService();

  List<LoggedExercise> get loggedExercises =>
      List.unmodifiable(_loggedExercises);
  List<LoggedRoutine> get loggedRoutines => List.unmodifiable(_loggedRoutines);
  List<PersonalRecord> get personalRecords =>
      List.unmodifiable(_personalRecords);
  List<Achievement> get achievements => List.unmodifiable(_achievements);
  bool get isLoading => _isLoading;

  // Get recent exercises (last 5)
  List<LoggedExercise> get recentExercises {
    final sorted = List<LoggedExercise>.from(_loggedExercises)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  // Get recent routines (last 5)
  List<LoggedRoutine> get recentRoutines {
    final sorted = List<LoggedRoutine>.from(_loggedRoutines)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  WorkoutProvider() {
    _loadWorkouts();
  }

  // Load workouts from Firestore
  Future<void> _loadWorkouts() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load data from Firestore in parallel
      final futures = await Future.wait([
        _workoutFirestoreService.getWorkoutSessions(),
        _workoutFirestoreService.getRoutineSessions(),
        _workoutFirestoreService.getPersonalRecords(),
        _workoutFirestoreService.getAchievements(),
      ]);

      _loggedExercises = futures[0] as List<LoggedExercise>;
      _loggedRoutines = futures[1] as List<LoggedRoutine>;
      _personalRecords = futures[2] as List<PersonalRecord>;
      _achievements = futures[3] as List<Achievement>;

      _isLoading = false;
      notifyListeners();
      print(
          'Workouts loaded from Firestore: ${_loggedExercises.length} exercises, ${_loggedRoutines.length} routines, ${_personalRecords.length} PRs, ${_achievements.length} achievements');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading workouts from Firestore: $e');
    }
  }

  // Clear all workout logs (for testing/reset)
  Future<void> clearAllWorkouts() async {
    try {
      _loggedExercises.clear();
      _loggedRoutines.clear();
      _personalRecords.clear();
      _achievements.clear();
      notifyListeners();
      print('All workout data cleared from local cache');
    } catch (e) {
      print('Error clearing workout data: $e');
    }
  }

  // Log a single exercise
  Future<void> logExercise({
    required String exerciseId,
    required String exerciseName,
    required List<String> targetMuscles,
    required String equipment,
    // Individual sets data (preferred)
    List<WorkoutSetData>? individualSets,
    // Legacy parameters for backward compatibility
    int? sets,
    double? weight,
    int? reps,
    // Cardio-specific parameters
    double? distance,
    Duration? duration,
    double? pace,
    int? calories,
    double? speed,
    int? heartRate,
  }) async {
    final loggedExercise = LoggedExercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      targetMuscles: targetMuscles,
      equipment: equipment,
      date: DateTime.now(),
      // Individual sets data
      individualSets: individualSets,
      // Legacy aggregated data
      sets: sets,
      weight: weight,
      reps: reps,
      // Cardio data
      distance: distance,
      duration: duration,
      pace: pace,
      calories: calories,
      speed: speed,
      heartRate: heartRate,
    );

    try {
      // Save to Firestore
      final firestoreId =
          await _workoutFirestoreService.logExerciseSession(loggedExercise);

      // Update local list with Firestore ID
      final updatedExercise = LoggedExercise(
        id: firestoreId,
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        targetMuscles: targetMuscles,
        equipment: equipment,
        date: DateTime.now(),
        individualSets: individualSets,
        sets: sets,
        weight: weight,
        reps: reps,
        distance: distance,
        duration: duration,
        pace: pace,
        calories: calories,
        speed: speed,
        heartRate: heartRate,
      );

      _loggedExercises.add(updatedExercise);

      // Check for new personal record
      await _checkAndCreatePersonalRecord(updatedExercise);

      notifyListeners();
      print('Exercise logged to Firestore: $exerciseName');
    } catch (e) {
      print('Error logging exercise to Firestore: $e');
      throw Exception('Failed to log exercise: $e');
    }
  }

  // Log a routine workout
  Future<void> logRoutine({
    required String routineId,
    required String routineName,
    required List<String> targetMuscles,
    required List<LoggedExercise> exercises,
    bool orderIsRequired = false,
  }) async {
    final loggedRoutine = LoggedRoutine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      routineId: routineId,
      name: routineName,
      targetMuscles: targetMuscles,
      date: DateTime.now(),
      exercises: exercises,
      orderIsRequired: orderIsRequired,
    );

    try {
      // Save to Firestore
      final firestoreId =
          await _workoutFirestoreService.logRoutineSession(loggedRoutine);

      // Update local list with Firestore ID
      final updatedRoutine = LoggedRoutine(
        id: firestoreId,
        routineId: routineId,
        name: routineName,
        targetMuscles: targetMuscles,
        date: DateTime.now(),
        exercises: exercises,
        orderIsRequired: orderIsRequired,
      );

      _loggedRoutines.add(updatedRoutine);
      notifyListeners();
      print('Routine logged to Firestore: $routineName');
    } catch (e) {
      print('Error logging routine to Firestore: $e');
      throw Exception('Failed to log routine: $e');
    }
  }

  // Update a logged exercise
  Future<void> updateLoggedExercise(
    String exerciseId, {
    // Strength
    double? weight,
    int? reps,
    // Cardio
    double? distance,
    Duration? duration,
    int? calories,
    // Common
    String? equipment,
    int? sets,
  }) async {
    final index = _loggedExercises.indexWhere((ex) => ex.id == exerciseId);
    if (index != -1) {
      final exercise = _loggedExercises[index];

      // If updating strength exercise with new values, clear individual sets
      // and use legacy format (since we're editing to average values)
      List<WorkoutSetData>? updatedIndividualSets = exercise.individualSets;
      double? updatedWeight = weight ?? exercise.weight;
      int? updatedReps = reps ?? exercise.reps;
      int? updatedSets = sets ?? exercise.sets;

      // If we're providing new weight/reps, convert to legacy format
      if (weight != null || reps != null || sets != null) {
        updatedIndividualSets = null; // Clear individual sets
        updatedWeight = weight ?? exercise.averageWeight;
        updatedReps = reps ?? exercise.averageReps;
        updatedSets = sets ?? exercise.totalSets;
      }

      final updatedExercise = LoggedExercise(
        id: exercise.id,
        exerciseId: exercise.exerciseId,
        exerciseName: exercise.exerciseName,
        targetMuscles: exercise.targetMuscles,
        date: exercise.date,
        // Individual sets (may be cleared if editing)
        individualSets: updatedIndividualSets,
        // Common
        equipment: equipment ?? exercise.equipment,
        sets: updatedSets,
        // Strength-specific
        weight: updatedWeight,
        reps: updatedReps,
        // Cardio-specific
        distance: distance ?? exercise.distance,
        duration: duration ?? exercise.duration,
        calories: calories ?? exercise.calories,
        // Preserve other fields
        pace: exercise.pace,
        speed: exercise.speed,
        heartRate: exercise.heartRate,
      );

      try {
        // Update in Firestore
        await _workoutFirestoreService.updateExerciseSession(
            exerciseId, updatedExercise);

        // Update local list
        _loggedExercises[index] = updatedExercise;
        notifyListeners();
        print('Exercise updated in Firestore: ${updatedExercise.exerciseName}');
      } catch (e) {
        print('Error updating exercise in Firestore: $e');
        throw Exception('Failed to update exercise: $e');
      }
    }
  }

  // Update a logged routine exercise
  Future<void> updateLoggedRoutineExercise(
    String routineId,
    String exerciseId, {
    double? weight,
    int? reps,
    String? equipment,
    int? sets,
  }) async {
    final routineIndex = _loggedRoutines.indexWhere((r) => r.id == routineId);
    if (routineIndex != -1) {
      final routine = _loggedRoutines[routineIndex];
      final exerciseIndex =
          routine.exercises.indexWhere((ex) => ex.id == exerciseId);
      if (exerciseIndex != -1) {
        final exercise = routine.exercises[exerciseIndex];
        final updatedExercise = LoggedExercise(
          id: exercise.id,
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          targetMuscles: exercise.targetMuscles,
          weight: weight ?? exercise.weight,
          reps: reps ?? exercise.reps,
          equipment: equipment ?? exercise.equipment,
          sets: sets ?? exercise.sets,
          date: exercise.date,
        );

        final updatedExercises = List<LoggedExercise>.from(routine.exercises);
        updatedExercises[exerciseIndex] = updatedExercise;

        _loggedRoutines[routineIndex] = LoggedRoutine(
          id: routine.id,
          routineId: routine.routineId,
          name: routine.name,
          targetMuscles: routine.targetMuscles,
          date: routine.date,
          exercises: updatedExercises,
          orderIsRequired: routine.orderIsRequired,
        );

        notifyListeners();
      }
    }
  }

  // Delete a logged exercise
  Future<void> deleteLoggedExercise(String exerciseId) async {
    try {
      // Delete from Firestore
      await _workoutFirestoreService.deleteExerciseSession(exerciseId);

      // Delete from local list
      _loggedExercises.removeWhere((ex) => ex.id == exerciseId);
      notifyListeners();
      print('Exercise deleted from Firestore: $exerciseId');
    } catch (e) {
      print('Error deleting exercise from Firestore: $e');
      throw Exception('Failed to delete exercise: $e');
    }
  }

  // Delete a logged routine
  Future<void> deleteLoggedRoutine(String routineId) async {
    try {
      // Delete from Firestore
      await _workoutFirestoreService.deleteRoutineSession(routineId);

      // Delete from local list
      _loggedRoutines.removeWhere((r) => r.id == routineId);
      notifyListeners();
      print('Routine deleted from Firestore: $routineId');
    } catch (e) {
      print('Error deleting routine from Firestore: $e');
      throw Exception('Failed to delete routine: $e');
    }
  }

  // Delete an exercise from a logged routine
  Future<void> deleteLoggedRoutineExercise(
      String routineId, String exerciseId) async {
    final routineIndex = _loggedRoutines.indexWhere((r) => r.id == routineId);
    if (routineIndex != -1) {
      final routine = _loggedRoutines[routineIndex];
      final exerciseIndex =
          routine.exercises.indexWhere((ex) => ex.id == exerciseId);

      if (exerciseIndex != -1) {
        final updatedExercises = List<LoggedExercise>.from(routine.exercises);
        updatedExercises.removeAt(exerciseIndex);

        // If no exercises left, delete the entire routine
        if (updatedExercises.isEmpty) {
          _loggedRoutines.removeAt(routineIndex);
        } else {
          // Update the routine with remaining exercises
          _loggedRoutines[routineIndex] = LoggedRoutine(
            id: routine.id,
            routineId: routine.routineId,
            name: routine.name,
            targetMuscles: routine.targetMuscles,
            date: routine.date,
            exercises: updatedExercises,
            orderIsRequired: routine.orderIsRequired,
          );
        }

        notifyListeners();
      }
    }
  }

  // Delete exercises from a logged routine starting from a specific index (for order-dependent routines)
  Future<void> deleteLoggedRoutineExercisesFromIndex(
      String routineId, int startIndex) async {
    final routineIndex = _loggedRoutines.indexWhere((r) => r.id == routineId);
    if (routineIndex != -1) {
      final routine = _loggedRoutines[routineIndex];

      if (startIndex < routine.exercises.length) {
        final updatedExercises = routine.exercises.take(startIndex).toList();

        // If no exercises left, delete the entire routine
        if (updatedExercises.isEmpty) {
          _loggedRoutines.removeAt(routineIndex);
        } else {
          // Update the routine with remaining exercises
          _loggedRoutines[routineIndex] = LoggedRoutine(
            id: routine.id,
            routineId: routine.routineId,
            name: routine.name,
            targetMuscles: routine.targetMuscles,
            date: routine.date,
            exercises: updatedExercises,
            orderIsRequired: routine.orderIsRequired,
          );
        }

        notifyListeners();
      }
    }
  }

  // Check and create personal record
  Future<void> _checkAndCreatePersonalRecord(LoggedExercise exercise) async {
    // Handle strength exercises
    if (exercise.isStrength &&
        exercise.averageWeight != null &&
        exercise.averageReps != null) {
      // For exercises with individual sets, check for PRs using the best set
      double weightForPR = exercise.averageWeight!;
      int repsForPR = exercise.averageReps!;

      // If we have individual sets, use the best set for PR calculation
      if (exercise.individualSets != null &&
          exercise.individualSets!.isNotEmpty) {
        final bestSet = exercise.bestSet;
        if (bestSet != null) {
          weightForPR = bestSet.weight;
          repsForPR = bestSet.reps;
        }
      }

      if (PersonalRecordService.isNewPersonalRecord(
          exercise, _personalRecords)) {
        final oneRepMax =
            PersonalRecordService.calculateOneRepMax(weightForPR, repsForPR);

        final personalRecord = PersonalRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          date: exercise.date,
          equipment: exercise.equipment,
          type: PersonalRecordType.weight,
          weight: weightForPR,
          reps: repsForPR,
          sets: exercise.totalSets,
          oneRepMax: oneRepMax,
        );

        try {
          // Save to Firestore
          final firestoreId =
              await _workoutFirestoreService.savePersonalRecord(personalRecord);

          // Update local list with Firestore ID
          final updatedRecord = PersonalRecord(
            id: firestoreId,
            exerciseId: exercise.exerciseId,
            exerciseName: exercise.exerciseName,
            date: exercise.date,
            equipment: exercise.equipment,
            type: PersonalRecordType.weight,
            weight: weightForPR,
            reps: repsForPR,
            sets: exercise.totalSets,
            oneRepMax: oneRepMax,
          );

          _personalRecords.add(updatedRecord);

          // Generate new achievements
          await _generateAchievements();

          print(
              'New strength PR created: ${exercise.exerciseName} - ${weightForPR}kg × ${repsForPR} reps (1RM: ${oneRepMax.toStringAsFixed(1)}kg)');
        } catch (e) {
          print('Error saving personal record to Firestore: $e');
        }
      }
    }

    // Handle cardio exercises
    if (exercise.isCardio) {
      await _checkAndCreateCardioPersonalRecord(exercise);
    }
  }

  // Check and create cardio personal record
  Future<void> _checkAndCreateCardioPersonalRecord(
      LoggedExercise exercise) async {
    // Check for distance PR
    if (exercise.distance != null) {
      final existingDistancePRs = _personalRecords
          .where((pr) =>
              pr.exerciseId == exercise.exerciseId &&
              pr.type == PersonalRecordType.distance)
          .toList();

      bool isNewDistancePR = existingDistancePRs.isEmpty;
      if (existingDistancePRs.isNotEmpty) {
        final bestDistancePR = existingDistancePRs
            .reduce((a, b) => (a.distance ?? 0) > (b.distance ?? 0) ? a : b);
        isNewDistancePR = exercise.distance! > (bestDistancePR.distance ?? 0);
      }

      if (isNewDistancePR) {
        final personalRecord = PersonalRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          date: exercise.date,
          equipment: exercise.equipment,
          type: PersonalRecordType.distance,
          distance: exercise.distance,
        );

        _personalRecords.add(personalRecord);
        print(
            'New distance PR created: ${exercise.exerciseName} - ${exercise.distance}km');
      }
    }

    // Check for pace PR (faster is better)
    if (exercise.pace != null) {
      final existingPacePRs = _personalRecords
          .where((pr) =>
              pr.exerciseId == exercise.exerciseId &&
              pr.type == PersonalRecordType.pace)
          .toList();

      bool isNewPacePR = existingPacePRs.isEmpty;
      if (existingPacePRs.isNotEmpty) {
        final bestPacePR = existingPacePRs.reduce((a, b) =>
            (a.pace ?? double.infinity) < (b.pace ?? double.infinity) ? a : b);
        isNewPacePR = exercise.pace! < (bestPacePR.pace ?? double.infinity);
      }

      if (isNewPacePR) {
        final personalRecord = PersonalRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          date: exercise.date,
          equipment: exercise.equipment,
          type: PersonalRecordType.pace,
          pace: exercise.pace,
        );

        _personalRecords.add(personalRecord);
        print(
            'New pace PR created: ${exercise.exerciseName} - ${exercise.pace} min/km');
      }
    }

    // Check for duration PR
    if (exercise.duration != null) {
      final existingDurationPRs = _personalRecords
          .where((pr) =>
              pr.exerciseId == exercise.exerciseId &&
              pr.type == PersonalRecordType.duration)
          .toList();

      bool isNewDurationPR = existingDurationPRs.isEmpty;
      if (existingDurationPRs.isNotEmpty) {
        final bestDurationPR = existingDurationPRs.reduce((a, b) =>
            (a.duration?.inMinutes ?? 0) > (b.duration?.inMinutes ?? 0)
                ? a
                : b);
        isNewDurationPR = exercise.duration!.inMinutes >
            (bestDurationPR.duration?.inMinutes ?? 0);
      }

      if (isNewDurationPR) {
        final personalRecord = PersonalRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          date: exercise.date,
          equipment: exercise.equipment,
          type: PersonalRecordType.duration,
          duration: exercise.duration,
        );

        _personalRecords.add(personalRecord);
        print(
            'New duration PR created: ${exercise.exerciseName} - ${exercise.duration!.inMinutes} minutes');
      }
    }

    // Generate new achievements after cardio PRs
    await _generateAchievements();
  }

  // Generate achievements
  Future<void> _generateAchievements() async {
    final newAchievements = PersonalRecordService.generateAchievements(
        _personalRecords, _loggedRoutines);

    for (final achievement in newAchievements) {
      // Check if achievement already exists
      final exists = _achievements.any((a) => a.id == achievement.id);
      if (!exists) {
        try {
          // Save to Firestore
          final firestoreId =
              await _workoutFirestoreService.saveAchievement(achievement);

          // Update local list with Firestore ID
          final updatedAchievement = Achievement(
            id: firestoreId,
            title: achievement.title,
            description: achievement.description,
            achievedDate: achievement.achievedDate,
            type: achievement.type,
            exerciseName: achievement.exerciseName,
            value: achievement.value,
          );

          _achievements.add(updatedAchievement);
          print('New achievement unlocked: ${achievement.title}');
        } catch (e) {
          print('Error saving achievement to Firestore: $e');
        }
      }
    }
  }

  // Get recent personal records
  List<PersonalRecord> get recentPersonalRecords {
    return PersonalRecordService.getRecentPRs(_personalRecords, days: 30);
  }

  // Get personal records by exercise
  List<PersonalRecord> getPersonalRecordsByExercise(String exerciseId) {
    return _personalRecords.where((pr) => pr.exerciseId == exerciseId).toList();
  }

  // Get best personal record for an exercise
  PersonalRecord? getBestPersonalRecord(String exerciseId) {
    return PersonalRecordService.getBestPR(exerciseId, _personalRecords);
  }

  // Get strongest lift
  PersonalRecord? get strongestLift {
    return PersonalRecordService.getStrongestLift(_personalRecords);
  }

  // Get recent achievements
  List<Achievement> get recentAchievements {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    return _achievements
        .where((a) => a.achievedDate.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.achievedDate.compareTo(a.achievedDate));
  }

  // Update a logged exercise with individual sets
  Future<void> updateLoggedExerciseWithSets(
    String exerciseId, {
    required List<WorkoutSetData> individualSets,
    String? equipment,
  }) async {
    final index = _loggedExercises.indexWhere((ex) => ex.id == exerciseId);
    if (index != -1) {
      final exercise = _loggedExercises[index];

      final updatedExercise = LoggedExercise(
        id: exercise.id,
        exerciseId: exercise.exerciseId,
        exerciseName: exercise.exerciseName,
        targetMuscles: exercise.targetMuscles,
        date: exercise.date,
        // Set new individual sets
        individualSets: individualSets,
        // Clear legacy fields since we're using individual sets
        sets: null,
        weight: null,
        reps: null,
        // Common
        equipment: equipment ?? exercise.equipment,
        // Cardio-specific (preserve)
        distance: exercise.distance,
        duration: exercise.duration,
        calories: exercise.calories,
        pace: exercise.pace,
        speed: exercise.speed,
        heartRate: exercise.heartRate,
      );

      try {
        // Update in Firestore
        await _workoutFirestoreService.updateExerciseSession(
            exerciseId, updatedExercise);

        // Update local list
        _loggedExercises[index] = updatedExercise;
        notifyListeners();
        print(
            'Exercise individual sets updated in Firestore: ${updatedExercise.exerciseName}');
      } catch (e) {
        print('Error updating exercise individual sets in Firestore: $e');
        throw Exception('Failed to update exercise individual sets: $e');
      }
    }
  }
}
