import 'package:hive/hive.dart';
import 'package:lab_chart/features/lab/data/models/lab_system_model.dart';
import 'package:lab_chart/features/lab/data/models/student_assignment_model.dart';

import '../models/teacher_model.dart';

/// Handles all Hive storage operations
/// 
/// SOLID Principles:
/// - Single Responsibility: Only manages Hive box operations
/// - Dependency Inversion: Abstracts Hive implementation details
/// - Interface Segregation: Focused on storage concerns
class LabStorageService {
  static const String boxName = 'lab_systems_box';
  static const String assignmentsBoxName = 'lab_assignments_box';
  static const String teachersBoxName = 'teachers_box';

  late Box<LabSystemModel> _labSystemsBox;
  late Box<List<dynamic>> _assignmentsBox;
  late Box<TeacherModel> _teachersBox;

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
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(TeacherModelAdapter());
      }

      // Open boxes
      _labSystemsBox = await Hive.openBox<LabSystemModel>(boxName);
      _assignmentsBox = await Hive.openBox<List<dynamic>>(assignmentsBoxName);
      _teachersBox = await Hive.openBox<TeacherModel>(teachersBoxName);
    } catch (e) {
      throw Exception('Failed to initialize local storage: $e');
    }
  }

  /// Check if service is initialized
  bool get isInitialized {
    try {
      return _labSystemsBox.isOpen && _assignmentsBox.isOpen && _teachersBox.isOpen;
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
      for (final system in _labSystemsBox.values) {
        if (system.id == id) {
          return system;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to retrieve lab system: $e');
    }
  }

  /// Retrieve all saved teachers from local storage.
  Future<List<TeacherModel>> getTeachers() async {
    try {
      return _teachersBox.values.toList();
    } catch (e) {
      throw Exception('Failed to retrieve teachers: $e');
    }
  }

  /// Cache a teacher list to local storage.
  Future<void> saveTeachers(List<TeacherModel> teachers) async {
    try {
      await _teachersBox.clear();
      await _teachersBox.addAll(teachers);
    } catch (e) {
      throw Exception('Failed to save teachers: $e');
    }
  }

  /// Add a single teacher entry to storage.
  Future<void> addTeacher(TeacherModel teacher) async {
    try {
      if (_teachersBox.values.any((entry) => entry.name == teacher.name)) {
        throw Exception('Teacher with name ${teacher.name} already exists.');
      }
      await _teachersBox.add(teacher);
    } catch (e) {
      throw Exception('Failed to add teacher: $e');
    }
  }

  /// Get a teacher by name.
  Future<TeacherModel?> getTeacherByName(String name) async {
    try {
      for (final teacher in _teachersBox.values) {
        if (teacher.name == name) {
          return teacher;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to retrieve teacher: $e');
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      await _labSystemsBox.clear();
      await _assignmentsBox.clear();
      await _teachersBox.clear();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }

  /// Close all Hive boxes
  Future<void> close() async {
    try {
      await _labSystemsBox.close();
      await _assignmentsBox.close();
      await _teachersBox.close();
    } catch (e) {
      throw Exception('Failed to close storage: $e');
    }
  }
}
