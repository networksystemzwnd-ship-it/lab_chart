/// CLEAN ARCHITECTURE & LOCAL DATA SOURCE INTEGRATION GUIDE
/// 
/// This document explains the implementation of local data persistence
/// following Clean Architecture principles and SOLID guidelines.
/// 
/// ============================================================================
/// ARCHITECTURE LAYERS
/// ============================================================================
/// 
/// 1. PRESENTATION LAYER (presentation/)
///    - Flutter UI widgets (pages, dialogs, etc.)
///    - BLoC for state management
///    - Communicates with Domain layer only
/// 
/// 2. DOMAIN LAYER (domain/)
///    - Entities: Pure business logic models (LabSystem, StudentAssignment)
///    - Repositories: Abstract contracts for data operations
///    - No external dependencies (framework-agnostic)
/// 
/// 3. DATA LAYER (data/)
///    - Models: Extend domain entities, add serialization logic
///    - Data Sources: Concrete implementations (LocalDataSource)
///    - Repositories: Implement domain contracts
///    - Storage Service: Handles Hive/database operations
/// 
/// ============================================================================
/// SOLID PRINCIPLES APPLIED
/// ============================================================================
/// 
/// S - Single Responsibility
///   - LabStorageService: Only manages Hive operations
///   - LabLocalDataSourceImpl: Only handles data source logic
///   - StudentAssignmentModel: Only handles serialization
/// 
/// O - Open/Closed
///   - New storage backends can be added without modifying existing code
///   - Add RemoteDataSource implementing LabLocalDataSource
///   - Repository can switch between implementations
/// 
/// L - Liskov Substitution
///   - LabSystemModel properly extends LabSystem
///   - StudentAssignmentModel properly extends StudentAssignment
///   - Implementations can be swapped transparently
/// 
/// I - Interface Segregation
///   - LabLocalDataSource defines only necessary methods
///   - LabStorageService separated from data source logic
///   - Each class exposes minimal required interface
/// 
/// D - Dependency Inversion
///   - Repository depends on LabLocalDataSource abstraction
///   - BLoC depends on LabRepository abstraction
///   - LabServiceProvider injected as singleton
/// 
/// ============================================================================
/// DATA FLOW
/// ============================================================================
/// 
/// USER ACTION
///     ↓
/// BLoC Event (presentation/)
///     ↓
/// BLoC Event Handler
///     ↓
/// Repository.getLabSystems() (domain contract)
///     ↓
/// LabRepositoryImpl.getLabSystems() (data/)
///     ↓
/// LabLocalDataSourceImpl.getLastSavedLabData() (data/)
///     ↓
/// LabStorageService.getLabSystems() (Hive operations)
///     ↓
/// Hive Box (local storage)
///     ↓
/// Models ↔ Entities (conversion)
///     ↓
/// BLoC State (domain entities)
///     ↓
/// UI Widgets
/// 
/// ============================================================================
/// INITIALIZATION IN MAIN.DART
/// ============================================================================
/// 
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   // Initialize all lab feature dependencies
///   await LabServiceProvider.initialize();
///   
///   runApp(const MyApp());
/// }
/// 
/// ============================================================================
/// USING THE REPOSITORY IN BLOC
/// ============================================================================
/// 
/// class LabBloc extends Bloc<LabEvent, LabState> {
///   final LabRepository labRepository;
///   
///   LabBloc({required this.labRepository}) : super(LabInitial()) {
///     on<LoadLabSystems>(_onLoadSystems);
///   }
///   
///   void _onLoadSystems(LoadLabSystems event, Emitter<LabState> emit) async {
///     try {
///       final systems = await labRepository.getLabSystems();
///       emit(LabLoaded(systems: systems, ...));
///     } catch (e) {
///       emit(LabError(e.toString()));
///     }
///   }
/// }
/// 
/// // Inject in main.dart or service locator
/// context.read<LabBloc>() // Already has repository injected
/// 
/// ============================================================================
/// DATA PERSISTENCE DETAILS
/// ============================================================================
/// 
/// Storage Location: Platform-specific app documents directory
/// - Android: /data/data/com.example.lab_chart/files/
/// - iOS: Library/Documents/
/// - Windows: AppData/Local/lab_chart/
/// 
/// Database Format: Hive (Key-Value store)
/// - Type-safe with Hive adapters
/// - Fast access (in-memory + disk)
/// - Supports complex objects
/// 
/// Box Structure:
/// - lab_systems_box: List<LabSystemModel>
/// - lab_assignments_box: Backup assignments storage
/// 
/// ============================================================================
/// ADDING NEW FEATURES
/// ============================================================================
/// 
/// 1. Add new method to LabRepository (domain/)
/// 2. Implement in LabRepositoryImpl (data/)
/// 3. Call LabLocalDataSourceImpl method
/// 4. Add LabStorageService helper if needed
/// 5. Update LabBloc with new event/handler
/// 6. Create UI for new feature
/// 
/// ============================================================================
/// TESTING
/// ============================================================================
/// 
/// Mock the LabRepository for BLoC tests:
/// 
///   class MockLabRepository extends Mock implements LabRepository {}
///   
///   setUp(() {
///     mockRepository = MockLabRepository();
///     labBloc = LabBloc(labRepository: mockRepository);
///   });
/// 
/// ============================================================================
/// ERROR HANDLING
/// ============================================================================
/// 
/// The architecture includes multi-layer error handling:
/// 
/// 1. Storage Service: Raw exceptions with context
/// 2. Data Source: Wraps errors with descriptive messages
/// 3. Repository: Adds business context to errors
/// 4. BLoC: Converts to error states for UI display
/// 5. UI: Shows user-friendly error messages
/// 
/// ============================================================================
