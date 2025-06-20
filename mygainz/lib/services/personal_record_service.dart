import '../models/personal_record.dart';
import '../providers/workout_provider.dart';

class PersonalRecordService {
  // Calculate 1RM using Epley formula: weight × (1 + reps/30)
  static double calculateOneRepMax(double weight, int reps) {
    if (reps <= 0) return weight;
    if (reps == 1) return weight;

    // Epley formula: weight × (1 + reps/30)
    return weight * (1 + reps / 30);
  }

  // Check if a new PR is achieved
  static bool isNewPersonalRecord(
    LoggedExercise exercise,
    List<PersonalRecord> existingPRs,
  ) {
    // Only handle strength exercises here (cardio is handled separately)
    if (!exercise.isStrength ||
        exercise.weight == null ||
        exercise.reps == null) {
      return false;
    }

    final exercisePRs = existingPRs
        .where((pr) =>
            pr.exerciseId == exercise.exerciseId &&
            pr.type == PersonalRecordType.weight)
        .toList();

    if (exercisePRs.isEmpty) return true;

    final newOneRepMax = calculateOneRepMax(exercise.weight!, exercise.reps!);
    final bestExistingPR = exercisePRs
        .reduce((a, b) => (a.oneRepMax ?? 0) > (b.oneRepMax ?? 0) ? a : b);

    return newOneRepMax > (bestExistingPR.oneRepMax ?? 0);
  }

  // Get the best PR for an exercise
  static PersonalRecord? getBestPR(
      String exerciseId, List<PersonalRecord> personalRecords,
      {PersonalRecordType type = PersonalRecordType.weight}) {
    final exercisePRs = personalRecords
        .where((pr) => pr.exerciseId == exerciseId && pr.type == type)
        .toList();

    if (exercisePRs.isEmpty) return null;

    return exercisePRs.reduce((a, b) {
      final aValue = a.primaryValue ?? 0;
      final bValue = b.primaryValue ?? 0;

      // For pace, lower is better; for others, higher is better
      if (type == PersonalRecordType.pace) {
        return aValue < bValue ? a : b;
      }
      return aValue > bValue ? a : b;
    });
  }

  // Get recent PRs (last 30 days)
  static List<PersonalRecord> getRecentPRs(List<PersonalRecord> personalRecords,
      {int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return personalRecords.where((pr) => pr.date.isAfter(cutoffDate)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Generate achievements based on PRs and workout data
  static List<Achievement> generateAchievements(
    List<PersonalRecord> personalRecords,
    List<LoggedRoutine> workoutHistory,
  ) {
    final achievements = <Achievement>[];
    final now = DateTime.now();

    // === WEIGHT-BASED ACHIEVEMENTS ===

    // First PR achievement
    if (personalRecords.isNotEmpty) {
      final firstPR =
          personalRecords.reduce((a, b) => a.date.isBefore(b.date) ? a : b);

      achievements.add(Achievement(
        id: 'first_pr_${firstPR.exerciseId}',
        title: 'First Personal Record!',
        description: 'You achieved your first PR in ${firstPR.exerciseName}',
        achievedDate: firstPR.date,
        type: AchievementType.weight,
        exerciseName: firstPR.exerciseName,
        value: firstPR.primaryValue,
      ));
    }

    // Progressive weight milestones (only for strength exercises)
    final weightMilestones = [50.0, 75.0, 100.0, 125.0, 150.0, 200.0];
    final strengthPRs = personalRecords
        .where(
            (pr) => pr.type == PersonalRecordType.weight && pr.weight != null)
        .toList();

    for (final milestone in weightMilestones) {
      final heavyLifts =
          strengthPRs.where((pr) => pr.weight! >= milestone).toList();
      if (heavyLifts.isNotEmpty) {
        final firstHeavyLift =
            heavyLifts.reduce((a, b) => a.date.isBefore(b.date) ? a : b);

        // Check if we already have this achievement
        final existingAchievement = achievements
            .where((a) => a.id == '${milestone.toInt()}kg_milestone')
            .toList();
        if (existingAchievement.isEmpty) {
          achievements.add(Achievement(
            id: '${milestone.toInt()}kg_milestone',
            title: '${milestone.toInt()}kg Club!',
            description:
                'You lifted ${milestone.toInt()}kg or more in ${firstHeavyLift.exerciseName}',
            achievedDate: firstHeavyLift.date,
            type: AchievementType.milestone,
            exerciseName: firstHeavyLift.exerciseName,
            value: firstHeavyLift.weight,
          ));
        }
      }
    }

    // Exercise-specific milestones (in kg for simplicity)
    final exerciseMilestones = {
      'Bench Press': [60.0, 90.0, 135.0, 180.0], // 135lb, 225lb, 315lb, 405lb
      'Deadlift': [100.0, 135.0, 180.0, 225.0], // 225lb, 315lb, 405lb, 495lb
      'Squat': [100.0, 135.0, 180.0], // 225lb, 315lb, 405lb
    };

    for (final entry in exerciseMilestones.entries) {
      final exerciseName = entry.key;
      final milestones = entry.value;

      for (final milestone in milestones) {
        final exercisePRs = strengthPRs
            .where((pr) =>
                pr.exerciseName
                    .toLowerCase()
                    .contains(exerciseName.toLowerCase()) &&
                pr.weight! >= milestone)
            .toList();

        if (exercisePRs.isNotEmpty) {
          final firstMilestone =
              exercisePRs.reduce((a, b) => a.date.isBefore(b.date) ? a : b);
          final plates =
              (milestone / 20.4).round(); // Approximate plates (20.4kg each)

          achievements.add(Achievement(
            id: '${exerciseName.toLowerCase().replaceAll(' ', '_')}_${milestone.toInt()}kg',
            title: '${milestone.toInt()}kg ${exerciseName}!',
            description:
                'You hit ${milestone.toInt()}kg on ${exerciseName} - that\'s ${plates} plates!',
            achievedDate: firstMilestone.date,
            type: AchievementType.milestone,
            exerciseName: exerciseName,
            value: firstMilestone.weight,
          ));
        }
      }
    }

    // === CARDIO ACHIEVEMENTS ===

    // Distance achievements
    final distancePRs = personalRecords
        .where((pr) =>
            pr.type == PersonalRecordType.distance && pr.distance != null)
        .toList();

    final distanceMilestones = [
      5.0,
      10.0,
      21.0,
      42.0
    ]; // 5km, 10km, half marathon, marathon
    for (final milestone in distanceMilestones) {
      final longDistancePRs =
          distancePRs.where((pr) => pr.distance! >= milestone).toList();
      if (longDistancePRs.isNotEmpty) {
        final firstLongDistance =
            longDistancePRs.reduce((a, b) => a.date.isBefore(b.date) ? a : b);

        achievements.add(Achievement(
          id: 'distance_${milestone.toInt()}km',
          title: '${milestone.toInt()}km Achievement!',
          description:
              'You completed ${milestone.toInt()}km in ${firstLongDistance.exerciseName}',
          achievedDate: firstLongDistance.date,
          type: AchievementType.distance,
          exerciseName: firstLongDistance.exerciseName,
          value: firstLongDistance.distance,
        ));
      }
    }

    // Pace achievements
    final pacePRs = personalRecords
        .where((pr) => pr.type == PersonalRecordType.pace && pr.pace != null)
        .toList();

    if (pacePRs.isNotEmpty) {
      final fastestPace = pacePRs.reduce((a, b) =>
          (a.pace ?? double.infinity) < (b.pace ?? double.infinity) ? a : b);

      if (fastestPace.pace! <= 5.0) {
        // Sub-5 min/km
        achievements.add(Achievement(
          id: 'pace_sub_5min',
          title: 'Speed Demon!',
          description:
              'You achieved sub-5 min/km pace in ${fastestPace.exerciseName}',
          achievedDate: fastestPace.date,
          type: AchievementType.pace,
          exerciseName: fastestPace.exerciseName,
          value: fastestPace.pace,
        ));
      }
    }

    // === VOLUME & CONSISTENCY ACHIEVEMENTS ===

    // Multiple PRs in a week
    final recentPRs = getRecentPRs(personalRecords, days: 7);
    if (recentPRs.length >= 3) {
      achievements.add(Achievement(
        id: 'multiple_prs_week',
        title: 'PR Machine!',
        description: 'You achieved ${recentPRs.length} PRs this week',
        achievedDate: now,
        type: AchievementType.weight,
        value: recentPRs.length.toDouble(),
      ));
    }

    // === EXERCISE VARIETY ACHIEVEMENTS ===

    // Exercise diversity
    final uniqueExercises =
        personalRecords.map((pr) => pr.exerciseName).toSet();
    final diversityMilestones = [10, 25, 50, 100];

    for (final milestone in diversityMilestones) {
      if (uniqueExercises.length >= milestone) {
        achievements.add(Achievement(
          id: 'exercise_diversity_$milestone',
          title: 'Exercise Explorer!',
          description: 'You\'ve tried $milestone different exercises!',
          achievedDate: now,
          type: AchievementType.frequency,
          value: uniqueExercises.length.toDouble(),
        ));
      }
    }

    // Equipment mastery
    final uniqueEquipment = personalRecords.map((pr) => pr.equipment).toSet();
    if (uniqueEquipment.length >= 3) {
      achievements.add(Achievement(
        id: 'equipment_master',
        title: 'Equipment Master!',
        description:
            'You\'re versatile with ${uniqueEquipment.length} different equipment types!',
        achievedDate: now,
        type: AchievementType.frequency,
        value: uniqueEquipment.length.toDouble(),
      ));
    }

    // === PROGRESS & IMPROVEMENT ACHIEVEMENTS ===

    // Rapid progress (10% improvement in 30 days)
    final thirtyDaysAgo = now.subtract(Duration(days: 30));
    final recentPRs30Days =
        personalRecords.where((pr) => pr.date.isAfter(thirtyDaysAgo)).toList();

    if (recentPRs30Days.isNotEmpty) {
      // Group by exercise and check for improvement
      final exerciseGroups = <String, List<PersonalRecord>>{};
      for (final pr in recentPRs30Days) {
        exerciseGroups.putIfAbsent(pr.exerciseName, () => []).add(pr);
      }

      for (final entry in exerciseGroups.entries) {
        final exerciseName = entry.key;
        final prs = entry.value;

        if (prs.length >= 2) {
          prs.sort((a, b) => a.date.compareTo(b.date));
          final firstPR = prs.first;
          final lastPR = prs.last;

          final firstValue = firstPR.primaryValue ?? 0;
          final lastValue = lastPR.primaryValue ?? 0;

          if (firstValue > 0) {
            final improvement = ((lastValue - firstValue) / firstValue) * 100;

            if (improvement >= 10) {
              achievements.add(Achievement(
                id: 'rapid_progress_${exerciseName.toLowerCase().replaceAll(' ', '_')}',
                title: 'Rapid Progress!',
                description:
                    'You\'ve improved your $exerciseName by ${improvement.toStringAsFixed(1)}% this month!',
                achievedDate: lastPR.date,
                type: AchievementType.weight,
                exerciseName: exerciseName,
                value: improvement,
              ));
            }
          }
        }
      }
    }

    // === ENDURANCE ACHIEVEMENTS ===

    // High rep achievements (strength only)
    final highRepPRs =
        strengthPRs.where((pr) => pr.reps != null && pr.reps! >= 20).toList();
    if (highRepPRs.isNotEmpty) {
      final firstHighRep =
          highRepPRs.reduce((a, b) => a.date.isBefore(b.date) ? a : b);

      achievements.add(Achievement(
        id: 'endurance_feat',
        title: 'Endurance Beast!',
        description:
            'You completed ${firstHighRep.reps} reps - that\'s endurance!',
        achievedDate: firstHighRep.date,
        type: AchievementType.reps,
        exerciseName: firstHighRep.exerciseName,
        value: firstHighRep.reps!.toDouble(),
      ));
    }

    // === SPECIALIZED ACHIEVEMENTS ===

    // Perfect form (consistent sets)
    final consistentPRs =
        strengthPRs.where((pr) => pr.sets != null && pr.sets! >= 3).toList();
    if (consistentPRs.isNotEmpty) {
      final firstConsistent =
          consistentPRs.reduce((a, b) => a.date.isBefore(b.date) ? a : b);

      achievements.add(Achievement(
        id: 'perfect_form',
        title: 'Perfect Form!',
        description:
            'Your form is dialed in - ${firstConsistent.sets} consistent sets!',
        achievedDate: firstConsistent.date,
        type: AchievementType.volume,
        exerciseName: firstConsistent.exerciseName,
        value: firstConsistent.sets!.toDouble(),
      ));
    }

    // === TIME-BASED ACHIEVEMENTS ===

    // Seasonal goals (Summer body prep - March to June)
    final march = DateTime(now.year, 3, 1);
    final june = DateTime(now.year, 6, 30);
    if (now.isAfter(march) && now.isBefore(june)) {
      final springWorkouts = workoutHistory
          .where((w) => w.date.isAfter(march) && w.date.isBefore(june))
          .toList();

      if (springWorkouts.length >= 20) {
        achievements.add(Achievement(
          id: 'summer_body_prep',
          title: 'Summer Body Prep!',
          description:
              'You\'re preparing for summer with ${springWorkouts.length} workouts!',
          achievedDate: now,
          type: AchievementType.frequency,
          value: springWorkouts.length.toDouble(),
        ));
      }
    }

    // New Year resolution (consistent January)
    final january = DateTime(now.year, 1, 1);
    final february = DateTime(now.year, 2, 1);
    if (now.isAfter(january) && now.isBefore(february)) {
      final januaryWorkouts = workoutHistory
          .where((w) => w.date.isAfter(january) && w.date.isBefore(february))
          .toList();

      if (januaryWorkouts.length >= 15) {
        achievements.add(Achievement(
          id: 'new_year_resolution',
          title: 'New Year Resolution!',
          description:
              'You stuck to your New Year goals with ${januaryWorkouts.length} January workouts!',
          achievedDate: now,
          type: AchievementType.frequency,
          value: januaryWorkouts.length.toDouble(),
        ));
      }
    }

    // === DATA CONSISTENCY ACHIEVEMENTS ===

    // Logging consistency
    final consecutiveLoggingDays =
        _calculateConsecutiveLoggingDays(workoutHistory);
    final loggingMilestones = [30, 60, 100];

    for (final milestone in loggingMilestones) {
      if (consecutiveLoggingDays >= milestone) {
        achievements.add(Achievement(
          id: 'logging_consistency_$milestone',
          title: 'Data Warrior!',
          description:
              'You\'re committed to tracking your progress for $milestone consecutive days!',
          achievedDate: now,
          type: AchievementType.streak,
          value: consecutiveLoggingDays.toDouble(),
        ));
      }
    }

    return achievements;
  }

  // Helper method to calculate consecutive logging days
  static int _calculateConsecutiveLoggingDays(
      List<LoggedRoutine> workoutHistory) {
    if (workoutHistory.isEmpty) return 0;

    final sortedWorkouts = workoutHistory.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    int consecutiveDays = 0;
    DateTime? currentDate = DateTime.now();

    for (final workout in sortedWorkouts) {
      final workoutDate =
          DateTime(workout.date.year, workout.date.month, workout.date.day);
      final currentDateOnly =
          DateTime(currentDate!.year, currentDate.month, currentDate.day);

      if (workoutDate.isAtSameMomentAs(currentDateOnly)) {
        consecutiveDays++;
        currentDate = currentDate.subtract(Duration(days: 1));
      } else if (workoutDate.isBefore(currentDateOnly)) {
        final daysDiff = currentDateOnly.difference(workoutDate).inDays;
        if (daysDiff == 1) {
          consecutiveDays++;
          currentDate = workoutDate;
        } else {
          break;
        }
      }
    }

    return consecutiveDays;
  }

  // Get PR progress over time for a specific exercise
  static List<Map<String, dynamic>> getPRProgress(
    String exerciseId,
    List<PersonalRecord> personalRecords,
  ) {
    final exercisePRs = personalRecords
        .where((pr) => pr.exerciseId == exerciseId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return exercisePRs
        .map((pr) => {
              'date': pr.date,
              'oneRepMax': pr.oneRepMax,
              'weight': pr.weight,
              'reps': pr.reps,
            })
        .toList();
  }

  // Calculate total PRs by exercise
  static Map<String, int> getPRCountByExercise(
    List<PersonalRecord> personalRecords,
  ) {
    final Map<String, int> counts = {};

    for (final pr in personalRecords) {
      counts[pr.exerciseName] = (counts[pr.exerciseName] ?? 0) + 1;
    }

    return counts;
  }

  // Get strongest lift (highest 1RM)
  static PersonalRecord? getStrongestLift(
    List<PersonalRecord> personalRecords,
  ) {
    final strengthPRs = personalRecords
        .where((pr) =>
            pr.type == PersonalRecordType.weight && pr.oneRepMax != null)
        .toList();

    if (strengthPRs.isEmpty) return null;

    return strengthPRs
        .reduce((a, b) => (a.oneRepMax ?? 0) > (b.oneRepMax ?? 0) ? a : b);
  }
}
