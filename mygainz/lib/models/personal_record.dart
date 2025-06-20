enum PersonalRecordType {
  weight, // 1RM for strength
  distance, // Longest distance
  duration, // Longest duration
  pace, // Fastest pace
  speed, // Fastest speed
  calories, // Most calories burned
}

class PersonalRecord {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final DateTime date;
  final String equipment;
  final PersonalRecordType type;

  // Strength-specific fields (nullable for cardio)
  final double? weight;
  final int? reps;
  final int? sets;
  final double? oneRepMax;

  // Cardio-specific fields (nullable for strength)
  final double? distance;
  final Duration? duration;
  final double? pace;
  final double? speed;
  final int? calories;
  final int? heartRate;

  PersonalRecord({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.date,
    required this.equipment,
    required this.type,
    this.weight,
    this.reps,
    this.sets,
    this.oneRepMax,
    this.distance,
    this.duration,
    this.pace,
    this.speed,
    this.calories,
    this.heartRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'date': date.toIso8601String(),
      'equipment': equipment,
      'type': type.toString(),
      'weight': weight,
      'reps': reps,
      'sets': sets,
      'oneRepMax': oneRepMax,
      'distance': distance,
      'duration': duration?.inMinutes,
      'pace': pace,
      'speed': speed,
      'calories': calories,
      'heartRate': heartRate,
    };
  }

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    return PersonalRecord(
      id: json['id'],
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      date: DateTime.parse(json['date']),
      equipment: json['equipment'],
      type: PersonalRecordType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PersonalRecordType.weight,
      ),
      weight: json['weight']?.toDouble(),
      reps: json['reps'],
      sets: json['sets'],
      oneRepMax: json['oneRepMax']?.toDouble(),
      distance: json['distance']?.toDouble(),
      duration:
          json['duration'] != null ? Duration(minutes: json['duration']) : null,
      pace: json['pace']?.toDouble(),
      speed: json['speed']?.toDouble(),
      calories: json['calories'],
      heartRate: json['heartRate'],
    );
  }

  // Check if this PR is better than another (for strength)
  bool isBetterThan(PersonalRecord other) {
    if (type == PersonalRecordType.weight &&
        other.type == PersonalRecordType.weight) {
      return (oneRepMax ?? 0) > (other.oneRepMax ?? 0);
    }
    // Add cardio comparison logic here
    return false;
  }

  // Helper method to get the primary value for this PR
  double? get primaryValue {
    switch (type) {
      case PersonalRecordType.weight:
        return oneRepMax;
      case PersonalRecordType.distance:
        return distance;
      case PersonalRecordType.duration:
        return duration?.inMinutes.toDouble();
      case PersonalRecordType.pace:
        return pace;
      case PersonalRecordType.speed:
        return speed;
      case PersonalRecordType.calories:
        return calories?.toDouble();
    }
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final DateTime achievedDate;
  final AchievementType type;
  final String? exerciseName;
  final double? value;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.achievedDate,
    required this.type,
    this.exerciseName,
    this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'achievedDate': achievedDate.toIso8601String(),
      'type': type.toString(),
      'exerciseName': exerciseName,
      'value': value,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      achievedDate: DateTime.parse(json['achievedDate']),
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      exerciseName: json['exerciseName'],
      value: json['value']?.toDouble(),
    );
  }
}

enum AchievementType {
  weight, // Weight PR
  reps, // Rep PR
  volume, // Volume PR
  streak, // Workout streak
  frequency, // Workout frequency
  milestone, // General milestones
  distance, // Distance PR
  duration, // Duration PR
  pace, // Pace PR
  speed, // Speed PR
  calories, // Calories PR
}
