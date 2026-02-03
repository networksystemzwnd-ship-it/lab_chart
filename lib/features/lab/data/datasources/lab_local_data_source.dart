import 'package:lab_chart/features/lab/data/models/lab_system_model.dart';

abstract class LabLocalDataSource {
  Future<List<LabSystemModel>> getLastSavedLabData();
  Future<void> cacheLabData(List<LabSystemModel> systems);
}

class LabLocalDataSourceImpl implements LabLocalDataSource {
  // Example using a simple in-memory list or SharedPrefs/Hive
  @override
  Future<List<LabSystemModel>> getLastSavedLabData() async {
    // If no data, return default list (your 12 empty PCs)
    return List.generate(
      5,
      (index) => LabSystemModel(id: '$index', systemNumber: 'PC-${index + 1}'),
    );

    // ACTUAL DB CALL GOES HERE
    // e.g., return hiveBox.values.toList();
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate DB
    return []; // Return empty or cached data
  }

  @override
  Future<void> cacheLabData(List<LabSystemModel> systems) async {
    // Save to DB
  }
}
