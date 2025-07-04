import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
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
  String _selectedCategory = 'All';

  // Dummy data for exercises
  final List<Exercise> _exercises = [
    Exercise(
      id: '1',
      userId: 'user1',
      exerciseName: 'Bench Press',
      targetMuscles: ['Chest', 'Triceps'],
      equipment: ['Barbell', 'Dumbbell'],
    ),
    Exercise(
      id: '2',
      userId: 'user1',
      exerciseName: 'Squats',
      targetMuscles: ['Quads', 'Glutes'],
      equipment: ['Barbell', 'Dumbbell'],
    ),
    Exercise(
      id: '3',
      userId: 'user1',
      exerciseName: 'Deadlift',
      targetMuscles: ['Back', 'Hamstrings'],
      equipment: ['Barbell'],
    ),
    Exercise(
      id: '4',
      userId: 'user1',
      exerciseName: 'Pull-ups',
      targetMuscles: ['Back', 'Biceps'],
      equipment: ['Bodyweight'],
    ),
    Exercise(
      id: '5',
      userId: 'user1',
      exerciseName: 'Overhead Press',
      targetMuscles: ['Shoulders', 'Triceps'],
      equipment: ['Barbell', 'Dumbbell'],
    ),
    Exercise(
      id: '6',
      userId: 'user1',
      exerciseName: 'Bicep Curls',
      targetMuscles: ['Biceps'],
      equipment: ['Dumbbell', 'Barbell'],
    ),
    Exercise(
      id: '7',
      userId: 'user1',
      exerciseName: 'Running',
      targetMuscles: ['Legs', 'Core'],
      equipment: ['None'],
      exerciseType: ExerciseType.cardio,
      cardioMetrics: CardioMetrics(
        hasDistance: true,
        hasDuration: true,
        hasPace: true,
        hasCalories: true,
        primaryMetric: 'distance',
      ),
    ),
    Exercise(
      id: '8',
      userId: 'user1',
      exerciseName: 'Cycling',
      targetMuscles: ['Legs', 'Glutes'],
      equipment: ['Machine'],
      exerciseType: ExerciseType.cardio,
      cardioMetrics: CardioMetrics(
        hasDistance: true,
        hasDuration: true,
        hasPace: true,
        hasCalories: true,
        primaryMetric: 'distance',
      ),
    ),
    Exercise(
      id: '9',
      userId: 'user1',
      exerciseName: 'Swimming',
      targetMuscles: ['Full Body', 'Back', 'Shoulders'],
      equipment: ['None'],
      exerciseType: ExerciseType.cardio,
      cardioMetrics: CardioMetrics(
        hasDistance: true,
        hasDuration: true,
        hasPace: false,
        hasCalories: true,
        primaryMetric: 'duration',
      ),
    ),
  ];

  // Dummy data for routines
  final List<Routine> _routines = [
    Routine(
      id: '1',
      userId: 'user1',
      name: 'Upper Body',
      orderIsRequired: false,
      exerciseIds: [
        '1',
        '4',
        '5',
        '6'
      ], // Bench Press, Pull-ups, Overhead Press, Bicep Curls
    ),
    Routine(
      id: '2',
      userId: 'user1',
      name: 'Lower Body',
      orderIsRequired: true,
      exerciseIds: ['2', '3'], // Squats, Deadlift
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Clean up any orphaned routines on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cleanupOrphanedRoutines();
    });
  }

  List<Exercise> get filteredExercises {
    if (_selectedCategory == 'All') {
      return _exercises;
    } else {
      return _exercises
          .where(
            (exercise) => exercise.targetMuscles.contains(_selectedCategory),
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

  void _navigateToAddExercise(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseFormPage(
          isEditing: false,
          onSave: (exerciseData) {
            // Handle saving the new exercise
            final newExercise = Exercise(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: 'user1', // Would use actual user ID in real app
              exerciseName: exerciseData['exerciseName'] as String,
              targetMuscles:
                  List<String>.from(exerciseData['targetMuscles'] as List),
              equipment: List<String>.from(exerciseData['equipment'] as List),
              exerciseType: exerciseData['exerciseType'] as ExerciseType,
              cardioMetrics: exerciseData['cardioMetrics'] as CardioMetrics?,
            );

            setState(() {
              _exercises.add(newExercise);
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Exercise "${newExercise.exerciseName}" added successfully!'),
              ),
            );
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
          onSave: (exerciseData) {
            // Handle updating the exercise
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

            setState(() {
              final index = _exercises.indexWhere((ex) => ex.id == exercise.id);
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
          },
        ),
      ),
    );
  }

  void _navigateToAddRoutine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineFormPage(
          isEditing: false,
          availableExercises: _exercises,
          onSave: (routineData) {
            // Handle saving the new routine
            final newRoutine = Routine(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: 'user1', // Would use actual user ID in real app
              name: routineData['name'] as String,
              orderIsRequired: routineData['orderIsRequired'] as bool,
              exerciseIds:
                  List<String>.from(routineData['exerciseIds'] as List),
            );

            setState(() {
              _routines.add(newRoutine);
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Routine "${newRoutine.name}" added successfully!'),
              ),
            );
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
          onSave: (routineData) {
            // Handle updating the routine
            final updatedRoutine = Routine(
              id: routine.id,
              userId: routine.userId,
              name: routineData['name'] as String,
              orderIsRequired: routineData['orderIsRequired'] as bool,
              exerciseIds:
                  List<String>.from(routineData['exerciseIds'] as List),
            );

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
          },
        ),
      ),
    );
  }

  void _deleteExercise(BuildContext context, Exercise exercise) {
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
              onPressed: () {
                setState(() {
                  // Delete the exercise
                  _exercises.removeWhere((e) => e.id == exercise.id);

                  // Delete routines that use this exercise
                  _routines
                      .removeWhere((r) => r.exerciseIds.contains(exercise.id));
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
              onPressed: () {
                setState(() {
                  _routines.removeWhere((r) => r.id == routine.id);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Routine "${routine.name}" deleted successfully!'),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Clean up routines that have no valid exercises
  void _cleanupOrphanedRoutines() {
    final exerciseIds = _exercises.map((e) => e.id).toSet();
    final orphanedRoutines = _routines.where((routine) {
      return routine.exerciseIds.every((id) => !exerciseIds.contains(id));
    }).toList();

    if (orphanedRoutines.isNotEmpty) {
      setState(() {
        _routines.removeWhere((r) => orphanedRoutines.contains(r));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      // Category filter
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              CategoryFilter(
                                category: 'All',
                                isSelected: _selectedCategory == 'All',
                                onTap: () =>
                                    setState(() => _selectedCategory = 'All'),
                              ),
                              const SizedBox(width: 8),
                              CategoryFilter(
                                category: 'Chest',
                                isSelected: _selectedCategory == 'Chest',
                                onTap: () =>
                                    setState(() => _selectedCategory = 'Chest'),
                              ),
                              const SizedBox(width: 8),
                              CategoryFilter(
                                category: 'Back',
                                isSelected: _selectedCategory == 'Back',
                                onTap: () =>
                                    setState(() => _selectedCategory = 'Back'),
                              ),
                              const SizedBox(width: 8),
                              CategoryFilter(
                                category: 'Lower Body',
                                isSelected: _selectedCategory == 'Lower Body',
                                onTap: () => setState(
                                    () => _selectedCategory = 'Lower Body'),
                              ),
                              const SizedBox(width: 8),
                              CategoryFilter(
                                category: 'Core',
                                isSelected: _selectedCategory == 'Core',
                                onTap: () =>
                                    setState(() => _selectedCategory = 'Core'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Exercise list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = filteredExercises[index];
                            return ExerciseLibraryCard(
                              exercise: exercise,
                              onEdit: () =>
                                  _navigateToEditExercise(context, exercise),
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
                    child: ListView.builder(
                      itemCount: validRoutines.length,
                      itemBuilder: (context, index) {
                        final routine = validRoutines[index];
                        return RoutineLibraryCard(
                          routine: routine,
                          availableExercises: _exercises,
                          onEdit: () =>
                              _navigateToEditRoutine(context, routine),
                          onDelete: () => _deleteRoutine(context, routine),
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
