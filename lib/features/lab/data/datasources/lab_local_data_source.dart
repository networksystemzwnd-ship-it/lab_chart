import 'package:flutter/material.dart';
import 'package:lab_chart/features/lab/data/datasources/lab_storage_service.dart';
import 'package:lab_chart/features/lab/data/models/lab_system_model.dart';
import 'package:lab_chart/features/lab/data/models/teacher_model.dart';

/// Contract for local data source operations
/// 
/// SOLID Principles:
/// - Interface Segregation: Focused on local persistence contracts
/// - Dependency Inversion: Repository depends on abstraction
abstract class LabLocalDataSource {
  /// Retrieve the last saved lab data from local storage
  Future<List<LabSystemModel>> getLastSavedLabData();

  /// Cache/Save lab systems to local storage
  Future<void> cacheLabData(List<LabSystemModel> systems);

  /// Update a specific lab system in local storage
  Future<void> updateLabSystem(LabSystemModel system);

  /// Get a specific lab system by ID
  Future<LabSystemModel?> getLabSystemById(String id);

  /// Retrieve all saved teachers from local storage
  Future<List<TeacherModel>> getTeachers();

  /// Add a teacher to the local store
  Future<void> addTeacher(TeacherModel teacher);

  /// Update an existing teacher record
  Future<void> updateTeacher(TeacherModel teacher, {required String originalName});

  /// Delete a teacher from storage
  Future<void> deleteTeacher(String name);

  /// Cache teacher list to local storage
  Future<void> cacheTeachers(List<TeacherModel> teachers);

  /// Clear all cached data
  Future<void> clearCache();
}

/// Implementation of local data source using Hive for persistence
/// 
/// SOLID Principles:
/// - Single Responsibility: Handles only local data persistence
/// - Open/Closed: Can be extended for other storage backends
/// - Liskov Substitution: Proper implementation of LabLocalDataSource
/// - Dependency Inversion: Depends on LabStorageService abstraction
class LabLocalDataSourceImpl implements LabLocalDataSource {
  final LabStorageService storageService;

  // Default lab systems (22 empty PCs as per requirements)
  static const int _defaultSystemCount = 22;

  LabLocalDataSourceImpl({required this.storageService});

  /// Generate default empty lab systems
  static List<LabSystemModel> _generateDefaultSystems() {
    return List.generate(
      _defaultSystemCount,
      (index) => LabSystemModel(
        id: 'lab_system_${index + 1}',
        systemNumber: 'PC-${(index + 1).toString().padLeft(2, '0')}',
        studentAssignments: [],
      ),
    );
  }

  @override
  Future<List<LabSystemModel>> getLastSavedLabData() async {
    try {
      // Try to get cached data from storage
      final cachedSystems = await storageService.getLabSystems();

      // If no cached data, return default systems and save them
      if (cachedSystems.isEmpty) {
        final defaultSystems = _generateDefaultSystems();
        await cacheLabData(defaultSystems);
        return defaultSystems;
      }

      return cachedSystems;
    } catch (e) {
      // Fallback: return default systems if storage fails
      return _generateDefaultSystems();
    }
  }

  @override
  Future<void> cacheLabData(List<LabSystemModel> systems) async {
    try {
      await storageService.saveLabSystems(systems);
    } catch (e) {
      throw Exception('Failed to cache lab data: $e');
    }
  }

  @override
  Future<List<TeacherModel>> getTeachers() async {
    try {
      final cachedTeachers = await storageService.getTeachers();
      if (cachedTeachers.isEmpty) {
        final defaultTeachers = _generateDefaultTeachers();
        await cacheTeachers(defaultTeachers);
        return defaultTeachers;
      }
      return cachedTeachers;
    } catch (e) {
      return _generateDefaultTeachers();
    }
  }

  @override
  Future<void> addTeacher(TeacherModel teacher) async {
    try {
      await storageService.addTeacher(teacher);
    } catch (e) {
      throw Exception('Failed to add teacher: $e');
    }
  }

  @override
  Future<void> updateTeacher(TeacherModel teacher, {required String originalName}) async {
    try {
      await storageService.updateTeacher(teacher, originalName: originalName);
    } catch (e) {
      throw Exception('Failed to update teacher: $e');
    }
  }

  @override
  Future<void> deleteTeacher(String name) async {
    try {
      await storageService.deleteTeacher(name);
    } catch (e) {
      throw Exception('Failed to delete teacher: $e');
    }
  }

  @override
  Future<void> cacheTeachers(List<TeacherModel> teachers) async {
    try {
      await storageService.saveTeachers(teachers);
    } catch (e) {
      throw Exception('Failed to cache teachers: $e');
    }
  }

  @override
  Future<void> updateLabSystem(LabSystemModel system) async {
    try {
      final allSystems = await storageService.getLabSystems();
      final index = allSystems.indexWhere((s) => s.id == system.id);

      if (index == -1) {
        throw Exception('Lab system with ID ${system.id} not found');
      }

      await storageService.saveLabSystem(system, index);
    } catch (e) {
      throw Exception('Failed to update lab system: $e');
    }
  }

  @override
  Future<LabSystemModel?> getLabSystemById(String id) async {
    try {
      return await storageService.getLabSystemById(id);
    } catch (e) {
      throw Exception('Failed to retrieve lab system: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await storageService.clearAll();
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  static List<TeacherModel> _generateDefaultTeachers() {
    return [
      TeacherModel(name: 'Jiffry', color: Colors.red),
      TeacherModel(name: 'Anandu', color: Colors.blueAccent),
      TeacherModel(name: 'Farsana', color: Colors.green),
      TeacherModel(name: 'Hadiya', color: Colors.deepPurple),
      TeacherModel(name: 'Farshana', color: Colors.cyan),
      TeacherModel(name: 'Afeef', color: Colors.amber),
    ];
  }
}
