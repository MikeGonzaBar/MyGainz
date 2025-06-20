enum ExerciseType {
  strength,
  cardio,
}

class CardioMetrics {
  final bool hasDistance;
  final bool hasDuration;
  final bool hasPace;
  final bool hasCalories;
  final String? primaryMetric; // 'distance', 'duration', 'pace'

  CardioMetrics({
    required this.hasDistance,
    required this.hasDuration,
    required this.hasPace,
    required this.hasCalories,
    this.primaryMetric,
  });

  Map<String, dynamic> toJson() {
    return {
      'hasDistance': hasDistance,
      'hasDuration': hasDuration,
      'hasPace': hasPace,
      'hasCalories': hasCalories,
      'primaryMetric': primaryMetric,
    };
  }

  factory CardioMetrics.fromJson(Map<String, dynamic> json) {
    return CardioMetrics(
      hasDistance: json['hasDistance'] ?? false,
      hasDuration: json['hasDuration'] ?? false,
      hasPace: json['hasPace'] ?? false,
      hasCalories: json['hasCalories'] ?? false,
      primaryMetric: json['primaryMetric'],
    );
  }
}

class Exercise {
  final String id; // Document ID
  final String userId;
  final String exerciseName;
  final List<String> targetMuscles;
  final List<String> equipment;
  final ExerciseType exerciseType;
  final CardioMetrics? cardioMetrics;

  Exercise({
    required this.id,
    required this.userId,
    required this.exerciseName,
    required this.targetMuscles,
    required this.equipment,
    this.exerciseType = ExerciseType.strength,
    this.cardioMetrics,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseName': exerciseName,
      'targetMuscles': targetMuscles,
      'equipment': equipment,
      'exerciseType': exerciseType.toString(),
      'cardioMetrics': cardioMetrics?.toJson(),
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      userId: json['userId'],
      exerciseName: json['exerciseName'],
      targetMuscles: List<String>.from(json['targetMuscles']),
      equipment: List<String>.from(json['equipment']),
      exerciseType: ExerciseType.values.firstWhere(
        (e) => e.toString() == json['exerciseType'],
        orElse: () => ExerciseType.strength,
      ),
      cardioMetrics: json['cardioMetrics'] != null
          ? CardioMetrics.fromJson(json['cardioMetrics'])
          : null,
    );
  }
}
