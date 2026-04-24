// domain/entities/student_assignment.dart
import 'dart:ui';
import 'package:equatable/equatable.dart';

class StudentAssignment extends Equatable {
  final String studentName;
  final String teacherName;
  final Color teacherColor; // Logic to map Teacher -> Color happens in Domain/Data
  final DateTime startTime;
  final DateTime endTime;

  const StudentAssignment({
    required this.studentName,
    required this.teacherName,
    required this.teacherColor,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object> get props => [studentName, teacherName, teacherColor.value, startTime, endTime];
}
