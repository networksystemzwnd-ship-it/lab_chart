import 'package:hive/hive.dart';
import 'package:lab_chart/features/lab/data/models/student_assignment_model.dart';
import 'package:lab_chart/features/lab/domain/entities/lab_system.dart';

part 'lab_system_model.g.dart';

/// Model for serialization/deserialization of LabSystem
/// Extends domain entity to maintain clean architecture layers
/// 
/// SOLID Principles:
/// - Single Responsibility: Handles only serialization concerns
/// - Open/Closed: Can be extended for new persistence formats
/// - Liskov Substitution: Proper subclass of LabSystem
@HiveType(typeId: 0)
class LabSystemModel extends LabSystem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String systemNumber;

  @HiveField(2)
  final List<StudentAssignmentModel> studentAssignments;

  LabSystemModel({
    required this.id,
    required this.systemNumber,
    this.studentAssignments = const [],
  }) : super(
    id: id,
    systemNumber: systemNumber,
    studentAssignments: studentAssignments,
  );

  /// Convert domain entity to model for persistence
  factory LabSystemModel.fromEntity(LabSystem entity) {
    return LabSystemModel(
      id: entity.id,
      systemNumber: entity.systemNumber,
      studentAssignments: entity.studentAssignments
          .map((assignment) => StudentAssignmentModel.fromEntity(assignment))
          .toList(),
    );
  }

  /// Reconstruct entity from model
  LabSystem toEntity() {
    return LabSystem(
      id: id,
      systemNumber: systemNumber,
      studentAssignments: studentAssignments
          .map((model) => model.toEntity())
          .toList(),
    );
  }
}
