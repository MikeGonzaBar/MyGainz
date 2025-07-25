import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/providers/auth_provider.dart';
import '../../exercises/providers/workout_provider.dart';
import '../../../core/providers/units_provider.dart';

class DataExportService {
  static Future<void> exportPersonalData({
    required AuthProvider authProvider,
    required WorkoutProvider workoutProvider,
    required UnitsProvider unitsProvider,
  }) async {
    try {
      // Get temporary directory for file storage
      final directory = await getTemporaryDirectory();
      final now = DateTime.now();
      final dateString =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final fileName = 'MyGainz_Personal_Data_$dateString.csv';
      final filePath = '${directory.path}/$fileName';

      // Generate CSV content
      final csvContent = await _generateCSVContent(
        authProvider: authProvider,
        workoutProvider: workoutProvider,
        unitsProvider: unitsProvider,
      );

      // Write to file
      final file = File(filePath);
      await file.writeAsString(csvContent);

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'MyGainz Personal Data Export - Complete Workout History',
      );
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  static Future<String> _generateCSVContent({
    required AuthProvider authProvider,
    required WorkoutProvider workoutProvider,
    required UnitsProvider unitsProvider,
  }) async {
    final List<List<dynamic>> allData = [];

    // Add export info header
    allData.add(['MyGainz Personal Data Export']);
    allData.add(['Generated on:', DateTime.now().toIso8601String()]);
    allData.add(['Export Type:', 'Complete Personal Data']);
    allData.add([]); // Empty row

    // User Profile Section
    allData.add(['=== USER PROFILE ===']);
    allData.add(['Field', 'Value']);

    final user = authProvider.currentUser;
    if (user != null) {
      allData.add(['Full Name', user.fullName]);
      allData.add(['Email', user.email]);
      allData.add(['Age', user.age.toString()]);
      allData.add(['Weight', (unitsProvider.formatWeight(user.weight))]);
      allData.add(['Height', (unitsProvider.formatHeight(user.height))]);
      allData.add(['Account Created', user.createdAt.toIso8601String()]);
      allData.add(['Last Updated', user.updatedAt.toIso8601String()]);
    } else {
      allData.add(['Error', 'No user data available']);
    }

    allData.add([]); // Empty row

    // Settings Section
    allData.add(['=== SETTINGS & PREFERENCES ===']);
    allData.add(['Setting', 'Value']);
    allData.add(['Weight Unit', unitsProvider.weightUnit]);
    allData.add(['Height Unit', unitsProvider.heightUnit]);
    allData.add(['Distance Unit', unitsProvider.distanceUnit]);
    allData.add([]); // Empty row

    // Logged Exercises Section
    allData.add(['=== LOGGED EXERCISES ===']);
    allData.add([
      'Exercise ID',
      'Exercise Name',
      'Target Muscles',
      'Weight (${unitsProvider.weightUnit})',
      'Reps',
      'Sets',
      'Equipment',
      'Date Logged',
    ]);

    for (final exercise in workoutProvider.loggedExercises) {
      allData.add([
        exercise.id,
        exercise.exerciseName,
        exercise.targetMuscles.join('; '),
        exercise.weight != null
            ? unitsProvider.convertWeight(exercise.weight!).toStringAsFixed(2)
            : 'N/A',
        exercise.reps?.toString() ?? 'N/A',
        exercise.sets.toString(),
        exercise.equipment,
        exercise.date.toIso8601String(),
      ]);
    }

    if (workoutProvider.loggedExercises.isEmpty) {
      allData.add(['No exercises logged yet']);
    }

    allData.add([]); // Empty row

    // Logged Routines Section
    allData.add(['=== LOGGED ROUTINES ===']);
    allData.add([
      'Routine ID',
      'Routine Name',
      'Target Muscles',
      'Number of Exercises',
      'Date Logged',
      'Exercise Details',
    ]);

    for (final routine in workoutProvider.loggedRoutines) {
      // Create exercise details string
      final exerciseDetails = routine.exercises.map((exercise) {
        final weightText = exercise.weight != null
            ? '${unitsProvider.convertWeight(exercise.weight!).toStringAsFixed(1)}${unitsProvider.weightUnit}'
            : 'N/A';
        final repsText = exercise.reps?.toString() ?? 'N/A';
        return '${exercise.exerciseName} ($weightText x $repsText reps x ${exercise.sets} sets)';
      }).join(' | ');

      allData.add([
        routine.id,
        routine.name,
        routine.targetMuscles.join('; '),
        routine.exercises.length.toString(),
        routine.date.toIso8601String(),
        exerciseDetails,
      ]);
    }

    if (workoutProvider.loggedRoutines.isEmpty) {
      allData.add(['No routines logged yet']);
    }

    allData.add([]); // Empty row

    // Detailed Exercise Breakdown for Routines
    if (workoutProvider.loggedRoutines.isNotEmpty) {
      allData.add(['=== DETAILED ROUTINE EXERCISES ===']);
      allData.add([
        'Routine ID',
        'Routine Name',
        'Exercise ID',
        'Exercise Name',
        'Target Muscles',
        'Weight (${unitsProvider.weightUnit})',
        'Reps',
        'Sets',
        'Equipment',
        'Date Logged',
      ]);

      for (final routine in workoutProvider.loggedRoutines) {
        for (final exercise in routine.exercises) {
          allData.add([
            routine.id,
            routine.name,
            exercise.id,
            exercise.exerciseName,
            exercise.targetMuscles.join('; '),
            exercise.weight != null
                ? unitsProvider
                    .convertWeight(exercise.weight!)
                    .toStringAsFixed(2)
                : 'N/A',
            exercise.reps?.toString() ?? 'N/A',
            exercise.sets.toString(),
            exercise.equipment,
            routine.date.toIso8601String(),
          ]);
        }
      }

      allData.add([]); // Empty row
    }

    // Individual Sets Section
    allData.add(['=== INDIVIDUAL SETS ===']);
    allData.add([
      'Parent Type', // 'Exercise' or 'Routine Exercise'
      'Parent ID', // Exercise ID or Routine Exercise ID
      'Exercise Name',
      'Set Number',
      'Weight',
      'Reps',
      'Rest Time (sec)',
      'Date',
    ]);
    // Logged Exercises
    for (final exercise in workoutProvider.loggedExercises) {
      if (exercise.individualSets != null &&
          exercise.individualSets!.isNotEmpty) {
        for (final set in exercise.individualSets!) {
          allData.add([
            'Exercise',
            exercise.id,
            exercise.exerciseName,
            set.setNumber,
            set.weight.toStringAsFixed(2),
            set.reps.toString(),
            set.restTime?.inSeconds.toString() ?? 'N/A',
            exercise.date.toIso8601String(),
          ]);
        }
      }
    }
    // Routine Exercises
    for (final routine in workoutProvider.loggedRoutines) {
      for (final exercise in routine.exercises) {
        if (exercise.individualSets != null &&
            exercise.individualSets!.isNotEmpty) {
          for (final set in exercise.individualSets!) {
            allData.add([
              'Routine Exercise',
              exercise.id,
              exercise.exerciseName,
              set.setNumber,
              set.weight.toStringAsFixed(2),
              set.reps.toString(),
              set.restTime?.inSeconds.toString() ?? 'N/A',
              routine.date.toIso8601String(),
            ]);
          }
        }
      }
    }
    if (allData.last[0] == '=== INDIVIDUAL SETS ===') {
      allData.add(['No individual set data yet']);
    }
    allData.add([]); // Empty row

    // Personal Records Section
    allData.add(['=== PERSONAL RECORDS ===']);
    allData.add([
      'PR ID',
      'Exercise ID',
      'Exercise Name',
      'Date',
      'Equipment',
      'Type',
      'Weight',
      'Reps',
      'Sets',
      '1RM',
      'Distance',
      'Duration (min)',
      'Pace',
      'Speed',
      'Calories',
      'Heart Rate',
    ]);
    for (final pr in workoutProvider.personalRecords) {
      allData.add([
        pr.id,
        pr.exerciseId,
        pr.exerciseName,
        pr.date.toIso8601String(),
        pr.equipment,
        pr.type.toString().split('.').last,
        pr.weight?.toStringAsFixed(2) ?? 'N/A',
        pr.reps?.toString() ?? 'N/A',
        pr.sets?.toString() ?? 'N/A',
        pr.oneRepMax?.toStringAsFixed(2) ?? 'N/A',
        pr.distance?.toStringAsFixed(2) ?? 'N/A',
        pr.duration?.inMinutes.toString() ?? 'N/A',
        pr.pace?.toStringAsFixed(2) ?? 'N/A',
        pr.speed?.toStringAsFixed(2) ?? 'N/A',
        pr.calories?.toString() ?? 'N/A',
        pr.heartRate?.toString() ?? 'N/A',
      ]);
    }
    if (workoutProvider.personalRecords.isEmpty) {
      allData.add(['No personal records yet']);
    }
    allData.add([]); // Empty row

    // Achievements Section
    allData.add(['=== ACHIEVEMENTS ===']);
    allData.add([
      'Achievement ID',
      'Title',
      'Description',
      'Achieved Date',
      'Type',
      'Exercise Name',
      'Value',
      'Linked Exercise ID',
      'Linked PR ID',
    ]);
    for (final ach in workoutProvider.achievements) {
      allData.add([
        ach.id,
        ach.title,
        ach.description,
        ach.achievedDate.toIso8601String(),
        ach.type.toString().split('.').last,
        ach.exerciseName ?? 'N/A',
        ach.value?.toStringAsFixed(2) ?? 'N/A',
        ach.linkedExerciseId ?? 'N/A',
        ach.linkedPersonalRecordId ?? 'N/A',
      ]);
    }
    if (workoutProvider.achievements.isEmpty) {
      allData.add(['No achievements yet']);
    }
    allData.add([]); // Empty row

    // Statistics Section
    allData.add(['=== WORKOUT STATISTICS ===']);
    allData.add(['Metric', 'Value']);

    final totalExercises = workoutProvider.loggedExercises.length;
    final totalRoutines = workoutProvider.loggedRoutines.length;
    final totalWorkouts = totalExercises + totalRoutines;

    // Calculate muscle group distribution
    final muscleGroups = <String, int>{};
    for (final exercise in workoutProvider.loggedExercises) {
      for (final muscle in exercise.targetMuscles) {
        muscleGroups[muscle] = (muscleGroups[muscle] ?? 0) + 1;
      }
    }
    for (final routine in workoutProvider.loggedRoutines) {
      for (final exercise in routine.exercises) {
        for (final muscle in exercise.targetMuscles) {
          muscleGroups[muscle] = (muscleGroups[muscle] ?? 0) + 1;
        }
      }
    }

    // Calculate equipment usage
    final equipmentUsage = <String, int>{};
    for (final exercise in workoutProvider.loggedExercises) {
      equipmentUsage[exercise.equipment] =
          (equipmentUsage[exercise.equipment] ?? 0) + 1;
    }
    for (final routine in workoutProvider.loggedRoutines) {
      for (final exercise in routine.exercises) {
        equipmentUsage[exercise.equipment] =
            (equipmentUsage[exercise.equipment] ?? 0) + 1;
      }
    }

    // Calculate date range
    DateTime? earliestDate;
    DateTime? latestDate;

    final allDates = [
      ...workoutProvider.loggedExercises.map((e) => e.date),
      ...workoutProvider.loggedRoutines.map((r) => r.date),
    ];

    if (allDates.isNotEmpty) {
      earliestDate =
          allDates.reduce((DateTime a, DateTime b) => a.isBefore(b) ? a : b);
      latestDate =
          allDates.reduce((DateTime a, DateTime b) => a.isAfter(b) ? a : b);
    }

    allData.add(['Total Individual Exercises', totalExercises.toString()]);
    allData.add(['Total Routine Workouts', totalRoutines.toString()]);
    allData.add(['Total Workouts', totalWorkouts.toString()]);
    allData.add(['First Workout', earliestDate?.toIso8601String() ?? 'N/A']);
    allData.add(['Latest Workout', latestDate?.toIso8601String() ?? 'N/A']);
    allData.add([
      'Most Trained Muscle',
      muscleGroups.isNotEmpty
          ? muscleGroups.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : 'N/A'
    ]);
    allData.add([
      'Most Used Equipment',
      equipmentUsage.isNotEmpty
          ? equipmentUsage.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
          : 'N/A'
    ]);

    allData.add([]); // Empty row

    // Muscle Group Breakdown
    if (muscleGroups.isNotEmpty) {
      allData.add(['=== MUSCLE GROUP BREAKDOWN ===']);
      allData.add(['Muscle Group', 'Exercise Count', 'Percentage']);

      final totalMuscleExercises = muscleGroups.values.reduce((a, b) => a + b);
      final sortedMuscles = muscleGroups.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sortedMuscles) {
        final percentage =
            (entry.value / totalMuscleExercises * 100).toStringAsFixed(1);
        allData.add([entry.key, entry.value.toString(), '$percentage%']);
      }

      allData.add([]); // Empty row
    }

    // Equipment Usage Breakdown
    if (equipmentUsage.isNotEmpty) {
      allData.add(['=== EQUIPMENT USAGE BREAKDOWN ===']);
      allData.add(['Equipment', 'Usage Count', 'Percentage']);

      final totalEquipmentUsage = equipmentUsage.values.reduce((a, b) => a + b);
      final sortedEquipment = equipmentUsage.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sortedEquipment) {
        final percentage =
            (entry.value / totalEquipmentUsage * 100).toStringAsFixed(1);
        allData.add([entry.key, entry.value.toString(), '$percentage%']);
      }

      allData.add([]); // Empty row
    }

    // Footer
    allData.add(['=== END OF EXPORT ===']);
    allData.add(['Generated by MyGainz App']);
    allData.add(['For questions or support, contact: support@mygainz.app']);

    // Convert to CSV string
    return const ListToCsvConverter().convert(allData);
  }
}
