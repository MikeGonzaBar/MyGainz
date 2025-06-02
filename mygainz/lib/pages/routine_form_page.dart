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
      width: 70,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getIconForExercise(exercise.exerciseName), size: 30),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  exercise.exerciseName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _toggleExercise(exercise),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForExercise(String exerciseName) {
    switch (exerciseName.toLowerCase()) {
      case 'bench press':
        return Icons.fitness_center;
      case 'pull-ups':
        return Icons.accessibility_new;
      case 'rows':
        return Icons.rowing;
      case 'katana':
        return Icons.sports_martial_arts;
      case 'skull crusher':
        return Icons.sports_gymnastics;
      case 'shoulder press':
        return Icons.fitness_center;
      default:
        return Icons.fitness_center;
    }
  }
}
