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
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onModeChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isExerciseMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isExerciseMode
                      ? Border.all(color: Colors.grey.shade300)
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 32,
                      color: isExerciseMode ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Single\nExercise',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isExerciseMode ? Colors.black : Colors.grey,
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
                padding: const EdgeInsets.symmetric(vertical: 26),
                decoration: BoxDecoration(
                  color: !isExerciseMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: !isExerciseMode
                      ? Border.all(color: Colors.grey.shade300)
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.checklist,
                      size: 32,
                      color: !isExerciseMode ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Routine',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !isExerciseMode ? Colors.black : Colors.grey,
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
