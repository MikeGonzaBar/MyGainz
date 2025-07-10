import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../exercises/providers/workout_provider.dart';
import '../widgets/routine_card.dart';

class RoutineHistoryPage extends StatelessWidget {
  const RoutineHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2027),
        foregroundColor: Colors.white,
        title: const Text('Routine History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          final routines = workoutProvider.loggedRoutines;

          // Sort routines by date (newest first)
          final sortedRoutines = List<LoggedRoutine>.from(routines)
            ..sort((a, b) => b.date.compareTo(a.date));

          if (sortedRoutines.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await workoutProvider.refreshWorkouts();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
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
                            'No routines wrapped up... Let\'s finish strong!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete your first routine to see your history',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Pull down to refresh',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await workoutProvider.refreshWorkouts();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: sortedRoutines.length,
              itemBuilder: (context, index) {
                final routine = sortedRoutines[index];
                return RoutineCard(
                  routine: routine,
                  showEditButton: true,
                  onDelete: () => _showDeleteRoutineDialog(
                      context, routine, workoutProvider),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteRoutineDialog(BuildContext context, LoggedRoutine routine,
      WorkoutProvider workoutProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Routine'),
          content: Text(
            'Are you sure you want to delete "${routine.name}" from your history? This will also delete all ${routine.exercises.length} exercises in this routine. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await workoutProvider.deleteLoggedRoutine(routine.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Routine "${routine.name}" deleted from history'),
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
}
