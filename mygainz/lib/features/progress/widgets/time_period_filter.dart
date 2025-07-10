import 'package:flutter/material.dart';

class TimePeriodFilter extends StatelessWidget {
  final List<String> timePeriods;
  final String selectedTimePeriod;
  final ValueChanged<String> onTimePeriodChanged;

  const TimePeriodFilter({
    super.key,
    required this.timePeriods,
    required this.selectedTimePeriod,
    required this.onTimePeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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
                  onTimePeriodChanged(period);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
