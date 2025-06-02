import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoggedExercise {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final List<String> targetMuscles;
  final double weight;
  final int reps;
  final String equipment;
  final int sets;
  final DateTime date;

  LoggedExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.targetMuscles,
    required this.weight,
    required this.reps,
    required this.equipment,
    required this.sets,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'targetMuscles': targetMuscles,
      'weight': weight,
      'reps': reps,
      'equipment': equipment,
      'sets': sets,
      'date': date.toIso8601String(),
    };
  }

  factory LoggedExercise.fromJson(Map<String, dynamic> json) {
    return LoggedExercise(
      id: json['id'],
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      targetMuscles: List<String>.from(json['targetMuscles']),
      weight: json['weight'].toDouble(),
      reps: json['reps'],
      equipment: json['equipment'],
      sets: json['sets'],
      date: DateTime.parse(json['date']),
    );
  }
}

class LoggedRoutine {
  final String id;
  final String routineId;
  final String name;
  final List<String> targetMuscles;
  final DateTime date;
  final List<LoggedExercise> exercises;

  LoggedRoutine({
    required this.id,
    required this.routineId,
    required this.name,
    required this.targetMuscles,
    required this.date,
    required this.exercises,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routineId': routineId,
      'name': name,
      'targetMuscles': targetMuscles,
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
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
    );
  }
}

class WorkoutProvider with ChangeNotifier {
  List<LoggedExercise> _loggedExercises = [];
  List<LoggedRoutine> _loggedRoutines = [];
  bool _isLoading = false;

  List<LoggedExercise> get loggedExercises =>
      List.unmodifiable(_loggedExercises);
  List<LoggedRoutine> get loggedRoutines => List.unmodifiable(_loggedRoutines);
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

      _isLoading = false;
      notifyListeners();
      print(
          'Workouts loaded: ${_loggedExercises.length} exercises, ${_loggedRoutines.length} routines');
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
    required double weight,
    required int reps,
    required String equipment,
    required int sets,
  }) async {
    final loggedExercise = LoggedExercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      targetMuscles: targetMuscles,
      weight: weight,
      reps: reps,
      equipment: equipment,
      sets: sets,
      date: DateTime.now(),
    );

    _loggedExercises.add(loggedExercise);
    await _saveWorkouts();
    notifyListeners();
  }

  // Log a routine workout
  Future<void> logRoutine({
    required String routineId,
    required String routineName,
    required List<String> targetMuscles,
    required List<LoggedExercise> exercises,
  }) async {
    final loggedRoutine = LoggedRoutine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      routineId: routineId,
      name: routineName,
      targetMuscles: targetMuscles,
      date: DateTime.now(),
      exercises: exercises,
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
}
