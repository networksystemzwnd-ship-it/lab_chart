// domain/entities/lab_system.dart
import 'package:lab_chart/features/lab/domain/entities/student_assignment.dart';

class LabSystem {
  final String id;
  final String systemNumber; // e.g., "PC-01"
  final List<StudentAssignment> studentAssignments; // Null if free

  LabSystem({
    required this.id,
    required this.systemNumber,
    this.studentAssignments = const [],
  });
}
