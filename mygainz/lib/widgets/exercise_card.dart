import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/units_provider.dart';
import '../providers/workout_provider.dart';
import '../utils/date_helpers.dart';

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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Exercise name
                    Text(
                      exercise.exerciseName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        // Equipment type
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            exercise.equipment,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Sets
                        Text(
                          '${exercise.sets} sets',
                          style: TextStyle(color: Colors.grey.shade700),
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
          exercise.weight != null
              ? unitsProvider.formatWeight(exercise.weight!)
              : 'N/A',
          Icons.fitness_center,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          '${exercise.reps ?? 0} reps',
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
    final weightController =
        TextEditingController(text: exercise.weight?.toString() ?? '');
    final repsController =
        TextEditingController(text: exercise.reps?.toString() ?? '');
    final setsController =
        TextEditingController(text: exercise.sets.toString());
    String selectedEquipment = exercise.equipment;

    final equipmentOptions = [
      'Barbell',
      'Dumbbell',
      'Kettlebell',
      'Machine',
      'Bodyweight',
    ];

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
                    final weight = double.tryParse(weightController.text);
                    final reps = int.tryParse(repsController.text);
                    final sets = int.tryParse(setsController.text);

                    if (weight != null && reps != null && sets != null) {
                      final workoutProvider =
                          Provider.of<WorkoutProvider>(context, listen: false);
                      await workoutProvider.updateLoggedExercise(
                        exercise.id,
                        weight: weight,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please enter valid numbers for all fields'),
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

  void _showEditCardioDialog(BuildContext context) {
    final distanceController =
        TextEditingController(text: exercise.distance?.toString() ?? '');
    final durationController = TextEditingController(
        text: exercise.duration?.inMinutes.toString() ?? '');
    final caloriesController =
        TextEditingController(text: exercise.calories?.toString() ?? '');
    String selectedEquipment = exercise.equipment;
    final equipmentOptions = [
      'Treadmill',
      'Outdoor',
      'Track',
      'Pool',
      'Open Water',
      'Stationary Bike',
      'Road Bike',
      'Mountain Bike',
      'Spin Bike',
      'Stair Master',
      'Stepper',
      'Rowing Machine',
      'Water',
      'Elliptical'
    ];

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
