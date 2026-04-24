import 'package:hive_flutter/hive_flutter.dart';
import 'package:lab_chart/features/lab/data/datasources/lab_local_data_source.dart';
import 'package:lab_chart/features/lab/data/datasources/lab_storage_service.dart';
import 'package:lab_chart/features/lab/data/repositories/lab_repository_impl.dart';
import 'package:lab_chart/features/lab/domain/repositories/lab_repository.dart';

/// Service locator and dependency injection for Lab feature
/// 
/// SOLID Principles:
/// - Dependency Inversion: Provides abstractions, not implementations
/// - Single Responsibility: Only manages lab feature dependencies
/// - Interface Segregation: Exposes only necessary initialization methods
/// 
/// Clean Architecture:
/// - Separates dependency setup from business logic
/// - Allows easy swapping of implementations (e.g., mock for testing)
/// - Centralizes configuration for maintainability
class LabServiceProvider {
  static final LabServiceProvider _instance = LabServiceProvider._internal();
  static late LabStorageService _storageService;
  static late LabLocalDataSource _localDataSource;
  static late LabRepository _repository;

  factory LabServiceProvider() {
    return _instance;
  }

  LabServiceProvider._internal();

  /// Initialize all lab feature dependencies
  /// Must be called once during app startup, preferably in main()
  static Future<void> initialize() async {
    try {
      // 1. Initialize Hive for persistence
      await Hive.initFlutter();

      // 2. Create and initialize storage service
      _storageService = LabStorageService();
      await _storageService.initialize();

      // 3. Create local data source with storage service
      _localDataSource = LabLocalDataSourceImpl(
        storageService: _storageService,
      );

      // 4. Create repository with local data source
      _repository = LabRepositoryImpl(
        localDataSource: _localDataSource,
      );
    } catch (e) {
      throw Exception('Failed to initialize Lab services: $e');
    }
  }

  /// Get the initialized repository
  static LabRepository get repository {
    if (_repository == null) {
      throw Exception(
        'LabRepository not initialized. Call LabServiceProvider.initialize() first.',
      );
    }
    return _repository;
  }

  /// Get the initialized storage service
  static LabStorageService get storageService {
    if (_storageService == null) {
      throw Exception(
        'LabStorageService not initialized. Call LabServiceProvider.initialize() first.',
      );
    }
    return _storageService;
  }

  /// Cleanup resources (call during app shutdown)
  static Future<void> dispose() async {
    try {
      await _storageService.close();
    } catch (e) {
      throw Exception('Failed to dispose Lab services: $e');
    }
  }
}
