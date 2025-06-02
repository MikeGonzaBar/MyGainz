import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../utils/date_helpers.dart';
import 'muscle_icon.dart';

class RoutineCard extends StatelessWidget {
  final LoggedRoutine routine;
  final bool showEditButton;

  const RoutineCard({
    super.key,
    required this.routine,
    this.showEditButton = false,
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please enter valid numbers for all fields'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B2027),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Update Exercise'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
