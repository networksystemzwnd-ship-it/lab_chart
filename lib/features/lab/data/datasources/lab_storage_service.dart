import 'package:hive/hive.dart';
import 'package:lab_chart/features/lab/data/models/lab_system_model.dart';

/// Handles all Hive storage operations
/// 
/// SOLID Principles:
/// - Single Responsibility: Only manages Hive box operations
/// - Dependency Inversion: Abstracts Hive implementation details
/// - Interface Segregation: Focused on storage concerns
class LabStorageService {
  static const String boxName = 'lab_systems_box';
  static const String assignmentsBoxName = 'lab_assignments_box';

  late Box<LabSystemModel> _labSystemsBox;
  late Box<List<dynamic>> _assignmentsBox;

  /// Initialize the storage service and open Hive boxes
  Future<void> initialize() async {
    try {
      // Register Hive adapters for models
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(LabSystemModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(StudentAssignmentModelAdapter());
      }

      // Open boxes
      _labSystemsBox = await Hive.openBox<LabSystemModel>(boxName);
      _assignmentsBox = await Hive.openBox<List<dynamic>>(assignmentsBoxName);
    } catch (e) {
      throw Exception('Failed to initialize local storage: $e');
    }
  }

  /// Check if service is initialized
  bool get isInitialized {
    try {
      return _labSystemsBox.isOpen && _assignmentsBox.isOpen;
    } catch (_) {
      return false;
    }
  }

  /// Save a list of lab systems to local storage
  Future<void> saveLabSystems(List<LabSystemModel> systems) async {
    try {
      await _labSystemsBox.clear();
      await _labSystemsBox.addAll(systems);
    } catch (e) {
      throw Exception('Failed to save lab systems: $e');
    }
  }

  /// Save a single lab system
  Future<void> saveLabSystem(LabSystemModel system, int index) async {
    try {
      await _labSystemsBox.putAt(index, system);
    } catch (e) {
      throw Exception('Failed to save lab system: $e');
    }
  }

  /// Retrieve all lab systems from local storage
  Future<List<LabSystemModel>> getLabSystems() async {
    try {
      if (_labSystemsBox.isEmpty) {
        return [];
      }
      return _labSystemsBox.values.toList();
    } catch (e) {
      throw Exception('Failed to retrieve lab systems: $e');
    }
  }

  /// Get a specific lab system by ID
  Future<LabSystemModel?> getLabSystemById(String id) async {
    try {
      final systems = _labSystemsBox.values.toList();
      return systems.firstWhere(
        (system) => system.id == id,
        orElse: () => LabSystemModel(id: '', systemNumber: ''),
      );
    } catch (e) {
      throw Exception('Failed to retrieve lab system: $e');
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      await _labSystemsBox.clear();
      await _assignmentsBox.clear();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }

  /// Close all Hive boxes
  Future<void> close() async {
    try {
      await _labSystemsBox.close();
      await _assignmentsBox.close();
    } catch (e) {
      throw Exception('Failed to close storage: $e');
    }
  }
}
