import 'package:lab_chart/features/lab/domain/entities/student_assignment.dart';

import '../../domain/entities/lab_system.dart';
import '../../domain/repositories/lab_repository.dart';
import '../datasources/lab_local_data_source.dart';

class LabRepositoryImpl implements LabRepository {
  final LabLocalDataSource localDataSource;

  LabRepositoryImpl({required this.localDataSource});

  @override
  Future<List<LabSystem>> getLabSystems() async {
    try {
      // 1. Ask Data Source for data
      final models = await localDataSource.getLastSavedLabData();

      // 2. Convert Models -> Entities (if needed)
      return models;
    } catch (e) {
      // Handle DB errors
      throw Exception("Failed to load lab data");
    }
  }

  @override
  Future<void> assignStudent(
    String systemId,
    StudentAssignment assignment,
  ) async {
    // 1. Get current list
    final currentList = await getLabSystems();

    // 2. Modify list logic...

    // 3. Save back to Data Source
    // await localDataSource.cacheLabData(newList);
  }
}
