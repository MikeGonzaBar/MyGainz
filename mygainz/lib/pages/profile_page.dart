import 'package:flutter/material.dart';
import 'login_page.dart';
import 'settings_page.dart';

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

  User copyWith({
    String? name,
    String? lastName,
    DateTime? dateOfBirth,
    String? email,
    double? height,
    double? weight,
    double? fatPercentage,
    double? musclePercentage,
  }) {
    return User(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      musclePercentage: musclePercentage ?? this.musclePercentage,
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User data following the database structure
  User currentUser = User(
    name: 'John',
    lastName: 'Anderson',
    dateOfBirth: DateTime(1990, 5, 15),
    email: 'john.anderson@email.com',
    height: 175.0,
    weight: 75.0,
    fatPercentage: 15.0,
    musclePercentage: 40.0,
  );

  // Muscle group focus data with colors
  final Map<String, Map<String, dynamic>> muscleGroupFocus = {
    'Chest': {'percentage': 65.0, 'color': Colors.blue},
    'Back': {'percentage': 45.0, 'color': Colors.green},
    'Legs': {'percentage': 80.0, 'color': Colors.purple},
    'Arms': {'percentage': 55.0, 'color': Colors.orange},
  };

  void _editWeight() {
    _showEditDialog(
      title: 'Edit Weight',
      currentValue: currentUser.weight.toString(),
      unit: 'kg',
      onSave: (value) {
        final newWeight = double.tryParse(value);
        if (newWeight != null && newWeight > 0 && newWeight < 500) {
          setState(() {
            currentUser = currentUser.copyWith(weight: newWeight);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Weight updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid weight')),
          );
        }
      },
    );
  }

  void _editHeight() {
    _showEditDialog(
      title: 'Edit Height',
      currentValue: currentUser.height.toString(),
      unit: 'cm',
      onSave: (value) {
        final newHeight = double.tryParse(value);
        if (newHeight != null && newHeight > 0 && newHeight < 300) {
          setState(() {
            currentUser = currentUser.copyWith(height: newHeight);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Height updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid height')),
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Profile Section
            _buildUserProfileSection(),
            const SizedBox(height: 32),

            // Weight and Height Stats
            _buildStatsSection(),
            const SizedBox(height: 32),

            // Muscle Group Focus Section
            _buildMuscleGroupFocusSection(),
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
  }

  Widget _buildUserProfileSection() {
    return Column(
      children: [
        Text(
          '${currentUser.name} ${currentUser.lastName}',
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
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildEditableStatCard(
            icon: Icons.monitor_weight,
            label: 'Weight',
            value: '${currentUser.weight.toInt()} kg',
            onTap: _editWeight,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildEditableStatCard(
            icon: Icons.height,
            label: 'Height',
            value: '${currentUser.height.toInt()} cm',
            onTap: _editHeight,
          ),
        ),
      ],
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
              color: Colors.grey.withOpacity(0.1),
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
                Icon(Icons.edit, size: 16, color: Colors.grey.shade400),
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

  Widget _buildMuscleGroupFocusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Muscle Group Focus',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        ...muscleGroupFocus.entries.map(
          (entry) => _buildMuscleGroupItem(
            entry.key,
            entry.value['percentage'],
            entry.value['color'],
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleGroupItem(
    String muscleName,
    double percentage,
    Color color,
  ) {
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement download personal data functionality
          print('Download personal data requested');
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
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
        _buildMenuTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {
            // TODO: Navigate to Help & Support page
            print('Navigate to Help & Support');
          },
        ),
        _buildMenuTile(
          icon: Icons.info_outline,
          title: 'About',
          onTap: () {
            // TODO: Navigate to About page
            print('Navigate to About');
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
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}
