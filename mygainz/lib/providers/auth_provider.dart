import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart' as local_user;
import '../services/user_firestore_service.dart';

class AuthProvider with ChangeNotifier {
  local_user.User? _currentUser;
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _error;

  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final UserFirestoreService _userFirestoreService = UserFirestoreService();

  local_user.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null && _isInitialized;

  // Static method to initialize AuthProvider
  static AuthProvider? _instance;
  static AuthProvider get instance {
    _instance ??= AuthProvider();
    return _instance!;
  }

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    print('Starting Firebase authentication initialization...');
    try {
      // Clean up any old authentication data first
      await cleanupOldAuthData();

      // Listen to auth state changes
      _firebaseAuth.authStateChanges().listen((firebase_auth.User? user) {
        print('=== AUTH STATE CHANGE ===');
        if (user != null) {
          print('User authenticated, loading data...');
          _printFirebaseUserInfo(user);
          _loadUserData(user.uid);
        } else {
          print('User signed out or not authenticated');
          _currentUser = null;
          notifyListeners();
        }
        print('========================');
      });

      // Check current user
      final firebase_auth.User? currentFirebaseUser = _firebaseAuth.currentUser;
      if (currentFirebaseUser != null) {
        await _loadUserData(currentFirebaseUser.uid);
      }

      print('Firebase auth initialization completed successfully');
    } catch (e) {
      print('Firebase auth initialization error: $e');
      _error = 'Error initializing authentication: ${e.toString()}';
    } finally {
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      print(
          'Auth initialization finished. Initialized: $_isInitialized, Loading: $_isLoading, User: ${_currentUser?.email ?? 'null'}');
    }
  }

  // Load user data from Firestore using Firebase UID
  Future<void> _loadUserData(String uid) async {
    try {
      print('Loading user data from Firestore for UID: $uid');

      final user = await _userFirestoreService.getUser(uid);

      if (user != null) {
        _currentUser = user;
        print('User data loaded from Firestore: ${user.email}');
      } else {
        print('No user data found in Firestore for UID: $uid');
        // Create default user from Firebase data
        await _createDefaultUserFromFirebase();
      }

      notifyListeners();
    } catch (e) {
      print('Error loading user data from Firestore: $e');
      _error = 'Error loading user data';
      notifyListeners();
    }
  }

  // Helper method to create default user from Firebase data
  Future<void> _createDefaultUserFromFirebase() async {
    final firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      // Debug: Print all Firebase user information
      _printFirebaseUserInfo(firebaseUser);

      _currentUser = local_user.User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName?.split(' ').first ?? 'User',
        lastName: firebaseUser.displayName?.split(' ').skip(1).join(' ') ?? '',
        dateOfBirth: DateTime.now()
            .subtract(const Duration(days: 365 * 25)), // Default age
        email: firebaseUser.email ?? '',
        password: '', // Not stored locally
        height: 170.0, // Default height
        weight: 70.0, // Default weight
        fatPercentage: 15.0,
        musclePercentage: 35.0,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the default user data to Firestore
      await _userFirestoreService.saveUser(_currentUser!);
      print(
          'Created and saved default user to Firestore: ${_currentUser?.email}');
    }
  }

  // Debug method to print all Firebase user information
  void _printFirebaseUserInfo(firebase_auth.User user) {
    print('=== FIREBASE USER DEBUG INFO ===');
    print('UID: ${user.uid}');
    print('Email: ${user.email}');
    print('Display Name: ${user.displayName}');
    print('Photo URL: ${user.photoURL}');
    print('Phone Number: ${user.phoneNumber}');
    print('Email Verified: ${user.emailVerified}');
    print('Is Anonymous: ${user.isAnonymous}');
    print('Tenant ID: ${user.tenantId}');
    print('Refresh Token: ${user.refreshToken}');
    print('Creation Time: ${user.metadata.creationTime}');
    print('Last Sign In Time: ${user.metadata.lastSignInTime}');
    print('Provider Data:');
    for (var providerData in user.providerData) {
      print('  - Provider ID: ${providerData.providerId}');
      print('  - UID: ${providerData.uid}');
      print('  - Display Name: ${providerData.displayName}');
      print('  - Email: ${providerData.email}');
      print('  - Phone Number: ${providerData.phoneNumber}');
      print('  - Photo URL: ${providerData.photoURL}');
    }
    print('================================');
  }

  // Save user data to Firestore using Firebase UID
  Future<void> _saveUserData(local_user.User user) async {
    try {
      await _userFirestoreService.saveUser(user);
      print('User data saved to Firestore successfully: ${user.email}');
    } catch (e) {
      _error = 'Error saving user data';
      print('Error saving user data to Firestore: $e');
      notifyListeners();
    }
  }

  // Register a new user with Firebase Auth
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

      // Create user with Firebase Auth
      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Debug: Print all Firebase user information
        print('=== REGISTRATION SUCCESS ===');
        _printFirebaseUserInfo(userCredential.user!);

        // Update Firebase user display name
        await userCredential.user!.updateDisplayName('$name $lastName');

        // Create local user data
        final newUser = local_user.User(
          id: userCredential.user!.uid,
          name: name,
          lastName: lastName,
          dateOfBirth: dateOfBirth,
          email: email.toLowerCase(),
          password: '', // Don't store password locally
          height: height,
          weight: weight,
          fatPercentage: 15.0, // Default values
          musclePercentage: 35.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save user data locally
        await _saveUserData(newUser);
        _currentUser = newUser;

        _isLoading = false;
        notifyListeners();
        print('User registered successfully: ${newUser.email}');
        return true;
      }

      _error = 'Failed to create user account';
      _isLoading = false;
      notifyListeners();
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      print('Registration error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('Registration error: $e');
      return false;
    }
  }

  // Login user with Firebase Auth
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Sign in with Firebase Auth
      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Debug: Print all Firebase user information
        print('=== LOGIN SUCCESS ===');
        _printFirebaseUserInfo(userCredential.user!);

        // Load user data
        await _loadUserData(userCredential.user!.uid);

        _isLoading = false;
        notifyListeners();
        print('User logged in successfully: ${userCredential.user!.email}');
        return true;
      }

      _error = 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      print('Login error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('Login error: $e');
      return false;
    }
  }

  // Update user data
  Future<bool> updateUser(local_user.User updatedUser) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Update Firebase user display name if changed
      final firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        final newDisplayName = '${updatedUser.name} ${updatedUser.lastName}';
        if (firebaseUser.displayName != newDisplayName) {
          await firebaseUser.updateDisplayName(newDisplayName);
        }
      }

      // Update user data in Firestore
      final userWithTimestamp = updatedUser.copyWith(updatedAt: DateTime.now());
      await _userFirestoreService.saveUser(userWithTimestamp);
      _currentUser = userWithTimestamp;

      _isLoading = false;
      notifyListeners();
      print('User updated successfully in Firestore: ${_currentUser?.email}');
      return true;
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
    double? fatPercentage,
    double? musclePercentage,
  }) async {
    if (_currentUser == null) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Update fitness info in Firestore
      await _userFirestoreService.updateUserFitnessInfo(
        weight: weight,
        height: height,
        fatPercentage: fatPercentage,
        musclePercentage: musclePercentage,
      );

      // Update local user data
      _currentUser = _currentUser!.copyWith(
        weight: weight ?? _currentUser!.weight,
        height: height ?? _currentUser!.height,
        fatPercentage: fatPercentage ?? _currentUser!.fatPercentage,
        musclePercentage: musclePercentage ?? _currentUser!.musclePercentage,
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      print('User stats updated successfully in Firestore');
      return true;
    } catch (e) {
      _error = 'Stats update failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('Stats update error: $e');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
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
  // NOTE: fetchSignInMethodsForEmail is deprecated for security reasons.
  // We now rely on Firebase registration errors to handle duplicate emails.
  Future<bool> emailExists(String email) async {
    // Always return false - let Firebase handle email validation during registration
    // This prevents email enumeration attacks
    return false;
  }

  // Delete account
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Delete user data from Firestore
      await _userFirestoreService.deleteUser(_currentUser!.id);

      // Delete Firebase user
      final firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.delete();
      }

      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      print('Account deleted successfully');
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      print('Delete account error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      _error = 'Failed to delete account: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('Delete account error: $e');
      return false;
    }
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

      final firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Re-authenticate user with old password
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: firebaseUser.email!,
        password: oldPassword,
      );

      await firebaseUser.reauthenticateWithCredential(credential);

      // Update password
      await firebaseUser.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      print('Password updated successfully');
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      print('Change password error: ${e.code} - ${e.message}');
      return false;
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

      final firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Update email in Firebase if changed (requires verification)
      if (email != null &&
          email.toLowerCase() != _currentUser!.email.toLowerCase()) {
        await firebaseUser.verifyBeforeUpdateEmail(email.toLowerCase());
        // Note: Email will only be updated after user verifies the new email
      }

      // Update display name in Firebase if name changed
      final newName = name ?? _currentUser!.name;
      final newLastName = lastName ?? _currentUser!.lastName;
      final newDisplayName = '$newName $newLastName';
      if (firebaseUser.displayName != newDisplayName) {
        await firebaseUser.updateDisplayName(newDisplayName);
      }

      // Update local user profile
      final updatedUser = _currentUser!.copyWith(
        name: newName,
        lastName: newLastName,
        email: email?.toLowerCase() ?? _currentUser!.email,
        updatedAt: DateTime.now(),
      );

      return await updateUser(updatedUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      print('Update profile error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('Update profile error: $e');
      return false;
    }
  }

  // Debug method to check what's stored
  Future<void> debugPrintStoredData() async {
    try {
      final firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;

      print('=== DEBUG FIREBASE AUTH DATA ===');
      print('Firebase user: ${firebaseUser?.email ?? 'null'}');
      print('Firebase UID: ${firebaseUser?.uid ?? 'null'}');
      print('Current user: ${_currentUser?.email ?? 'null'}');
      print(
          'Auth state - Initialized: $_isInitialized, Loading: $_isLoading, LoggedIn: $isLoggedIn');

      if (firebaseUser != null) {
        try {
          final firestoreUser =
              await _userFirestoreService.getUser(firebaseUser.uid);
          print('Firestore user data: ${firestoreUser?.email ?? 'null'}');
          print('Firestore user name: ${firestoreUser?.fullName ?? 'null'}');
          print(
              'Firestore user created: ${firestoreUser?.createdAt ?? 'null'}');
        } catch (e) {
          print('Error fetching Firestore user: $e');
        }
      }

      print('===============================');
    } catch (e) {
      print('Error debugging stored data: $e');
    }
  }

  // Clean up old authentication data that might cause crashes
  Future<void> cleanupOldAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove old authentication keys from previous implementation
      await prefs.remove('current_user');
      await prefs.remove('registered_users');

      // Get all keys and remove any old user data format
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('user_data_')) {
          // Old format, remove it
          await prefs.remove(key);
          print('Removed old data key: $key');
        }
      }

      print('Cleanup of old authentication data completed');
    } catch (e) {
      print('Error during cleanup: $e');
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
        '- Firebase User: ${_firebaseAuth.currentUser?.email ?? 'null'}\n'
        '- Error: ${_error ?? 'none'}\n'
        '- Is Logged In: $isLoggedIn';
  }

  // Convert Firebase Auth error codes to user-friendly messages
  String _getFirebaseErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Invalid password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  // Clear user data (for logout/cleanup)
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove any remaining old SharedPreferences data
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('user_data_')) {
          await prefs.remove(key);
          print('Removed old user data key: $key');
        }
      }

      print('User data cleared from local storage');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }
}
