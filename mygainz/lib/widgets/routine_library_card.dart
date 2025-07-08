import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import 'exercise_tile.dart';

class RoutineLibraryCard extends StatelessWidget {
  final Routine routine;
  final List<Exercise> availableExercises;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const RoutineLibraryCard({
    super.key,
    required this.routine,
    required this.availableExercises,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    routine.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 20),
                        onPressed: onDelete,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: routine.exerciseIds
                  .map((id) => _buildExerciseTile(context, id))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTile(BuildContext context, String id) {
    try {
      final exercise = availableExercises.firstWhere((e) => e.id == id);
      return ExerciseTile(exercise: exercise);
    } catch (e) {
      // Exercise not found - show a placeholder
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, size: 16, color: Colors.red.shade600),
            const SizedBox(width: 4),
            Text(
              'Exercise not found',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade600,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      );
    }
  }
}
