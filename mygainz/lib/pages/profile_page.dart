import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/units_provider.dart';
import '../providers/workout_provider.dart';
import '../services/data_export_service.dart';
import '../models/user_model.dart';
import 'login_page.dart';
import 'settings_page.dart';

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
                _buildUserProfileSection(currentUser),
                const SizedBox(height: 32),

                // Weight and Height Stats
                _buildStatsSection(currentUser),
                const SizedBox(height: 32),

                // Muscle Group Focus Section with real data
                Consumer<WorkoutProvider>(
                  builder: (context, workoutProvider, child) {
                    return _buildMuscleGroupFocusSection(workoutProvider);
                  },
                ),
                const SizedBox(height: 32),

                // Download Personal Data Button
                _buildDownloadDataButton(),
                const SizedBox(height: 24),

                // Settings Menu
                _buildSettingsMenu(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserProfileSection(User currentUser) {
    return Column(
      children: [
        Text(
          currentUser.fullName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          currentUser.email,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          'Age: ${currentUser.age}',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildStatsSection(User currentUser) {
    return Consumer<UnitsProvider>(
      builder: (context, unitsProvider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildEditableStatCard(
                icon: Icons.monitor_weight,
                label: 'Weight',
                value: unitsProvider.formatWeight(currentUser.weight),
                onTap: _editWeight,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildEditableStatCard(
                icon: Icons.height,
                label: 'Height',
                value: unitsProvider.formatHeight(currentUser.height),
                onTap: _editHeight,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableStatCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleGroupFocusSection(WorkoutProvider workoutProvider) {
    final muscleGroupFocus =
        _calculateMuscleGroupFocus(workoutProvider.loggedExercises);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Muscle Group Focus',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (workoutProvider.loggedExercises.isNotEmpty)
              Text(
                '${workoutProvider.loggedExercises.length} exercises',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (workoutProvider.loggedExercises.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No workout data yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start logging exercises to see your muscle group focus!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ...muscleGroupFocus.entries.map(
            (entry) => _buildMuscleGroupItem(
              entry.key,
              entry.value['percentage'],
              entry.value['color'],
              workoutProvider.loggedExercises,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Based on your logged exercises. Percentages show relative focus on each muscle group.',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMuscleGroupItem(
    String muscleName,
    double percentage,
    Color color,
    List<LoggedExercise> exercises,
  ) {
    // Count exercises for this muscle group
    final exerciseCount = exercises
        .where((exercise) => exercise.targetMuscles.contains(muscleName))
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                muscleName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$exerciseCount exercises',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${percentage.toInt()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadDataButton() {
    return Consumer3<AuthProvider, WorkoutProvider, UnitsProvider>(
      builder: (context, authProvider, workoutProvider, unitsProvider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await _downloadPersonalData(
                  authProvider, workoutProvider, unitsProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B2027),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.download),
            label: const Text(
              'Download Personal Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadPersonalData(
    AuthProvider authProvider,
    WorkoutProvider workoutProvider,
    UnitsProvider unitsProvider,
  ) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Generating your personal data export...'),
                const SizedBox(height: 8),
                Text(
                  'This may take a moment',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        },
      );

      // Generate and share the export
      await DataExportService.exportPersonalData(
        authProvider: authProvider,
        workoutProvider: workoutProvider,
        unitsProvider: unitsProvider,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Personal data export generated successfully!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  const Text('Export Failed'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Failed to generate your personal data export.'),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${e.toString()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                      'Please try again or contact support if the problem persists.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _downloadPersonalData(
                        authProvider, workoutProvider, unitsProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2027),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Widget _buildSettingsMenu() {
    return Column(
      children: [
        _buildMenuTile(
          icon: Icons.settings,
          title: 'Settings',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
        _buildMenuTile(
          icon: Icons.info_outline,
          title: 'About',
          onTap: () {
            _showAboutDialog();
          },
        ),
        const SizedBox(height: 16),
        _buildLogOutButton(),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey.shade600, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey.shade400,
          size: 16,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),
    );
  }

  Widget _buildLogOutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          _showLogOutDialog();
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Log Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showLogOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                // Navigation will be handled automatically by AuthWrapper
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if image fails to load
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2027),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MyGainz',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Track your fitness journey with comprehensive workout logging, progress visualization, and personalized insights.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // Features Section
                const Text(
                  'Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('• Workout logging with sets, reps, and weights'),
                const Text('• Progress tracking with visual charts'),
                const Text('• Custom routine creation and management'),
                const Text('• Metric and Imperial unit support'),
                const Text('• Personal data export capabilities'),
                const Text('• Muscle group focus analysis'),

                const SizedBox(height: 20),

                // Technical Info
                const Text(
                  'Technical Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('• Built with Flutter'),
                const Text('• Cross-platform: iOS, Android, Web'),
                const Text('• Local data storage with export'),

                const SizedBox(height: 20),

                // Developer Section
                const Text(
                  'Developer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Developed by MikeGonzaBar'),
                const Text('Made with ❤️ for fitness enthusiasts'),
                const SizedBox(height: 8),

                // Contact/Support
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Support & Feedback',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Have suggestions or found a bug? We\'d love to hear from you!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final Uri githubUrl = Uri.parse(
                              'https://github.com/MikeGonzaBar/MyGainz');
                          try {
                            if (await canLaunchUrl(githubUrl)) {
                              await launchUrl(githubUrl,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              // Fallback to showing dialog if can't launch
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('GitHub Repository'),
                                    content: const SelectableText(
                                      'https://github.com/MikeGonzaBar/MyGainz',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 14,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            // If there's an error, show a snackbar
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Could not open GitHub repository: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.code,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'View on GitHub',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
