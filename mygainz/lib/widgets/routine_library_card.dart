import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import 'exercise_tile.dart';

class RoutineLibraryCard extends StatelessWidget {
  final Routine routine;
  final List<Exercise> availableExercises;
  final VoidCallback onEdit;

  const RoutineLibraryCard({
    super.key,
    required this.routine,
    required this.availableExercises,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: routine.exerciseIds
                  .map((id) => _buildExerciseTile(id))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTile(String id) {
    final exercise = availableExercises.firstWhere((e) => e.id == id);
    return ExerciseTile(exercise: exercise);
  }
}
