import 'package:equatable/equatable.dart';
import 'package:lab_chart/features/lab/domain/entities/student_assignment.dart';
import 'package:lab_chart/features/time_line_slot_picker_widget/time_line_slot_picker_widget.dart';

abstract class LabEvent extends Equatable {
  const LabEvent();

  @override
  List<Object> get props => [];
}

// 1. Initial Load
class LoadLabSystems extends LabEvent {}

// 2. User fills out the form and clicks "Save"
class AssignStudent extends LabEvent {
  final String systemId;
  final String studentName;
  final String teacherName;

  const AssignStudent({
    required this.systemId,
    required this.studentName,
    required this.teacherName,
  });

  @override
  List<Object> get props => [
    systemId,
    studentName,
    teacherName,
  ];
}

class SelectTimeSlot extends LabEvent {
  final TimeSlot selectedTimeSlot;

  const SelectTimeSlot({
    required this.selectedTimeSlot,
  });

  @override
  List<Object> get props => [selectedTimeSlot];
}

class UpdateStudentAssignment extends LabEvent {
  final String systemId;
  final StudentAssignment oldAssignment;
  final StudentAssignment updatedAssignment;

  const UpdateStudentAssignment({
    required this.systemId,
    required this.oldAssignment,
    required this.updatedAssignment,
  });

  @override
  List<Object> get props => [systemId, oldAssignment, updatedAssignment];
}

class DeleteStudentAssignment extends LabEvent {
  final String systemId;
  final StudentAssignment assignment;

  const DeleteStudentAssignment({
    required this.systemId,
    required this.assignment,
  });

  @override
  List<Object> get props => [systemId, assignment];
}

