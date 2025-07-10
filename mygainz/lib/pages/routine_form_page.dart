import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/routine.dart';

class RoutineFormPage extends StatefulWidget {
  final bool isEditing;
  final Routine? routine;
  final List<Exercise> availableExercises;
  final Function(Map<String, dynamic>) onSave;

  const RoutineFormPage({
    super.key,
    required this.isEditing,
    this.routine,
    required this.availableExercises,
    required this.onSave,
  });

  @override
  State<RoutineFormPage> createState() => _RoutineFormPageState();
}

class _RoutineFormPageState extends State<RoutineFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _orderIsRequired = false;
  final List<Exercise> _selectedExercises = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.routine != null) {
      // Pre-fill form with routine data
      _nameController.text = widget.routine!.name;
      _orderIsRequired = widget.routine!.orderIsRequired;

      // Convert exerciseIds to Exercise objects
      for (String exerciseId in widget.routine!.exerciseIds) {
        final exercise = widget.availableExercises.firstWhere(
          (ex) => ex.id == exerciseId,
          orElse: () => Exercise(
            id: exerciseId,
            userId: 'user1',
            exerciseName: 'Unknown Exercise',
            targetMuscles: ['Unknown'],
            equipment: ['Unknown'],
          ),
        );
        _selectedExercises.add(exercise);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final routineData = {
        'name': _nameController.text,
        'orderIsRequired': _orderIsRequired,
        'exerciseIds': _selectedExercises.map((e) => e.id).toList(),
      };

      widget.onSave(routineData);
    }
  }

  void _toggleExercise(Exercise exercise) {
    setState(() {
      if (_selectedExercises.any((e) => e.id == exercise.id)) {
        _selectedExercises.removeWhere((e) => e.id == exercise.id);
      } else {
        _selectedExercises.add(exercise);
      }
    });
  }

  // Get the appropriate muscle group icon path based on target muscles
  String _getMuscleIconPath(List<String> targetMuscles) {
    if (targetMuscles.isEmpty) return 'assets/icons/muscles/Chest.png';

    // Priority mapping - use the first muscle that matches
    final muscleIconMap = {
      'Chest': 'assets/icons/muscles/Chest.png',
      'Back': 'assets/icons/muscles/Back.png',
      'Biceps': 'assets/icons/muscles/Biceps.png',
      'Triceps': 'assets/icons/muscles/Triceps.png',
      'Shoulders': 'assets/icons/muscles/Shoulder.png',
      'Quads': 'assets/icons/muscles/Thigh.png',
      'Hamstrings': 'assets/icons/muscles/Hamstrings.png',
      'Glutes': 'assets/icons/muscles/butt.png',
      'Calves': 'assets/icons/muscles/Calves.png',
      'Abs': 'assets/icons/muscles/Abs.png',
      'Lower Back': 'assets/icons/muscles/Back.png',
      'Obliques': 'assets/icons/muscles/Abs.png',
    };

    // Return the first matching muscle group icon
    for (final muscle in targetMuscles) {
      if (muscleIconMap.containsKey(muscle)) {
        return muscleIconMap[muscle]!;
      }
    }

    // Default fallback
    return 'assets/icons/muscles/Chest.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2027),
        foregroundColor: Colors.white,
        title: Text(widget.isEditing ? 'Edit Routine' : 'Add new Routine'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Routine Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Routine Name',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Order Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order switch',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: _orderIsRequired,
                    onChanged: (value) {
                      setState(() {
                        _orderIsRequired = value;
                      });
                    },
                    activeColor: const Color(0xFF1B2027),
                  ),
                ],
              ),
              Text(
                _orderIsRequired
                    ? 'Exercises must be performed in order'
                    : 'Exercises can be performed in any order',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Selected Exercises Section
              const Text(
                'Selected Exercises',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_selectedExercises.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('No exercises selected'),
                )
              else
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Routine name and exercise count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _nameController.text.isEmpty
                                  ? 'New Routine'
                                  : _nameController.text,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Selected exercises
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedExercises
                              .map(
                                (exercise) =>
                                    _buildSelectedExerciseTile(exercise),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Add Exercise Button
              OutlinedButton.icon(
                onPressed: () {
                  _showExerciseSelectionDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Exercise'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B2027),
                  side: const BorderSide(color: Color(0xFF1B2027)),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2027),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.isEditing ? 'Save Routine' : 'Save Routine',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExerciseSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState /* this is the dialog's setState */) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF9FAFB),
              title: const Text('Select Exercises'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.availableExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = widget.availableExercises[index];
                    final isSelected = _selectedExercises.any(
                      (e) => e.id == exercise.id,
                    );
                    return CheckboxListTile(
                      title: Text(exercise.exerciseName),
                      subtitle: Text(exercise.targetMuscles.join(', ')),
                      value: isSelected,
                      activeColor: const Color(0xFF1B2027),
                      checkColor: Colors.white,
                      onChanged: (bool? value) {
                        // first update the dialog's state so the checkbox redraws immediately
                        setState(() {
                          if (isSelected) {
                            _selectedExercises.removeWhere(
                              (e) => e.id == exercise.id,
                            );
                          } else {
                            _selectedExercises.add(exercise);
                          }
                        });
                        // then call the parent's setState so the card below the form also updates
                        this.setState(() {});
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1B2027),
                  ),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSelectedExerciseTile(Exercise exercise) {
    return Container(
      width: 85,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Muscle group icon
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: Image.asset(
                    _getMuscleIconPath(exercise.targetMuscles),
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.fitness_center,
                        size: 28,
                        color: Colors.grey.shade600,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                // Exercise name with better formatting
                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Remove button
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => _toggleExercise(exercise),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
