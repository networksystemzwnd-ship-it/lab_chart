// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_assignment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudentAssignmentModelAdapter
    extends TypeAdapter<StudentAssignmentModel> {
  @override
  final int typeId = 1;

  @override
  StudentAssignmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudentAssignmentModel(
      studentName: fields[0] as String,
      teacherName: fields[1] as String,
      teacherColor: Color(fields[2] as int),
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StudentAssignmentModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.studentName)
      ..writeByte(1)
      ..write(obj.teacherName)
      ..writeByte(2)
      ..write(obj.teacherColorValue)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentAssignmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
