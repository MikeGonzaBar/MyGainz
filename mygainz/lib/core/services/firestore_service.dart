import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  // Get authenticated user reference
  String get authenticatedUserId {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('User not authenticated');
    }
    return uid;
  }

  // Helper method to create document with auto-generated ID
  DocumentReference createDocumentRef(String collection) {
    return _firestore.collection(collection).doc();
  }

  // Helper method to get collection reference
  CollectionReference getCollection(String collection) {
    return _firestore.collection(collection);
  }

  // Helper method to get user-specific query
  Query getUserQuery(String collection) {
    return _firestore
        .collection(collection)
        .where('userId', isEqualTo: authenticatedUserId);
  }

  // Helper method for batch operations
  WriteBatch createBatch() {
    return _firestore.batch();
  }

  // Helper method to handle Firestore errors
  String handleFirestoreError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Access denied. Please check your permissions.';
        case 'not-found':
          return 'Document not found.';
        case 'already-exists':
          return 'Document already exists.';
        case 'resource-exhausted':
          return 'Too many requests. Please try again later.';
        case 'failed-precondition':
          return 'Operation failed. Please try again.';
        case 'aborted':
          return 'Operation was aborted. Please try again.';
        case 'out-of-range':
          return 'Invalid data range.';
        case 'unimplemented':
          return 'Operation not supported.';
        case 'internal':
          return 'Internal server error. Please try again.';
        case 'unavailable':
          return 'Service temporarily unavailable. Please try again.';
        case 'data-loss':
          return 'Data loss occurred. Please contact support.';
        case 'unauthenticated':
          return 'Authentication required. Please log in.';
        case 'deadline-exceeded':
          return 'Request timeout. Please try again.';
        case 'cancelled':
          return 'Operation was cancelled.';
        default:
          return 'An error occurred: ${error.message}';
      }
    }
    return 'An unexpected error occurred: $error';
  }

  // Helper method to convert Firestore timestamp to DateTime
  DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is DateTime) {
      return timestamp;
    }
    return null;
  }

  // Helper method to convert DateTime to Firestore timestamp
  Timestamp? dateTimeToTimestamp(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }
}
