import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/units_provider.dart';
import '../providers/workout_provider.dart';

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

  // Exercise search state
  List<Exercise> filteredExercises = [];
  Exercise? selectedExercise;
  bool showSuggestions = false;
  final FocusNode _searchFocusNode = FocusNode();

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
    Exercise(
      id: '9',
      userId: 'user1',
      exerciseName: 'Squats',
      targetMuscles: ['Quads', 'Hamstrings', 'Glutes'],
      equipment: ['Barbell', 'Dumbbell'],
    ),
    Exercise(
      id: '10',
      userId: 'user1',
      exerciseName: 'Deadlift',
      targetMuscles: ['Back', 'Hamstrings', 'Glutes'],
      equipment: ['Barbell'],
    ),
    Exercise(
      id: '11',
      userId: 'user1',
      exerciseName: 'Bicep Curls',
      targetMuscles: ['Biceps'],
      equipment: ['Dumbbell', 'Barbell'],
    ),
    Exercise(
      id: '12',
      userId: 'user1',
      exerciseName: 'Overhead Press',
      targetMuscles: ['Shoulders', 'Triceps'],
      equipment: ['Barbell', 'Dumbbell'],
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
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        filteredExercises = [];
        showSuggestions = false;
      });
      return;
    }

    final filtered = availableExercises.where((exercise) {
      return exercise.exerciseName.toLowerCase().contains(query) ||
          exercise.targetMuscles
              .any((muscle) => muscle.toLowerCase().contains(query));
    }).toList();

    setState(() {
      filteredExercises = filtered;
      showSuggestions = true;
    });
  }

  void _onFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      // Delay hiding suggestions to allow for selection
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            showSuggestions = false;
          });
        }
      });
    } else {
      // When focus is gained, show suggestions if there's text
      if (_searchController.text.trim().isNotEmpty) {
        _onSearchChanged();
      }
    }
  }

  void _selectExercise(Exercise exercise) {
    print('_selectExercise called with: ${exercise.exerciseName}'); // Debug
    setState(() {
      selectedExercise = exercise;
      _searchController.text = exercise.exerciseName;
      showSuggestions = false;
      // Set default equipment for selected exercise
      if (exercise.equipment.isNotEmpty) {
        selectedEquipment = exercise.equipment.first;
      }
    });
    print('Exercise selected, unfocusing search field'); // Debug
    _searchFocusNode.unfocus();
  }

  void _createNewExercise() {
    final exerciseName = _searchController.text.trim();
    if (exerciseName.isEmpty) return;

    // Create a new exercise on-the-fly
    final newExercise = Exercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'user1',
      exerciseName: exerciseName,
      targetMuscles: ['General'], // Default muscle group
      equipment: [selectedEquipment],
    );

    setState(() {
      selectedExercise = newExercise;
      availableExercises.add(newExercise); // Add to available exercises
      showSuggestions = false;
    });
    _searchFocusNode.unfocus();
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

  void _saveExercise() async {
    if (selectedExercise == null && _searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select or enter an exercise name')),
      );
      return;
    }

    // Calculate average weight and reps from all sets
    double totalWeight = 0;
    int totalReps = 0;
    int validSets = 0;

    for (var set in sets) {
      final weight = double.tryParse(set.weightController.text);
      final reps = int.tryParse(set.repsController.text);

      if (weight != null && reps != null && weight > 0 && reps > 0) {
        totalWeight += weight;
        totalReps += reps;
        validSets++;
      }
    }

    if (validSets == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please enter valid weight and reps for at least one set')),
      );
      return;
    }

    final avgWeight = totalWeight / validSets;
    final avgReps = (totalReps / validSets).round();

    // Use selected exercise or create new one
    Exercise exerciseToLog = selectedExercise ??
        Exercise(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'user1',
          exerciseName: _searchController.text.trim(),
          targetMuscles: ['General'],
          equipment: [selectedEquipment],
        );

    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await workoutProvider.logExercise(
      exerciseId: exerciseToLog.id,
      exerciseName: exerciseToLog.exerciseName,
      targetMuscles: exerciseToLog.targetMuscles,
      weight: avgWeight,
      reps: avgReps,
      equipment: selectedEquipment,
      sets: validSets,
    );

    if (!mounted) return;

    // Clear the form
    _searchController.clear();
    setState(() {
      sets = [WorkoutSet()];
      selectedExercise = null;
      filteredExercises = [];
      showSuggestions = false;
    });

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Exercise logged successfully!')),
    );
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
          orElse: () => Exercise(
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

  void _saveRoutineWorkout() async {
    if (selectedRoutine == null) return;

    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    List<LoggedExercise> loggedExercises = [];

    // Convert routine exercises to logged exercises
    for (String exerciseId in selectedRoutine!.exerciseIds) {
      if (!completedExercises.contains(exerciseId)) continue;

      final exercise = _getExerciseById(exerciseId);
      final exerciseSets = routineExerciseSets[exerciseId] ?? [];

      // Calculate averages for this exercise
      double totalWeight = 0;
      int totalReps = 0;
      int validSets = 0;

      for (var set in exerciseSets) {
        final weight = double.tryParse(set.weightController.text);
        final reps = int.tryParse(set.repsController.text);

        if (weight != null && reps != null && weight > 0 && reps > 0) {
          totalWeight += weight;
          totalReps += reps;
          validSets++;
        }
      }

      if (validSets > 0) {
        final avgWeight = totalWeight / validSets;
        final avgReps = (totalReps / validSets).round();

        loggedExercises.add(LoggedExercise(
          id: DateTime.now().millisecondsSinceEpoch.toString() + exerciseId,
          exerciseId: exerciseId,
          exerciseName: exercise.exerciseName,
          targetMuscles: exercise.targetMuscles,
          weight: avgWeight,
          reps: avgReps,
          equipment: routineExerciseEquipment[exerciseId] ?? 'Unknown',
          sets: validSets,
          date: DateTime.now(),
        ));
      }
    }

    if (loggedExercises.isNotEmpty) {
      // Collect all target muscles from exercises
      Set<String> allTargetMuscles = {};
      for (var exercise in loggedExercises) {
        allTargetMuscles.addAll(exercise.targetMuscles);
      }

      await workoutProvider.logRoutine(
        routineId: selectedRoutine!.id,
        routineName: selectedRoutine!.name,
        targetMuscles: allTargetMuscles.toList(),
        exercises: loggedExercises,
      );

      if (!mounted) return;

      // Reset routine state
      setState(() {
        selectedRoutine = null;
        routineExerciseSets.clear();
        routineExerciseEquipment.clear();
        completedExercises.clear();
      });

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Routine workout saved successfully!')),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
            content:
                Text('Please complete at least one exercise with valid data')),
      );
    }
  }

  Exercise? _getNextExercise() {
    if (selectedRoutine == null || !selectedRoutine!.orderIsRequired) {
      return null;
    }

    for (String exerciseId in selectedRoutine!.exerciseIds) {
      if (!completedExercises.contains(exerciseId)) {
        return availableExercises.firstWhere(
          (ex) => ex.id == exerciseId,
          orElse: () => Exercise(
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
      orElse: () => Exercise(
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
                  border: isExerciseMode
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
                  border: !isExerciseMode
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
        Column(
          children: [
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                suffixIcon: selectedExercise != null
                    ? Icon(Icons.check_circle, color: Colors.green.shade600)
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                selectedExercise = null;
                                filteredExercises = [];
                                showSuggestions = false;
                              });
                            },
                          )
                        : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            // Suggestions dropdown
            if (showSuggestions && filteredExercises.isNotEmpty) ...[
              const SizedBox(height: 8),
              Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    physics: const ClampingScrollPhysics(),
                    itemCount: filteredExercises.length +
                        1, // +1 for "Create new" option
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      if (index == filteredExercises.length) {
                        // "Create new exercise" option
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: InkWell(
                            onTap: () {
                              print(
                                  'Creating new exercise: ${_searchController.text}'); // Debug
                              _createNewExercise();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.add, color: Colors.green),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Create "${_searchController.text}"',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Text(
                                          'New exercise',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final exercise = filteredExercises[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () {
                            print(
                                'Tapping on ${exercise.exerciseName}'); // Debug
                            _selectExercise(exercise);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.exerciseName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exercise.targetMuscles.join(', '),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 4,
                                  children: exercise.equipment
                                      .map((eq) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              eq,
                                              style:
                                                  const TextStyle(fontSize: 10),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            // Show "no results" when search has text but no matches
            if (showSuggestions &&
                filteredExercises.isEmpty &&
                _searchController.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: InkWell(
                      onTap: () {
                        print(
                            'Creating new exercise (no results): ${_searchController.text}'); // Debug
                        _createNewExercise();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: Colors.green),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create "${_searchController.text}"',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Text(
                                    'No existing exercises found - create new',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        // Selected exercise info
        if (selectedExercise != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedExercise!.exerciseName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      Text(
                        'Targets: ${selectedExercise!.targetMuscles.join(', ')}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedExercise = null;
                      _searchController.clear();
                    });
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),
        const Text(
          'Equipment',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: (selectedExercise?.equipment ?? equipmentOptions)
                .map((equipment) {
              final isSelected = selectedEquipment == equipment;
              final isAvailable = selectedExercise == null ||
                  selectedExercise!.equipment.contains(equipment);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(equipment),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1B2027),
                  backgroundColor:
                      isAvailable ? Colors.grey.shade200 : Colors.grey.shade100,
                  disabledColor: Colors.grey.shade100,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isAvailable ? Colors.black87 : Colors.grey.shade500),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: isAvailable
                      ? (selected) {
                          if (selected) {
                            setState(() => selectedEquipment = equipment);
                          }
                        }
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Sets',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ...sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          return _buildSetInput(set, index);
        }),
        const SizedBox(height: 12),
        // Add Set button below all sets
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addSet,
            icon: const Icon(Icons.add),
            label: const Text('Add Set'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1B2027),
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
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

  Widget _buildSetInput(WorkoutSet set, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
          Consumer<UnitsProvider>(
            builder: (context, unitsProvider, child) {
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weight (${unitsProvider.weightUnit})',
                          style: const TextStyle(
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
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
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
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
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
              );
            },
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
                  children: routine.exerciseIds
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
        onTap: () => _showCreateRoutineDialog(),
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

  void _showCreateRoutineDialog() {
    final nameController = TextEditingController();
    List<String> selectedExerciseIds = [];
    bool orderIsRequired = false; // Add order requirement state

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create New Routine'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Routine Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Order required switch
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Require Exercise Order',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  orderIsRequired
                                      ? 'Exercises must be performed in the specified order'
                                      : 'Exercises can be performed in any order',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: orderIsRequired,
                            onChanged: (value) {
                              setDialogState(() {
                                orderIsRequired = value;
                              });
                            },
                            activeColor: const Color(0xFF1B2027),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Select Exercises:'),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = availableExercises[index];
                          final isSelected =
                              selectedExerciseIds.contains(exercise.id);

                          return CheckboxListTile(
                            title: Text(exercise.exerciseName),
                            subtitle: Text(exercise.targetMuscles.join(', ')),
                            value: isSelected,
                            onChanged: (value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedExerciseIds.add(exercise.id);
                                } else {
                                  selectedExerciseIds.remove(exercise.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty ||
                        selectedExerciseIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please enter a name and select at least one exercise')),
                      );
                      return;
                    }

                    // Create new routine with order requirement
                    final newRoutine = Routine(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: 'user1', // Would use actual user ID
                      name: nameController.text.trim(),
                      orderIsRequired: orderIsRequired, // Use the switch value
                      exerciseIds: selectedExerciseIds,
                    );

                    setState(() {
                      availableRoutines.add(newRoutine);
                    });

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Routine "${newRoutine.name}" created successfully! '
                          '${orderIsRequired ? "(Order required)" : "(Flexible order)"}',
                        ),
                      ),
                    );
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
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
              color: const Color(0xFF1B2027).withValues(alpha: 0.1),
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
    final isDisabled = selectedRoutine!.orderIsRequired &&
        nextExercise != null &&
        nextExercise.id != exerciseId &&
        !isCompleted; // Don't disable if already completed

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: isCompleted
            ? Colors.green.shade50
            : (isNext
                ? const Color(0xFF1B2027).withValues(alpha: 0.05)
                : (isDisabled ? Colors.grey.shade100 : Colors.white)),
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
                        Row(
                          children: [
                            Text(
                              exercise.exerciseName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDisabled ? Colors.grey : Colors.black,
                              ),
                            ),
                            if (isDisabled) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.lock,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          exercise.targetMuscles.join(', '),
                          style: TextStyle(
                            color:
                                isDisabled ? Colors.grey : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        if (isDisabled)
                          Text(
                            'Complete previous exercises first',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
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
                      onChanged: (value) =>
                          _toggleExerciseCompletion(exerciseId),
                      activeColor: const Color(0xFF1B2027),
                    ),
                ],
              ),

              if (!isDisabled || isCompleted) ...[
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
                    children: exercise.equipment.map((equipment) {
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
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: !isCompleted
                              ? (selected) {
                                  if (selected) {
                                    setState(() {
                                      routineExerciseEquipment[exerciseId] =
                                          equipment;
                                    });
                                  }
                                }
                              : null,
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
                    if (!isCompleted)
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
                  return _buildRoutineSetWidget(
                      exerciseId, index, set, isCompleted);
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineSetWidget(
      String exerciseId, int index, WorkoutSet set, bool isCompleted) {
    final sets = routineExerciseSets[exerciseId]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Set ${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isCompleted ? Colors.green.shade800 : Colors.black,
                ),
              ),
              if (sets.length > 1 && !isCompleted)
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
          Consumer<UnitsProvider>(
            builder: (context, unitsProvider, child) {
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weight (${unitsProvider.weightUnit})',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: isCompleted
                                ? Colors.green.shade700
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: set.weightController,
                          keyboardType: TextInputType.number,
                          enabled: !isCompleted,
                          decoration: InputDecoration(
                            hintText: '0',
                            filled: true,
                            fillColor: isCompleted
                                ? Colors.green.shade100
                                : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isCompleted
                                    ? Colors.green.shade300
                                    : Colors.grey.shade300,
                              ),
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
                        Text(
                          'Reps',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: isCompleted
                                ? Colors.green.shade700
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: set.repsController,
                          keyboardType: TextInputType.number,
                          enabled: !isCompleted,
                          decoration: InputDecoration(
                            hintText: '0',
                            filled: true,
                            fillColor: isCompleted
                                ? Colors.green.shade100
                                : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isCompleted
                                    ? Colors.green.shade300
                                    : Colors.grey.shade300,
                              ),
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
              );
            },
          ),
          if (isCompleted) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green.shade600, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
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
