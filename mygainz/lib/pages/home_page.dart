import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/units_provider.dart';
import '../providers/workout_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCard(),
              const SizedBox(height: 16),
              _buildRecentActivityCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Consumer2<AuthProvider, UnitsProvider>(
      builder: (context, authProvider, unitsProvider, child) {
        final currentUser = authProvider.currentUser;

        return Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Overview'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                        'Weight',
                        currentUser != null
                            ? unitsProvider.formatWeight(currentUser.weight)
                            : 'No data'),
                    _buildStatCard(
                        'Height',
                        currentUser != null
                            ? unitsProvider.formatHeight(currentUser.height)
                            : 'No data'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivityCard() {
    return Consumer2<AuthProvider, WorkoutProvider>(
      builder: (context, authProvider, workoutProvider, child) {
        final currentUser = authProvider.currentUser;
        final recentExercises = workoutProvider.recentExercises;
        final recentRoutines = workoutProvider.recentRoutines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personalized greeting
            if (currentUser != null) ...[
              Text(
                'Welcome back, ${currentUser.name}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Recent Exercises Section
            _buildSectionHeader('Recent exercises'),
            if (recentExercises.isEmpty)
              _buildEmptyState(
                  'No exercises logged yet. Start by logging your first workout!')
            else
              ...recentExercises
                  .map((exercise) => _buildExerciseCard(exercise)),

            const SizedBox(height: 24),

            // Recent Routines Section
            _buildSectionHeader('Recent Routines'),
            if (recentRoutines.isEmpty)
              _buildEmptyState(
                  'No routines completed yet. Try completing a routine!')
            else
              ...recentRoutines.map((routine) => _buildRoutineCard(routine)),
          ],
        );
      },
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

  Widget _buildEmptyState(String message) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.fitness_center,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(LoggedExercise exercise) {
    return Consumer<UnitsProvider>(
      builder: (context, unitsProvider, child) {
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
                            unitsProvider.formatWeight(exercise.weight,
                                decimals: 0),
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
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
                Text(
                  '${routine.exercises.length} exercises',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Muscle group icons
            Row(
              children: routine.targetMuscles
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
