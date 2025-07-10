import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/units_provider.dart';
import 'edit_profile_page.dart';
import '../../auth/pages/change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings state variables (except units which are now managed by UnitsProvider)

// seconds

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
      body: Consumer<UnitsProvider>(
        builder: (context, unitsProvider, child) {
          return SingleChildScrollView(
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
                    value: unitsProvider.weightUnit,
                    options: unitsProvider.weightUnitOptions,
                    onChanged: (value) => unitsProvider.setWeightUnit(value!),
                  ),
                  _buildDropdownTile(
                    icon: Icons.height,
                    title: 'Height Unit',
                    value: unitsProvider.heightUnit,
                    options: unitsProvider.heightUnitOptions,
                    onChanged: (value) => unitsProvider.setHeightUnit(value!),
                  ),
                  _buildDropdownTile(
                    icon: Icons.straighten,
                    title: 'Distance Unit',
                    value: unitsProvider.distanceUnit,
                    options: unitsProvider.distanceUnitOptions,
                    onChanged: (value) => unitsProvider.setDistanceUnit(value!),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditProfilePage()),
                      );
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.lock,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangePasswordPage()),
                      );
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
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        onChanged: onChanged,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDestructive ? Colors.red : Colors.black87,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDestructive ? Colors.red.shade300 : Colors.grey.shade600,
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
        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
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
                  onPressed: authProvider.isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          Navigator.of(context).pop();

                          final success = await authProvider.deleteAccount();

                          if (success) {
                            if (mounted) {
                              _showToast('Account deleted successfully');
                              // Navigation back to login will be handled by AuthWrapper
                            }
                          } else {
                            if (mounted) {
                              _showToast(authProvider.error ??
                                  'Failed to delete account');
                            }
                          }
                        },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
