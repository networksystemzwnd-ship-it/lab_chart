import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_chart/features/lab/domain/repositories/lab_repository.dart';

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
  }

  void _onLoadSystems(LoadLabSystems event, Emitter<LabState> emit) async {
    emit(LabLoading());
    try {
      // Call the repository
      _systems = await labRepository.getLabSystems();

      emit(LabLoaded(systems: _systems, teacherColorMap: _teacherColors));
    } catch (e) {
      emit(LabError("Failed to fetch data"));
    }
  }

  void _onAssignStudent(AssignStudent event, Emitter<LabState> emit) {
    if (state is LabLoaded) {
      // 1. Find the system index
      final index = _systems.indexWhere((s) => s.id == event.systemId);
      if (index == -1) return;

      // 2. Create the new assignment object
      final newAssignment = StudentAssignment(
        studentName: event.studentName,
        teacherName: event.teacherName,
        teacherColor:
            _teacherColors[event.teacherName] ?? Colors.grey, // Assign color
        startTime: event.startTime,
        endTime: event.endTime,
      );

      // 3. Create a NEW list instance immediately
      final updatedSystems = List<LabSystem>.from(_systems);

      // 4. Update the item in the NEW list
      updatedSystems[index] = LabSystem(
        id: _systems[index].id,
        systemNumber: _systems[index].systemNumber,
        currentAssignment: newAssignment,
      );

      // 5. Update your private variable and emit the NEW list
      _systems = updatedSystems;
      emit(
        LabLoaded(
          systems: _systems, // Already a new instance from List.from
          teacherColorMap: _teacherColors,
        ),
      );
    }
  }
}
