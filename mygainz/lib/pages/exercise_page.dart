import 'package:flutter/material.dart';
import 'exercise_form_page.dart';
import 'routine_form_page.dart';

class Exercise {
  final String id;
  final String name;
  final List<String> muscleGroups;
  final List<String> equipment;
  final String category;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroups,
    required this.equipment,
    required this.category,
  });
}

class Routine {
  final String id;
  final String name;
  final List<Exercise> exercises;
  final bool strictOrder;

  Routine({
    required this.id,
    required this.name,
    required this.exercises,
    required this.strictOrder,
  });
}

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
      name: 'Bench Press',
      muscleGroups: ['Chest', 'Triceps'],
      equipment: ['Barbell', 'Dumbbell', 'Machine'],
      category: 'Upper Body',
    ),
    Exercise(
      id: '2',
      name: 'Pull-ups',
      muscleGroups: ['Back', 'Biceps'],
      equipment: ['Pull-up bar'],
      category: 'Upper Body',
    ),
    Exercise(
      id: '3',
      name: 'Squats',
      muscleGroups: ['Quads', 'Hamstrings', 'Glutes'],
      equipment: ['Barbell'],
      category: 'Lower Body',
    ),
    Exercise(
      id: '4',
      name: 'Crunches',
      muscleGroups: ['Abs'],
      equipment: ['No equipment'],
      category: 'Core',
    ),
  ];

  // Dummy data for routines
  final List<Routine> _routines = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize dummy routines
    _routines.add(
      Routine(
        id: '1',
        name: 'Back / Tricep',
        exercises: [
          Exercise(
            id: '2',
            name: 'Pull-ups',
            muscleGroups: ['Back', 'Biceps'],
            equipment: ['Pull-up bar'],
            category: 'Upper Body',
          ),
          Exercise(
            id: '5',
            name: 'Rows',
            muscleGroups: ['Back'],
            equipment: ['Barbell'],
            category: 'Upper Body',
          ),
          Exercise(
            id: '6',
            name: 'Katana',
            muscleGroups: ['Back', 'Shoulders'],
            equipment: ['Cable'],
            category: 'Upper Body',
          ),
          Exercise(
            id: '7',
            name: 'Skull crusher',
            muscleGroups: ['Triceps'],
            equipment: ['Dumbbell'],
            category: 'Upper Body',
          ),
        ],
        strictOrder: false,
      ),
    );

    _routines.add(
      Routine(
        id: '2',
        name: 'Chest / Shoulders',
        exercises: [
          Exercise(
            id: '1',
            name: 'Bench Press',
            muscleGroups: ['Chest', 'Triceps'],
            equipment: ['Barbell', 'Dumbbell', 'Machine'],
            category: 'Upper Body',
          ),
          Exercise(
            id: '8',
            name: 'Shoulder Press',
            muscleGroups: ['Shoulders'],
            equipment: ['Dumbbell'],
            category: 'Upper Body',
          ),
        ],
        strictOrder: true,
      ),
    );
  }

  List<Exercise> get filteredExercises {
    if (_selectedCategory == 'All') {
      return _exercises;
    } else {
      return _exercises
          .where((exercise) => exercise.category == _selectedCategory)
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
        builder:
            (context) => ExerciseFormPage(
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
        builder:
            (context) => ExerciseFormPage(
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
        builder:
            (context) => RoutineFormPage(
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
        builder:
            (context) => RoutineFormPage(
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
                            _buildCategoryFilter('All'),
                            const SizedBox(width: 8),
                            _buildCategoryFilter('Upper Body'),
                            const SizedBox(width: 8),
                            _buildCategoryFilter('Lower Body'),
                            const SizedBox(width: 8),
                            _buildCategoryFilter('Core'),
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
                            return _buildExerciseCard(exercise);
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
                        return _buildRoutineCard(routine);
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

  Widget _buildCategoryFilter(String category) {
    final isSelected = _selectedCategory == category;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToEditExercise(context, exercise),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            Text(exercise.muscleGroups.join(', ')),
            const SizedBox(height: 8),
            Row(
              children:
                  exercise.equipment.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(item, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(Routine routine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToEditRoutine(context, routine),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  routine.exercises
                      .map((exercise) => _buildExerciseTile(exercise))
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTile(Exercise exercise) {
    return Container(
      width: 50,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              exercise.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
