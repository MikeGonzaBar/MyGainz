import 'package:flutter/material.dart';
import 'exercise_page.dart';

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
  String _selectedCategory = 'Upper Body';
  final List<String> _selectedMuscles = [];
  final List<String> _selectedEquipment = [];

  // Available options
  final List<String> _categories = ['Upper Body', 'Lower Body', 'Core'];
  final Map<String, List<String>> _musclesByCategory = {
    'Upper Body': ['Chest', 'Back', 'Biceps', 'Triceps', 'Shoulders'],
    'Lower Body': ['Quads', 'Hamstrings', 'Glutes', 'Calves'],
    'Core': ['Abs', 'Lower Back', 'Obliques'],
  };
  final List<String> _equipment = [
    'Barbell',
    'Dumbbell',
    'Machine',
    'Cable',
    'Bodyweight',
    'Kettlebell',
    'Resistance Band',
    'None',
    'Rack',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.exercise != null) {
      // Pre-fill form with exercise data
      _nameController.text = widget.exercise!.name;
      _selectedCategory = widget.exercise!.category;
      _selectedMuscles.addAll(widget.exercise!.muscleGroups);
      _selectedEquipment.addAll(widget.exercise!.equipment);
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
        'name': _nameController.text,
        'category': _selectedCategory,
        'muscleGroups': _selectedMuscles,
        'equipment': _selectedEquipment,
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

              // Category
              const Text(
                'Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDropdown(),
              const SizedBox(height: 24),

              // Target Muscles
              const Text(
                'Target Muscles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _getMusclesForCategory().map((muscle) {
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
              TextButton.icon(
                onPressed: () {
                  // Add more muscles (would open a dialog or another page)
                },
                icon: const Icon(Icons.add),
                label: const Text('Add More'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1B2027),
                ),
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
                children:
                    _equipment.take(5).map((item) {
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
              TextButton.icon(
                onPressed: () {
                  // Show more equipment options
                },
                icon: const Icon(Icons.add),
                label: const Text('Add More'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1B2027),
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

  List<String> _getMusclesForCategory() {
    return _musclesByCategory[_selectedCategory] ?? [];
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          hint: const Text('Select Category'),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategory = newValue;
                // Clear selected muscles when category changes
                _selectedMuscles.clear();
              });
            }
          },
          items:
              _categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
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
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
