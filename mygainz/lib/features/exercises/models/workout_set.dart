import 'package:flutter/material.dart';

class WorkoutSet {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController repsController = TextEditingController();

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}

// New model for storing individual set data in Firestore
class WorkoutSetData {
  final double weight;
  final int reps;
  final Duration? restTime; // Optional rest time between sets
  final int setNumber; // Order of the set (1, 2, 3, etc.)

  WorkoutSetData({
    required this.weight,
    required this.reps,
    this.restTime,
    required this.setNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'reps': reps,
      'restTime': restTime?.inSeconds,
      'setNumber': setNumber,
    };
  }

  factory WorkoutSetData.fromJson(Map<String, dynamic> json) {
    return WorkoutSetData(
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'] as int,
      restTime: json['restTime'] != null
          ? Duration(seconds: json['restTime'] as int)
          : null,
      setNumber: json['setNumber'] as int,
    );
  }

  // Helper method to create from WorkoutSet UI controllers
  static WorkoutSetData? fromWorkoutSet(WorkoutSet workoutSet, int setNumber,
      {required String currentWeightUnit}) {
    final weight = double.tryParse(workoutSet.weightController.text);
    final reps = int.tryParse(workoutSet.repsController.text);

    if (weight != null && reps != null && weight > 0 && reps > 0) {
      // Convert weight to kg (base unit) for storage
      double weightInKg = weight;
      if (currentWeightUnit == 'lbs') {
        weightInKg = weight * 0.453592; // Convert lbs to kg
      }

      return WorkoutSetData(
        weight: weightInKg, // Always store in kg
        reps: reps,
        setNumber: setNumber,
      );
    }

    return null;
  }
}
