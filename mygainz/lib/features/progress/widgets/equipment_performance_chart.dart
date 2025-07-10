import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/units_provider.dart';

class EquipmentPerformanceChart extends StatelessWidget {
  final Map<String, List<FlSpot>> equipmentData;
  final String selectedEquipment;

  const EquipmentPerformanceChart({
    super.key,
    required this.equipmentData,
    required this.selectedEquipment,
  });

  @override
  Widget build(BuildContext context) {
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
}
