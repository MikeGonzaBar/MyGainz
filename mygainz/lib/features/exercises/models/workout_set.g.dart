// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSetDataAdapter extends TypeAdapter<WorkoutSetData> {
  @override
  final int typeId = 3;

  @override
  WorkoutSetData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSetData(
      weight: fields[0] as double,
      reps: fields[1] as int,
      restTime: fields[2] as Duration?,
      setNumber: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSetData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.weight)
      ..writeByte(1)
      ..write(obj.reps)
      ..writeByte(2)
      ..write(obj.restTime)
      ..writeByte(3)
      ..write(obj.setNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSetDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
