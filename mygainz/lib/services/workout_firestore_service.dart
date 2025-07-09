import '../models/exercise.dart';
import '../models/routine.dart';
import '../models/personal_record.dart';
import '../models/workout_set.dart';
import '../providers/workout_provider.dart';
import 'firestore_service.dart';

class WorkoutFirestoreService extends FirestoreService {
  static const String _exercisesCollection = 'ExerciseCollection';
  static const String _routinesCollection = 'RoutinesCollection';
  static const String _workoutSessionsCollection = 'workoutSessionsCollections';
  static const String _routineSessionsCollection = 'RoutineSessionsCollection';
  static const String _personalRecordsCollection = 'PersonalRecordsCollection';
  static const String _achievementsCollection = 'AchievementsCollection';

  // ==================== EXERCISES ====================

  // Save exercise
  Future<String> saveExercise(Exercise exercise) async {
    try {
      final exerciseDoc = exercise.id.isEmpty
          ? createDocumentRef(_exercisesCollection)
          : firestore.collection(_exercisesCollection).doc(exercise.id);

      final exerciseData = {
        'userId': authenticatedUserId,
        'exerciseName': exercise.exerciseName,
        'targetMuscles': exercise.targetMuscles,
        'equipment': exercise.equipment,
        'exerciseType': exercise.exerciseType.toString(),
        'isCustom': true, // User-created exercises
        'createdAt': dateTimeToTimestamp(DateTime.now()),
      };

      // Add cardio metrics if present
      if (exercise.cardioMetrics != null) {
        exerciseData['cardioMetrics'] = exercise.cardioMetrics!.toJson();
      }

      await exerciseDoc.set(exerciseData);
      print('Exercise saved to Firestore: ${exercise.exerciseName}');
      return exerciseDoc.id;
    } catch (e) {
      print('Error saving exercise: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Get user exercises
  Future<List<Exercise>> getUserExercises() async {
    try {
      final query = getUserQuery(_exercisesCollection);
      final snapshot = await query.get();

      final exercises = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _parseExerciseFromFirestore(doc.id, data);
      }).toList();

      // Sort by exercise name for now (simple client-side sorting)
      exercises.sort((a, b) => a.exerciseName.compareTo(b.exerciseName));

      return exercises;
    } catch (e) {
      print('Error getting user exercises: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Get exercise by ID
  Future<Exercise?> getExercise(String exerciseId) async {
    try {
      final doc = await firestore
          .collection(_exercisesCollection)
          .doc(exerciseId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return _parseExerciseFromFirestore(doc.id, data);
    } catch (e) {
      print('Error getting exercise: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Delete exercise
  Future<void> deleteExercise(String exerciseId) async {
    try {
      await firestore.collection(_exercisesCollection).doc(exerciseId).delete();
      print('Exercise deleted from Firestore: $exerciseId');
    } catch (e) {
      print('Error deleting exercise: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // ==================== ROUTINES ====================

  // Save routine
  Future<String> saveRoutine(Routine routine) async {
    try {
      final routineDoc = routine.id.isEmpty
          ? createDocumentRef(_routinesCollection)
          : firestore.collection(_routinesCollection).doc(routine.id);

      final routineData = {
        'userId': authenticatedUserId,
        'name': routine.name,
        'orderIsRequired': routine.orderIsRequired,
        'exerciseIds': routine.exerciseIds,
        'createdAt': dateTimeToTimestamp(DateTime.now()),
        'updatedAt': dateTimeToTimestamp(DateTime.now()),
        'isActive': true,
      };

      await routineDoc.set(routineData);
      print('Routine saved to Firestore: ${routine.name}');
      return routineDoc.id;
    } catch (e) {
      print('Error saving routine: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Get user routines
  Future<List<Routine>> getUserRoutines() async {
    try {
      final query =
          getUserQuery(_routinesCollection).where('isActive', isEqualTo: true);

      final snapshot = await query.get();

      final routines = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _parseRoutineFromFirestore(doc.id, data);
      }).toList();

      // Sort by routine name (simple client-side sorting)
      routines.sort((a, b) => a.name.compareTo(b.name));

      return routines;
    } catch (e) {
      print('Error getting user routines: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Delete routine (soft delete)
  Future<void> deleteRoutine(String routineId) async {
    try {
      await firestore.collection(_routinesCollection).doc(routineId).update({
        'isActive': false,
        'updatedAt': dateTimeToTimestamp(DateTime.now()),
      });
      print('Routine soft deleted from Firestore: $routineId');
    } catch (e) {
      print('Error deleting routine: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // ==================== WORKOUT SESSIONS ====================

  // Log exercise session
  Future<String> logExerciseSession(LoggedExercise exercise) async {
    try {
      final sessionDoc = createDocumentRef(_workoutSessionsCollection);

      final sessionData = {
        'userId': authenticatedUserId,
        'sessionType': 'exercise',
        'date': dateTimeToTimestamp(exercise.date),
        'createdAt': dateTimeToTimestamp(DateTime.now()),
        'exerciseId': exercise.exerciseId,
        'exerciseName': exercise.exerciseName,
        'targetMuscles': exercise.targetMuscles,
        'equipment': exercise.equipment,
      };

      // Add individual sets data if available
      if (exercise.individualSets != null &&
          exercise.individualSets!.isNotEmpty) {
        sessionData['individualSets'] =
            exercise.individualSets!.map((set) => set.toJson()).toList();
        sessionData['totalSets'] = exercise.individualSets!.length;

        // Calculate and store aggregated data for easy querying
        final totalWeight = exercise.individualSets!
            .fold<double>(0, (sum, set) => sum + set.weight);
        final totalReps =
            exercise.individualSets!.fold<int>(0, (sum, set) => sum + set.reps);
        sessionData['averageWeight'] =
            totalWeight / exercise.individualSets!.length;
        sessionData['averageReps'] =
            (totalReps / exercise.individualSets!.length).round();
        sessionData['totalVolume'] =
            totalWeight * totalReps; // Total weight × reps

        // Find best set (highest weight × reps)
        final bestSet = exercise.bestSet;
        if (bestSet != null) {
          sessionData['bestSet'] = {
            'weight': bestSet.weight,
            'reps': bestSet.reps,
            'setNumber': bestSet.setNumber,
          };
        }
      } else {
        // Legacy format for backward compatibility
        if (exercise.sets != null) sessionData['sets'] = exercise.sets;
        if (exercise.weight != null) sessionData['weight'] = exercise.weight;
        if (exercise.reps != null) sessionData['reps'] = exercise.reps;
      }

      // Add cardio-specific fields
      if (exercise.distance != null)
        sessionData['distance'] = exercise.distance;
      if (exercise.duration != null)
        sessionData['duration'] = exercise.duration!.inSeconds;
      if (exercise.pace != null) sessionData['pace'] = exercise.pace;
      if (exercise.speed != null) sessionData['speed'] = exercise.speed;
      if (exercise.calories != null)
        sessionData['calories'] = exercise.calories;
      if (exercise.heartRate != null)
        sessionData['heartRate'] = exercise.heartRate;

      await sessionDoc.set(sessionData);
      print('Exercise session logged to Firestore: ${exercise.exerciseName}');
      return sessionDoc.id;
    } catch (e) {
      print('Error logging exercise session: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Log routine session
  Future<String> logRoutineSession(LoggedRoutine routine) async {
    try {
      final sessionDoc = createDocumentRef(_routineSessionsCollection);

      final sessionData = {
        'userId': authenticatedUserId,
        'routineId': routine.routineId,
        'routineName': routine.name,
        'date': dateTimeToTimestamp(routine.date),
        'orderIsRequired': routine.orderIsRequired,
        'exercises': routine.exercises.map((exercise) {
          final exerciseData = <String, dynamic>{
            'exerciseId': exercise.exerciseId,
            'exerciseName': exercise.exerciseName,
            'targetMuscles': exercise.targetMuscles,
            'equipment': exercise.equipment,
          };

          // Handle individual sets data if available
          if (exercise.individualSets != null &&
              exercise.individualSets!.isNotEmpty) {
            exerciseData['individualSets'] =
                exercise.individualSets!.map((set) => set.toJson()).toList();
            exerciseData['totalSets'] = exercise.individualSets!.length;

            // Calculate and store aggregated data for easy querying
            final totalWeight = exercise.individualSets!
                .fold<double>(0, (sum, set) => sum + set.weight);
            final totalReps = exercise.individualSets!
                .fold<int>(0, (sum, set) => sum + set.reps);
            exerciseData['averageWeight'] =
                totalWeight / exercise.individualSets!.length;
            exerciseData['averageReps'] =
                (totalReps / exercise.individualSets!.length).round();
            exerciseData['totalVolume'] =
                totalWeight * totalReps; // Total weight × reps

            // Find best set (highest weight × reps)
            final bestSet = exercise.bestSet;
            if (bestSet != null) {
              exerciseData['bestSet'] = {
                'weight': bestSet.weight,
                'reps': bestSet.reps,
                'setNumber': bestSet.setNumber,
              };
            }

            // Legacy format for backward compatibility
            exerciseData['sets'] = exercise.individualSets!.length;
            exerciseData['weight'] =
                totalWeight / exercise.individualSets!.length;
            exerciseData['reps'] =
                (totalReps / exercise.individualSets!.length).round();
          } else {
            // Legacy format when no individual sets
            if (exercise.sets != null) exerciseData['sets'] = exercise.sets;
            if (exercise.weight != null)
              exerciseData['weight'] = exercise.weight;
            if (exercise.reps != null) exerciseData['reps'] = exercise.reps;
          }

          // Add cardio-specific fields
          if (exercise.distance != null)
            exerciseData['distance'] = exercise.distance;
          if (exercise.duration != null)
            exerciseData['duration'] = exercise.duration!.inSeconds;
          if (exercise.pace != null) exerciseData['pace'] = exercise.pace;
          if (exercise.speed != null) exerciseData['speed'] = exercise.speed;
          if (exercise.calories != null)
            exerciseData['calories'] = exercise.calories;
          if (exercise.heartRate != null)
            exerciseData['heartRate'] = exercise.heartRate;

          return exerciseData;
        }).toList(),
        'createdAt': dateTimeToTimestamp(DateTime.now()),
      };

      await sessionDoc.set(sessionData);
      print('Routine session logged to Firestore: ${routine.name}');
      return sessionDoc.id;
    } catch (e) {
      print('Error logging routine session: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Get workout sessions
  Future<List<LoggedExercise>> getWorkoutSessions({int limit = 50}) async {
    try {
      final query = getUserQuery(_workoutSessionsCollection)
          .where('sessionType', isEqualTo: 'exercise');

      final snapshot = await query.get();

      final sessions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _parseLoggedExerciseFromFirestore(doc.id, data);
      }).toList();

      // Sort by date on client side and limit
      sessions.sort((a, b) => b.date.compareTo(a.date));
      return sessions.take(limit).toList();
    } catch (e) {
      print('Error getting workout sessions: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Get routine sessions
  Future<List<LoggedRoutine>> getRoutineSessions({int limit = 50}) async {
    try {
      final query = getUserQuery(_routineSessionsCollection);
      final snapshot = await query.get();

      final sessions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _parseLoggedRoutineFromFirestore(doc.id, data);
      }).toList();

      // Sort by date on client side and limit
      sessions.sort((a, b) => b.date.compareTo(a.date));
      return sessions.take(limit).toList();
    } catch (e) {
      print('Error getting routine sessions: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Update exercise session
  Future<void> updateExerciseSession(
      String sessionId, LoggedExercise exercise) async {
    try {
      final sessionDoc =
          firestore.collection(_workoutSessionsCollection).doc(sessionId);

      final sessionData = {
        'userId': authenticatedUserId,
        'sessionType': 'exercise',
        'date': dateTimeToTimestamp(exercise.date),
        'updatedAt': dateTimeToTimestamp(DateTime.now()),
        'exerciseId': exercise.exerciseId,
        'exerciseName': exercise.exerciseName,
        'targetMuscles': exercise.targetMuscles,
        'equipment': exercise.equipment,
      };

      // Add individual sets data if available
      if (exercise.individualSets != null &&
          exercise.individualSets!.isNotEmpty) {
        sessionData['individualSets'] =
            exercise.individualSets!.map((set) => set.toJson()).toList();
        sessionData['totalSets'] = exercise.individualSets!.length;

        // Calculate and store aggregated data for easy querying
        final totalWeight = exercise.individualSets!
            .fold<double>(0, (sum, set) => sum + set.weight);
        final totalReps =
            exercise.individualSets!.fold<int>(0, (sum, set) => sum + set.reps);
        sessionData['averageWeight'] =
            totalWeight / exercise.individualSets!.length;
        sessionData['averageReps'] =
            (totalReps / exercise.individualSets!.length).round();
        sessionData['totalVolume'] =
            totalWeight * totalReps; // Total weight × reps

        // Find best set (highest weight × reps)
        final bestSet = exercise.bestSet;
        if (bestSet != null) {
          sessionData['bestSet'] = {
            'weight': bestSet.weight,
            'reps': bestSet.reps,
            'setNumber': bestSet.setNumber,
          };
        }
      } else {
        // Legacy format for backward compatibility
        if (exercise.sets != null) sessionData['sets'] = exercise.sets;
        if (exercise.weight != null) sessionData['weight'] = exercise.weight;
        if (exercise.reps != null) sessionData['reps'] = exercise.reps;
      }

      // Add cardio-specific fields
      if (exercise.distance != null)
        sessionData['distance'] = exercise.distance;
      if (exercise.duration != null)
        sessionData['duration'] = exercise.duration!.inSeconds;
      if (exercise.pace != null) sessionData['pace'] = exercise.pace;
      if (exercise.speed != null) sessionData['speed'] = exercise.speed;
      if (exercise.calories != null)
        sessionData['calories'] = exercise.calories;
      if (exercise.heartRate != null)
        sessionData['heartRate'] = exercise.heartRate;

      await sessionDoc.update(sessionData);
      print('Exercise session updated in Firestore: ${exercise.exerciseName}');
    } catch (e) {
      print('Error updating exercise session: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Delete exercise session
  Future<void> deleteExerciseSession(String sessionId) async {
    try {
      await firestore
          .collection(_workoutSessionsCollection)
          .doc(sessionId)
          .delete();
      print('Exercise session deleted from Firestore: $sessionId');
    } catch (e) {
      print('Error deleting exercise session: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Update routine session exercise with individual sets
  Future<void> updateRoutineSessionExercise(
      String routineSessionId,
      String exerciseId,
      List<WorkoutSetData> individualSets,
      String equipment) async {
    try {
      final routineDoc = firestore
          .collection(_routineSessionsCollection)
          .doc(routineSessionId);
      final routineSnapshot = await routineDoc.get();

      if (!routineSnapshot.exists) {
        throw Exception('Routine session not found');
      }

      final routineData = routineSnapshot.data()!;
      final exercises =
          List<Map<String, dynamic>>.from(routineData['exercises'] ?? []);

      // Find the exercise to update by matching the exerciseId
      int exerciseIndex = -1;
      for (int i = 0; i < exercises.length; i++) {
        if (exercises[i]['exerciseId'] == exerciseId) {
          exerciseIndex = i;
          break;
        }
      }

      if (exerciseIndex == -1) {
        throw Exception('Exercise not found in routine');
      }

      // Update the exercise data with new individual sets
      final exerciseData = Map<String, dynamic>.from(exercises[exerciseIndex]);

      // Add individual sets data
      exerciseData['individualSets'] =
          individualSets.map((set) => set.toJson()).toList();
      exerciseData['totalSets'] = individualSets.length;

      // Calculate and store aggregated data
      final totalWeight =
          individualSets.fold<double>(0, (sum, set) => sum + set.weight);
      final totalReps =
          individualSets.fold<int>(0, (sum, set) => sum + set.reps);
      exerciseData['averageWeight'] = totalWeight / individualSets.length;
      exerciseData['averageReps'] = (totalReps / individualSets.length).round();
      exerciseData['totalVolume'] = totalWeight * totalReps;

      // Find best set
      final bestSet = individualSets.reduce((a, b) {
        final aScore = a.weight * a.reps;
        final bScore = b.weight * b.reps;
        return aScore > bScore ? a : b;
      });

      exerciseData['bestSet'] = {
        'weight': bestSet.weight,
        'reps': bestSet.reps,
        'setNumber': bestSet.setNumber,
      };

      // Legacy format for backward compatibility
      exerciseData['sets'] = individualSets.length;
      exerciseData['weight'] = totalWeight / individualSets.length;
      exerciseData['reps'] = (totalReps / individualSets.length).round();

      // Update equipment
      exerciseData['equipment'] = equipment;

      // Replace the exercise in the exercises array
      exercises[exerciseIndex] = exerciseData;

      // Update the routine document
      await routineDoc.update({
        'exercises': exercises,
        'updatedAt': dateTimeToTimestamp(DateTime.now()),
      });

      print(
          'Routine session exercise updated in Firestore: ${exerciseData['exerciseName']}');
    } catch (e) {
      print('Error updating routine session exercise: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Delete routine session
  Future<void> deleteRoutineSession(String sessionId) async {
    try {
      await firestore
          .collection(_routineSessionsCollection)
          .doc(sessionId)
          .delete();
      print('Routine session deleted from Firestore: $sessionId');
    } catch (e) {
      print('Error deleting routine session: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // ==================== PERSONAL RECORDS ====================

  // Save personal record
  Future<String> savePersonalRecord(PersonalRecord record) async {
    try {
      final recordDoc = createDocumentRef(_personalRecordsCollection);

      final recordData = {
        'userId': authenticatedUserId,
        'exerciseId': record.exerciseId,
        'exerciseName': record.exerciseName,
        'equipment': record.equipment,
        'date': dateTimeToTimestamp(record.date),
        'type': record.type.toString(),
        'createdAt': dateTimeToTimestamp(DateTime.now()),
      };

      // Add strength-specific fields
      if (record.weight != null) recordData['weight'] = record.weight;
      if (record.reps != null) recordData['reps'] = record.reps;
      if (record.sets != null) recordData['sets'] = record.sets;
      if (record.oneRepMax != null) recordData['oneRepMax'] = record.oneRepMax;

      // Add cardio-specific fields
      if (record.distance != null) recordData['distance'] = record.distance;
      if (record.duration != null)
        recordData['duration'] = record.duration!.inSeconds;
      if (record.pace != null) recordData['pace'] = record.pace;
      if (record.speed != null) recordData['speed'] = record.speed;
      if (record.calories != null) recordData['calories'] = record.calories;
      if (record.heartRate != null) recordData['heartRate'] = record.heartRate;

      await recordDoc.set(recordData);
      print('Personal record saved to Firestore: ${record.exerciseName}');
      return recordDoc.id;
    } catch (e) {
      print('Error saving personal record: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Update personal record
  Future<void> updatePersonalRecord(
      String recordId, PersonalRecord record) async {
    try {
      final recordDoc =
          firestore.collection(_personalRecordsCollection).doc(recordId);

      final recordData = {
        'userId': authenticatedUserId,
        'exerciseId': record.exerciseId,
        'exerciseName': record.exerciseName,
        'equipment': record.equipment,
        'date': dateTimeToTimestamp(record.date),
        'type': record.type.toString(),
        'updatedAt': dateTimeToTimestamp(DateTime.now()),
      };

      // Add strength-specific fields
      if (record.weight != null) recordData['weight'] = record.weight;
      if (record.reps != null) recordData['reps'] = record.reps;
      if (record.sets != null) recordData['sets'] = record.sets;
      if (record.oneRepMax != null) recordData['oneRepMax'] = record.oneRepMax;

      // Add cardio-specific fields
      if (record.distance != null) recordData['distance'] = record.distance;
      if (record.duration != null)
        recordData['duration'] = record.duration!.inSeconds;
      if (record.pace != null) recordData['pace'] = record.pace;
      if (record.speed != null) recordData['speed'] = record.speed;
      if (record.calories != null) recordData['calories'] = record.calories;
      if (record.heartRate != null) recordData['heartRate'] = record.heartRate;

      await recordDoc.update(recordData);
      print('Personal record updated in Firestore: ${record.exerciseName}');
    } catch (e) {
      print('Error updating personal record: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Get personal records
  Future<List<PersonalRecord>> getPersonalRecords() async {
    try {
      final query = getUserQuery(_personalRecordsCollection);
      final snapshot = await query.get();

      final records = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _parsePersonalRecordFromFirestore(doc.id, data);
      }).toList();

      // Sort by date on client side
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    } catch (e) {
      print('Error getting personal records: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // ==================== ACHIEVEMENTS ====================

  // Save achievement
  Future<String> saveAchievement(Achievement achievement) async {
    try {
      final achievementDoc = createDocumentRef(_achievementsCollection);

      final achievementData = {
        'userId': authenticatedUserId,
        'title': achievement.title,
        'description': achievement.description,
        'achievedDate': dateTimeToTimestamp(achievement.achievedDate),
        'type': achievement.type.toString(),
        'exerciseName': achievement.exerciseName,
        'value': achievement.value,
        'createdAt': dateTimeToTimestamp(DateTime.now()),
      };

      await achievementDoc.set(achievementData);
      print('Achievement saved to Firestore: ${achievement.title}');
      return achievementDoc.id;
    } catch (e) {
      print('Error saving achievement: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // Get achievements
  Future<List<Achievement>> getAchievements() async {
    try {
      final query = getUserQuery(_achievementsCollection);
      final snapshot = await query.get();

      final achievements = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _parseAchievementFromFirestore(doc.id, data);
      }).toList();

      // Sort by achieved date on client side
      achievements.sort((a, b) => b.achievedDate.compareTo(a.achievedDate));
      return achievements;
    } catch (e) {
      print('Error getting achievements: $e');
      throw Exception(handleFirestoreError(e));
    }
  }

  // ==================== HELPER METHODS ====================

  Exercise _parseExerciseFromFirestore(String id, Map<String, dynamic> data) {
    return Exercise(
      id: id,
      userId: data['userId'] ?? '',
      exerciseName: data['exerciseName'] ?? '',
      targetMuscles: List<String>.from(data['targetMuscles'] ?? []),
      equipment: List<String>.from(data['equipment'] ?? []),
      exerciseType: ExerciseType.values.firstWhere(
        (e) => e.toString() == data['exerciseType'],
        orElse: () => ExerciseType.strength,
      ),
      cardioMetrics: data['cardioMetrics'] != null
          ? CardioMetrics.fromJson(data['cardioMetrics'])
          : null,
    );
  }

  Routine _parseRoutineFromFirestore(String id, Map<String, dynamic> data) {
    return Routine(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      orderIsRequired: data['orderIsRequired'] ?? false,
      exerciseIds: List<String>.from(data['exerciseIds'] ?? []),
    );
  }

  LoggedExercise _parseLoggedExerciseFromFirestore(
      String id, Map<String, dynamic> data) {
    // Parse individual sets if available
    List<WorkoutSetData>? individualSets;
    if (data['individualSets'] != null) {
      final setsData = data['individualSets'] as List;
      individualSets = setsData
          .map((setData) =>
              WorkoutSetData.fromJson(setData as Map<String, dynamic>))
          .toList();
    }

    return LoggedExercise(
      id: id,
      exerciseId: data['exerciseId'] ?? '',
      exerciseName: data['exerciseName'] ?? '',
      targetMuscles: List<String>.from(data['targetMuscles'] ?? []),
      equipment: data['equipment'] ?? '',
      date: timestampToDateTime(data['date']) ?? DateTime.now(),

      // Individual sets data
      individualSets: individualSets,

      // Legacy aggregated data (for backward compatibility)
      sets: data['sets'] ?? data['totalSets'],
      weight: data['weight']?.toDouble() ?? data['averageWeight']?.toDouble(),
      reps: data['reps'] ?? data['averageReps'],

      // Cardio data
      distance: data['distance']?.toDouble(),
      duration:
          data['duration'] != null ? Duration(seconds: data['duration']) : null,
      pace: data['pace']?.toDouble(),
      speed: data['speed']?.toDouble(),
      calories: data['calories'],
      heartRate: data['heartRate'],
    );
  }

  LoggedRoutine _parseLoggedRoutineFromFirestore(
      String id, Map<String, dynamic> data) {
    final exercisesData = data['exercises'] as List<dynamic>? ?? [];
    final exercises = exercisesData.map((exerciseData) {
      final exData = exerciseData as Map<String, dynamic>;

      // Parse individual sets if available
      List<WorkoutSetData>? individualSets;
      if (exData['individualSets'] != null) {
        final setsData = exData['individualSets'] as List;
        individualSets = setsData
            .map((setData) =>
                WorkoutSetData.fromJson(setData as Map<String, dynamic>))
            .toList();
      }

      return LoggedExercise(
        id: '${id}_${exercisesData.indexOf(exerciseData)}',
        exerciseId: exData['exerciseId'] ?? '',
        exerciseName: exData['exerciseName'] ?? '',
        targetMuscles: List<String>.from(exData['targetMuscles'] ?? []),
        equipment: exData['equipment'] ?? '',
        date: timestampToDateTime(data['date']) ?? DateTime.now(),

        // Individual sets data
        individualSets: individualSets,

        // Legacy aggregated data (for backward compatibility)
        sets: exData['sets'] ?? exData['totalSets'],
        weight:
            exData['weight']?.toDouble() ?? exData['averageWeight']?.toDouble(),
        reps: exData['reps'] ?? exData['averageReps'],

        // Cardio data
        distance: exData['distance']?.toDouble(),
        duration: exData['duration'] != null
            ? Duration(seconds: exData['duration'])
            : null,
        pace: exData['pace']?.toDouble(),
        speed: exData['speed']?.toDouble(),
        calories: exData['calories'],
        heartRate: exData['heartRate'],
      );
    }).toList();

    return LoggedRoutine(
      id: id,
      routineId: data['routineId'] ?? '',
      name: data['routineName'] ?? '',
      targetMuscles: [], // Will be computed from exercises
      date: timestampToDateTime(data['date']) ?? DateTime.now(),
      exercises: exercises,
      orderIsRequired: data['orderIsRequired'] ?? false,
    );
  }

  PersonalRecord _parsePersonalRecordFromFirestore(
      String id, Map<String, dynamic> data) {
    return PersonalRecord(
      id: id,
      exerciseId: data['exerciseId'] ?? '',
      exerciseName: data['exerciseName'] ?? '',
      date: timestampToDateTime(data['date']) ?? DateTime.now(),
      equipment: data['equipment'] ?? '',
      type: PersonalRecordType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => PersonalRecordType.weight,
      ),
      weight: data['weight']?.toDouble(),
      reps: data['reps'],
      sets: data['sets'],
      oneRepMax: data['oneRepMax']?.toDouble(),
      distance: data['distance']?.toDouble(),
      duration:
          data['duration'] != null ? Duration(seconds: data['duration']) : null,
      pace: data['pace']?.toDouble(),
      speed: data['speed']?.toDouble(),
      calories: data['calories'],
      heartRate: data['heartRate'],
    );
  }

  Achievement _parseAchievementFromFirestore(
      String id, Map<String, dynamic> data) {
    return Achievement(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      achievedDate: timestampToDateTime(data['achievedDate']) ?? DateTime.now(),
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => AchievementType.milestone,
      ),
      exerciseName: data['exerciseName'],
      value: data['value']?.toDouble(),
    );
  }
}
