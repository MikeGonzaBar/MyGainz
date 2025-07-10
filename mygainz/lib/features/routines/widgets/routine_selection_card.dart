import 'package:flutter/material.dart';
import '../../exercises/models/exercise.dart';
import '../models/routine.dart';

class RoutineSelectionCard extends StatelessWidget {
  final Routine routine;
  final List<Exercise> availableExercises;
  final VoidCallback onTap;

  const RoutineSelectionCard({
    super.key,
    required this.routine,
    required this.availableExercises,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      routine.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      routine.orderIsRequired
                          ? Icons.format_list_numbered
                          : Icons.shuffle,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  routine.orderIsRequired
                      ? 'Exercises must be performed in order'
                      : 'Exercises can be performed in any order',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Text(
                  '${routine.exerciseIds.length} exercises',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: routine.exerciseIds
                      .map((exerciseId) => _buildMiniExerciseTile(exerciseId))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniExerciseTile(String exerciseId) {
    final exercise = availableExercises.firstWhere(
      (ex) => ex.id == exerciseId,
      orElse: () => Exercise(
        id: exerciseId,
        userId: 'user1',
        exerciseName: 'Unknown Exercise',
        targetMuscles: ['Unknown'],
        equipment: ['Unknown'],
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(exercise.exerciseName, style: const TextStyle(fontSize: 12)),
    );
  }
}
