import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../utils/muscle_group_options.dart';

class ExerciseFormPage extends StatefulWidget {
  final bool isEditing;
  final Exercise? exercise;
  final Function(Map<String, dynamic>) onSave;

  const ExerciseFormPage({
    super.key,
    required this.isEditing,
    this.exercise,
    required this.onSave,
  });

  @override
  State<ExerciseFormPage> createState() => _ExerciseFormPageState();
}

class _ExerciseFormPageState extends State<ExerciseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<String> _selectedMuscles = [];
  final List<String> _selectedEquipment = [];
  ExerciseType _exerciseType = ExerciseType.strength;

  // Cardio metrics state
  bool _hasDistance = false;
  bool _hasDuration = true; // Default for most cardio
  bool _hasPace = false;
  bool _hasCalories = true; // Default for most cardio
  String? _primaryMetric;

  // Available options
  final List<String> _allMuscles = MuscleGroupOptions.all;
  final List<String> _equipment = [
    'Barbell',
    'Dumbbell',
    'Machine',
    'Cable',
    'Bodyweight',
    'Kettlebell',
    'Resistance Band',
    'Pull-up bar',
    'None',
    'Rack',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.exercise != null) {
      // Pre-fill form with exercise data
      _nameController.text = widget.exercise!.exerciseName;
      _exerciseType = widget.exercise!.exerciseType;

      if (_exerciseType == ExerciseType.strength) {
        _selectedMuscles.addAll(widget.exercise!.targetMuscles);
        _selectedEquipment.addAll(widget.exercise!.equipment);
      } else if (_exerciseType == ExerciseType.cardio &&
          widget.exercise!.cardioMetrics != null) {
        final metrics = widget.exercise!.cardioMetrics!;
        _hasDistance = metrics.hasDistance;
        _hasDuration = metrics.hasDuration;
        _hasPace = metrics.hasPace;
        _hasCalories = metrics.hasCalories;
        _primaryMetric = metrics.primaryMetric;
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
      final exerciseData = {
        'exerciseName': _nameController.text,
        'exerciseType': _exerciseType,
        'targetMuscles': _selectedMuscles,
        'equipment': _selectedEquipment,
        'cardioMetrics': _exerciseType == ExerciseType.cardio
            ? CardioMetrics(
                hasDistance: _hasDistance,
                hasDuration: _hasDuration,
                hasPace: _hasPace,
                hasCalories: _hasCalories,
                primaryMetric: _primaryMetric,
              )
            : null,
      };

      widget.onSave(exerciseData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2027),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.isEditing ? 'Edit Exercise' : 'Add new Exercise'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Name
              _buildTextField(
                controller: _nameController,
                labelText: 'Exercise Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an exercise name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Exercise Type Toggle
              _buildExerciseTypeToggle(),
              const SizedBox(height: 24),

              // Conditional UI based on exercise type
              if (_exerciseType == ExerciseType.strength)
                _buildStrengthSection()
              else
                _buildCardioSection(),

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
                    widget.isEditing ? 'Save Exercise' : 'Save Exercise',
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

  Widget _buildExerciseTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: _buildToggleButton(
            label: 'Strength',
            isSelected: _exerciseType == ExerciseType.strength,
            onPressed: () {
              setState(() => _exerciseType = ExerciseType.strength);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildToggleButton(
            label: 'Cardio',
            isSelected: _exerciseType == ExerciseType.cardio,
            onPressed: () {
              setState(() => _exerciseType = ExerciseType.cardio);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF1B2027) : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF1B2027),
        side: const BorderSide(color: Color(0xFF1B2027)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildStrengthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Target Muscles
        const Text(
          'Target Muscles',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allMuscles.map((muscle) {
            final isSelected = _selectedMuscles.contains(muscle);
            return _buildSelectionChip(
              label: muscle,
              isSelected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedMuscles.add(muscle);
                  } else {
                    _selectedMuscles.remove(muscle);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Equipment Needed
        const Text(
          'Equipment Needed',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _equipment.map((item) {
            final isSelected = _selectedEquipment.contains(item);
            return _buildSelectionChip(
              label: item,
              isSelected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedEquipment.add(item);
                  } else {
                    _selectedEquipment.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCardioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cardio Metrics to Track',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildMetricSwitch(
          title: 'Distance (e.g., km, miles)',
          value: _hasDistance,
          onChanged: (value) => setState(() => _hasDistance = value),
        ),
        _buildMetricSwitch(
          title: 'Duration (e.g., minutes)',
          value: _hasDuration,
          onChanged: (value) => setState(() => _hasDuration = value),
        ),
        _buildMetricSwitch(
          title: 'Pace (e.g., min/km)',
          value: _hasPace,
          onChanged: (value) => setState(() => _hasPace = value),
        ),
        _buildMetricSwitch(
          title: 'Calories Burned',
          value: _hasCalories,
          onChanged: (value) => setState(() => _hasCalories = value),
        ),
      ],
    );
  }

  Widget _buildMetricSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF1B2027),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSelectionChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF1B2027),
      backgroundColor: Colors.grey.shade200,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
