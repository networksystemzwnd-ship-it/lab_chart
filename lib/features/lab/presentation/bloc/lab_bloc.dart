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
    'Mr. Smith': Colors.blueAccent,
    'Ms. Johnson': Colors.green,
    'Mrs. Davis': Colors.orangeAccent,
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

      // 3. Update the specific system in the list
      // Note: We create a NEW LabSystem object because State must be immutable
      _systems[index] = LabSystem(
        id: _systems[index].id,
        systemNumber: _systems[index].systemNumber,
        currentAssignment: newAssignment,
      );

      // 4. Emit new state with updated list
      emit(
        LabLoaded(
          systems: List.from(_systems),
          teacherColorMap: _teacherColors,
        ),
      );
    }
  }
}
