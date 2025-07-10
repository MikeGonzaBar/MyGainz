import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/units_provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout_set.dart';
import '../../../core/utils/date_helpers.dart';
import '../utils/equipment_options.dart';

class ExerciseCard extends StatelessWidget {
  final LoggedExercise exercise;
  final bool showEditButton;
  final VoidCallback? onDelete;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.showEditButton = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UnitsProvider>(
      builder: (context, unitsProvider, child) {
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
                    children: [
                      // Exercise name - make it flexible to prevent overflow
                      Expanded(
                        child: Text(
                          exercise.exerciseName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Right side content - wrap in a constrained container
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Equipment type
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              exercise.equipment,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Sets
                          Text(
                            '${exercise.totalSets}x',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),

                          if (onDelete != null) ...[
                            const SizedBox(width: 2),
                            IconButton(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete, color: Colors.red),
                              iconSize: 18,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Muscle groups
                  Text(
                    exercise.targetMuscles.join(', '),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  _buildExerciseStats(context, unitsProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseStats(
      BuildContext context, UnitsProvider unitsProvider) {
    Widget statsWidget;
    if (exercise.isStrength) {
      statsWidget = _buildStrengthStats(unitsProvider);
    } else if (exercise.isCardio) {
      statsWidget = _buildCardioStats(unitsProvider);
    } else {
      statsWidget = const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(child: statsWidget),
        const SizedBox(width: 8),
        Text(
          DateHelpers.formatShortDate(exercise.date),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStrengthStats(UnitsProvider unitsProvider) {
    return Row(
      children: [
        _buildStatChip(
          exercise.averageWeight != null
              ? unitsProvider.formatWeight(exercise.averageWeight!)
              : 'N/A',
          Icons.fitness_center,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          '${exercise.averageReps ?? 0} reps',
          Icons.repeat,
        ),
      ],
    );
  }

  Widget _buildCardioStats(UnitsProvider unitsProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (exercise.distance != null && exercise.distance! > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildStatChip(
                unitsProvider.formatDistance(exercise.distance!),
                Icons.directions_run,
              ),
            ),
          if (exercise.duration != null && exercise.duration!.inMinutes > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildStatChip(
                '${exercise.duration!.inMinutes} min',
                Icons.timer_outlined,
              ),
            ),
          if (exercise.calories != null && exercise.calories! > 0)
            _buildStatChip(
              '${exercise.calories} kcal',
              Icons.local_fire_department_outlined,
            ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    if (exercise.isStrength) {
      _showEditStrengthDialog(context);
    } else if (exercise.isCardio) {
      _showEditCardioDialog(context);
    }
  }

  void _showEditStrengthDialog(BuildContext context) {
    // If exercise has individual sets, show individual sets editor
    if (exercise.individualSets != null &&
        exercise.individualSets!.isNotEmpty) {
      _showIndividualSetsEditDialog(context);
    } else {
      // Fall back to simple editor for legacy data
      _showSimpleStrengthEditDialog(context);
    }
  }

  void _showIndividualSetsEditDialog(BuildContext context) {
    // Create controllers for each set
    List<TextEditingController> weightControllers = [];
    List<TextEditingController> repsControllers = [];
    String selectedEquipment = exercise.equipment;
    final unitsProvider = Provider.of<UnitsProvider>(context, listen: false);

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
        // Ignore disposal errors
        if (kDebugMode) {
          print('Controller disposal error (ignored): $e');
        }
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              disposeAllControllers();
            }
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Edit ${exercise.exerciseName}'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Equipment selector
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
                            if (value != null) {
                              setState(() {
                                selectedEquipment = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Individual sets editor
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.fitness_center,
                                      color: Colors.blue.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Individual Sets',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Add set button
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        weightControllers
                                            .add(TextEditingController());
                                        repsControllers
                                            .add(TextEditingController());
                                      });
                                    },
                                    icon: Icon(Icons.add,
                                        color: Colors.green.shade600),
                                    iconSize: 20,
                                    tooltip: 'Add Set',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Sets list
                              ...List.generate(weightControllers.length,
                                  (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      // Set number
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade800,
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
                                              // Safely dispose the specific controllers
                                              try {
                                                weightControllers[index]
                                                    .dispose();
                                                repsControllers[index]
                                                    .dispose();
                                              } catch (e) {
                                                // Ignore disposal errors
                                              }
                                              weightControllers.removeAt(index);
                                              repsControllers.removeAt(index);
                                            });
                                          },
                                          icon: Icon(Icons.delete,
                                              color: Colors.red.shade600),
                                          iconSize: 20,
                                          tooltip: 'Remove Set',
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
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

                      // Store provider references before async operation
                      final unitsProvider =
                          Provider.of<UnitsProvider>(context, listen: false);
                      final workoutProvider =
                          Provider.of<WorkoutProvider>(context, listen: false);

                      // Add small delay to ensure keyboard dismissal
                      await Future.delayed(const Duration(milliseconds: 100));

                      // Validate and collect sets data
                      List<WorkoutSetData> newSets = [];

                      for (int i = 0; i < weightControllers.length; i++) {
                        final weight =
                            double.tryParse(weightControllers[i].text);
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
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please enter valid weight and reps for at least one set'),
                            ),
                          );
                        }
                        return;
                      }

                      // Update exercise with new individual sets
                      try {
                        await workoutProvider.updateLoggedExerciseWithSets(
                          exercise.id,
                          individualSets: newSets,
                          equipment: selectedEquipment,
                        );

                        // Dispose controllers and close dialog
                        disposeAllControllers();

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${exercise.exerciseName} updated successfully!'),
                            ),
                          );
                        }
                      } catch (e) {
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
          ),
        );
      },
    );
  }

  void _showSimpleStrengthEditDialog(BuildContext context) {
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
    String selectedEquipment = exercise.equipment;

    final equipmentOptions = EquipmentOptions.basic;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit ${exercise.exerciseName}'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(width: 16),
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: setsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sets',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        if (value != null) {
                          setState(() {
                            selectedEquipment = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final weight = double.tryParse(weightController.text);
                    final reps = int.tryParse(repsController.text);
                    final sets = int.tryParse(setsController.text);

                    if (weight != null && reps != null && sets != null) {
                      // Convert weight to kg (base unit) for storage
                      double weightInKg = weight;
                      if (unitsProvider.weightUnit == 'lbs') {
                        weightInKg = weight * 0.453592; // Convert lbs to kg
                      }

                      final workoutProvider =
                          Provider.of<WorkoutProvider>(context, listen: false);
                      await workoutProvider.updateLoggedExercise(
                        exercise.id,
                        weight: weightInKg, // Always store in kg
                        reps: reps,
                        equipment: selectedEquipment,
                        sets: sets,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
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
                            content: Text(
                                'Please enter valid numbers for all fields'),
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

  void _showEditCardioDialog(BuildContext context) {
    final distanceController =
        TextEditingController(text: exercise.distance?.toString() ?? '');
    final durationController = TextEditingController(
        text: exercise.duration?.inMinutes.toString() ?? '');
    final caloriesController =
        TextEditingController(text: exercise.calories?.toString() ?? '');
    String selectedEquipment = exercise.equipment;
    final equipmentOptions = EquipmentOptions.cardio;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit ${exercise.exerciseName}'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: distanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Distance',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Calories',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedEquipment,
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
                        if (value != null) {
                          setState(() {
                            selectedEquipment = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final distance = double.tryParse(distanceController.text);
                    final duration = int.tryParse(durationController.text);
                    final calories = int.tryParse(caloriesController.text);

                    final workoutProvider =
                        Provider.of<WorkoutProvider>(context, listen: false);
                    await workoutProvider.updateLoggedExercise(
                      exercise.id,
                      distance: distance,
                      duration:
                          duration != null ? Duration(minutes: duration) : null,
                      calories: calories,
                      equipment: selectedEquipment,
                      sets: 1,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${exercise.exerciseName} updated successfully!'),
                        ),
                      );
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
}
