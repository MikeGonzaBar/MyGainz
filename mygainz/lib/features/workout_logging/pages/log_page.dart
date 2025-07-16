import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/units_provider.dart';
import '../../exercises/providers/workout_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../exercises/services/workout_firestore_service.dart';
import '../../exercises/models/exercise.dart';
import '../../routines/models/routine.dart';
import '../../exercises/models/workout_set.dart';
import '../../exercises/utils/equipment_options.dart';
import '../widgets/workout_mode_toggle.dart';
import '../../routines/widgets/routine_selection_card.dart';

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

  // Cardio exercise state
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

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

  // Set focus tracking
  int focusedSetIndex = 0; // For single exercise mode
  Map<String, int> routineFocusedSetIndex = {}; // For routine mode

  final List<String> equipmentOptions = EquipmentOptions.basic;

  // Data loaded from Firestore
  List<Exercise> availableExercises = [];
  List<Routine> availableRoutines = [];
  bool _isLoading = true;

  final WorkoutFirestoreService _workoutFirestoreService =
      WorkoutFirestoreService();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
    _loadUserData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _distanceController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
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
    if (kDebugMode) {
      print('_selectExercise called with: ${exercise.exerciseName}'); // Debug
    }
    setState(() {
      selectedExercise = exercise;
      _searchController.text = exercise.exerciseName;
      showSuggestions = false;
      // Set default equipment for selected exercise
      if (exercise.equipment.isNotEmpty) {
        selectedEquipment = exercise.equipment.first;
      }
      // Reset input fields
      sets = [WorkoutSet()];
      focusedSetIndex = 0; // Reset focus to first set
      _distanceController.clear();
      _durationController.clear();
      _caloriesController.clear();
    });
    if (kDebugMode) {
      print('Exercise selected, unfocusing search field'); // Debug
    }
    _searchFocusNode.unfocus();
  }

  void _createNewExercise() async {
    final exerciseName = _searchController.text.trim();
    if (exerciseName.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Create a new exercise and save to Firestore
    final newExercise = Exercise(
      id: '', // Will be set by Firestore
      userId: authProvider.currentUser?.email ?? '',
      exerciseName: exerciseName,
      targetMuscles: ['General'], // Default muscle group
      equipment: [selectedEquipment],
    );

    try {
      // Save to Firestore
      final firestoreId =
          await _workoutFirestoreService.saveExercise(newExercise);

      // Update local list with Firestore ID
      final savedExercise = Exercise(
        id: firestoreId,
        userId: authProvider.currentUser?.email ?? '',
        exerciseName: exerciseName,
        targetMuscles: ['General'],
        equipment: [selectedEquipment],
      );

      if (mounted) {
        setState(() {
          selectedExercise = savedExercise;
          availableExercises.add(savedExercise); // Add to available exercises
          showSuggestions = false;
        });

        _searchFocusNode.unfocus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Exercise "$exerciseName" created and selected!')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving new exercise: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addSet() {
    setState(() {
      sets.add(WorkoutSet());
      focusedSetIndex = sets.length - 1; // Focus on the new set
    });
  }

  void _removeSet(int index) {
    if (sets.length > 1) {
      setState(() {
        sets.removeAt(index);
        // Adjust focused set index if needed
        if (focusedSetIndex >= sets.length) {
          focusedSetIndex = sets.length - 1;
        } else if (focusedSetIndex > index) {
          focusedSetIndex--;
        }
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

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Use selected exercise or create new one
    Exercise exerciseToLog = selectedExercise ??
        Exercise(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: authProvider.currentUser?.email ?? '',
          exerciseName: _searchController.text.trim(),
          targetMuscles: ['General'],
          equipment: [selectedEquipment],
        );

    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (exerciseToLog.exerciseType == ExerciseType.cardio) {
      // Handle cardio exercise logging
      final distance = double.tryParse(_distanceController.text);
      final duration = int.tryParse(_durationController.text);
      final calories = int.tryParse(_caloriesController.text);

      if (distance == null && duration == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please enter distance or duration')),
        );
        return;
      }

      await workoutProvider.logExercise(
        exerciseId: exerciseToLog.id,
        exerciseName: exerciseToLog.exerciseName,
        targetMuscles: exerciseToLog.targetMuscles,
        equipment: selectedEquipment,
        sets: 1, // Cardio is logged as a single event
        distance: distance,
        duration: duration != null ? Duration(minutes: duration) : null,
        calories: calories,
      );
    } else {
      // Handle strength exercise logging with individual sets
      List<WorkoutSetData> individualSets = [];
      final unitsProvider = Provider.of<UnitsProvider>(context, listen: false);

      for (int i = 0; i < sets.length; i++) {
        final setData = WorkoutSetData.fromWorkoutSet(sets[i], i + 1,
            currentWeightUnit: unitsProvider.weightUnit);
        if (setData != null) {
          individualSets.add(setData);
        }
      }

      if (individualSets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Please enter valid weight and reps for at least one set')),
        );
        return;
      }

      await workoutProvider.logExercise(
        exerciseId: exerciseToLog.id,
        exerciseName: exerciseToLog.exerciseName,
        targetMuscles: exerciseToLog.targetMuscles,
        equipment: selectedEquipment,
        individualSets: individualSets,
      );
    }

    if (!mounted) return;

    // Clear the form
    _searchController.clear();
    setState(() {
      sets = [WorkoutSet()];
      focusedSetIndex = 0; // Reset focus
      _distanceController.clear();
      _durationController.clear();
      _caloriesController.clear();
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
      routineFocusedSetIndex.clear();

      // Initialize sets and equipment for each exercise
      for (String exerciseId in routine.exerciseIds) {
        routineExerciseSets[exerciseId] = [WorkoutSet()];
        routineFocusedSetIndex[exerciseId] = 0; // Initialize focus to first set

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
      // Focus on the new set
      final setCount = routineExerciseSets[exerciseId]?.length ?? 0;
      routineFocusedSetIndex[exerciseId] = setCount - 1;
    });
  }

  void _removeRoutineExerciseSet(String exerciseId, int index) {
    if ((routineExerciseSets[exerciseId]?.length ?? 0) > 1) {
      setState(() {
        routineExerciseSets[exerciseId]?.removeAt(index);
        // Adjust focused set index if needed
        final setCount = routineExerciseSets[exerciseId]?.length ?? 0;
        final currentFocus = routineFocusedSetIndex[exerciseId] ?? 0;
        if (currentFocus >= setCount) {
          routineFocusedSetIndex[exerciseId] = setCount - 1;
        } else if (currentFocus > index) {
          routineFocusedSetIndex[exerciseId] = currentFocus - 1;
        }
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

  // Set focus management methods
  void _focusOnSet(int index) {
    setState(() {
      focusedSetIndex = index;
    });
  }

  void _focusOnRoutineSet(String exerciseId, int index) {
    setState(() {
      routineFocusedSetIndex[exerciseId] = index;
    });
  }

  void _saveRoutineWorkout() async {
    if (selectedRoutine == null) return;

    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);
    final unitsProvider = Provider.of<UnitsProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    List<LoggedExercise> loggedExercises = [];

    // Convert routine exercises to logged exercises
    for (String exerciseId in selectedRoutine!.exerciseIds) {
      if (!completedExercises.contains(exerciseId)) continue;

      final exercise = _getExerciseById(exerciseId);
      final exerciseSets = routineExerciseSets[exerciseId] ?? [];

      // Collect individual sets for this exercise
      List<WorkoutSetData> individualSets = [];

      for (int i = 0; i < exerciseSets.length; i++) {
        final setData = WorkoutSetData.fromWorkoutSet(exerciseSets[i], i + 1,
            currentWeightUnit: unitsProvider.weightUnit);
        if (setData != null) {
          individualSets.add(setData);
        }
      }

      if (individualSets.isNotEmpty) {
        loggedExercises.add(LoggedExercise(
          id: DateTime.now().millisecondsSinceEpoch.toString() + exerciseId,
          exerciseId: exerciseId,
          exerciseName: exercise.exerciseName,
          targetMuscles: exercise.targetMuscles,
          equipment: routineExerciseEquipment[exerciseId] ?? 'Unknown',
          date: DateTime.now(),
          individualSets: individualSets,
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
        orderIsRequired: selectedRoutine!.orderIsRequired,
      );

      if (!mounted) return;

      // Reset routine state
      setState(() {
        selectedRoutine = null;
        routineExerciseSets.clear();
        routineExerciseEquipment.clear();
        completedExercises.clear();
        routineFocusedSetIndex.clear(); // Reset focus
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

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    for (String exerciseId in selectedRoutine!.exerciseIds) {
      if (!completedExercises.contains(exerciseId)) {
        return availableExercises.firstWhere(
          (ex) => ex.id == exerciseId,
          orElse: () => Exercise(
            id: exerciseId,
            userId: authProvider.currentUser?.email ?? '',
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return availableExercises.firstWhere(
      (ex) => ex.id == exerciseId,
      orElse: () => Exercise(
        id: exerciseId,
        userId: authProvider.currentUser?.email ?? '',
        exerciseName: 'Unknown Exercise',
        targetMuscles: ['Unknown'],
        equipment: ['Barbell'],
      ),
    );
  }

  // Load user's exercises and routines from Firestore
  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      // Load exercises and routines in parallel
      final results = await Future.wait([
        _workoutFirestoreService.getUserExercises(),
        _workoutFirestoreService.getUserRoutines(),
      ]);

      if (mounted) {
        setState(() {
          availableExercises = results[0] as List<Exercise>;
          availableRoutines = results[1] as List<Routine>;
          _isLoading = false;
        });
      }

      if (kDebugMode) {
        print(
            'Loaded ${availableExercises.length} exercises and ${availableRoutines.length} routines for logging');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (kDebugMode) {
          print('Error loading user data for logging: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Log Workout',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            WorkoutModeToggle(
              isExerciseMode: isExerciseMode,
              onModeChanged: (mode) => setState(() => isExerciseMode = mode),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Refresh both exercise/routine data and workout data
                  await Future.wait([
                    _loadUserData(),
                    Provider.of<WorkoutProvider>(context, listen: false)
                        .refreshWorkouts(),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
            ),
          ],
        ),
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
                              if (kDebugMode) {
                                print(
                                    'Creating new exercise: ${_searchController.text}'); // Debug
                              }
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
                            if (kDebugMode) {
                              print(
                                  'Tapping on ${exercise.exerciseName}'); // Debug
                            }
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
                        if (kDebugMode) {
                          print(
                              'Creating new exercise (no results): ${_searchController.text}'); // Debug
                        }
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
        if (selectedExercise?.exerciseType == ExerciseType.cardio)
          _buildCardioInputSection()
        else
          _buildStrengthInputSection(),
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

  Widget _buildStrengthInputSection() {
    final unitsProvider = Provider.of<UnitsProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sets',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        ...sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          final isFocused = index == focusedSetIndex;

          // Show compact view if not focused
          if (!isFocused) {
            return _buildCompactSetWidget(
              index: index,
              set: set,
              onTap: () => _focusOnSet(index),
              onDelete: sets.length > 1 ? () => _removeSet(index) : null,
              showDelete: sets.length > 1,
            );
          }

          // Show expanded view if focused
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
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
                        fontSize: 13,
                      ),
                    ),
                    if (sets.length > 1)
                      IconButton(
                        onPressed: () => _removeSet(index),
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red.shade400,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricInput(
                        controller: set.weightController,
                        label: 'Weight (${unitsProvider.weightUnit})',
                        hint: '0',
                        icon: Icons.fitness_center,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricInput(
                        controller: set.repsController,
                        label: 'Reps',
                        hint: '0',
                        icon: Icons.repeat,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
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
      ],
    );
  }

  Widget _buildMetricInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                icon != null ? Icon(icon, color: Colors.grey.shade500) : null,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildCardioInputSection() {
    if (selectedExercise == null) return const SizedBox.shrink();

    final metrics = selectedExercise!.cardioMetrics;
    if (metrics == null) return const SizedBox.shrink();

    final unitsProvider = Provider.of<UnitsProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metrics',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        if (metrics.hasDistance) ...[
          _buildMetricInput(
            controller: _distanceController,
            label: 'Distance (${unitsProvider.distanceUnit})',
            hint: '0.0',
            icon: Icons.directions_run,
          ),
          const SizedBox(height: 16),
        ],
        if (metrics.hasDuration) ...[
          _buildMetricInput(
            controller: _durationController,
            label: 'Duration (minutes)',
            hint: '0',
            icon: Icons.timer_outlined,
          ),
          const SizedBox(height: 16),
        ],
        if (metrics.hasCalories) ...[
          _buildMetricInput(
            controller: _caloriesController,
            label: 'Calories Burned',
            hint: '0',
            icon: Icons.local_fire_department_outlined,
          ),
          const SizedBox(height: 16),
        ],
      ],
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
        if (availableRoutines.isEmpty) ...[
          // Empty state for routines
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.list_alt,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No routines available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first routine to get started!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ] else ...[
          ...availableRoutines.map((routine) => RoutineSelectionCard(
                routine: routine,
                availableExercises: availableExercises,
                onTap: () => _selectRoutine(routine),
              )),
          const SizedBox(height: 16),
        ],
        _buildCreateNewRoutineCard(),
      ],
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
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        selectedExerciseIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please enter a name and select at least one exercise')),
                      );
                      return;
                    }

                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);

                    // Create new routine and save to Firestore
                    final newRoutine = Routine(
                      id: '', // Will be set by Firestore
                      userId: authProvider.currentUser?.email ?? '',
                      name: nameController.text.trim(),
                      orderIsRequired: orderIsRequired,
                      exerciseIds: selectedExerciseIds,
                    );

                    try {
                      // Save to Firestore
                      final firestoreId = await _workoutFirestoreService
                          .saveRoutine(newRoutine);

                      // Update local list with Firestore ID
                      final savedRoutine = Routine(
                        id: firestoreId,
                        userId: authProvider.currentUser?.email ?? '',
                        name: nameController.text.trim(),
                        orderIsRequired: orderIsRequired,
                        exerciseIds: selectedExerciseIds,
                      );

                      if (context.mounted) {
                        setState(() {
                          availableRoutines.add(savedRoutine);
                        });

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Routine "${savedRoutine.name}" created successfully! '
                              '${orderIsRequired ? "(Order required)" : "(Flexible order)"}',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print('Error saving new routine: $e');
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error creating routine: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
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
                  routineFocusedSetIndex.clear(); // Reset focus
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
                            Expanded(
                              child: Text(
                                exercise.exerciseName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDisabled ? Colors.grey : Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  // Right side - show completion status and stats when completed
                  if (isCompleted) ...[
                    Flexible(
                      child: _buildCompactStats(exerciseId),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _toggleExerciseCompletion(exerciseId),
                      child: Container(
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
                      ),
                    ),
                  ] else if (!isDisabled)
                    Checkbox(
                      value: false,
                      onChanged: (value) =>
                          _toggleExerciseCompletion(exerciseId),
                      activeColor: const Color(0xFF1B2027),
                    ),
                ],
              ),

              // Show expanded form when not completed or not disabled
              if (!isCompleted && (!isDisabled || isCompleted)) ...[
                const SizedBox(height: 12),

                // Equipment selection
                const Text(
                  'Equipment',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
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
                const SizedBox(height: 12),

                // Sets
                const Text(
                  'Sets',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                ...routineExerciseSets[exerciseId]!.asMap().entries.map((
                  entry,
                ) {
                  final index = entry.key;
                  final set = entry.value;
                  return _buildRoutineSetWidget(exerciseId, index, set,
                      false); // Never completed in edit mode
                }),

                // Add Set button at the bottom
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _addRoutineExerciseSet(exerciseId),
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
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStats(String exerciseId) {
    final sets = routineExerciseSets[exerciseId] ?? [];
    final selectedEquipment = routineExerciseEquipment[exerciseId] ?? 'Unknown';

    // Calculate stats from the sets (weights are entered in current unit, display as-is)
    double totalWeight = 0;
    int totalReps = 0;
    int validSets = 0;

    for (final set in sets) {
      final weight = double.tryParse(set.weightController.text) ?? 0;
      final reps = int.tryParse(set.repsController.text) ?? 0;

      if (weight > 0 && reps > 0) {
        totalWeight += weight;
        totalReps += reps;
        validSets++;
      }
    }

    final averageWeight = validSets > 0 ? totalWeight / validSets : 0.0;
    final averageReps = validSets > 0 ? (totalReps / validSets).round() : 0;

    return Consumer<UnitsProvider>(
      builder: (context, unitsProvider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Equipment badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  selectedEquipment,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Sets count
              Text(
                '${validSets}x',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Weight and reps in a single chip if both exist
              if (averageWeight > 0 && averageReps > 0) ...[
                const SizedBox(width: 4),
                _buildStatChip(
                  '${averageWeight.toStringAsFixed(1)} ${unitsProvider.weightUnit} × $averageReps',
                  Icons.fitness_center,
                ),
              ] else ...[
                // Show individual stats if only one exists
                if (averageWeight > 0) ...[
                  const SizedBox(width: 4),
                  _buildStatChip(
                    '${averageWeight.toStringAsFixed(1)} ${unitsProvider.weightUnit}',
                    Icons.fitness_center,
                  ),
                ],
                if (averageReps > 0) ...[
                  const SizedBox(width: 4),
                  _buildStatChip(
                    '$averageReps reps',
                    Icons.repeat,
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.green.shade700),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSetWidget({
    required int index,
    required WorkoutSet set,
    required VoidCallback onTap,
    required VoidCallback? onDelete,
    required bool showDelete,
  }) {
    final unitsProvider = Provider.of<UnitsProvider>(context, listen: false);
    final weight = double.tryParse(set.weightController.text) ?? 0;
    final reps = int.tryParse(set.repsController.text) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Text(
                'Set ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              if (weight > 0 || reps > 0) ...[
                Text(
                  weight > 0
                      ? '${weight.toStringAsFixed(1)} ${unitsProvider.weightUnit}'
                      : '-',
                  style: TextStyle(
                    fontSize: 12,
                    color: weight > 0 ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '×',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  reps > 0 ? '$reps reps' : '- reps',
                  style: TextStyle(
                    fontSize: 12,
                    color: reps > 0 ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
              ] else ...[
                Text(
                  'Empty set',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const Spacer(),
              if (showDelete && onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade400,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineSetWidget(
      String exerciseId, int index, WorkoutSet set, bool isCompleted) {
    final sets = routineExerciseSets[exerciseId]!;
    final focusedIndex = routineFocusedSetIndex[exerciseId] ?? 0;
    final isFocused = index == focusedIndex && !isCompleted;

    // Show compact view if not focused and not completed
    if (!isFocused && !isCompleted) {
      return _buildCompactSetWidget(
        index: index,
        set: set,
        onTap: () => _focusOnRoutineSet(exerciseId, index),
        onDelete: sets.length > 1
            ? () => _removeRoutineExerciseSet(exerciseId, index)
            : null,
        showDelete: sets.length > 1,
      );
    }

    // Show expanded view if focused or completed
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
                  fontSize: 13,
                  color: isCompleted ? Colors.green.shade800 : Colors.black,
                ),
              ),
              if (sets.length > 1 && !isCompleted)
                IconButton(
                  onPressed: () => _removeRoutineExerciseSet(exerciseId, index),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade400,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
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
            const SizedBox(height: 6),
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
