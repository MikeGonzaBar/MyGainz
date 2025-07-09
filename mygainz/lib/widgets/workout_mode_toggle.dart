import 'package:flutter/material.dart';

class WorkoutModeToggle extends StatelessWidget {
  final bool isExerciseMode;
  final ValueChanged<bool> onModeChanged;

  const WorkoutModeToggle({
    super.key,
    required this.isExerciseMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onModeChanged(true),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isExerciseMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isExerciseMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 18,
                      color: isExerciseMode
                          ? const Color(0xFF1B2027)
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Single Exercise',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isExerciseMode ? FontWeight.w600 : FontWeight.w500,
                        color: isExerciseMode
                            ? const Color(0xFF1B2027)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onModeChanged(false),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: !isExerciseMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: !isExerciseMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.checklist,
                      size: 18,
                      color: !isExerciseMode
                          ? const Color(0xFF1B2027)
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Routine',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            !isExerciseMode ? FontWeight.w600 : FontWeight.w500,
                        color: !isExerciseMode
                            ? const Color(0xFF1B2027)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
