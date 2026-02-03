import 'package:equatable/equatable.dart';

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
  final DateTime startTime;
  final DateTime endTime;

  const AssignStudent({
    required this.systemId,
    required this.studentName,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object> get props => [
    systemId,
    studentName,
    teacherName,
    startTime,
    endTime,
  ];
}
