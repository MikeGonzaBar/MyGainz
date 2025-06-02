import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/units_provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/user_profile_header.dart';
import '../widgets/editable_stat_card.dart';
import '../widgets/muscle_group_focus_section.dart';
import '../widgets/download_data_button.dart';
import '../widgets/profile_settings_menu.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Calculate muscle group focus from workout data
  Map<String, Map<String, dynamic>> _calculateMuscleGroupFocus(
      List<LoggedExercise> exercises) {
    if (exercises.isEmpty) {
      return {
        'No Data': {'percentage': 100.0, 'color': Colors.grey.shade400}
      };
    }

    // Count exercises per muscle group
    final Map<String, int> muscleCounts = {};
    final Map<String, double> muscleWeights = {};

    for (final exercise in exercises) {
      for (final muscle in exercise.targetMuscles) {
        muscleCounts[muscle] = (muscleCounts[muscle] ?? 0) + 1;
        muscleWeights[muscle] = (muscleWeights[muscle] ?? 0) + exercise.weight;
      }
    }

    if (muscleCounts.isEmpty) {
      return {
        'No Data': {'percentage': 100.0, 'color': Colors.grey.shade400}
      };
    }

    // Calculate percentages based on exercise count
    final totalExercises = muscleCounts.values.reduce((a, b) => a + b);
    final Map<String, Map<String, dynamic>> result = {};

    // Sort by count and take top muscle groups
    final sortedMuscles = muscleCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Define colors for different muscle groups
    final List<Color> muscleColors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    // Take top 6 muscle groups to avoid cluttering
    final topMuscles = sortedMuscles.take(6).toList();

    for (int i = 0; i < topMuscles.length; i++) {
      final entry = topMuscles[i];
      final percentage = (entry.value / totalExercises * 100);
      result[entry.key] = {
        'percentage': percentage,
        'color': muscleColors[i % muscleColors.length],
      };
    }

    return result;
  }

  void _editWeight() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final unitsProvider = Provider.of<UnitsProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    // Convert stored weight (kg) to display unit
    final displayWeight = unitsProvider.convertWeight(currentUser.weight);

    _showEditDialog(
      title: 'Edit Weight',
      currentValue: displayWeight.toStringAsFixed(1),
      unit: unitsProvider.weightUnit,
      onSave: (value) async {
        final newWeight = double.tryParse(value);
        if (newWeight != null && newWeight > 0 && newWeight < 1000) {
          // Convert from display unit to storage unit (kg)
          final weightInKg = unitsProvider.convertWeight(
            newWeight,
            fromUnit: unitsProvider.weightUnit,
            toUnit: 'kg',
          );
          final success =
              await authProvider.updateUserStats(weight: weightInKg);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Weight updated successfully')),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.error ?? 'Failed to update weight'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid weight'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _editHeight() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final unitsProvider = Provider.of<UnitsProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    // Convert stored height (cm) to display unit
    final displayHeight = unitsProvider.convertHeight(currentUser.height);

    _showEditDialog(
      title: 'Edit Height',
      currentValue: unitsProvider.heightUnit == 'ft-in'
          ? displayHeight.toStringAsFixed(0)
          : displayHeight.toStringAsFixed(1),
      unit: unitsProvider.heightUnit,
      onSave: (value) async {
        final newHeight = double.tryParse(value);
        if (newHeight != null && newHeight > 0 && newHeight < 300) {
          // Convert from display unit to storage unit (cm)
          final heightInCm = unitsProvider.convertHeight(
            newHeight,
            fromUnit: unitsProvider.heightUnit,
            toUnit: 'cm',
          );
          final success =
              await authProvider.updateUserStats(height: heightInCm);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Height updated successfully')),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.error ?? 'Failed to update height'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid height'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _showEditDialog({
    required String title,
    required String currentValue,
    required String unit,
    required Function(String) onSave,
  }) {
    final TextEditingController controller = TextEditingController();
    controller.text = currentValue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter new value',
                  suffixText: unit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2027),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while AuthProvider is initializing or loading
        if (!authProvider.isInitialized || authProvider.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Loading profile...'),
                  const SizedBox(height: 24),
                  // Debug button for troubleshooting
                  ElevatedButton(
                    onPressed: () async {
                      await authProvider.debugPrintStoredData();
                    },
                    child: const Text('Debug Auth State'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show error state if there's an error
        if (authProvider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      authProvider.clearError();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final currentUser = authProvider.currentUser;

        // Show loading if user is still null after initialization
        if (currentUser == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('No user data found'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to login
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User Profile Section
                UserProfileHeader(user: currentUser),
                const SizedBox(height: 32),

                // Weight and Height Stats
                Consumer<UnitsProvider>(
                  builder: (context, unitsProvider, child) {
                    return Row(
                      children: [
                        Expanded(
                          child: EditableStatCard(
                            icon: Icons.monitor_weight,
                            label: 'Weight',
                            value:
                                unitsProvider.formatWeight(currentUser.weight),
                            onTap: _editWeight,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: EditableStatCard(
                            icon: Icons.height,
                            label: 'Height',
                            value:
                                unitsProvider.formatHeight(currentUser.height),
                            onTap: _editHeight,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Muscle Group Focus Section with real data
                Consumer<WorkoutProvider>(
                  builder: (context, workoutProvider, child) {
                    return MuscleGroupFocusSection(
                      workoutProvider: workoutProvider,
                      muscleGroupFocus: _calculateMuscleGroupFocus(
                          workoutProvider.loggedExercises),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Download Personal Data Button
                const DownloadDataButton(),
                const SizedBox(height: 24),

                // Settings Menu
                const ProfileSettingsMenu(),
              ],
            ),
          ),
        );
      },
    );
  }
}
