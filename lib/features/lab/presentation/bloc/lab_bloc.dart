import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_chart/features/lab/domain/repositories/lab_repository.dart';
import 'package:lab_chart/features/time_line_slot_picker_widget/time_line_slot_picker_widget.dart';

import '../../domain/entities/lab_system.dart';
import '../../domain/entities/student_assignment.dart';
import 'lab_event.dart';
import 'lab_state.dart';

class LabBloc extends Bloc<LabEvent, LabState> {
  List<LabSystem> _systems = [];

  // Hardcoded Logic for Teacher Colors (In real app, this might come from API)
  final Map<String, Color> _teacherColors = {
    'Teacher 1': Colors.blueAccent,
    'Teacher 2': Colors.green,
    'Teacher 3': Colors.orange,
    'Teacher 4': Colors.yellow,
    'Teacher 5': Colors.cyan,
    'Teacher 6': Colors.deepOrange,
    'Teacher 7': Colors.red,
  };

  // DEPEND ON THE CONTRACT, NOT THE IMPLEMENTATION
  final LabRepository labRepository;

  LabBloc({required this.labRepository}) : super(LabInitial()) {
    on<LoadLabSystems>(_onLoadSystems);
    on<AssignStudent>(_onAssignStudent);
    on<UpdateStudentAssignment>(_onUpdateStudentAssignment);
    on<DeleteStudentAssignment>(_onDeleteStudentAssignment);
    on<SelectTimeSlot>(_onSelectTimeSlot);
  }

  void _onLoadSystems(LoadLabSystems event, Emitter<LabState> emit) async {
    emit(LabLoading());
    try {
      // Call the repository
      _systems = await labRepository.getLabSystems();

      // Initialize with current time rounded to nearest 30-minute interval
      final now = DateTime.now();
      final startMinute = (now.minute ~/ 30) * 30;
      final initialStart = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        startMinute,
      );
      final initialEnd = initialStart.add(const Duration(minutes: 30));

      emit(
        LabLoaded(
          systems: _systems,
          teacherColorMap: _teacherColors,
          selectedTimeSlot: TimeSlot(
            start: initialStart,
            end: initialEnd,
          ),
        ),
      );
    } catch (e) {
      emit(LabError("Failed to fetch data"));
    }
  }

  Future<void> _onAssignStudent(AssignStudent event, Emitter<LabState> emit) async {
    if (state is! LabLoaded) return;

    final currentState = state as LabLoaded;

    final newAssignment = StudentAssignment(
      studentName: event.studentName,
      teacherName: event.teacherName,
      teacherColor:
          _teacherColors[event.teacherName] ?? Colors.grey,
      startTime: currentState.selectedTimeSlot.start,
      endTime: currentState.selectedTimeSlot.end,
    );

    // 1. Check for time slot conflicts
    final index = _systems.indexWhere((s) => s.id == event.systemId);
    if (index == -1) {
      emit(
        LabLoaded(
          systems: currentState.systems,
          teacherColorMap: currentState.teacherColorMap,
          selectedTimeSlot: currentState.selectedTimeSlot,
          message: "System not found",
        ),
      );
      return;
    }

    final hasConflict = _systems[index].studentAssignments.any(
      (existing) =>
          existing.endTime.isAfter(currentState.selectedTimeSlot.start) &&
          existing.startTime.isBefore(currentState.selectedTimeSlot.end),
    );

    if (hasConflict) {
      emit(
        LabLoaded(
          systems: currentState.systems,
          teacherColorMap: currentState.teacherColorMap,
          selectedTimeSlot: currentState.selectedTimeSlot,
          message: "Time slot conflict: another student is assigned during this period",
        ),
      );
      return;
    }

    try {
      await labRepository.assignStudent(event.systemId, newAssignment);
      _systems = await labRepository.getLabSystems();

      emit(
        LabLoaded(
          systems: _systems,
          teacherColorMap: _teacherColors,
          selectedTimeSlot: currentState.selectedTimeSlot,
        ),
      );
    } catch (e) {
      emit(
        LabLoaded(
          systems: currentState.systems,
          teacherColorMap: currentState.teacherColorMap,
          selectedTimeSlot: currentState.selectedTimeSlot,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateStudentAssignment(
    UpdateStudentAssignment event,
    Emitter<LabState> emit,
  ) async {
    if (state is! LabLoaded) return;

    final currentState = state as LabLoaded;

    try {
      await labRepository.updateStudentAssignment(
        event.systemId,
        event.oldAssignment,
        event.updatedAssignment,
      );
      _systems = await labRepository.getLabSystems();

      emit(
        LabLoaded(
          systems: _systems,
          teacherColorMap: _teacherColors,
          selectedTimeSlot: currentState.selectedTimeSlot,
        ),
      );
    } catch (e) {
      emit(
        LabLoaded(
          systems: currentState.systems,
          teacherColorMap: currentState.teacherColorMap,
          selectedTimeSlot: currentState.selectedTimeSlot,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteStudentAssignment(
    DeleteStudentAssignment event,
    Emitter<LabState> emit,
  ) async {
    if (state is! LabLoaded) return;

    final currentState = state as LabLoaded;

    try {
      await labRepository.deleteStudentAssignment(
        event.systemId,
        event.assignment,
      );
      _systems = await labRepository.getLabSystems();

      emit(
        LabLoaded(
          systems: _systems,
          teacherColorMap: _teacherColors,
          selectedTimeSlot: currentState.selectedTimeSlot,
        ),
      );
    } catch (e) {
      emit(
        LabLoaded(
          systems: currentState.systems,
          teacherColorMap: currentState.teacherColorMap,
          selectedTimeSlot: currentState.selectedTimeSlot,
          message: e.toString(),
        ),
      );
    }
  }

  void _onSelectTimeSlot(SelectTimeSlot event, Emitter<LabState> emit) {
    if (state is! LabLoaded) return;

    final currentState = state as LabLoaded;

    // Only emit if the time slot has changed to avoid unnecessary rebuilds
    if (currentState.selectedTimeSlot == event.selectedTimeSlot) {
      return;
    }

    emit(
      LabLoaded(
        systems: currentState.systems,
        teacherColorMap: currentState.teacherColorMap,
        selectedTimeSlot: event.selectedTimeSlot,
      ),
    );
  }
}
