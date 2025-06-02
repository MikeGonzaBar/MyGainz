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
      id: '3',
      userId: 'user1',
      exerciseName: 'Squats',
      targetMuscles: ['Quads', 'Hamstrings', 'Glutes'],
      equipment: ['Barbell'],
    ),
    Exercise(
      id: '4',
      userId: 'user1',
      exerciseName: 'Crunches',
      targetMuscles: ['Abs'],
      equipment: ['No equipment'],
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

  // Dummy data for routines
  final List<Routine> _routines = [
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
    _tabController = TabController(length: 2, vsync: this);
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
          onSave: (newExercise) {
            // Handle saving the new exercise
            Navigator.pop(context);
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
          onSave: (updatedExercise) {
            // Handle updating the exercise
            Navigator.pop(context);
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
            Navigator.pop(context);
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
            Navigator.pop(context);
          },
        ),
      ),
    );
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
                      itemCount: _routines.length,
                      itemBuilder: (context, index) {
                        final routine = _routines[index];
                        return RoutineLibraryCard(
                          routine: routine,
                          availableExercises: _exercises,
                          onEdit: () =>
                              _navigateToEditRoutine(context, routine),
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
