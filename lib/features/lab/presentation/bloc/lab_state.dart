import 'dart:ui';

import 'package:equatable/equatable.dart';

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

  const LabLoaded({required this.systems, required this.teacherColorMap});

  @override
  List<Object> get props => [systems, teacherColorMap];
}

class LabError extends LabState {
  final String message;
  const LabError(this.message);
}
