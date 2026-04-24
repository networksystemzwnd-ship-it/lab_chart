import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lab_chart/features/lab/domain/entities/student_assignment.dart';

part 'student_assignment_model.g.dart';

/// Model for serialization/deserialization of StudentAssignment
/// Extends domain entity to maintain clean architecture layers
/// 
/// SOLID Principles:
/// - Single Responsibility: Handles only serialization concerns
/// - Open/Closed: Can be extended for new persistence formats
/// - Liskov Substitution: Proper subclass of StudentAssignment
@HiveType(typeId: 1)
class StudentAssignmentModel extends StudentAssignment {
  @HiveField(0)
  final String studentName;

  @HiveField(1)
  final String teacherName;

  @HiveField(2)
  final int teacherColorValue; // Store as int (0xARGB)

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final DateTime endTime;

  StudentAssignmentModel({
    required this.studentName,
    required this.teacherName,
    required Color teacherColor,
    required this.startTime,
    required this.endTime,
  })  : teacherColorValue = teacherColor.value,
        super(
          studentName: studentName,
          teacherName: teacherName,
          teacherColor: teacherColor,
          startTime: startTime,
          endTime: endTime,
        );

  /// Convert domain entity to model for persistence
  factory StudentAssignmentModel.fromEntity(StudentAssignment entity) {
    return StudentAssignmentModel(
      studentName: entity.studentName,
      teacherName: entity.teacherName,
      teacherColor: entity.teacherColor,
      startTime: entity.startTime,
      endTime: entity.endTime,
    );
  }

  /// Reconstruct entity from stored color value
  StudentAssignment toEntity() {
    return StudentAssignment(
      studentName: studentName,
      teacherName: teacherName,
      teacherColor: Color(teacherColorValue),
      startTime: startTime,
      endTime: endTime,
    );
  }
}
