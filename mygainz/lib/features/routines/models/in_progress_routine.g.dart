// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_progress_routine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InProgressRoutineAdapter extends TypeAdapter<InProgressRoutine> {
  @override
  final int typeId = 1;

  @override
  InProgressRoutine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InProgressRoutine(
      id: fields[0] as String,
      routineId: fields[1] as String,
      name: fields[2] as String,
      targetMuscles: (fields[3] as List).cast<String>(),
      lastUpdated: fields[4] as DateTime,
      exercises: (fields[5] as List).cast<InProgressExercise>(),
      orderIsRequired: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, InProgressRoutine obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.routineId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.targetMuscles)
      ..writeByte(4)
      ..write(obj.lastUpdated)
      ..writeByte(5)
      ..write(obj.exercises)
      ..writeByte(6)
      ..write(obj.orderIsRequired);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InProgressRoutineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InProgressExerciseAdapter extends TypeAdapter<InProgressExercise> {
  @override
  final int typeId = 2;

  @override
  InProgressExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InProgressExercise(
      id: fields[0] as String,
      exerciseId: fields[1] as String,
      exerciseName: fields[2] as String,
      targetMuscles: (fields[3] as List).cast<String>(),
      equipment: fields[4] as String,
      sets: (fields[5] as List).cast<WorkoutSetData>(),
      lastUpdated: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, InProgressExercise obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseId)
      ..writeByte(2)
      ..write(obj.exerciseName)
      ..writeByte(3)
      ..write(obj.targetMuscles)
      ..writeByte(4)
      ..write(obj.equipment)
      ..writeByte(5)
      ..write(obj.sets)
      ..writeByte(6)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InProgressExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
