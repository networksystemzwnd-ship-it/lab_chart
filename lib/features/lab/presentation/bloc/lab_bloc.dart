import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_chart/features/lab/domain/entities/teacher.dart';
import 'package:lab_chart/features/lab/domain/repositories/lab_repository.dart';
import 'package:lab_chart/features/time_line_slot_picker_widget/time_line_slot_picker_widget.dart';

import '../../domain/entities/lab_system.dart';
import '../../domain/entities/student_assignment.dart';
import 'lab_event.dart';
import 'lab_state.dart';

class LabBloc extends Bloc<LabEvent, LabState> {
  List<LabSystem> _systems = [];
  List<Teacher> _teachers = [];

  // DEPEND ON THE CONTRACT, NOT THE IMPLEMENTATION
  final LabRepository labRepository;

  LabBloc({required this.labRepository}) : super(LabInitial()) {
    on<LoadLabSystems>(_onLoadSystems);
    on<AddTeacher>(_onAddTeacher);
    on<AssignStudent>(_onAssignStudent);
    on<UpdateStudentAssignment>(_onUpdateStudentAssignment);
    on<DeleteStudentAssignment>(_onDeleteStudentAssignment);
    on<SelectTimeSlot>(_onSelectTimeSlot);
  }

  Map<String, Color> _teacherColorMapFromTeachers(List<Teacher> teachers) {
    return {for (final teacher in teachers) teacher.name: teacher.color};
  }

  void _onLoadSystems(LoadLabSystems event, Emitter<LabState> emit) async {
    emit(LabLoading());
    try {
      _systems = await labRepository.getLabSystems();
      _teachers = await labRepository.getTeachers();

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
          teachers: _teachers,
          teacherColorMap: _teacherColorMapFromTeachers(_teachers),
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

  Future<void> _onAddTeacher(AddTeacher event, Emitter<LabState> emit) async {
    if (state is! LabLoaded) return;

    final currentState = state as LabLoaded;
    final newTeacher = Teacher(name: event.name, color: event.color);

    try {
      await labRepository.addTeacher(newTeacher);
      _teachers = await labRepository.getTeachers();

      emit(
        LabLoaded(
          systems: currentState.systems,
          teachers: _teachers,
          teacherColorMap: _teacherColorMapFromTeachers(_teachers),
          selectedTimeSlot: currentState.selectedTimeSlot,
        ),
      );
    } catch (e) {
      emit(
        LabLoaded(
          systems: currentState.systems,
          teachers: currentState.teachers,
          teacherColorMap: currentState.teacherColorMap,
          selectedTimeSlot: currentState.selectedTimeSlot,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAssignStudent(AssignStudent event, Emitter<LabState> emit) async {
    if (state is! LabLoaded) return;

    final currentState = state as LabLoaded;

    final newAssignment = StudentAssignment(
      studentName: event.studentName,
      teacherName: event.teacherName,
      teacherColor:
          currentState.teacherColorMap[event.teacherName] ?? Colors.grey,
      startTime: currentState.selectedTimeSlot.start,
      endTime: currentState.selectedTimeSlot.end,
    );

    // 1. Check for time slot conflicts
    final index = _systems.indexWhere((s) => s.id == event.systemId);
    if (index == -1) {
      emit(
        LabLoaded(
          systems: currentState.systems,
          teachers: currentState.teachers,
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
          teachers: currentState.teachers,
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
          teachers: currentState.teachers,
          teacherColorMap: currentState.teacherColorMap,
          selectedTimeSlot: currentState.selectedTimeSlot,
        ),
      );
    } catch (e) {
      emit(
        LabLoaded(
          systems: currentState.systems,
          teachers: currentState.teachers,
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
          teachers: currentState.teachers,
          teacherColorMap: currentState.teacherColorMap,
          selectedTimeSlot: currentState.selectedTimeSlot,
        ),
      );
    } catch (e) {
      emit(
        LabLoaded(
          systems: currentState.systems,
          teachers: currentState.teachers,
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
          teachers: currentState.teachers,
          teacherColorMap: currentState.teacherColorMap,
          selectedTimeSlot: currentState.selectedTimeSlot,
        ),
      );
    } catch (e) {
      emit(
        LabLoaded(
          systems: currentState.systems,
          teachers: currentState.teachers,
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
        teachers: currentState.teachers,
        teacherColorMap: currentState.teacherColorMap,
        selectedTimeSlot: event.selectedTimeSlot,
      ),
    );
  }
}
