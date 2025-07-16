import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../exercises/providers/workout_provider.dart';
import '../../../core/providers/units_provider.dart';
import '../models/personal_record.dart';

class PersonalRecordsDashboard extends StatelessWidget {
  const PersonalRecordsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final recentPRs = workoutProvider.recentPersonalRecords;
        final strongestLift = workoutProvider.strongestLift;
        final recentAchievements = workoutProvider.recentAchievements;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Personal Records'),
            const SizedBox(height: 16),

            // Strongest lift card
            if (strongestLift != null) _buildStrongestLiftCard(strongestLift),

            const SizedBox(height: 16),

            // Recent PRs
            if (recentPRs.isNotEmpty) ...[
              _buildRecentPRsSection(recentPRs),
              const SizedBox(height: 16),
            ],

            // Recent achievements
            if (recentAchievements.isNotEmpty) ...[
              _buildAchievementsSection(recentAchievements),
              const SizedBox(height: 16),
            ],

            // Empty state
            if (recentPRs.isEmpty && recentAchievements.isEmpty) ...[
              _buildEmptyState(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        fontFamily: 'Manrope',
      ),
    );
  }

  Widget _buildStrongestLiftCard(PersonalRecord strongestLift) {
    return Consumer<UnitsProvider>(
      builder: (context, unitsProvider, child) {
        // Convert stored weight (kg) to display weight for current unit
        double? displayWeight = strongestLift.weight;
        double? displayOneRepMax = strongestLift.oneRepMax;
        if (displayWeight != null && unitsProvider.weightUnit == 'lbs') {
          displayWeight = displayWeight / 0.453592; // Convert kg to lbs
        }
        if (displayOneRepMax != null && unitsProvider.weightUnit == 'lbs') {
          displayOneRepMax = displayOneRepMax / 0.453592; // Convert kg to lbs
        }

        return Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Strongest Lift',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  strongestLift.exerciseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMetricChip(
                      '${displayWeight?.toStringAsFixed(1) ?? 'N/A'}${unitsProvider.weightUnit}',
                      Colors.blue.shade100,
                      Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      '${strongestLift.reps ?? 'N/A'} reps',
                      Colors.green.shade100,
                      Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      '1RM: ${displayOneRepMax?.toStringAsFixed(1) ?? 'N/A'}${unitsProvider.weightUnit}',
                      Colors.orange.shade100,
                      Colors.orange.shade700,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Achieved on ${_formatDate(strongestLift.date)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentPRsSection(List<PersonalRecord> recentPRs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Personal Records',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...recentPRs.take(3).map((pr) => _buildPRCard(pr)),
      ],
    );
  }

  Widget _buildPRCard(PersonalRecord pr) {
    return Consumer<UnitsProvider>(
      builder: (context, unitsProvider, child) {
        // Convert stored one rep max (kg) to display weight for current unit
        double? displayOneRepMax = pr.oneRepMax;
        if (displayOneRepMax != null && unitsProvider.weightUnit == 'lbs') {
          displayOneRepMax = displayOneRepMax / 0.453592; // Convert kg to lbs
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getPRIcon(pr.type),
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pr.exerciseName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildPRValue(pr, unitsProvider),
                    ],
                  ),
                ),
                if (pr.type == PersonalRecordType.weight)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${displayOneRepMax?.toStringAsFixed(1) ?? 'N/A'}${unitsProvider.weightUnit}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        '1RM',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                        ),
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

  Widget _buildPRValue(PersonalRecord pr, UnitsProvider unitsProvider) {
    String value;
    switch (pr.type) {
      case PersonalRecordType.weight:
        // Convert stored weight (kg) to display weight for current unit
        double? displayWeight = pr.weight;
        if (displayWeight != null && unitsProvider.weightUnit == 'lbs') {
          displayWeight = displayWeight / 0.453592; // Convert kg to lbs
        }
        value =
            '${displayWeight?.toStringAsFixed(1) ?? 'N/A'} ${unitsProvider.weightUnit} × ${pr.reps ?? 'N/A'} reps';
        break;
      case PersonalRecordType.distance:
        value = '${pr.distance?.toStringAsFixed(2) ?? 'N/A'} km';
        break;
      case PersonalRecordType.duration:
        value = '${pr.duration?.inMinutes ?? 'N/A'} minutes';
        break;
      case PersonalRecordType.pace:
        value = '${pr.pace?.toStringAsFixed(2) ?? 'N/A'} min/km';
        break;
      default:
        value = 'N/A';
    }

    return Text(
      value,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B2027),
      ),
    );
  }

  IconData _getPRIcon(PersonalRecordType type) {
    switch (type) {
      case PersonalRecordType.weight:
        return Icons.fitness_center;
      case PersonalRecordType.distance:
        return Icons.directions_run;
      case PersonalRecordType.duration:
        return Icons.timer_outlined;
      case PersonalRecordType.pace:
        return Icons.speed;
      default:
        return Icons.trending_up;
    }
  }

  Widget _buildAchievementsSection(List<Achievement> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Achievements',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // DEBUG: Achievement recalculation button (only in debug mode)
            if (kDebugMode) ...[
              Consumer<WorkoutProvider>(
                builder: (context, workoutProvider, child) {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      // Show confirmation dialog
                      final shouldRecalculate = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('DEBUG: Recalculate All Data'),
                          content: const Text(
                            'This will delete all current achievements AND personal records, then recalculate them from scratch based on your current exercise data. This action cannot be undone.\n\nContinue?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Recalculate'),
                            ),
                          ],
                        ),
                      );

                      if (shouldRecalculate == true) {
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const AlertDialog(
                            content: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 16),
                                Text('Recalculating all data...'),
                              ],
                            ),
                          ),
                        );

                        try {
                          await workoutProvider
                              .debugRecalculateAllAchievements();

                          if (context.mounted) {
                            Navigator.of(context).pop(); // Close loading dialog

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'DEBUG: Full recalculation completed! Generated ${workoutProvider.personalRecords.length} personal records and ${workoutProvider.achievements.length} achievements.',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.of(context).pop(); // Close loading dialog

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'DEBUG: Error recalculating all data: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('DEBUG: Recalc'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ...achievements
            .take(3)
            .map((achievement) => _buildAchievementCard(achievement)),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.star,
                color: Colors.purple.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatDate(achievement.achievedDate),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(
      String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'No PRs yet...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start logging and let\'s smash some records!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),

              // DEBUG: Achievement recalculation button (only in debug mode)
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                Consumer<WorkoutProvider>(
                  builder: (context, workoutProvider, child) {
                    return ElevatedButton.icon(
                      onPressed: () async {
                        // Show confirmation dialog
                        final shouldRecalculate = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title:
                                const Text('DEBUG: Recalculate Achievements'),
                            content: const Text(
                              'This will delete all current achievements and recalculate them from scratch based on your current exercise data. This action cannot be undone.\n\nContinue?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Recalculate'),
                              ),
                            ],
                          ),
                        );

                        if (shouldRecalculate == true) {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const AlertDialog(
                              content: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 16),
                                  Text('Recalculating all data...'),
                                ],
                              ),
                            ),
                          );

                          try {
                            await workoutProvider
                                .debugRecalculateAllAchievements();

                            if (context.mounted) {
                              Navigator.of(context)
                                  .pop(); // Close loading dialog

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'DEBUG: Full recalculation completed! Generated ${workoutProvider.personalRecords.length} personal records and ${workoutProvider.achievements.length} achievements.',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.of(context)
                                  .pop(); // Close loading dialog

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'DEBUG: Error recalculating all data: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('DEBUG: Recalculate All Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
