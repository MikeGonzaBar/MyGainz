import 'package:flutter/material.dart';
import '../providers/workout_provider.dart';

class MuscleGroupProgressItem extends StatelessWidget {
  final String muscleName;
  final double percentage;
  final Color color;
  final List<LoggedExercise> exercises;

  const MuscleGroupProgressItem({
    super.key,
    required this.muscleName,
    required this.percentage,
    required this.color,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    // Count exercises for this muscle group
    final exerciseCount = exercises
        .where((exercise) => exercise.targetMuscles.contains(muscleName))
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                muscleName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$exerciseCount exercises',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${percentage.toInt()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
