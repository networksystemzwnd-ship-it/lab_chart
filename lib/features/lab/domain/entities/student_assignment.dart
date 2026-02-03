// domain/entities/student_assignment.dart
import 'dart:ui';

class StudentAssignment {
  final String studentName;
  final String teacherName;
  final Color
  teacherColor; // Logic to map Teacher -> Color happens in Domain/Data
  final DateTime startTime;
  final DateTime endTime;

  StudentAssignment({
    required this.studentName,
    required this.teacherName,
    required this.teacherColor,
    required this.startTime,
    required this.endTime,
  });
}
