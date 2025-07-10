import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/units_provider.dart';
import 'dart:math' as math;

class MuscleGroupProgressChart extends StatelessWidget {
  final Map<String, double> muscleGroupCounts;
  final Map<String, double> muscleGroupWeights;
  final bool showWeightProgress;
  final bool isSpiderView;

  const MuscleGroupProgressChart({
    super.key,
    required this.muscleGroupCounts,
    required this.muscleGroupWeights,
    required this.showWeightProgress,
    required this.isSpiderView,
  });

  @override
  Widget build(BuildContext context) {
    final data = showWeightProgress ? muscleGroupWeights : muscleGroupCounts;

    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return (isSpiderView && data.length >= 3)
        ? _buildSpiderChart(data)
        : _buildBarChart(data);
  }

  Widget _buildSpiderChart(Map<String, double> data) {
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

  Widget _buildBarChart(Map<String, double> data) {
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
}
