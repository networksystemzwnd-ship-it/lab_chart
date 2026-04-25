import 'package:lab_chart/features/lab/data/datasources/lab_local_data_source.dart';
import 'package:lab_chart/features/lab/data/models/lab_system_model.dart';
import 'package:lab_chart/features/lab/data/models/student_assignment_model.dart';
import 'package:lab_chart/features/lab/data/models/teacher_model.dart';
import 'package:lab_chart/features/lab/domain/entities/lab_system.dart';
import 'package:lab_chart/features/lab/domain/entities/student_assignment.dart';
import 'package:lab_chart/features/lab/domain/entities/teacher.dart';
import 'package:lab_chart/features/lab/domain/repositories/lab_repository.dart';

/// Implementation of LabRepository using local data source
/// 
/// SOLID Principles:
/// - Single Responsibility: Orchestrates data source operations
/// - Open/Closed: Can add remote data source without modifying this class
/// - Liskov Substitution: Proper implementation of LabRepository contract
/// - Interface Segregation: Implements only required methods
/// - Dependency Inversion: Depends on LabLocalDataSource abstraction
class LabRepositoryImpl implements LabRepository {
  final LabLocalDataSource localDataSource;

  LabRepositoryImpl({required this.localDataSource});

  @override
  Future<List<LabSystem>> getLabSystems() async {
    try {
      // 1. Get systems from local data source
      final models = await localDataSource.getLastSavedLabData();

      // 2. Convert Models → Entities (data layer → domain layer)
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception("Failed to load lab data: $e");
    }
  }

  @override
  Future<List<Teacher>> getTeachers() async {
    try {
      final models = await localDataSource.getTeachers();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception("Failed to load teacher data: $e");
    }
  }

  @override
  Future<void> addTeacher(Teacher teacher) async {
    try {
      final model = TeacherModel.fromEntity(teacher);
      await localDataSource.addTeacher(model);
    } catch (e) {
      throw Exception("Failed to add teacher: $e");
    }
  }

  @override
  Future<void> updateTeacher(Teacher teacher, {required String originalName}) async {
    try {
      final model = TeacherModel.fromEntity(teacher);
      await localDataSource.updateTeacher(model, originalName: originalName);
    } catch (e) {
      throw Exception("Failed to update teacher: $e");
    }
  }

  @override
  Future<void> deleteTeacher(String name) async {
    try {
      await localDataSource.deleteTeacher(name);
    } catch (e) {
      throw Exception("Failed to delete teacher: $e");
    }
  }

  @override
  Future<void> saveLabSystems(List<LabSystem> systems) async {
    try {
      final models = systems.map((system) => LabSystemModel.fromEntity(system)).toList();
      await localDataSource.cacheLabData(models);
    } catch (e) {
      throw Exception("Failed to save lab systems: $e");
    }
  }

  @override
  Future<void> assignStudent(
    String systemId,
    StudentAssignment assignment,
  ) async {
    try {
      await _updateSystemAssignments(systemId, [assignment], add: true);
    } catch (e) {
      throw Exception("Failed to assign student: $e");
    }
  }

  @override
  Future<void> updateStudentAssignment(
    String systemId,
    StudentAssignment oldAssignment,
    StudentAssignment updatedAssignment,
  ) async {
    try {
      await _updateSystemAssignments(
        systemId,
        [updatedAssignment],
        replace: oldAssignment,
      );
    } catch (e) {
      throw Exception("Failed to update student assignment: $e");
    }
  }

  @override
  Future<void> deleteStudentAssignment(
    String systemId,
    StudentAssignment assignment,
  ) async {
    try {
      await _updateSystemAssignments(systemId, [assignment], remove: true);
    } catch (e) {
      throw Exception("Failed to delete student assignment: $e");
    }
  }

  Future<void> _updateSystemAssignments(
    String systemId,
    List<StudentAssignment> assignments, {
    bool add = false,
    bool remove = false,
    StudentAssignment? replace,
  }) async {
    final systemModel = await localDataSource.getLabSystemById(systemId);
    if (systemModel == null) {
      throw Exception('Lab system with ID $systemId not found');
    }

    final currentAssignments = List<StudentAssignmentModel>.from(systemModel.studentAssignments);
    final assignmentModels = assignments
        .map((assignment) => StudentAssignmentModel.fromEntity(assignment))
        .toList();

    if (remove) {
      if (assignmentModels.isEmpty) return;
      currentAssignments.removeWhere((existing) => existing == assignmentModels.first);
    } else if (replace != null) {
      final replacementModel = StudentAssignmentModel.fromEntity(replace);
      final index = currentAssignments.indexWhere((existing) => existing == replacementModel);
      if (index == -1) {
        throw Exception('Existing assignment not found');
      }
      currentAssignments[index] = assignmentModels.first;
    } else if (add) {
      currentAssignments.addAll(assignmentModels);
    }

    final updatedSystem = LabSystemModel(
      id: systemModel.id,
      systemNumber: systemModel.systemNumber,
      studentAssignments: currentAssignments,
    );

    await localDataSource.updateLabSystem(updatedSystem);
  }


  /// Clear all locally cached data
  /// Useful for logout or reset operations
  Future<void> clearLocalData() async {
    try {
      await localDataSource.clearCache();
    } catch (e) {
      throw Exception("Failed to clear local data: $e");
    }
  }
}
