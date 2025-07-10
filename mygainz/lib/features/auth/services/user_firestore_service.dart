import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../../core/services/firestore_service.dart';

class UserFirestoreService extends FirestoreService {
  static const String _collectionName = 'UsersCollection';

  // Create or update user in Firestore
  Future<void> saveUser(User user) async {
    try {
      final userDoc = firestore.collection(_collectionName).doc(user.id);

      final userData = {
        'personalInfo': {
          'name': user.name,
          'lastName': user.lastName,
          'dateOfBirth': dateTimeToTimestamp(user.dateOfBirth),
          'email': user.email,
          'createdAt': dateTimeToTimestamp(user.createdAt),
          'updatedAt': dateTimeToTimestamp(user.updatedAt),
        },
        'fitnessInfo': {
          'height': user.height, // Always in cm
          'weight': user.weight, // Always in kg
          'fatPercentage': user.fatPercentage,
          'musclePercentage': user.musclePercentage,
        },
        'preferences': {
          'weightUnit': 'kg', // Default, can be updated separately
          'heightUnit': 'cm', // Default, can be updated separately
          'distanceUnit': 'km', // Default, can be updated separately
        },
        // Computed fields for queries
        'age': user.age,
        'fullName': user.fullName,
      };

      await userDoc.set(userData, SetOptions(merge: true));
      if (kDebugMode) print('User saved to Firestore: ${user.email}');
    } catch (e) {
      if (kDebugMode) print('Error saving user to Firestore: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Get user from Firestore
  Future<User?> getUser(String userId) async {
    try {
      final userDoc =
          await firestore.collection(_collectionName).doc(userId).get();

      if (!userDoc.exists) {
        if (kDebugMode) print('User document not found for ID: $userId');
        return null;
      }

      final data = userDoc.data()!;
      return _parseUserFromFirestore(userId, data);
    } catch (e) {
      if (kDebugMode) print('Error getting user from Firestore: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences({
    String? weightUnit,
    String? heightUnit,
    String? distanceUnit,
  }) async {
    try {
      final userId = authenticatedUserId;
      final userDoc = firestore.collection(_collectionName).doc(userId);

      final updates = <String, dynamic>{};
      if (weightUnit != null) updates['preferences.weightUnit'] = weightUnit;
      if (heightUnit != null) updates['preferences.heightUnit'] = heightUnit;
      if (distanceUnit != null) {
        updates['preferences.distanceUnit'] = distanceUnit;
      }

      if (updates.isNotEmpty) {
        updates['personalInfo.updatedAt'] = dateTimeToTimestamp(DateTime.now());
        await userDoc.update(updates);
        if (kDebugMode) print('User preferences updated');
      }
    } catch (e) {
      if (kDebugMode) print('Error updating user preferences: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Update user fitness info
  Future<void> updateUserFitnessInfo({
    double? height,
    double? weight,
    double? fatPercentage,
    double? musclePercentage,
  }) async {
    try {
      final userId = authenticatedUserId;
      final userDoc = firestore.collection(_collectionName).doc(userId);

      final updates = <String, dynamic>{};
      if (height != null) updates['fitnessInfo.height'] = height;
      if (weight != null) updates['fitnessInfo.weight'] = weight;
      if (fatPercentage != null) {
        updates['fitnessInfo.fatPercentage'] = fatPercentage;
      }
      if (musclePercentage != null) {
        updates['fitnessInfo.musclePercentage'] = musclePercentage;
      }

      if (updates.isNotEmpty) {
        updates['personalInfo.updatedAt'] = dateTimeToTimestamp(DateTime.now());
        await userDoc.update(updates);
        if (kDebugMode) print('User fitness info updated');
      }
    } catch (e) {
      if (kDebugMode) print('Error updating user fitness info: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Update user personal info
  Future<void> updateUserPersonalInfo({
    String? name,
    String? lastName,
    DateTime? dateOfBirth,
  }) async {
    try {
      final userId = authenticatedUserId;
      final userDoc = firestore.collection(_collectionName).doc(userId);

      final updates = <String, dynamic>{};
      if (name != null) updates['personalInfo.name'] = name;
      if (lastName != null) updates['personalInfo.lastName'] = lastName;
      if (dateOfBirth != null) {
        updates['personalInfo.dateOfBirth'] = dateTimeToTimestamp(dateOfBirth);
      }

      if (updates.isNotEmpty) {
        updates['personalInfo.updatedAt'] = dateTimeToTimestamp(DateTime.now());

        // Update computed fields if name or lastName changed
        if (name != null || lastName != null) {
          // We need to get current data to compute fullName
          final currentDoc = await userDoc.get();
          if (currentDoc.exists) {
            final currentData = currentDoc.data()!;
            final currentName = name ?? currentData['personalInfo']['name'];
            final currentLastName =
                lastName ?? currentData['personalInfo']['lastName'];
            updates['fullName'] = '$currentName $currentLastName';
          }
        }

        // Update age if dateOfBirth changed
        if (dateOfBirth != null) {
          final now = DateTime.now();
          int age = now.year - dateOfBirth.year;
          if (now.month < dateOfBirth.month ||
              (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
            age--;
          }
          updates['age'] = age;
        }

        await userDoc.update(updates);
        if (kDebugMode) print('User personal info updated');
      }
    } catch (e) {
      if (kDebugMode) print('Error updating user personal info: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Delete user (soft delete by adding deletedAt timestamp)
  Future<void> deleteUser(String userId) async {
    try {
      final userDoc = firestore.collection(_collectionName).doc(userId);
      await userDoc.update({
        'deletedAt': dateTimeToTimestamp(DateTime.now()),
        'personalInfo.updatedAt': dateTimeToTimestamp(DateTime.now()),
      });
      if (kDebugMode) print('User soft deleted: $userId');
    } catch (e) {
      if (kDebugMode) print('Error deleting user: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Get user preferences
  Future<Map<String, String>?> getUserPreferences(String userId) async {
    try {
      final userDoc =
          await firestore.collection(_collectionName).doc(userId).get();

      if (!userDoc.exists) return null;

      final data = userDoc.data()!;
      final preferences = data['preferences'] as Map<String, dynamic>?;

      if (preferences == null) return null;

      return {
        'weightUnit': preferences['weightUnit'] ?? 'kg',
        'heightUnit': preferences['heightUnit'] ?? 'cm',
        'distanceUnit': preferences['distanceUnit'] ?? 'km',
      };
    } catch (e) {
      if (kDebugMode) print('Error getting user preferences: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Helper method to parse user from Firestore data
  User _parseUserFromFirestore(String userId, Map<String, dynamic> data) {
    final personalInfo = data['personalInfo'] as Map<String, dynamic>;
    final fitnessInfo = data['fitnessInfo'] as Map<String, dynamic>;

    return User(
      id: userId,
      name: personalInfo['name'] ?? '',
      lastName: personalInfo['lastName'] ?? '',
      dateOfBirth:
          timestampToDateTime(personalInfo['dateOfBirth']) ?? DateTime.now(),
      email: personalInfo['email'] ?? '',
      password: '', // Never store password
      height: (fitnessInfo['height'] ?? 170.0).toDouble(),
      weight: (fitnessInfo['weight'] ?? 70.0).toDouble(),
      fatPercentage: (fitnessInfo['fatPercentage'] ?? 15.0).toDouble(),
      musclePercentage: (fitnessInfo['musclePercentage'] ?? 35.0).toDouble(),
      createdAt:
          timestampToDateTime(personalInfo['createdAt']) ?? DateTime.now(),
      updatedAt:
          timestampToDateTime(personalInfo['updatedAt']) ?? DateTime.now(),
    );
  }

  // Stream user data changes
  Stream<User?> streamUser(String userId) {
    return firestore
        .collection(_collectionName)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return _parseUserFromFirestore(userId, doc.data()!);
    });
  }

  // Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      final userDoc =
          await firestore.collection(_collectionName).doc(userId).get();
      return userDoc.exists;
    } catch (e) {
      if (kDebugMode) print('Error checking if user exists: $e');
      return false;
    }
  }
}
