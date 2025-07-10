import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../exercises/providers/workout_provider.dart';
import '../../../core/providers/units_provider.dart';
import '../services/data_export_service.dart';

class DownloadDataButton extends StatelessWidget {
  const DownloadDataButton({super.key});

  Future<void> _downloadPersonalData(
    BuildContext context,
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
      if (context.mounted) {
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
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
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
                        context, authProvider, workoutProvider, unitsProvider);
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

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, WorkoutProvider, UnitsProvider>(
      builder: (context, authProvider, workoutProvider, unitsProvider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await _downloadPersonalData(
                  context, authProvider, workoutProvider, unitsProvider);
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
}
