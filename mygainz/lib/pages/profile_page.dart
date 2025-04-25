import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                border: Border.all(color: const Color(0xFF1B2027), width: 3),
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Color(0xFF1B2027),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Member since: January 2023',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            // Stats section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(13, 0, 0, 0),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildStatRow('Total Workouts', '42'),
                  const Divider(),
                  _buildStatRow('Workout Streak', '5 days'),
                  const Divider(),
                  _buildStatRow('Favorite Exercise', 'Bench Press'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Settings section
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(13, 0, 0, 0),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSettingsTile('Edit Profile', Icons.edit),
          _buildSettingsTile('Notifications', Icons.notifications),
          _buildSettingsTile('Privacy', Icons.privacy_tip),
          _buildSettingsTile('Help & Support', Icons.help),
          _buildSettingsTile('Log Out', Icons.logout),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1B2027)),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        // Navigate to setting screen
      },
    );
  }
}
