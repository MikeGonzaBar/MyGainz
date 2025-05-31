import 'package:flutter/material.dart';

// These represent logged workout sessions, not the exercise definitions
class LoggedExercise {
  final String exerciseId; // Reference to exercise document
  final String exerciseName; // Denormalized for display
  final List<String> targetMuscles; // Denormalized for display
  final double weight;
  final int reps;
  final String equipment;
  final int sets;
  final DateTime date;

  LoggedExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.targetMuscles,
    required this.weight,
    required this.reps,
    required this.equipment,
    required this.sets,
    required this.date,
  });
}

class LoggedRoutine {
  final String routineId; // Reference to routine document
  final String name; // Denormalized for display
  final List<String> targetMuscles; // Calculated from exercises
  final DateTime date;

  LoggedRoutine({
    required this.routineId,
    required this.name,
    required this.targetMuscles,
    required this.date,
  });
}

class User {
  final String name;
  final String lastName;
  final DateTime dateOfBirth;
  final String email;
  final double height; // in cm
  final double weight; // in kg
  final double fatPercentage; // %
  final double musclePercentage; // %

  User({
    required this.name,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
    required this.height,
    required this.weight,
    required this.fatPercentage,
    required this.musclePercentage,
  });
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Current user data
  final User currentUser = User(
    name: 'John',
    lastName: 'Anderson',
    dateOfBirth: DateTime(1990, 5, 15),
    email: 'john.anderson@email.com',
    height: 177.0,
    weight: 75.0,
    fatPercentage: 15.0,
    musclePercentage: 40.0,
  );

  // Dummy data for recent logged exercises
  final List<LoggedExercise> recentExercises = [
    LoggedExercise(
      exerciseId: '1',
      exerciseName: 'Bench Press',
      targetMuscles: ['Chest', 'Triceps'],
      weight: 50,
      reps: 8,
      equipment: 'Dumbbells',
      sets: 3,
      date: DateTime(2025, 4, 10),
    ),
    LoggedExercise(
      exerciseId: '3',
      exerciseName: 'Squats',
      targetMuscles: ['Quads', 'Hamstrings', 'Glutes'],
      weight: 100,
      reps: 8,
      equipment: 'Barbell',
      sets: 3,
      date: DateTime(2025, 4, 9),
    ),
  ];

  // Dummy data for recent logged routines
  final List<LoggedRoutine> recentRoutines = [
    LoggedRoutine(
      routineId: '2',
      name: 'Chest/Arms 4',
      targetMuscles: ['Chest', 'Biceps', 'Triceps'],
      date: DateTime(2025, 4, 10),
    ),
    LoggedRoutine(
      routineId: '1',
      name: 'Legs/Shoulders 4',
      targetMuscles: ['Quads', 'Hamstrings', 'Glutes', 'Shoulders'],
      date: DateTime(2025, 4, 9),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Exercises Section
            _buildSectionHeader('Recent exercises'),
            ...recentExercises.map((exercise) => _buildExerciseCard(exercise)),

            const SizedBox(height: 24),

            // Recent Routines Section
            _buildSectionHeader('Recent Routines'),
            ...recentRoutines.map((routine) => _buildRoutineCard(routine)),

            const Divider(),

            // Body Stats Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Weight', '${currentUser.weight} kg'),
                _buildStatCard('Height', '${currentUser.height} cm'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFamily: 'Manrope',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(LoggedExercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Exercise name
                Text(
                  exercise.exerciseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // Equipment type
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        exercise.equipment,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Sets
                    Text(
                      '${exercise.sets} sets',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    // Edit icon
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.amber.shade700,
                        size: 18,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Muscle groups
            Text(
              exercise.targetMuscles.join(', '),
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Weight and reps
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${exercise.weight.toInt()} kg',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${exercise.reps} reps',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                // Date
                Text(
                  '${exercise.date.day}-${_getMonthName(exercise.date.month)}-${exercise.date.year}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(LoggedRoutine routine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
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
                  icon: Icon(
                    Icons.edit,
                    color: Colors.amber.shade700,
                    size: 18,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            // Muscle group icons
            Row(
              children:
                  routine.targetMuscles
                      .map((muscle) => _buildMuscleIcon(muscle))
                      .toList(),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${routine.date.day}-${_getMonthName(routine.date.month)}-${routine.date.year}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleIcon(String muscle) {
    // Map muscle name to corresponding asset path
    String assetPath = 'assets/icons/muscles/';

    // Normalize the muscle name for comparison
    String normalizedMuscle = muscle.toLowerCase();

    if (normalizedMuscle.contains('chest')) {
      assetPath += 'Chest.png';
    } else if (normalizedMuscle.contains('tricep')) {
      assetPath += 'Triceps.png';
    } else if (normalizedMuscle.contains('bicep')) {
      assetPath += 'Biceps.png';
    } else if (normalizedMuscle.contains('quad')) {
      assetPath += 'Thigh.png';
    } else if (normalizedMuscle.contains('hamstring')) {
      assetPath += 'Hamstrings.png';
    } else if (normalizedMuscle.contains('glute')) {
      assetPath += 'butt.png';
    } else if (normalizedMuscle.contains('shoulder') ||
        normalizedMuscle.contains('delt')) {
      assetPath += 'Shoulder.png';
    } else if (normalizedMuscle.contains('back')) {
      assetPath += 'Back.png';
    } else if (normalizedMuscle.contains('ab') ||
        normalizedMuscle.contains('core')) {
      assetPath += 'Abs.png';
    } else if (normalizedMuscle.contains('forearm')) {
      assetPath += 'Forearm.png';
    } else if (normalizedMuscle.contains('calf') ||
        normalizedMuscle.contains('calves')) {
      assetPath += 'Calves.png';
    } else {
      // Default to showing a generic icon if no match
      assetPath += 'Chest.png';
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 4),
          Text(
            muscle.length > 5 ? '${muscle.substring(0, 5)}...' : muscle,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              13,
              0,
              0,
              0,
            ), // 0.05 opacity = 13 in 0-255 scale
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              fontFamily: 'LeagueSpartan',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'LeagueSpartan',
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
