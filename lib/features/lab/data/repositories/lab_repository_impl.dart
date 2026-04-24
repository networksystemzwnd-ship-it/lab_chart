import 'package:lab_chart/features/lab/data/datasources/lab_local_data_source.dart';
import 'package:lab_chart/features/lab/data/models/lab_system_model.dart';
import 'package:lab_chart/features/lab/data/models/student_assignment_model.dart';
import 'package:lab_chart/features/lab/domain/entities/lab_system.dart';
import 'package:lab_chart/features/lab/domain/entities/student_assignment.dart';
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
  Future<void> assignStudent(
    String systemId,
    StudentAssignment assignment,
  ) async {
    try {
      // 1. Get the specific system from storage
      final systemModel =
          await localDataSource.getLabSystemById(systemId);

      if (systemModel == null) {
        throw Exception('Lab system with ID $systemId not found');
      }

      // 2. Convert assignment entity to model for persistence
      final assignmentModel =
          StudentAssignmentModel.fromEntity(assignment);

      // 3. Create updated assignments list with new assignment
      final updatedAssignments = [
        ...systemModel.studentAssignments,
        assignmentModel,
      ];

      // 4. Create updated system model
      final updatedSystem = LabSystemModel(
        id: systemModel.id,
        systemNumber: systemModel.systemNumber,
        studentAssignments: updatedAssignments,
      );

      // 5. Save updated system back to storage
      await localDataSource.updateLabSystem(updatedSystem);
    } catch (e) {
      throw Exception("Failed to assign student: $e");
    }
  }

  /// Sync all lab systems to local storage
  /// Useful for initial load or refresh operations
  Future<void> syncLabSystems(List<LabSystem> systems) async {
    try {
      final models = systems
          .map((system) => LabSystemModel.fromEntity(system))
          .toList();
      await localDataSource.cacheLabData(models);
    } catch (e) {
      throw Exception("Failed to sync lab systems: $e");
    }
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
