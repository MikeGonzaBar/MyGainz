import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/time_period_filter.dart';
import '../widgets/progress_metric_toggle.dart';
import '../widgets/muscle_group_progress_chart.dart';
import '../widgets/equipment_performance_chart.dart';
import '../widgets/equipment_improvement_list.dart';
import '../widgets/personal_records_dashboard.dart';
import '../widgets/stat_card.dart';
import 'dart:math' as math;

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  String selectedTimePeriod = 'All Time';
  bool isSpiderView = true;
  bool showWeightProgress =
      false; // false = times exercised, true = weight progress
  String selectedEquipment = 'All Equipment';
  String selectedMuscleGroup = 'All Muscles';

  final List<String> timePeriods = ['All Time', 'Last 6 Months', 'Last Month'];
  final List<String> equipmentOptions = [
    'All Equipment',
    'Dumbbell',
    'Barbell',
    'Machine',
    'Kettlebell',
  ];
  final List<String> muscleGroupOptions = [
    'All Muscles',
    'Chest',
    'Back',
    'Legs',
    'Arms',
    'Shoulders',
    'Core',
    'Quads',
    'Hamstrings',
    'Glutes',
    'Biceps',
    'Triceps',
  ];

  // Helper method to filter exercises by time period
  List<LoggedExercise> _filterExercisesByTime(List<LoggedExercise> exercises) {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (selectedTimePeriod) {
      case 'Last Month':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case 'Last 6 Months':
        cutoffDate = now.subtract(const Duration(days: 180));
        break;
      default: // All Time
        return exercises;
    }

    return exercises
        .where((exercise) => exercise.date.isAfter(cutoffDate))
        .toList();
  }

  // Calculate muscle group exercise counts
  Map<String, double> _calculateMuscleGroupCounts(
      List<LoggedExercise> exercises) {
    final Map<String, double> counts = {};

    for (final exercise in exercises) {
      for (final muscle in exercise.targetMuscles) {
        counts[muscle] = (counts[muscle] ?? 0) + 1;
      }
    }

    return counts;
  }

  // Calculate average weights per muscle group
  Map<String, double> _calculateMuscleGroupWeights(
      List<LoggedExercise> exercises) {
    final Map<String, List<double>> weightsByMuscle = {};

    for (final exercise in exercises) {
      // Skip exercises without weight data
      if (exercise.weight == null) continue;

      for (final muscle in exercise.targetMuscles) {
        weightsByMuscle[muscle] = (weightsByMuscle[muscle] ?? [])
          ..add(exercise.weight!);
      }
    }

    final Map<String, double> averageWeights = {};
    weightsByMuscle.forEach((muscle, weights) {
      averageWeights[muscle] = weights.reduce((a, b) => a + b) / weights.length;
    });

    return averageWeights;
  }

  // Calculate equipment performance over time
  Map<String, List<FlSpot>> _calculateEquipmentPerformance(
      List<LoggedExercise> exercises) {
    if (exercises.isEmpty) return {};

    // Group exercises by equipment and month
    final Map<String, Map<int, List<double>>> equipmentData = {};
    final earliestDate =
        exercises.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);

    for (final exercise in exercises) {
      // Skip exercises without weight data
      if (exercise.weight == null) continue;

      final monthsFromStart =
          exercise.date.difference(earliestDate).inDays ~/ 30;

      // Filter by muscle group if selected
      if (selectedMuscleGroup != 'All Muscles' &&
          !exercise.targetMuscles.contains(selectedMuscleGroup)) {
        continue;
      }

      equipmentData[exercise.equipment] =
          equipmentData[exercise.equipment] ?? {};
      equipmentData[exercise.equipment]![monthsFromStart] =
          (equipmentData[exercise.equipment]![monthsFromStart] ?? [])
            ..add(exercise.weight!);
    }

    // Convert to FlSpot data
    final Map<String, List<FlSpot>> result = {};
    equipmentData.forEach((equipment, monthlyData) {
      final spots = <FlSpot>[];
      final sortedMonths = monthlyData.keys.toList()..sort();

      for (final month in sortedMonths) {
        final weights = monthlyData[month]!;
        final avgWeight = weights.reduce((a, b) => a + b) / weights.length;
        spots.add(FlSpot(month.toDouble(), avgWeight));
      }

      result[equipment] = spots;
    });

    return result;
  }

  // Calculate improvement percentages for equipment
  Map<String, double> _calculateEquipmentImprovement(
      List<LoggedExercise> exercises) {
    if (exercises.isEmpty) return {};

    final Map<String, double> improvements = {};
    final equipmentGroups = <String, List<LoggedExercise>>{};

    // Group exercises by equipment
    for (final exercise in exercises) {
      // Skip exercises without weight data
      if (exercise.weight == null) continue;

      // Filter by muscle group if selected
      if (selectedMuscleGroup != 'All Muscles' &&
          !exercise.targetMuscles.contains(selectedMuscleGroup)) {
        continue;
      }

      equipmentGroups[exercise.equipment] =
          (equipmentGroups[exercise.equipment] ?? [])..add(exercise);
    }

    // Calculate improvement for each equipment
    equipmentGroups.forEach((equipment, exerciseList) {
      if (exerciseList.length < 2) {
        improvements[equipment] = 0.0;
        return;
      }

      // Sort by date
      exerciseList.sort((a, b) => a.date.compareTo(b.date));

      // Take first and last quarters for comparison
      final quarterSize = math.max(1, exerciseList.length ~/ 4);
      final firstQuarter = exerciseList.take(quarterSize).toList();
      final lastQuarter =
          exerciseList.skip(exerciseList.length - quarterSize).toList();

      final firstAvg =
          firstQuarter.map((e) => e.weight!).reduce((a, b) => a + b) /
              firstQuarter.length;
      final lastAvg =
          lastQuarter.map((e) => e.weight!).reduce((a, b) => a + b) /
              lastQuarter.length;

      if (firstAvg > 0) {
        improvements[equipment] = ((lastAvg - firstAvg) / firstAvg) * 100;
      } else {
        improvements[equipment] = 0.0;
      }
    });

    return improvements;
  }

  // Calculate total cardio metrics
  Map<String, double> _calculateCardioTotals(List<LoggedExercise> exercises) {
    double totalDistance = 0;
    double totalDuration = 0;
    double totalCalories = 0;

    for (final exercise in exercises) {
      if (exercise.isCardio) {
        totalDistance += exercise.distance ?? 0;
        totalDuration += exercise.duration?.inMinutes.toDouble() ?? 0;
        totalCalories += exercise.calories ?? 0;
      }
    }

    return {
      'distance': totalDistance,
      'duration': totalDuration,
      'calories': totalCalories,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Tracker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Time period filters
            TimePeriodFilter(
              timePeriods: timePeriods,
              selectedTimePeriod: selectedTimePeriod,
              onTimePeriodChanged: (period) =>
                  setState(() => selectedTimePeriod = period),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Consumer<WorkoutProvider>(
                builder: (context, workoutProvider, child) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Records Dashboard
                        const PersonalRecordsDashboard(),
                        const SizedBox(height: 32),

                        // Muscle Group Progress Section
                        _buildMuscleGroupProgressSection(workoutProvider),
                        const SizedBox(height: 32),

                        // Cardio Performance Section
                        _buildCardioPerformanceSection(workoutProvider),
                        const SizedBox(height: 32),

                        // Equipment Performance Section
                        _buildEquipmentPerformanceSection(workoutProvider),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleGroupProgressSection(WorkoutProvider workoutProvider) {
    final filteredExercises =
        _filterExercisesByTime(workoutProvider.loggedExercises);
    final muscleGroupCounts = _calculateMuscleGroupCounts(filteredExercises);
    final muscleGroupWeights = _calculateMuscleGroupWeights(filteredExercises);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Muscle Group Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Text('Spider View'),
                const SizedBox(width: 8),
                Switch(
                  value: isSpiderView,
                  onChanged: (value) => setState(() => isSpiderView = value),
                  activeColor: const Color(0xFF1B2027),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Metric toggle
        ProgressMetricToggle(
          showWeightProgress: showWeightProgress,
          onToggle: (value) => setState(() => showWeightProgress = value),
        ),
        const SizedBox(height: 16),

        // Chart container
        Container(
          height: 300,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2027),
            borderRadius: BorderRadius.circular(12),
          ),
          child: filteredExercises.isEmpty
              ? const Center(
                  child: Text(
                    'No exercise data available\nStart logging workouts to see progress!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : MuscleGroupProgressChart(
                  muscleGroupCounts: muscleGroupCounts,
                  muscleGroupWeights: muscleGroupWeights,
                  showWeightProgress: showWeightProgress,
                  isSpiderView: isSpiderView,
                ),
        ),

        // Add helpful message when spider view is selected but insufficient data
        if (isSpiderView &&
            filteredExercises.isNotEmpty &&
            (showWeightProgress ? muscleGroupWeights : muscleGroupCounts)
                    .length <
                3) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing Bar Chart: Spider view needs 3+ muscle groups. Log exercises targeting different muscles!',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCardioPerformanceSection(WorkoutProvider workoutProvider) {
    final filteredExercises =
        _filterExercisesByTime(workoutProvider.loggedExercises);
    final cardioTotals = _calculateCardioTotals(filteredExercises);

    // Only show the section if there is cardio data
    if (cardioTotals.values.every((v) => v == 0)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cardio Performance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Distance',
                value: '${cardioTotals['distance']!.toStringAsFixed(1)} km',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Total Duration',
                value: '${cardioTotals['duration']!.toStringAsFixed(0)} min',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StatCard(
          title: 'Total Calories Burned',
          value: '${cardioTotals['calories']!.toStringAsFixed(0)} kcal',
        ),
      ],
    );
  }

  Widget _buildEquipmentPerformanceSection(WorkoutProvider workoutProvider) {
    final filteredExercises =
        _filterExercisesByTime(workoutProvider.loggedExercises);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Equipment Performance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Muscle Group and Equipment selectors
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Muscle Group',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedMuscleGroup,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    underline: Container(),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() => selectedMuscleGroup = newValue!);
                    },
                    items: muscleGroupOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Equipment',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedEquipment,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    underline: Container(),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() => selectedEquipment = newValue!);
                    },
                    items: equipmentOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Line chart
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2027),
            borderRadius: BorderRadius.circular(12),
          ),
          child: filteredExercises.isEmpty
              ? const Center(
                  child: Text(
                    'No exercise data available\nStart logging workouts to see trends!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                )
              : EquipmentPerformanceChart(
                  equipmentData:
                      _calculateEquipmentPerformance(filteredExercises),
                  selectedEquipment: selectedEquipment,
                ),
        ),
        const SizedBox(height: 16),

        // Equipment list with improvements for selected muscle group
        EquipmentImprovementList(
          equipmentImprovement:
              _calculateEquipmentImprovement(filteredExercises),
          selectedMuscleGroup: selectedMuscleGroup,
        ),
      ],
    );
  }
}
