import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../utils/date_helpers.dart';
import 'muscle_icon.dart';

class RoutineCard extends StatelessWidget {
  final LoggedRoutine routine;
  final bool showEditButton;
  final VoidCallback? onDelete;

  const RoutineCard({
    super.key,
    required this.routine,
    this.showEditButton = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
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
                Row(
                  children: [
                    Text(
                      '${routine.exercises.length} exercises',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    if (showEditButton) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showEditDialog(context),
                        icon: const Icon(Icons.edit),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: const Color(0xFF1B2027),
                      ),
                    ],
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Muscle group icons
            Row(
              children: routine.targetMuscles
                  .map((muscle) => MuscleIcon(muscle: muscle))
                  .toList(),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateHelpers.formatShortDate(routine.date),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit ${routine.name}'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                children: routine.exercises.map((exercise) {
                  return _buildExerciseEditCard(context, exercise);
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExerciseEditCard(BuildContext context, LoggedExercise exercise) {
    final weightController =
        TextEditingController(text: exercise.weight.toString());
    final repsController =
        TextEditingController(text: exercise.reps.toString());
    final setsController =
        TextEditingController(text: exercise.sets.toString());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          exercise.exerciseName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${exercise.weight}kg × ${exercise.reps} reps, ${exercise.sets} sets',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: IconButton(
          onPressed: () => _showDeleteExerciseDialog(context, exercise),
          icon: const Icon(Icons.delete, color: Colors.red),
          iconSize: 20,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Weight',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: repsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: setsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Sets',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final weight = double.tryParse(weightController.text);
                      final reps = int.tryParse(repsController.text);
                      final sets = int.tryParse(setsController.text);

                      if (weight != null && reps != null && sets != null) {
                        final workoutProvider = Provider.of<WorkoutProvider>(
                            context,
                            listen: false);
                        await workoutProvider.updateLoggedRoutineExercise(
                          routine.id,
                          exercise.id,
                          weight: weight,
                          reps: reps,
                          sets: sets,
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${exercise.exerciseName} updated successfully!'),
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter valid numbers'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteExerciseDialog(
      BuildContext context, LoggedExercise exercise) {
    // Check if this routine is order-dependent
    final isOrderDependent = routine.orderIsRequired;
    final exerciseIndex =
        routine.exercises.indexWhere((e) => e.id == exercise.id);
    final exercisesAfter =
        exerciseIndex != -1 && exerciseIndex < routine.exercises.length - 1
            ? routine.exercises.skip(exerciseIndex + 1).toList()
            : <LoggedExercise>[];

    String warningMessage =
        'Are you sure you want to delete "${exercise.exerciseName}" from this routine?';

    if (isOrderDependent && exercisesAfter.isNotEmpty) {
      warningMessage +=
          '\n\nThis routine requires exercises to be performed in order. Deleting this exercise will also delete the following exercises:\n';
      for (final ex in exercisesAfter) {
        warningMessage += '• ${ex.exerciseName}\n';
      }
      warningMessage += '\nThis action cannot be undone.';
    } else {
      warningMessage += ' This action cannot be undone.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Exercise'),
          content: Text(warningMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final workoutProvider =
                    Provider.of<WorkoutProvider>(context, listen: false);

                if (isOrderDependent && exerciseIndex != -1) {
                  // Delete from this exercise onwards
                  await workoutProvider.deleteLoggedRoutineExercisesFromIndex(
                      routine.id, exerciseIndex);
                } else {
                  // Delete just this exercise
                  await workoutProvider.deleteLoggedRoutineExercise(
                      routine.id, exercise.id);
                }

                if (context.mounted) {
                  Navigator.of(context).pop(); // Close delete dialog
                  Navigator.of(context).pop(); // Close edit dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isOrderDependent &&
                              exercisesAfter.isNotEmpty
                          ? '${exercise.exerciseName} and ${exercisesAfter.length} following exercises deleted'
                          : '${exercise.exerciseName} deleted from routine'),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
