import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings state variables
  bool _isDarkMode = false;
  bool _workoutReminders = true;
  bool _achievementNotifications = true;
  bool _weeklyProgressSummary = true;
  bool _restTimerAlerts = true;
  bool _autoSaveWorkouts = true;

  String _weightUnit = 'kg';
  String _heightUnit = 'cm';
  String _distanceUnit = 'km';
  String _language = 'English';
  int _defaultRestTimer = 60; // seconds

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2027),
        foregroundColor: Colors.white,
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Units & Measurements Section
            _buildSectionHeader('Units & Measurements'),
            _buildSettingsCard([
              _buildDropdownTile(
                icon: Icons.monitor_weight,
                title: 'Weight Unit',
                value: _weightUnit,
                options: ['kg', 'lbs'],
                onChanged: (value) => setState(() => _weightUnit = value!),
              ),
              _buildDropdownTile(
                icon: Icons.height,
                title: 'Height Unit',
                value: _heightUnit,
                options: ['cm', 'ft-in'],
                onChanged: (value) => setState(() => _heightUnit = value!),
              ),
              _buildDropdownTile(
                icon: Icons.straighten,
                title: 'Distance Unit',
                value: _distanceUnit,
                options: ['km', 'miles'],
                onChanged: (value) => setState(() => _distanceUnit = value!),
              ),
            ]),

            const SizedBox(height: 24),

            // Workout Preferences Section
            _buildSectionHeader('Workout Preferences'),
            _buildSettingsCard([
              _buildSliderTile(
                icon: Icons.timer,
                title: 'Default Rest Timer',
                subtitle: '$_defaultRestTimer seconds',
                value: _defaultRestTimer.toDouble(),
                min: 30,
                max: 300,
                divisions: 27,
                onChanged:
                    (value) =>
                        setState(() => _defaultRestTimer = value.round()),
              ),
              _buildSwitchTile(
                icon: Icons.save,
                title: 'Auto-save Workouts',
                subtitle: 'Automatically save workout progress',
                value: _autoSaveWorkouts,
                onChanged: (value) => setState(() => _autoSaveWorkouts = value),
              ),
            ]),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.fitness_center,
                title: 'Workout Reminders',
                subtitle: 'Get reminded about your workouts',
                value: _workoutReminders,
                onChanged: (value) => setState(() => _workoutReminders = value),
              ),
              _buildSwitchTile(
                icon: Icons.emoji_events,
                title: 'Achievement Notifications',
                subtitle: 'Get notified about achievements',
                value: _achievementNotifications,
                onChanged:
                    (value) =>
                        setState(() => _achievementNotifications = value),
              ),
              _buildSwitchTile(
                icon: Icons.trending_up,
                title: 'Weekly Progress Summary',
                subtitle: 'Receive weekly progress reports',
                value: _weeklyProgressSummary,
                onChanged:
                    (value) => setState(() => _weeklyProgressSummary = value),
              ),
              _buildSwitchTile(
                icon: Icons.timer_outlined,
                title: 'Rest Timer Alerts',
                subtitle: 'Get alerted when rest time is up',
                value: _restTimerAlerts,
                onChanged: (value) => setState(() => _restTimerAlerts = value),
              ),
            ]),

            const SizedBox(height: 24),

            // Display & Interface Section
            _buildSectionHeader('Display & Interface'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                value: _isDarkMode,
                onChanged: (value) => setState(() => _isDarkMode = value),
              ),
              _buildDropdownTile(
                icon: Icons.language,
                title: 'Language',
                value: _language,
                options: ['English', 'Spanish', 'French', 'German'],
                onChanged: (value) => setState(() => _language = value!),
              ),
            ]),

            const SizedBox(height: 24),

            // Account Management Section
            _buildSectionHeader('Account Management'),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.person,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () {
                  // TODO: Navigate to edit profile page
                  _showToast('Edit Profile feature coming soon');
                },
              ),
              _buildActionTile(
                icon: Icons.lock,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () {
                  // TODO: Navigate to change password page
                  _showToast('Change Password feature coming soon');
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Data Management Section
            _buildSectionHeader('Data Management'),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.cloud_upload,
                title: 'Backup Data',
                subtitle: 'Backup your data to the cloud',
                onTap: () {
                  // TODO: Implement backup functionality
                  _showToast('Backup functionality coming soon');
                },
              ),
              _buildActionTile(
                icon: Icons.file_download,
                title: 'Export Data',
                subtitle: 'Download your workout data',
                onTap: () {
                  // TODO: Implement export functionality
                  _showToast('Export functionality coming soon');
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Danger Zone Section
            _buildSectionHeader('Danger Zone'),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                onTap: () => _showDeleteAccountDialog(),
                isDestructive: true,
              ),
            ]),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1B2027),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        onChanged: onChanged,
        items:
            options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.grey.shade600),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: const Color(0xFF1B2027),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDestructive ? Colors.red.shade300 : Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: isDestructive ? Colors.red.shade300 : Colors.grey.shade400,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showToast('Account deletion feature coming soon');
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
