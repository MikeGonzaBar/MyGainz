import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/units_provider.dart';

class ProgressMetricToggle extends StatelessWidget {
  final bool showWeightProgress;
  final ValueChanged<bool> onToggle;

  const ProgressMetricToggle({
    super.key,
    required this.showWeightProgress,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UnitsProvider>(
      builder: (context, unitsProvider, child) {
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onToggle(false),
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
                onTap: () => onToggle(true),
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
                      color: showWeightProgress ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
