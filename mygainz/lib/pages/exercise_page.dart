import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import '../providers/auth_provider.dart';
import '../services/workout_firestore_service.dart';
import '../utils/muscle_group_options.dart';
import '../widgets/category_filter.dart';
import '../widgets/exercise_library_card.dart';
import '../widgets/routine_library_card.dart';
import 'exercise_form_page.dart';
import 'routine_form_page.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _selectedCategories = ['All'];

  // Lists will be loaded from Firestore
  List<Exercise> _exercises = [];
  List<Routine> _routines = [];
  bool _isLoading = true;

  final WorkoutFirestoreService _workoutFirestoreService =
      WorkoutFirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadExercisesAndRoutines();
  }

  List<Exercise> get filteredExercises {
    if (_selectedCategories.contains('All') || _selectedCategories.isEmpty) {
      return _exercises;
    } else {
      return _exercises
          .where(
            (exercise) => exercise.targetMuscles.any(
              (muscle) => _selectedCategories.contains(muscle),
            ),
          )
          .toList();
    }
  }

  // Get routines that have at least one valid exercise
  List<Routine> get validRoutines {
    final exerciseIds = _exercises.map((e) => e.id).toSet();
    return _routines.where((routine) {
      return routine.exerciseIds.any((id) => exerciseIds.contains(id));
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Handle category selection with multiple selection support
  void _handleCategorySelection(String category) {
    setState(() {
      if (category == 'All') {
        // If "All" is selected, clear other selections and set only "All"
        _selectedCategories = ['All'];
      } else {
        // Remove "All" if it's currently selected and we're selecting a specific category
        if (_selectedCategories.contains('All')) {
          _selectedCategories.remove('All');
        }

        // Toggle the selected category
        if (_selectedCategories.contains(category)) {
          _selectedCategories.remove(category);
          // If no categories are selected, default back to "All"
          if (_selectedCategories.isEmpty) {
            _selectedCategories = ['All'];
          }
        } else {
          _selectedCategories.add(category);
        }
      }
    });
  }

  // Build filter chips with smart ordering: Selected filters first, then unselected
  List<Widget> _buildFilterChips() {
    final List<Widget> chips = [];

    // 1. Always add "All" first
    chips.add(
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: CategoryFilter(
          category: 'All',
          isSelected: _selectedCategories.contains('All'),
          onTap: () => _handleCategorySelection('All'),
        ),
      ),
    );

    // 2. Add selected muscle groups (excluding "All")
    final selectedMuscles =
        _selectedCategories.where((c) => c != 'All').toList();
    for (final muscle in selectedMuscles) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CategoryFilter(
            category: muscle,
            isSelected: true,
            onTap: () => _handleCategorySelection(muscle),
          ),
        ),
      );
    }

    // 3. Add clear button if there are selected filters
    if (selectedMuscles.isNotEmpty) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: InkWell(
            onTap: () => setState(() => _selectedCategories = ['All']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade300),
                color: Colors.red.shade50,
              ),
              child: Text(
                'Clear (${selectedMuscles.length})',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 4. Add unselected muscle groups
    final unselectedMuscles = MuscleGroupOptions.all
        .where((muscle) => !_selectedCategories.contains(muscle))
        .toList();
    for (final muscle in unselectedMuscles) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CategoryFilter(
            category: muscle,
            isSelected: false,
            onTap: () => _handleCategorySelection(muscle),
          ),
        ),
      );
    }

    return chips;
  }

  // Load exercises and routines from Firestore
  Future<void> _loadExercisesAndRoutines() async {
    try {
      setState(() => _isLoading = true);

      // Load exercises and routines in parallel
      final results = await Future.wait([
        _workoutFirestoreService.getUserExercises(),
        _workoutFirestoreService.getUserRoutines(),
      ]);

      setState(() {
        _exercises = results[0] as List<Exercise>;
        _routines = results[1] as List<Routine>;
        _isLoading = false;
      });

      print(
          'Loaded ${_exercises.length} exercises and ${_routines.length} routines from Firestore');
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading exercises and routines: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToAddExercise(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseFormPage(
          isEditing: false,
          onSave: (exerciseData) async {
            try {
              // Create exercise with current user ID
              final newExercise = Exercise(
                id: '', // Will be set by Firestore
                userId: authProvider.currentUser?.email ?? '',
                exerciseName: exerciseData['exerciseName'] as String,
                targetMuscles:
                    List<String>.from(exerciseData['targetMuscles'] as List),
                equipment: List<String>.from(exerciseData['equipment'] as List),
                exerciseType: exerciseData['exerciseType'] as ExerciseType,
                cardioMetrics: exerciseData['cardioMetrics'] as CardioMetrics?,
              );

              // Save to Firestore
              final firestoreId =
                  await _workoutFirestoreService.saveExercise(newExercise);

              // Update local list with Firestore ID
              final savedExercise = Exercise(
                id: firestoreId,
                userId: authProvider.currentUser?.email ?? '',
                exerciseName: exerciseData['exerciseName'] as String,
                targetMuscles:
                    List<String>.from(exerciseData['targetMuscles'] as List),
                equipment: List<String>.from(exerciseData['equipment'] as List),
                exerciseType: exerciseData['exerciseType'] as ExerciseType,
                cardioMetrics: exerciseData['cardioMetrics'] as CardioMetrics?,
              );

              setState(() {
                _exercises.add(savedExercise);
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Exercise "${savedExercise.exerciseName}" added successfully!'),
                ),
              );
            } catch (e) {
              print('Error saving exercise: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error saving exercise: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToEditExercise(BuildContext context, Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseFormPage(
          isEditing: true,
          exercise: exercise,
          onSave: (exerciseData) async {
            try {
              // Update exercise
              final updatedExercise = Exercise(
                id: exercise.id,
                userId: exercise.userId,
                exerciseName: exerciseData['exerciseName'] as String,
                targetMuscles:
                    List<String>.from(exerciseData['targetMuscles'] as List),
                equipment: List<String>.from(exerciseData['equipment'] as List),
                exerciseType: exerciseData['exerciseType'] as ExerciseType,
                cardioMetrics: exerciseData['cardioMetrics'] as CardioMetrics?,
              );

              // Save to Firestore
              await _workoutFirestoreService.saveExercise(updatedExercise);

              setState(() {
                final index =
                    _exercises.indexWhere((ex) => ex.id == exercise.id);
                if (index != -1) {
                  _exercises[index] = updatedExercise;
                }
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Exercise "${updatedExercise.exerciseName}" updated successfully!'),
                ),
              );
            } catch (e) {
              print('Error updating exercise: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating exercise: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToAddRoutine(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineFormPage(
          isEditing: false,
          availableExercises: _exercises,
          onSave: (routineData) async {
            try {
              // Create routine with current user ID
              final newRoutine = Routine(
                id: '', // Will be set by Firestore
                userId: authProvider.currentUser?.email ?? '',
                name: routineData['name'] as String,
                orderIsRequired: routineData['orderIsRequired'] as bool,
                exerciseIds:
                    List<String>.from(routineData['exerciseIds'] as List),
              );

              // Save to Firestore
              final firestoreId =
                  await _workoutFirestoreService.saveRoutine(newRoutine);

              // Update local list with Firestore ID
              final savedRoutine = Routine(
                id: firestoreId,
                userId: authProvider.currentUser?.email ?? '',
                name: routineData['name'] as String,
                orderIsRequired: routineData['orderIsRequired'] as bool,
                exerciseIds:
                    List<String>.from(routineData['exerciseIds'] as List),
              );

              setState(() {
                _routines.add(savedRoutine);
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Routine "${savedRoutine.name}" added successfully!'),
                ),
              );
            } catch (e) {
              print('Error saving routine: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error saving routine: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToEditRoutine(BuildContext context, Routine routine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineFormPage(
          isEditing: true,
          routine: routine,
          availableExercises: _exercises,
          onSave: (routineData) async {
            try {
              // Update routine
              final updatedRoutine = Routine(
                id: routine.id,
                userId: routine.userId,
                name: routineData['name'] as String,
                orderIsRequired: routineData['orderIsRequired'] as bool,
                exerciseIds:
                    List<String>.from(routineData['exerciseIds'] as List),
              );

              // Save to Firestore
              await _workoutFirestoreService.saveRoutine(updatedRoutine);

              setState(() {
                final index = _routines.indexWhere((r) => r.id == routine.id);
                if (index != -1) {
                  _routines[index] = updatedRoutine;
                }
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Routine "${updatedRoutine.name}" updated successfully!'),
                ),
              );
            } catch (e) {
              print('Error updating routine: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating routine: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _deleteExercise(BuildContext context, Exercise exercise) async {
    // Check if any routines use this exercise
    final affectedRoutines = _routines
        .where((routine) => routine.exerciseIds.contains(exercise.id))
        .toList();

    String warningMessage =
        'Are you sure you want to delete "${exercise.exerciseName}"? This action cannot be undone.';

    if (affectedRoutines.isNotEmpty) {
      warningMessage +=
          '\n\nThis exercise is used in the following routines:\n';
      for (final routine in affectedRoutines) {
        warningMessage += '• ${routine.name}\n';
      }
      warningMessage += '\nThese routines will also be deleted.';
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
                try {
                  // Delete from Firestore
                  await _workoutFirestoreService.deleteExercise(exercise.id);

                  // Delete affected routines from Firestore
                  for (final routine in affectedRoutines) {
                    await _workoutFirestoreService.deleteRoutine(routine.id);
                  }

                  setState(() {
                    // Delete the exercise
                    _exercises.removeWhere((e) => e.id == exercise.id);

                    // Delete routines that use this exercise
                    _routines.removeWhere(
                        (r) => r.exerciseIds.contains(exercise.id));
                  });

                  Navigator.of(context).pop();

                  String successMessage =
                      'Exercise "${exercise.exerciseName}" deleted successfully!';
                  if (affectedRoutines.isNotEmpty) {
                    successMessage +=
                        '\n${affectedRoutines.length} routine(s) also deleted.';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(successMessage),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  print('Error deleting exercise: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting exercise: $e'),
                      backgroundColor: Colors.red,
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

  void _deleteRoutine(BuildContext context, Routine routine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Routine'),
          content: Text(
            'Are you sure you want to delete "${routine.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Delete from Firestore
                  await _workoutFirestoreService.deleteRoutine(routine.id);

                  setState(() {
                    _routines.removeWhere((r) => r.id == routine.id);
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Routine "${routine.name}" deleted successfully!'),
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  print('Error deleting routine: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting routine: $e'),
                      backgroundColor: Colors.red,
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

    return Stack(
      children: [
        Column(
          children: [
            // Tab bar for Exercises/Routines
            TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Exercises'), Tab(text: 'Routines')],
              indicatorColor: const Color(0xFF1B2027),
              labelColor: const Color(0xFF1B2027),
              unselectedLabelColor: Colors.grey,
            ),
            // Tab contents
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Exercises tab
                  Column(
                    children: [
                      // Category filter - Horizontal scroll with selected filters first
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          children: _buildFilterChips(),
                        ),
                      ),
                      // Exercise list
                      Expanded(
                        child: filteredExercises.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.fitness_center,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No exercises saved yet...',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap ➕ to build your workout arsenal!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey.shade500,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16.0),
                                itemCount: filteredExercises.length,
                                itemBuilder: (context, index) {
                                  final exercise = filteredExercises[index];
                                  return ExerciseLibraryCard(
                                    exercise: exercise,
                                    onEdit: () => _navigateToEditExercise(
                                        context, exercise),
                                    onDelete: () =>
                                        _deleteExercise(context, exercise),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                  // Routines tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: validRoutines.isEmpty
                        ? Center(
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
                                  'Still no routines?',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap ➕ and craft your fitness flow!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade500,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: validRoutines.length,
                            itemBuilder: (context, index) {
                              final routine = validRoutines[index];
                              return RoutineLibraryCard(
                                routine: routine,
                                availableExercises: _exercises,
                                onEdit: () =>
                                    _navigateToEditRoutine(context, routine),
                                onDelete: () =>
                                    _deleteRoutine(context, routine),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Floating action button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF1B2027),
            foregroundColor: Colors.white,
            onPressed: () {
              if (_tabController.index == 0) {
                _navigateToAddExercise(context);
              } else {
                _navigateToAddRoutine(context);
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
