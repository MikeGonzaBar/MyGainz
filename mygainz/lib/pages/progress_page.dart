import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/units_provider.dart';
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
      for (final muscle in exercise.targetMuscles) {
        weightsByMuscle[muscle] = (weightsByMuscle[muscle] ?? [])
          ..add(exercise.weight);
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
            ..add(exercise.weight);
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
          firstQuarter.map((e) => e.weight).reduce((a, b) => a + b) /
              firstQuarter.length;
      final lastAvg = lastQuarter.map((e) => e.weight).reduce((a, b) => a + b) /
          lastQuarter.length;

      if (firstAvg > 0) {
        improvements[equipment] = ((lastAvg - firstAvg) / firstAvg) * 100;
      } else {
        improvements[equipment] = 0.0;
      }
    });

    return improvements;
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
            _buildTimePeriodFilter(),
            const SizedBox(height: 24),

            Expanded(
              child: Consumer<WorkoutProvider>(
                builder: (context, workoutProvider, child) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Muscle Group Progress Section
                        _buildMuscleGroupProgressSection(workoutProvider),
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

  Widget _buildTimePeriodFilter() {
    return Row(
      children: timePeriods.map((period) {
        final isSelected = selectedTimePeriod == period;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(period),
            selected: isSelected,
            selectedColor: const Color(0xFF1B2027),
            backgroundColor: Colors.grey.shade200,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() => selectedTimePeriod = period);
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }).toList(),
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
        Consumer<UnitsProvider>(
          builder: (context, unitsProvider, child) {
            return Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showWeightProgress = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !showWeightProgress
                            ? const Color(0xFF1B2027)
                            : Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Times Exercised',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !showWeightProgress
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showWeightProgress = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: showWeightProgress
                            ? const Color(0xFF1B2027)
                            : Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Weight Progress (${unitsProvider.weightUnit})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: showWeightProgress
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
              : (isSpiderView &&
                      (showWeightProgress
                                  ? muscleGroupWeights
                                  : muscleGroupCounts)
                              .length >=
                          3)
                  ? _buildSpiderChart(muscleGroupCounts, muscleGroupWeights)
                  : _buildBarChart(muscleGroupCounts, muscleGroupWeights),
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

  Widget _buildSpiderChart(Map<String, double> muscleGroupCounts,
      Map<String, double> muscleGroupWeights) {
    final data = showWeightProgress ? muscleGroupWeights : muscleGroupCounts;

    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    // Radar chart requires at least 3 data points
    if (data.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.white70,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Spider View requires at least 3 muscle groups',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Log more diverse exercises to unlock this view!',
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Current: ${data.length} muscle groups',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      );
    }

    final maxValue = data.values.reduce(math.max);
    if (maxValue == 0) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return Consumer<UnitsProvider>(
      builder: (context, unitsProvider, child) {
        // Convert weights if needed
        final displayData = <String, double>{};
        data.forEach((muscle, value) {
          if (showWeightProgress) {
            displayData[muscle] = unitsProvider.convertWeight(value);
          } else {
            displayData[muscle] = value;
          }
        });

        final displayMaxValue = displayData.values.reduce(math.max);

        return RadarChart(
          RadarChartData(
            dataSets: [
              RadarDataSet(
                fillColor: Colors.orange.withValues(alpha: 0.3),
                borderColor: Colors.orange,
                borderWidth: 2,
                dataEntries: displayData.entries.map((entry) {
                  return RadarEntry(value: entry.value / displayMaxValue * 100);
                }).toList(),
              ),
            ],
            radarShape: RadarShape.polygon,
            tickCount: 5,
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
            getTitle: (index, angle) {
              final titles = displayData.keys.toList();
              return RadarChartTitle(text: titles[index], angle: angle);
            },
            gridBorderData: const BorderSide(color: Colors.white24, width: 1),
            tickBorderData: const BorderSide(color: Colors.white24, width: 1),
            radarBorderData: const BorderSide(color: Colors.white24, width: 1),
            ticksTextStyle:
                const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        );
      },
    );
  }

  Widget _buildBarChart(Map<String, double> muscleGroupCounts,
      Map<String, double> muscleGroupWeights) {
    final data = showWeightProgress ? muscleGroupWeights : muscleGroupCounts;

    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return Consumer<UnitsProvider>(
      builder: (context, unitsProvider, child) {
        // Convert weights if needed
        final displayData = <String, double>{};
        data.forEach((muscle, value) {
          if (showWeightProgress) {
            displayData[muscle] = unitsProvider.convertWeight(value);
          } else {
            displayData[muscle] = value;
          }
        });

        if (displayData.isEmpty) {
          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }

        final maxValue = displayData.values.reduce(math.max);

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxValue * 1.2,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final titles = displayData.keys.toList();
                    if (value.toInt() < titles.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          titles[value.toInt()],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxValue / 5,
              getDrawingHorizontalLine: (value) {
                return const FlLine(color: Colors.white24, strokeWidth: 1);
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: displayData.entries.map((entry) {
              final index = displayData.keys.toList().indexOf(entry.key);
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    color: Colors.orange,
                    width: 16,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
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
              : _buildEquipmentLineChart(filteredExercises),
        ),
        const SizedBox(height: 16),

        // Equipment list with improvements for selected muscle group
        _buildEquipmentListForMuscleGroup(filteredExercises),
      ],
    );
  }

  Widget _buildEquipmentLineChart(List<LoggedExercise> exercises) {
    final equipmentData = _calculateEquipmentPerformance(exercises);

    if (equipmentData.isEmpty) {
      return const Center(
        child: Text(
          'No performance data available',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );
    }

    return Consumer<UnitsProvider>(
      builder: (context, unitsProvider, child) {
        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 10,
              getDrawingHorizontalLine: (value) {
                return const FlLine(color: Colors.white24, strokeWidth: 1);
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final displayValue = unitsProvider.convertWeight(value);
                    return Text(
                      '${displayValue.toInt()}${unitsProvider.weightUnit}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    // Show month indicators
                    return Text(
                      'M${value.toInt() + 1}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: _getEquipmentLineData(equipmentData, unitsProvider),
          ),
        );
      },
    );
  }

  List<LineChartBarData> _getEquipmentLineData(
      Map<String, List<FlSpot>> equipmentData, UnitsProvider unitsProvider) {
    if (selectedEquipment == 'All Equipment') {
      // Show all equipment lines
      return equipmentData.entries.map((entry) {
        Color lineColor;
        switch (entry.key) {
          case 'Dumbbell':
            lineColor = Colors.blue;
            break;
          case 'Barbell':
            lineColor = Colors.green;
            break;
          case 'Machine':
            lineColor = Colors.purple;
            break;
          case 'Kettlebell':
            lineColor = Colors.orange;
            break;
          default:
            lineColor = Colors.white;
        }

        // Convert weights to display units
        final convertedSpots = entry.value.map((spot) {
          return FlSpot(spot.x, unitsProvider.convertWeight(spot.y));
        }).toList();

        return LineChartBarData(
          spots: convertedSpots,
          isCurved: true,
          color: lineColor,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        );
      }).toList();
    } else {
      // Show selected equipment only
      final data = equipmentData[selectedEquipment] ?? [];
      if (data.isEmpty) return [];

      // Convert weights to display units
      final convertedSpots = data.map((spot) {
        return FlSpot(spot.x, unitsProvider.convertWeight(spot.y));
      }).toList();

      return [
        LineChartBarData(
          spots: convertedSpots,
          isCurved: true,
          color: Colors.orange,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.orange.withValues(alpha: 0.2),
          ),
        ),
      ];
    }
  }

  Widget _buildEquipmentListForMuscleGroup(List<LoggedExercise> exercises) {
    final equipmentImprovement = _calculateEquipmentImprovement(exercises);

    if (equipmentImprovement.isEmpty) {
      return const Text(
        'No equipment data available for the selected filters.',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedMuscleGroup != 'All Muscles') ...[
          Text(
            'Performance for $selectedMuscleGroup',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
        ],
        ...equipmentImprovement.entries.map(
          (entry) => _buildEquipmentItem(entry.key, entry.value),
        ),
      ],
    );
  }

  Widget _buildEquipmentItem(String equipment, double improvement) {
    Color dotColor;
    switch (equipment) {
      case 'Dumbbell':
        dotColor = Colors.blue;
        break;
      case 'Barbell':
        dotColor = Colors.green;
        break;
      case 'Machine':
        dotColor = Colors.purple;
        break;
      case 'Kettlebell':
        dotColor = Colors.orange;
        break;
      default:
        dotColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              equipment,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${improvement >= 0 ? '+' : ''}${improvement.toStringAsFixed(1)}%',
            style: TextStyle(
              color: improvement >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
