import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
    'Dumbbells',
    'Barbells',
    'Machines',
    'Cables',
  ];
  final List<String> muscleGroupOptions = [
    'All Muscles',
    'Chest',
    'Back',
    'Legs',
    'Arms',
    'Shoulders',
    'Core',
  ];

  // Dummy data for muscle groups
  final Map<String, double> muscleGroupExerciseCount = {
    'Chest': 45,
    'Back': 38,
    'Legs': 52,
    'Arms': 34,
    'Shoulders': 28,
    'Core': 31,
    'Glutes': 25,
    'Calves': 18,
  };

  final Map<String, double> muscleGroupWeightProgress = {
    'Chest': 85.5,
    'Back': 92.0,
    'Legs': 120.0,
    'Arms': 67.5,
    'Shoulders': 45.0,
    'Core': 25.0,
    'Glutes': 78.0,
    'Calves': 35.0,
  };

  // Updated equipment performance data by muscle group
  final Map<String, Map<String, List<FlSpot>>> equipmentPerformanceByMuscle = {
    'Chest': {
      'Dumbbells': [
        FlSpot(0, 25),
        FlSpot(1, 30),
        FlSpot(2, 35),
        FlSpot(3, 32),
        FlSpot(4, 40),
        FlSpot(5, 47),
        FlSpot(6, 50),
      ],
      'Barbells': [
        FlSpot(0, 50),
        FlSpot(1, 55),
        FlSpot(2, 52),
        FlSpot(3, 58),
        FlSpot(4, 65),
        FlSpot(5, 70),
        FlSpot(6, 75),
      ],
      'Machines': [
        FlSpot(0, 35),
        FlSpot(1, 40),
        FlSpot(2, 43),
        FlSpot(3, 45),
        FlSpot(4, 50),
        FlSpot(5, 55),
        FlSpot(6, 60),
      ],
      'Cables': [
        FlSpot(0, 20),
        FlSpot(1, 25),
        FlSpot(2, 30),
        FlSpot(3, 33),
        FlSpot(4, 37),
        FlSpot(5, 40),
        FlSpot(6, 43),
      ],
    },
    'Back': {
      'Dumbbells': [
        FlSpot(0, 30),
        FlSpot(1, 35),
        FlSpot(2, 40),
        FlSpot(3, 38),
        FlSpot(4, 45),
        FlSpot(5, 52),
        FlSpot(6, 55),
      ],
      'Barbells': [
        FlSpot(0, 60),
        FlSpot(1, 65),
        FlSpot(2, 62),
        FlSpot(3, 68),
        FlSpot(4, 75),
        FlSpot(5, 80),
        FlSpot(6, 85),
      ],
      'Machines': [
        FlSpot(0, 45),
        FlSpot(1, 50),
        FlSpot(2, 53),
        FlSpot(3, 55),
        FlSpot(4, 60),
        FlSpot(5, 65),
        FlSpot(6, 70),
      ],
      'Cables': [
        FlSpot(0, 25),
        FlSpot(1, 30),
        FlSpot(2, 35),
        FlSpot(3, 38),
        FlSpot(4, 42),
        FlSpot(5, 45),
        FlSpot(6, 48),
      ],
    },
    'Legs': {
      'Dumbbells': [
        FlSpot(0, 40),
        FlSpot(1, 45),
        FlSpot(2, 50),
        FlSpot(3, 48),
        FlSpot(4, 55),
        FlSpot(5, 62),
        FlSpot(6, 65),
      ],
      'Barbells': [
        FlSpot(0, 80),
        FlSpot(1, 85),
        FlSpot(2, 82),
        FlSpot(3, 88),
        FlSpot(4, 95),
        FlSpot(5, 100),
        FlSpot(6, 105),
      ],
      'Machines': [
        FlSpot(0, 60),
        FlSpot(1, 65),
        FlSpot(2, 68),
        FlSpot(3, 70),
        FlSpot(4, 75),
        FlSpot(5, 80),
        FlSpot(6, 85),
      ],
      'Cables': [
        FlSpot(0, 30),
        FlSpot(1, 35),
        FlSpot(2, 40),
        FlSpot(3, 43),
        FlSpot(4, 47),
        FlSpot(5, 50),
        FlSpot(6, 53),
      ],
    },
    'Arms': {
      'Dumbbells': [
        FlSpot(0, 15),
        FlSpot(1, 20),
        FlSpot(2, 25),
        FlSpot(3, 23),
        FlSpot(4, 30),
        FlSpot(5, 37),
        FlSpot(6, 40),
      ],
      'Barbells': [
        FlSpot(0, 30),
        FlSpot(1, 35),
        FlSpot(2, 32),
        FlSpot(3, 38),
        FlSpot(4, 45),
        FlSpot(5, 50),
        FlSpot(6, 55),
      ],
      'Machines': [
        FlSpot(0, 25),
        FlSpot(1, 30),
        FlSpot(2, 33),
        FlSpot(3, 35),
        FlSpot(4, 40),
        FlSpot(5, 45),
        FlSpot(6, 50),
      ],
      'Cables': [
        FlSpot(0, 10),
        FlSpot(1, 15),
        FlSpot(2, 20),
        FlSpot(3, 23),
        FlSpot(4, 27),
        FlSpot(5, 30),
        FlSpot(6, 33),
      ],
    },
    'Shoulders': {
      'Dumbbells': [
        FlSpot(0, 10),
        FlSpot(1, 15),
        FlSpot(2, 20),
        FlSpot(3, 18),
        FlSpot(4, 25),
        FlSpot(5, 32),
        FlSpot(6, 35),
      ],
      'Barbells': [
        FlSpot(0, 20),
        FlSpot(1, 25),
        FlSpot(2, 22),
        FlSpot(3, 28),
        FlSpot(4, 35),
        FlSpot(5, 40),
        FlSpot(6, 45),
      ],
      'Machines': [
        FlSpot(0, 15),
        FlSpot(1, 20),
        FlSpot(2, 23),
        FlSpot(3, 25),
        FlSpot(4, 30),
        FlSpot(5, 35),
        FlSpot(6, 40),
      ],
      'Cables': [
        FlSpot(0, 8),
        FlSpot(1, 12),
        FlSpot(2, 17),
        FlSpot(3, 20),
        FlSpot(4, 24),
        FlSpot(5, 27),
        FlSpot(6, 30),
      ],
    },
    'Core': {
      'Dumbbells': [
        FlSpot(0, 5),
        FlSpot(1, 8),
        FlSpot(2, 12),
        FlSpot(3, 10),
        FlSpot(4, 15),
        FlSpot(5, 20),
        FlSpot(6, 23),
      ],
      'Barbells': [
        FlSpot(0, 10),
        FlSpot(1, 15),
        FlSpot(2, 12),
        FlSpot(3, 18),
        FlSpot(4, 25),
        FlSpot(5, 30),
        FlSpot(6, 35),
      ],
      'Machines': [
        FlSpot(0, 8),
        FlSpot(1, 12),
        FlSpot(2, 15),
        FlSpot(3, 17),
        FlSpot(4, 22),
        FlSpot(5, 27),
        FlSpot(6, 32),
      ],
      'Cables': [
        FlSpot(0, 3),
        FlSpot(1, 7),
        FlSpot(2, 12),
        FlSpot(3, 15),
        FlSpot(4, 19),
        FlSpot(5, 22),
        FlSpot(6, 25),
      ],
    },
  };

  // Equipment performance data (fallback for 'All Muscles')
  final Map<String, List<FlSpot>> equipmentPerformanceData = {
    'Dumbbells': [
      FlSpot(0, 20),
      FlSpot(1, 25),
      FlSpot(2, 30),
      FlSpot(3, 28),
      FlSpot(4, 35),
      FlSpot(5, 42),
      FlSpot(6, 45),
    ],
    'Barbells': [
      FlSpot(0, 40),
      FlSpot(1, 45),
      FlSpot(2, 42),
      FlSpot(3, 48),
      FlSpot(4, 55),
      FlSpot(5, 60),
      FlSpot(6, 65),
    ],
    'Machines': [
      FlSpot(0, 30),
      FlSpot(1, 35),
      FlSpot(2, 38),
      FlSpot(3, 40),
      FlSpot(4, 45),
      FlSpot(5, 50),
      FlSpot(6, 55),
    ],
    'Cables': [
      FlSpot(0, 15),
      FlSpot(1, 20),
      FlSpot(2, 25),
      FlSpot(3, 28),
      FlSpot(4, 32),
      FlSpot(5, 35),
      FlSpot(6, 38),
    ],
  };

  // Equipment improvement by muscle group
  final Map<String, Map<String, double>> equipmentImprovementByMuscle = {
    'Chest': {
      'Dumbbells': 18.0,
      'Barbells': 12.0,
      'Machines': 15.0,
      'Cables': 20.0,
    },
    'Back': {
      'Dumbbells': 16.0,
      'Barbells': 10.0,
      'Machines': 13.0,
      'Cables': 18.0,
    },
    'Legs': {
      'Dumbbells': 14.0,
      'Barbells': 8.0,
      'Machines': 11.0,
      'Cables': 16.0,
    },
    'Arms': {
      'Dumbbells': 22.0,
      'Barbells': 15.0,
      'Machines': 18.0,
      'Cables': 25.0,
    },
    'Shoulders': {
      'Dumbbells': 24.0,
      'Barbells': 20.0,
      'Machines': 22.0,
      'Cables': 28.0,
    },
    'Core': {
      'Dumbbells': 30.0,
      'Barbells': 25.0,
      'Machines': 28.0,
      'Cables': 35.0,
    },
  };

  final Map<String, double> equipmentImprovement = {
    'Dumbbells': 15.0,
    'Barbells': 8.0,
    'Machines': 12.0,
    'Cables': 10.0,
  };

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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Muscle Group Progress Section
                    _buildMuscleGroupProgressSection(),
                    const SizedBox(height: 32),

                    // Equipment Performance Section
                    _buildEquipmentPerformanceSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePeriodFilter() {
    return Row(
      children:
          timePeriods.map((period) {
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

  Widget _buildMuscleGroupProgressSection() {
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
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => showWeightProgress = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        !showWeightProgress
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
                      color:
                          !showWeightProgress ? Colors.white : Colors.black87,
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
                    color:
                        showWeightProgress
                            ? const Color(0xFF1B2027)
                            : Colors.grey.shade200,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Weight Progress (kg)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: showWeightProgress ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
          child: isSpiderView ? _buildSpiderChart() : _buildBarChart(),
        ),
      ],
    );
  }

  Widget _buildSpiderChart() {
    final data =
        showWeightProgress
            ? muscleGroupWeightProgress
            : muscleGroupExerciseCount;
    final maxValue = data.values.reduce(math.max);

    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            fillColor: Colors.orange.withOpacity(0.3),
            borderColor: Colors.orange,
            borderWidth: 2,
            dataEntries:
                data.entries.map((entry) {
                  return RadarEntry(value: entry.value / maxValue * 100);
                }).toList(),
          ),
        ],
        radarShape: RadarShape.polygon,
        tickCount: 5,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
        getTitle: (index, angle) {
          final titles = data.keys.toList();
          return RadarChartTitle(text: titles[index], angle: angle);
        },
        gridBorderData: const BorderSide(color: Colors.white24, width: 1),
        tickBorderData: const BorderSide(color: Colors.white24, width: 1),
        radarBorderData: const BorderSide(color: Colors.white24, width: 1),
        ticksTextStyle: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
    );
  }

  Widget _buildBarChart() {
    final data =
        showWeightProgress
            ? muscleGroupWeightProgress
            : muscleGroupExerciseCount;
    final maxValue = data.values.reduce(math.max);

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
                final titles = data.keys.toList();
                if (value.toInt() < titles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      titles[value.toInt()],
                      style: const TextStyle(color: Colors.white, fontSize: 10),
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
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
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
        barGroups:
            data.entries.map((entry) {
              final index = data.keys.toList().indexOf(entry.key);
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
  }

  Widget _buildEquipmentPerformanceSection() {
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
                    items:
                        muscleGroupOptions.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
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
                    items:
                        equipmentOptions.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
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
          child: _buildEquipmentLineChart(),
        ),
        const SizedBox(height: 16),

        // Equipment list with improvements for selected muscle group
        _buildEquipmentListForMuscleGroup(),
      ],
    );
  }

  Widget _buildEquipmentLineChart() {
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
                return Text(
                  '${value.toInt()}kg',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                ];
                if (value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  );
                }
                return const Text('');
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
        lineBarsData: _getEquipmentLineData(),
      ),
    );
  }

  List<LineChartBarData> _getEquipmentLineData() {
    // Get data based on selected muscle group
    final Map<String, List<FlSpot>> currentData =
        selectedMuscleGroup == 'All Muscles'
            ? equipmentPerformanceData
            : equipmentPerformanceByMuscle[selectedMuscleGroup] ??
                equipmentPerformanceData;

    if (selectedEquipment == 'All Equipment') {
      // Show all equipment lines for the selected muscle group
      return currentData.entries.map((entry) {
        Color lineColor;
        switch (entry.key) {
          case 'Dumbbells':
            lineColor = Colors.blue;
            break;
          case 'Barbells':
            lineColor = Colors.green;
            break;
          case 'Machines':
            lineColor = Colors.purple;
            break;
          case 'Cables':
            lineColor = Colors.orange;
            break;
          default:
            lineColor = Colors.white;
        }

        return LineChartBarData(
          spots: entry.value,
          isCurved: true,
          color: lineColor,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        );
      }).toList();
    } else {
      // Show selected equipment only for the selected muscle group
      final data = currentData[selectedEquipment] ?? [];
      return [
        LineChartBarData(
          spots: data,
          isCurved: true,
          color: Colors.orange,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.orange.withOpacity(0.2),
          ),
        ),
      ];
    }
  }

  Widget _buildEquipmentListForMuscleGroup() {
    // Get the appropriate equipment data based on selected muscle group
    final Map<String, List<FlSpot>> currentData =
        selectedMuscleGroup == 'All Muscles'
            ? equipmentPerformanceData
            : equipmentPerformanceByMuscle[selectedMuscleGroup] ??
                equipmentPerformanceData;

    final Map<String, double> currentImprovement =
        selectedMuscleGroup == 'All Muscles'
            ? equipmentImprovement
            : equipmentImprovementByMuscle[selectedMuscleGroup] ??
                equipmentImprovement;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedMuscleGroup != 'All Muscles') ...[
          Text(
            'Performance for ${selectedMuscleGroup}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
        ],
        ...currentData.keys.map(
          (equipment) => _buildEquipmentItem(equipment, currentImprovement),
        ),
      ],
    );
  }

  Widget _buildEquipmentItem(
    String equipment,
    Map<String, double> improvementData,
  ) {
    Color dotColor;
    switch (equipment) {
      case 'Dumbbells':
        dotColor = Colors.blue;
        break;
      case 'Barbells':
        dotColor = Colors.green;
        break;
      case 'Machines':
        dotColor = Colors.purple;
        break;
      case 'Cables':
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
            '+${improvementData[equipment]?.toStringAsFixed(0) ?? '0'}%',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
