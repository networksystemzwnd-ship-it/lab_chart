import 'package:equatable/equatable.dart';
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

