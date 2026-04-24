import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:lab_chart/features/time_line_slot_picker_widget/time_line_slot_picker_widget.dart';

import '../../domain/entities/lab_system.dart';

abstract class LabState extends Equatable {
  const LabState();

  @override
  List<Object> get props => [];
}

class LabInitial extends LabState {}

class LabLoading extends LabState {}

class LabLoaded extends LabState {
  final List<LabSystem> systems;

  // We keep the teacher color map here so the UI can draw the Legend easily
  final Map<String, Color> teacherColorMap;

  // Selected Time slot;
  final TimeSlot selectedTimeSlot;

  const LabLoaded({
    required this.systems,
    required this.teacherColorMap,
    required this.selectedTimeSlot,
  });

  @override
  List<Object> get props => [systems, teacherColorMap, selectedTimeSlot];
}

class LabError extends LabState {
  final String message;
  const LabError(this.message);
}
