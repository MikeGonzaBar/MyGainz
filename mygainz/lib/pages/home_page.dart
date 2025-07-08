import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/units_provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_card.dart';
import '../widgets/routine_card.dart';
import '../widgets/stat_card.dart';
import 'exercise_history_page.dart';
import 'routine_history_page.dart';

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
                _buildSectionHeader(context, 'Overview'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StatCard(
                      title: 'Weight',
                      value: currentUser != null
                          ? unitsProvider.formatWeight(currentUser.weight)
                          : 'No data',
                    ),
                    StatCard(
                      title: 'Height',
                      value: currentUser != null
                          ? unitsProvider.formatHeight(currentUser.height)
                          : 'No data',
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Manrope',
                    ),
              ),
              const SizedBox(height: 20),
            ],

            // Recent Exercises Section
            _buildSectionHeader(context, 'Recent exercises'),
            if (recentExercises.isEmpty)
              _buildEmptyState(
                  context, 'Nothing recent here... Time to break a sweat!')
            else ...[
              ...recentExercises
                  .map((exercise) => ExerciseCard(exercise: exercise)),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () => _navigateToExerciseHistory(context),
                  icon: const Icon(Icons.history),
                  label: const Text('View All Exercise History'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1B2027),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Recent Routines Section
            _buildSectionHeader(context, 'Recent Routines'),
            if (recentRoutines.isEmpty)
              _buildEmptyState(
                  context, 'No routines wrapped up... Let\'s finish strong!')
            else ...[
              ...recentRoutines.map((routine) => RoutineCard(routine: routine)),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () => _navigateToRoutineHistory(context),
                  icon: const Icon(Icons.history),
                  label: const Text('View All Routine History'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1B2027),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Manrope',
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToExerciseHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExerciseHistoryPage()),
    );
  }

  void _navigateToRoutineHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoutineHistoryPage()),
    );
  }
}
