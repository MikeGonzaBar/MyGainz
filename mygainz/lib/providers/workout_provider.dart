import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/personal_record.dart';
import '../services/personal_record_service.dart';

class LoggedExercise {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final List<String> targetMuscles;
  final String equipment;
  final int sets;
  final DateTime date;

  // Strength-specific fields (nullable for cardio)
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
    required this.sets,
    required this.date,
    this.weight,
    this.reps,
    this.distance,
    this.duration,
    this.pace,
    this.calories,
    this.speed,
    this.heartRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'targetMuscles': targetMuscles,
      'equipment': equipment,
      'sets': sets,
      'date': date.toIso8601String(),
      'weight': weight,
      'reps': reps,
      'distance': distance,
      'duration': duration?.inMinutes,
      'pace': pace,
      'calories': calories,
      'speed': speed,
      'heartRate': heartRate,
    };
  }

  factory LoggedExercise.fromJson(Map<String, dynamic> json) {
    return LoggedExercise(
      id: json['id'],
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      targetMuscles: List<String>.from(json['targetMuscles']),
      equipment: json['equipment'],
      sets: json['sets'],
      date: DateTime.parse(json['date']),
      weight: json['weight']?.toDouble(),
      reps: json['reps'],
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
    return weight == null && (distance != null || duration != null);
  }

  // Helper method to determine if this is a strength exercise
  bool get isStrength {
    return weight != null && reps != null;
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

  static const String _exercisesKey = 'logged_exercises';
  static const String _routinesKey = 'logged_routines';
  static const String _personalRecordsKey = 'personal_records';
  static const String _achievementsKey = 'achievements';

  WorkoutProvider() {
    _loadWorkouts();
  }

  // Load workouts from SharedPreferences
  Future<void> _loadWorkouts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      // Load exercises
      final exercisesJson = prefs.getStringList(_exercisesKey) ?? [];
      _loggedExercises = exercisesJson
          .map((json) => LoggedExercise.fromJson(jsonDecode(json)))
          .toList();

      // Load routines
      final routinesJson = prefs.getStringList(_routinesKey) ?? [];
      _loggedRoutines = routinesJson
          .map((json) => LoggedRoutine.fromJson(jsonDecode(json)))
          .toList();

      // Load personal records
      final personalRecordsJson =
          prefs.getStringList(_personalRecordsKey) ?? [];
      _personalRecords = personalRecordsJson
          .map((json) => PersonalRecord.fromJson(jsonDecode(json)))
          .toList();

      // Load achievements
      final achievementsJson = prefs.getStringList(_achievementsKey) ?? [];
      _achievements = achievementsJson
          .map((json) => Achievement.fromJson(jsonDecode(json)))
          .toList();

      _isLoading = false;
      notifyListeners();
      print(
          'Workouts loaded: ${_loggedExercises.length} exercises, ${_loggedRoutines.length} routines, ${_personalRecords.length} PRs, ${_achievements.length} achievements');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading workouts: $e');
    }
  }

  // Save workouts to SharedPreferences
  Future<void> _saveWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save exercises
      final exercisesJson = _loggedExercises
          .map((exercise) => jsonEncode(exercise.toJson()))
          .toList();
      await prefs.setStringList(_exercisesKey, exercisesJson);

      // Save routines
      final routinesJson = _loggedRoutines
          .map((routine) => jsonEncode(routine.toJson()))
          .toList();
      await prefs.setStringList(_routinesKey, routinesJson);

      // Save personal records
      final personalRecordsJson =
          _personalRecords.map((pr) => jsonEncode(pr.toJson())).toList();
      await prefs.setStringList(_personalRecordsKey, personalRecordsJson);

      // Save achievements
      final achievementsJson = _achievements
          .map((achievement) => jsonEncode(achievement.toJson()))
          .toList();
      await prefs.setStringList(_achievementsKey, achievementsJson);

      print('Workouts saved successfully');
    } catch (e) {
      print('Error saving workouts: $e');
    }
  }

  // Log a single exercise
  Future<void> logExercise({
    required String exerciseId,
    required String exerciseName,
    required List<String> targetMuscles,
    required String equipment,
    required int sets,
    // Strength-specific parameters
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
      sets: sets,
      date: DateTime.now(),
      weight: weight,
      reps: reps,
      distance: distance,
      duration: duration,
      pace: pace,
      calories: calories,
      speed: speed,
      heartRate: heartRate,
    );

    _loggedExercises.add(loggedExercise);

    // Check for new personal record
    await _checkAndCreatePersonalRecord(loggedExercise);

    await _saveWorkouts();
    notifyListeners();
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

    _loggedRoutines.add(loggedRoutine);
    await _saveWorkouts();
    notifyListeners();
  }

  // Clear all workout logs
  Future<void> clearAllWorkouts() async {
    _loggedExercises.clear();
    _loggedRoutines.clear();
    await _saveWorkouts();
    notifyListeners();
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
      _loggedExercises[index] = LoggedExercise(
        id: exercise.id,
        exerciseId: exercise.exerciseId,
        exerciseName: exercise.exerciseName,
        targetMuscles: exercise.targetMuscles,
        date: exercise.date,
        // Common
        equipment: equipment ?? exercise.equipment,
        sets: sets ?? exercise.sets,
        // Strength-specific (keep if not provided)
        weight: weight ?? exercise.weight,
        reps: reps ?? exercise.reps,
        // Cardio-specific (keep if not provided)
        distance: distance ?? exercise.distance,
        duration: duration ?? exercise.duration,
        calories: calories ?? exercise.calories,
        // Preserve other fields that are not editable for now
        pace: exercise.pace,
        speed: exercise.speed,
        heartRate: exercise.heartRate,
      );
      await _saveWorkouts();
      notifyListeners();
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

        await _saveWorkouts();
        notifyListeners();
      }
    }
  }

  // Delete a logged exercise
  Future<void> deleteLoggedExercise(String exerciseId) async {
    _loggedExercises.removeWhere((ex) => ex.id == exerciseId);
    await _saveWorkouts();
    notifyListeners();
  }

  // Delete a logged routine
  Future<void> deleteLoggedRoutine(String routineId) async {
    _loggedRoutines.removeWhere((r) => r.id == routineId);
    await _saveWorkouts();
    notifyListeners();
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

        await _saveWorkouts();
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

        await _saveWorkouts();
        notifyListeners();
      }
    }
  }

  // Check and create personal record
  Future<void> _checkAndCreatePersonalRecord(LoggedExercise exercise) async {
    // Handle strength exercises
    if (exercise.isStrength &&
        exercise.weight != null &&
        exercise.reps != null) {
      if (PersonalRecordService.isNewPersonalRecord(
          exercise, _personalRecords)) {
        final oneRepMax = PersonalRecordService.calculateOneRepMax(
            exercise.weight!, exercise.reps!);

        final personalRecord = PersonalRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          date: exercise.date,
          equipment: exercise.equipment,
          type: PersonalRecordType.weight,
          weight: exercise.weight,
          reps: exercise.reps,
          sets: exercise.sets,
          oneRepMax: oneRepMax,
        );

        _personalRecords.add(personalRecord);

        // Generate new achievements
        await _generateAchievements();

        print(
            'New strength PR created: ${exercise.exerciseName} - ${exercise.weight}kg × ${exercise.reps} reps (1RM: ${oneRepMax.toStringAsFixed(1)}kg)');
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
        _achievements.add(achievement);
        print('New achievement unlocked: ${achievement.title}');
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
}
