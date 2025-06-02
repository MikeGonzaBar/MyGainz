import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = true; // Start with loading true
  bool _isInitialized = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null && _isInitialized;

  static const String _userKey = 'current_user';
  static const String _usersKey = 'registered_users';

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    print('Starting authentication initialization...');
    try {
      // Add timeout protection
      await Future.wait([
        _loadCurrentUser(),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Auth initialization timed out');
          throw Exception('Authentication initialization timed out');
        },
      );

      print('Auth initialization completed successfully');
    } catch (e) {
      print('Auth initialization error: $e');
      _error = 'Error initializing authentication: ${e.toString()}';
    } finally {
      // Always mark as initialized and stop loading
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      print(
          'Auth initialization finished. Initialized: $_isInitialized, Loading: $_isLoading, User: ${_currentUser?.email ?? 'null'}');
    }
  }

  // Load current user from SharedPreferences
  Future<void> _loadCurrentUser() async {
    try {
      print('Loading current user from SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      print('Raw user data from storage: $userJson');

      if (userJson != null && userJson.isNotEmpty) {
        try {
          final userMap = json.decode(userJson);
          _currentUser = User.fromJson(userMap);
          print('User loaded successfully: ${_currentUser?.email}');
        } catch (e) {
          print('Error parsing user JSON: $e');
          // Clear corrupted data
          await prefs.remove(_userKey);
        }
      } else {
        print('No user data found in SharedPreferences');
      }
    } catch (e) {
      print('Error loading user: $e');
      _error = 'Error loading user session: ${e.toString()}';
    }
  }

  // Save current user to SharedPreferences
  Future<void> _saveCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
      print('User saved successfully: ${user.email}');
    } catch (e) {
      _error = 'Error saving user session';
      print('Error saving user: $e');
      notifyListeners();
    }
  }

  // Get all registered users from SharedPreferences
  Future<List<User>> _getRegisteredUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];

      print('Loading ${usersJson.length} registered users');

      return usersJson.map((userJson) {
        final userMap = json.decode(userJson);
        return User.fromJson(userMap);
      }).toList();
    } catch (e) {
      print('Error loading registered users: $e');
      return [];
    }
  }

  // Save all users to SharedPreferences
  Future<void> _saveRegisteredUsers(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson =
          users.map((user) => json.encode(user.toJson())).toList();
      await prefs.setStringList(_usersKey, usersJson);
      print('Saved ${users.length} registered users');
    } catch (e) {
      _error = 'Error saving user data';
      print('Error saving registered users: $e');
      notifyListeners();
    }
  }

  // Register a new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String lastName,
    required DateTime dateOfBirth,
    required double height,
    required double weight,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if email already exists
      final users = await _getRegisteredUsers();
      if (users
          .any((user) => user.email.toLowerCase() == email.toLowerCase())) {
        _error = 'Email already registered';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new user
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        email: email.toLowerCase(),
        password: password, // In production, hash this
        height: height,
        weight: weight,
        fatPercentage: 15.0, // Default values
        musclePercentage: 35.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to registered users
      users.add(newUser);
      await _saveRegisteredUsers(users);

      // Set as current user
      _currentUser = newUser;
      await _saveCurrentUser(newUser);

      _isLoading = false;
      notifyListeners();
      print('User registered successfully: ${newUser.email}');
      return true;
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('Registration error: $e');
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Find user in registered users
      final users = await _getRegisteredUsers();
      final user = users.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );

      // Check password
      if (user.password != password) {
        _error = 'Invalid password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Set as current user
      _currentUser = user;
      await _saveCurrentUser(user);

      _isLoading = false;
      notifyListeners();
      print('User logged in successfully: ${user.email}');
      return true;
    } catch (e) {
      _error = e.toString().contains('User not found')
          ? 'No account found with this email'
          : 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('Login error: $e');
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUser(User updatedUser) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Update in registered users list
      final users = await _getRegisteredUsers();
      final userIndex = users.indexWhere((user) => user.id == updatedUser.id);

      if (userIndex != -1) {
        users[userIndex] = updatedUser.copyWith(updatedAt: DateTime.now());
        await _saveRegisteredUsers(users);

        // Update current user
        _currentUser = users[userIndex];
        await _saveCurrentUser(_currentUser!);

        _isLoading = false;
        notifyListeners();
        print('User updated successfully: ${_currentUser?.email}');
        return true;
      } else {
        _error = 'User not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Update failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('Update error: $e');
      return false;
    }
  }

  // Update user weight and height
  Future<bool> updateUserStats({
    double? weight,
    double? height,
  }) async {
    if (_currentUser == null) return false;

    final updatedUser = _currentUser!.copyWith(
      weight: weight ?? _currentUser!.weight,
      height: height ?? _currentUser!.height,
    );

    return await updateUser(updatedUser);
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);

      _currentUser = null;
      _error = null;
      notifyListeners();
      print('User logged out successfully');
    } catch (e) {
      _error = 'Error during logout';
      print('Logout error: $e');
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if email exists (for validation)
  Future<bool> emailExists(String email) async {
    final users = await _getRegisteredUsers();
    return users.any((user) => user.email.toLowerCase() == email.toLowerCase());
  }

  // Delete account
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Remove from registered users
      final users = await _getRegisteredUsers();
      users.removeWhere((user) => user.id == _currentUser!.id);
      await _saveRegisteredUsers(users);

      // Clear current user
      await logout();

      _isLoading = false;
      notifyListeners();
      print('Account deleted successfully');
      return true;
    } catch (e) {
      _error = 'Failed to delete account: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('Delete account error: $e');
      return false;
    }
  }

  // Debug method to check what's stored
  Future<void> debugPrintStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserJson = prefs.getString(_userKey);
      final usersJson = prefs.getStringList(_usersKey);

      print('=== DEBUG STORED DATA ===');
      print('Current user: $currentUserJson');
      print('Registered users count: ${usersJson?.length ?? 0}');
      print('Registered users: $usersJson');
      print(
          'Auth state - Initialized: $_isInitialized, Loading: $_isLoading, LoggedIn: $isLoggedIn');
      print('========================');
    } catch (e) {
      print('Error debugging stored data: $e');
    }
  }

  // Force complete initialization (for debugging)
  void forceCompleteInitialization() {
    print('Force completing initialization...');
    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  // Get current auth state for debugging
  String getAuthStateDebug() {
    return 'AuthProvider State:\n'
        '- Initialized: $_isInitialized\n'
        '- Loading: $_isLoading\n'
        '- Has User: ${_currentUser != null}\n'
        '- User Email: ${_currentUser?.email ?? 'null'}\n'
        '- Error: ${_error ?? 'none'}\n'
        '- Is Logged In: $isLoggedIn';
  }

  // Change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Verify old password
      if (_currentUser!.password != oldPassword) {
        _error = 'Current password is incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Update password in current user
      final updatedUser = _currentUser!.copyWith(
        password: newPassword,
        updatedAt: DateTime.now(),
      );

      // Update in registered users list
      final users = await _getRegisteredUsers();
      final userIndex = users.indexWhere((user) => user.id == updatedUser.id);

      if (userIndex != -1) {
        users[userIndex] = updatedUser;
        await _saveRegisteredUsers(users);

        // Update current user
        _currentUser = updatedUser;
        await _saveCurrentUser(_currentUser!);

        _isLoading = false;
        notifyListeners();
        print('Password updated successfully');
        return true;
      } else {
        _error = 'User not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to change password: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('Change password error: $e');
      return false;
    }
  }

  // Update user profile (name, email)
  Future<bool> updateProfile({
    String? name,
    String? lastName,
    String? email,
  }) async {
    if (_currentUser == null) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if email already exists (if email is being changed)
      if (email != null &&
          email.toLowerCase() != _currentUser!.email.toLowerCase()) {
        final users = await _getRegisteredUsers();
        if (users
            .any((user) => user.email.toLowerCase() == email.toLowerCase())) {
          _error = 'Email already in use by another account';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Update user profile
      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        lastName: lastName ?? _currentUser!.lastName,
        email: email?.toLowerCase() ?? _currentUser!.email,
        updatedAt: DateTime.now(),
      );

      return await updateUser(updatedUser);
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('Update profile error: $e');
      return false;
    }
  }
}
