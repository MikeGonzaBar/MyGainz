import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/units_provider.dart';
import '../utils/date_helpers.dart';
import '../models/workout_set.dart';
import '../utils/equipment_options.dart';
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
      child: InkWell(
        onTap: showEditButton ? () => _showEditDialog(context) : null,
        borderRadius: BorderRadius.circular(8),
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
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14),
                      ),
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
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Edit ${routine.name}'),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: SingleChildScrollView(
              child: Column(
                children: routine.exercises.map((exercise) {
                  return _buildExerciseEditCard(context, exercise);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseEditCard(BuildContext context, LoggedExercise exercise) {
    final unitsProvider = Provider.of<UnitsProvider>(context, listen: false);

    // Convert stored weight (kg) to display weight for the current unit
    double? displayWeight = exercise.averageWeight;
    if (displayWeight != null && unitsProvider.weightUnit == 'lbs') {
      displayWeight = displayWeight / 0.453592; // Convert kg to lbs
    }

    final weightController =
        TextEditingController(text: displayWeight?.toStringAsFixed(1) ?? '');
    final repsController =
        TextEditingController(text: exercise.averageReps?.toString() ?? '');
    final setsController =
        TextEditingController(text: exercise.totalSets.toString());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showIndividualSetsEditDialog(context, exercise),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.exerciseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer<UnitsProvider>(
                      builder: (context, unitsProvider, child) {
                        // Convert stored weight (kg) to display weight for current unit
                        double? displayWeight = exercise.averageWeight;
                        if (displayWeight != null &&
                            unitsProvider.weightUnit == 'lbs') {
                          displayWeight =
                              displayWeight / 0.453592; // Convert kg to lbs
                        }

                        return Text(
                          '${displayWeight?.toStringAsFixed(1) ?? 'N/A'}${unitsProvider.weightUnit} × ${exercise.averageReps ?? 'N/A'} reps, ${exercise.totalSets} sets',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () =>
                        _showDeleteExerciseDialog(context, exercise),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIndividualSetsEditDialog(
      BuildContext context, LoggedExercise exercise) {
    // If exercise has individual sets, use them; otherwise create from legacy data
    List<TextEditingController> weightControllers = [];
    List<TextEditingController> repsControllers = [];
    String selectedEquipment = exercise.equipment;
    final unitsProvider = Provider.of<UnitsProvider>(context, listen: false);

    if (exercise.individualSets != null &&
        exercise.individualSets!.isNotEmpty) {
      // Initialize controllers with existing set data (convert from kg to display unit)
      for (int i = 0; i < exercise.individualSets!.length; i++) {
        final set = exercise.individualSets![i];
        double displayWeight = set.weight; // Stored in kg
        if (unitsProvider.weightUnit == 'lbs') {
          displayWeight = displayWeight / 0.453592; // Convert kg to lbs
        }
        weightControllers
            .add(TextEditingController(text: displayWeight.toStringAsFixed(1)));
        repsControllers.add(TextEditingController(text: set.reps.toString()));
      }
    } else {
      // Fall back to legacy data - create sets based on totalSets
      double avgWeight = exercise.averageWeight ?? 0.0;
      if (unitsProvider.weightUnit == 'lbs') {
        avgWeight = avgWeight / 0.453592; // Convert kg to lbs for display
      }
      final avgReps = exercise.averageReps ?? 0;
      final totalSets = exercise.totalSets;

      for (int i = 0; i < totalSets; i++) {
        weightControllers
            .add(TextEditingController(text: avgWeight.toStringAsFixed(1)));
        repsControllers.add(TextEditingController(text: avgReps.toString()));
      }
    }

    final equipmentOptions = EquipmentOptions.basic;

    // Function to safely dispose all controllers
    void disposeAllControllers() {
      try {
        for (int i = 0; i < weightControllers.length; i++) {
          weightControllers[i].dispose();
        }
        for (int i = 0; i < repsControllers.length; i++) {
          repsControllers[i].dispose();
        }
        weightControllers.clear();
        repsControllers.clear();
      } catch (e) {
        print('Controller disposal error (ignored): $e');
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit ${exercise.exerciseName}'),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: Column(
                  children: [
                    // Equipment dropdown
                    DropdownButtonFormField<String>(
                      value: equipmentOptions.contains(selectedEquipment)
                          ? selectedEquipment
                          : equipmentOptions.first,
                      decoration: const InputDecoration(
                        labelText: 'Equipment',
                        border: OutlineInputBorder(),
                      ),
                      items: equipmentOptions.map((equipment) {
                        return DropdownMenuItem(
                          value: equipment,
                          child: Text(equipment),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedEquipment = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Sets list
                    Expanded(
                      child: ListView.builder(
                        itemCount: weightControllers.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Set number
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B2027),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Weight field
                                  Expanded(
                                    child: TextField(
                                      controller: weightControllers[index],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Weight',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Reps field
                                  Expanded(
                                    child: TextField(
                                      controller: repsControllers[index],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Reps',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),

                                  // Delete set button (only show if more than 1 set)
                                  if (weightControllers.length > 1) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          weightControllers[index].dispose();
                                          repsControllers[index].dispose();
                                          weightControllers.removeAt(index);
                                          repsControllers.removeAt(index);
                                        });
                                      },
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      iconSize: 20,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Add set button
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            weightControllers.add(TextEditingController());
                            repsControllers.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Set'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1B2027),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    disposeAllControllers();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Dismiss keyboard first
                    FocusScope.of(context).unfocus();

                    // Add small delay to ensure keyboard dismissal
                    await Future.delayed(const Duration(milliseconds: 100));

                    // Validate and collect sets data
                    List<WorkoutSetData> newSets = [];
                    final unitsProvider =
                        Provider.of<UnitsProvider>(context, listen: false);

                    for (int i = 0; i < weightControllers.length; i++) {
                      final weight = double.tryParse(weightControllers[i].text);
                      final reps = int.tryParse(repsControllers[i].text);

                      if (weight != null &&
                          reps != null &&
                          weight > 0 &&
                          reps > 0) {
                        // Convert weight to kg (base unit) for storage
                        double weightInKg = weight;
                        if (unitsProvider.weightUnit == 'lbs') {
                          weightInKg = weight * 0.453592; // Convert lbs to kg
                        }

                        newSets.add(WorkoutSetData(
                          weight: weightInKg, // Always store in kg
                          reps: reps,
                          setNumber: i + 1,
                        ));
                      }
                    }

                    if (newSets.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please enter valid weight and reps for at least one set'),
                        ),
                      );
                      return;
                    }

                    // Update exercise with new individual sets
                    try {
                      final workoutProvider =
                          Provider.of<WorkoutProvider>(context, listen: false);
                      await workoutProvider.updateLoggedExerciseWithSets(
                        exercise.id,
                        individualSets: newSets,
                        equipment: selectedEquipment,
                      );

                      disposeAllControllers();

                      if (context.mounted) {
                        Navigator.pop(context); // Close individual sets dialog
                        Navigator.pop(context); // Close routine edit dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${exercise.exerciseName} updated successfully!'),
                          ),
                        );
                      }
                    } catch (e) {
                      print('Error updating exercise sets: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error updating exercise: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2027),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
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
