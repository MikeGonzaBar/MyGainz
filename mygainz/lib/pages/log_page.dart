import 'package:flutter/material.dart';

class Exercise {
  final String id; // Document ID
  final String userId;
  final String exerciseName;
  final List<String> targetMuscles;
  final List<String> equipment;

  Exercise({
    required this.id,
    required this.userId,
    required this.exerciseName,
    required this.targetMuscles,
    required this.equipment,
  });
}

class Routine {
  final String id; // Document ID
  final String userId;
  final String name;
  final bool orderIsRequired;
  final List<String> exerciseIds; // References to exercise document IDs

  Routine({
    required this.id,
    required this.userId,
    required this.name,
    required this.orderIsRequired,
    required this.exerciseIds,
  });
}

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  bool isExerciseMode = true;
  final TextEditingController _searchController = TextEditingController();
  String selectedEquipment = 'Barbell';
  List<WorkoutSet> sets = [WorkoutSet()];

  // Routine mode state variables
  Routine? selectedRoutine;
  Map<String, List<WorkoutSet>> routineExerciseSets = {};
  Map<String, String> routineExerciseEquipment = {};
  List<String> completedExercises = [];

  final List<String> equipmentOptions = [
    'Barbell',
    'Dumbbell',
    'Kettlebell',
    'Machine',
  ];

  // Available exercises to resolve exercise IDs
  final List<Exercise> availableExercises = [
    Exercise(
      id: '1',
      userId: 'user1',
      exerciseName: 'Bench Press',
      targetMuscles: ['Chest', 'Triceps'],
      equipment: ['Barbell', 'Dumbbell', 'Machine'],
    ),
    Exercise(
      id: '2',
      userId: 'user1',
      exerciseName: 'Pull-ups',
      targetMuscles: ['Back', 'Biceps'],
      equipment: ['Pull-up bar'],
    ),
    Exercise(
      id: '5',
      userId: 'user1',
      exerciseName: 'Rows',
      targetMuscles: ['Back'],
      equipment: ['Barbell'],
    ),
    Exercise(
      id: '6',
      userId: 'user1',
      exerciseName: 'Katana',
      targetMuscles: ['Back', 'Shoulders'],
      equipment: ['Cable'],
    ),
    Exercise(
      id: '7',
      userId: 'user1',
      exerciseName: 'Skull crusher',
      targetMuscles: ['Triceps'],
      equipment: ['Dumbbell'],
    ),
    Exercise(
      id: '8',
      userId: 'user1',
      exerciseName: 'Shoulder Press',
      targetMuscles: ['Shoulders'],
      equipment: ['Dumbbell'],
    ),
  ];

  // Dummy routines data
  final List<Routine> availableRoutines = [
    Routine(
      id: '1',
      userId: 'user1',
      name: 'Back / Tricep',
      orderIsRequired: false,
      exerciseIds: ['2', '5', '6', '7'],
    ),
    Routine(
      id: '2',
      userId: 'user1',
      name: 'Chest / Shoulders',
      orderIsRequired: true,
      exerciseIds: ['1', '8'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addSet() {
    setState(() {
      sets.add(WorkoutSet());
    });
  }

  void _removeSet(int index) {
    if (sets.length > 1) {
      setState(() {
        sets.removeAt(index);
      });
    }
  }

  void _saveExercise() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exercise saved!')));
  }

  // Routine mode helper methods
  void _selectRoutine(Routine routine) {
    setState(() {
      selectedRoutine = routine;
      routineExerciseSets.clear();
      routineExerciseEquipment.clear();
      completedExercises.clear();

      // Initialize sets and equipment for each exercise
      for (String exerciseId in routine.exerciseIds) {
        routineExerciseSets[exerciseId] = [WorkoutSet()];

        // Find the exercise and set default equipment
        final exercise = availableExercises.firstWhere(
          (ex) => ex.id == exerciseId,
          orElse:
              () => Exercise(
                id: exerciseId,
                userId: 'user1',
                exerciseName: 'Unknown Exercise',
                targetMuscles: ['Unknown'],
                equipment: ['Barbell'],
              ),
        );
        routineExerciseEquipment[exerciseId] = exercise.equipment.first;
      }
    });
  }

  void _addRoutineExerciseSet(String exerciseId) {
    setState(() {
      routineExerciseSets[exerciseId]?.add(WorkoutSet());
    });
  }

  void _removeRoutineExerciseSet(String exerciseId, int index) {
    if ((routineExerciseSets[exerciseId]?.length ?? 0) > 1) {
      setState(() {
        routineExerciseSets[exerciseId]?.removeAt(index);
      });
    }
  }

  void _toggleExerciseCompletion(String exerciseId) {
    setState(() {
      if (completedExercises.contains(exerciseId)) {
        completedExercises.remove(exerciseId);
      } else {
        completedExercises.add(exerciseId);
      }
    });
  }

  void _saveRoutineWorkout() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Routine workout saved!')));
  }

  Exercise? _getNextExercise() {
    if (selectedRoutine == null || !selectedRoutine!.orderIsRequired)
      return null;

    for (String exerciseId in selectedRoutine!.exerciseIds) {
      if (!completedExercises.contains(exerciseId)) {
        return availableExercises.firstWhere(
          (ex) => ex.id == exerciseId,
          orElse:
              () => Exercise(
                id: exerciseId,
                userId: 'user1',
                exerciseName: 'Unknown Exercise',
                targetMuscles: ['Unknown'],
                equipment: ['Barbell'],
              ),
        );
      }
    }
    return null;
  }

  Exercise _getExerciseById(String exerciseId) {
    return availableExercises.firstWhere(
      (ex) => ex.id == exerciseId,
      orElse:
          () => Exercise(
            id: exerciseId,
            userId: 'user1',
            exerciseName: 'Unknown Exercise',
            targetMuscles: ['Unknown'],
            equipment: ['Barbell'],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Log Workout',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _buildModeToggle(),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isExerciseMode) ...[
                      _buildExerciseSection(),
                    ] else ...[
                      _buildRoutineSection(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isExerciseMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isExerciseMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isExerciseMode
                          ? Border.all(color: Colors.grey.shade300)
                          : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 32,
                      color: isExerciseMode ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Single\nExercise',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isExerciseMode ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isExerciseMode = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: !isExerciseMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      !isExerciseMode
                          ? Border.all(color: Colors.grey.shade300)
                          : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.checklist,
                      size: 32,
                      color: !isExerciseMode ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Routine',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !isExerciseMode ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exercise Name',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search exercises...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Equipment',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                equipmentOptions.map((equipment) {
                  final isSelected = selectedEquipment == equipment;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(equipment),
                      selected: isSelected,
                      selectedColor: const Color(0xFF1B2027),
                      backgroundColor: Colors.grey.shade200,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedEquipment = equipment);
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextButton.icon(
              onPressed: _addSet,
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1B2027),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          return _buildSetWidget(index, set);
        }),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveExercise,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B2027),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save Exercise',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetWidget(int index, WorkoutSet set) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Set ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (sets.length > 1)
                IconButton(
                  onPressed: () => _removeSet(index),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight (kg)',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: set.weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reps',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: set.repsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineSection() {
    if (selectedRoutine == null) {
      return _buildRoutineSelection();
    } else {
      return _buildSelectedRoutineWorkout();
    }
  }

  Widget _buildRoutineSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Routine',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        ...availableRoutines.map((routine) => _buildRoutineCard(routine)),
        const SizedBox(height: 16),
        _buildCreateNewRoutineCard(),
      ],
    );
  }

  Widget _buildRoutineCard(Routine routine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _selectRoutine(routine),
          borderRadius: BorderRadius.circular(12),
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
                    Icon(
                      routine.orderIsRequired
                          ? Icons.format_list_numbered
                          : Icons.shuffle,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  routine.orderIsRequired
                      ? 'Exercises must be performed in order'
                      : 'Exercises can be performed in any order',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Text(
                  '${routine.exerciseIds.length} exercises',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      routine.exerciseIds
                          .map(
                            (exerciseId) => _buildMiniExerciseTile(exerciseId),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniExerciseTile(String exerciseId) {
    final exercise = _getExerciseById(exerciseId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(exercise.exerciseName, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildCreateNewRoutineCard() {
    return Card(
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to routine creation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigate to routine creation')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Colors.grey.shade600,
                size: 32,
              ),
              const SizedBox(width: 16),
              Text(
                'Create New Routine',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedRoutineWorkout() {
    final nextExercise = _getNextExercise();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Routine header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedRoutine!.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    selectedRoutine!.orderIsRequired
                        ? 'Ordered routine'
                        : 'Flexible order',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedRoutine = null;
                  routineExerciseSets.clear();
                  routineExerciseEquipment.clear();
                  completedExercises.clear();
                });
              },
              child: const Text('Change'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Progress indicator
        _buildProgressIndicator(),
        const SizedBox(height: 24),

        // Next exercise indicator (for strict order)
        if (selectedRoutine!.orderIsRequired && nextExercise != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2027).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_forward, color: Color(0xFF1B2027)),
                const SizedBox(width: 8),
                Text(
                  'Next: ${nextExercise.exerciseName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B2027),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Exercise list
        ...selectedRoutine!.exerciseIds.map(
          (exerciseId) => _buildRoutineExerciseCard(exerciseId),
        ),

        const SizedBox(height: 32),

        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveRoutineWorkout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B2027),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save Workout',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final completedCount = completedExercises.length;
    final totalCount = selectedRoutine!.exerciseIds.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '$completedCount/$totalCount exercises',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1B2027)),
        ),
      ],
    );
  }

  Widget _buildRoutineExerciseCard(String exerciseId) {
    final exercise = _getExerciseById(exerciseId);
    final isCompleted = completedExercises.contains(exerciseId);
    final nextExercise = _getNextExercise();
    final isNext =
        selectedRoutine!.orderIsRequired && nextExercise?.id == exerciseId;
    final isDisabled =
        selectedRoutine!.orderIsRequired &&
        nextExercise != null &&
        nextExercise.id != exerciseId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        color:
            isCompleted
                ? Colors.green.shade50
                : (isNext
                    ? const Color(0xFF1B2027).withOpacity(0.05)
                    : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isNext ? const Color(0xFF1B2027) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exerciseName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDisabled ? Colors.grey : Colors.black,
                          ),
                        ),
                        Text(
                          exercise.targetMuscles.join(', '),
                          style: TextStyle(
                            color:
                                isDisabled ? Colors.grey : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  else if (!isDisabled)
                    Checkbox(
                      value: false,
                      onChanged:
                          (value) => _toggleExerciseCompletion(exerciseId),
                      activeColor: const Color(0xFF1B2027),
                    ),
                ],
              ),

              if (!isDisabled) ...[
                const SizedBox(height: 16),

                // Equipment selection
                const Text(
                  'Equipment',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        exercise.equipment.map((equipment) {
                          final isSelected =
                              routineExerciseEquipment[exerciseId] == equipment;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(equipment),
                              selected: isSelected,
                              selectedColor: const Color(0xFF1B2027),
                              backgroundColor: Colors.grey.shade200,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    routineExerciseEquipment[exerciseId] =
                                        equipment;
                                  });
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Sets
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sets',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _addRoutineExerciseSet(exerciseId),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Set'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1B2027),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ...routineExerciseSets[exerciseId]!.asMap().entries.map((
                  entry,
                ) {
                  final index = entry.key;
                  final set = entry.value;
                  return _buildRoutineSetWidget(exerciseId, index, set);
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineSetWidget(String exerciseId, int index, WorkoutSet set) {
    final sets = routineExerciseSets[exerciseId]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Set ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (sets.length > 1)
                IconButton(
                  onPressed: () => _removeRoutineExerciseSet(exerciseId, index),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight (kg)',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: set.weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reps',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: set.repsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkoutSet {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController repsController = TextEditingController();

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}
