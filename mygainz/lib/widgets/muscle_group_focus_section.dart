import 'package:flutter/material.dart';
import '../providers/workout_provider.dart';
import 'muscle_group_progress_item.dart';

class MuscleGroupFocusSection extends StatelessWidget {
  final WorkoutProvider workoutProvider;
  final Map<String, Map<String, dynamic>> muscleGroupFocus;

  const MuscleGroupFocusSection({
    super.key,
    required this.workoutProvider,
    required this.muscleGroupFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Muscle Group Focus',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (workoutProvider.loggedExercises.isNotEmpty)
              Text(
                '${workoutProvider.loggedExercises.length} exercises',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (workoutProvider.loggedExercises.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Focus area unknown...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start lifting and we\'ll show you the way!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ...muscleGroupFocus.entries.map(
            (entry) => MuscleGroupProgressItem(
              muscleName: entry.key,
              percentage: entry.value['percentage'],
              color: entry.value['color'],
              exercises: workoutProvider.loggedExercises,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Based on your logged exercises. Percentages show relative focus on each muscle group.',
                    style: TextStyle(
                      color: Colors.blue.shade800,
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
}
