// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_system_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LabSystemModelAdapter extends TypeAdapter<LabSystemModel> {
  @override
  final int typeId = 0;

  @override
  LabSystemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LabSystemModel(
      id: fields[0] as String,
      systemNumber: fields[1] as String,
      studentAssignments: (fields[2] as List).cast<StudentAssignmentModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, LabSystemModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.systemNumber)
      ..writeByte(2)
      ..write(obj.studentAssignments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabSystemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
