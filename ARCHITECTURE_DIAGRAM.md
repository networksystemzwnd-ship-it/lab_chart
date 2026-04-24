# ARCHITECTURE DIAGRAM - Clean Architecture + SOLID Principles

## Layer-by-Layer Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│  - Flutter UI (Widgets, Pages, Dialogs)                        │
│  - BLoC State Management                                        │
│  - User Interaction Handlers                                    │
└──────────────────────────┬──────────────────────────────────────┘
                           │ uses
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                                │
│  - Entities (LabSystem, StudentAssignment)                     │
│  - Repository Contracts (Abstract)                             │
│  - Business Logic / Use Cases                                  │
│  - Framework Independent                                       │
└──────────────────────────┬──────────────────────────────────────┘
                           │ implements
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│                     DATA LAYER                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Repository Implementation (LabRepositoryImpl)              │ │
│  │ - Orchestrates data source operations                     │ │
│  │ - Converts Models ↔ Entities                             │ │
│  └──────────────────────┬──────────────────────────────────┘ │
│                         │                                      │
│  ┌──────────────────────┴──────────────────────────────────┐ │
│  │ Data Source Layer (LabLocalDataSourceImpl)              │ │
│  │ - Persistence operations                                │ │
│  │ - Fallback logic                                        │ │
│  │ - Data validation                                       │ │
│  └──────────────────────┬──────────────────────────────────┘ │
│                         │                                      │
│  ┌──────────────────────┴──────────────────────────────────┐ │
│  │ Storage Service (LabStorageService)                     │ │
│  │ - Hive box management                                   │ │
│  │ - Adapter registration                                  │ │
│  │ - CRUD operations                                       │ │
│  └──────────────────────┬──────────────────────────────────┘ │
│                         │                                      │
│  ┌──────────────────────┴──────────────────────────────────┐ │
│  │ Models (LabSystemModel, StudentAssignmentModel)         │ │
│  │ - Serialization/Deserialization                         │ │
│  │ - Entity conversion                                      │ │
│  │ - Hive annotations                                       │ │
│  └──────────────────────────────────────────────────────────┘ │
└──────────────────────────┬──────────────────────────────────────┘
                           │ reads/writes
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│              LOCAL STORAGE LAYER                                │
│  - Hive Database (Key-Value Store)                             │
│  - Device File System                                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Dependency Injection Flow

```
┌──────────────────────┐
│    main() - Entry    │
│     Point            │
└──────────┬───────────┘
           │
           ├─→ WidgetsFlutterBinding.ensureInitialized()
           │
           ├─→ LabServiceProvider.initialize()
           │    │
           │    ├─→ Hive.initFlutter()
           │    │
           │    ├─→ LabStorageService()
           │    │    └─→ Hive.openBox<LabSystemModel>()
           │    │
           │    ├─→ LabLocalDataSourceImpl(storageService)
           │    │
           │    └─→ LabRepositoryImpl(localDataSource)
           │
           ├─→ BlocProvider<LabBloc>(
           │        create: (context) => LabBloc(
           │            labRepository: LabServiceProvider.repository
           │        )
           │    )
           │
           └─→ runApp(MyApp())
```

---

## Data Flow - Load Lab Systems

```
User Opens App
     ↓
LabBloc receives LoadLabSystems event
     ↓
BLoC calls: repository.getLabSystems()
     ↓
LabRepositoryImpl.getLabSystems()
     ↓
localDataSource.getLastSavedLabData()
     ↓
LabLocalDataSourceImpl.getLastSavedLabData()
     ↓
storageService.getLabSystems()
     ↓
Hive Box: lab_systems_box.values.toList()
     ↓
[LabSystemModel, LabSystemModel, ...]
     ↓
Convert Models → Entities
     ↓
[LabSystem, LabSystem, ...]
     ↓
Emit LabLoaded(systems: [...])
     ↓
UI Rebuilds with Systems
```

---

## Data Flow - Assign Student

```
User taps system card
     ↓
Show assignment form dialog
     ↓
User fills form & submits
     ↓
LabBloc receives AssignStudent event
     ↓
BLoC calls: repository.assignStudent(systemId, assignment)
     ↓
LabRepositoryImpl.assignStudent()
     ↓
localDataSource.getLabSystemById(systemId)
     ↓
storageService.getLabSystemById(systemId)
     ↓
Hive retrieval → LabSystemModel
     ↓
Convert assignment Entity → StudentAssignmentModel
     ↓
Create new assignments list with added assignment
     ↓
Create updated LabSystemModel
     ↓
localDataSource.updateLabSystem(updatedSystem)
     ↓
storageService.saveLabSystem(system, index)
     ↓
Hive Box update
     ↓
Data persisted to device storage
     ↓
UI automatically updates via BLoC state
```

---

## SOLID Principles Implementation Map

```
Single Responsibility Principle (SRP)
├─ LabStorageService          → Only manages Hive operations
├─ LabLocalDataSourceImpl      → Only handles data source logic
├─ LabRepositoryImpl           → Only orchestrates operations
├─ StudentAssignmentModel     → Only handles serialization
└─ LabSystemModel             → Only handles serialization

Open/Closed Principle (OCP)
├─ LabLocalDataSource (abstract)
│  ├─ LabLocalDataSourceImpl (current)
│  └─ RemoteDataSource (future, no changes needed)
└─ Can extend with new storage backends without modification

Liskov Substitution Principle (LSP)
├─ StudentAssignmentModel extends StudentAssignment ✓
├─ LabSystemModel extends LabSystem ✓
├─ LabRepositoryImpl implements LabRepository ✓
└─ Any implementation is interchangeable

Interface Segregation Principle (ISP)
├─ LabLocalDataSource
│  ├─ getLastSavedLabData()
│  ├─ cacheLabData()
│  ├─ updateLabSystem()
│  ├─ getLabSystemById()
│  └─ clearCache()
│  (Small, focused methods)
└─ LabStorageService (Specialized interface)

Dependency Inversion Principle (DIP)
├─ main() depends on LabServiceProvider (abstraction)
│  └─ LabServiceProvider depends on abstractions
│     ├─ BLoC depends on LabRepository (abstract)
│     │  └─ LabRepositoryImpl depends on LabLocalDataSource (abstract)
│     │     └─ LabLocalDataSourceImpl depends on LabStorageService (concrete)
│     └─ High-level modules don't depend on low-level details
```

---

## Class Relationships

```
┌──────────────────────────────────────────┐
│  LabServiceProvider (Singleton)          │
│  - initialize()                          │
│  - repository (getter)                   │
│  - storageService (getter)               │
│  - dispose()                             │
└────────────┬─────────────────────────────┘
             │ creates
             ├─→ LabStorageService
             │   ├─ initialize()
             │   ├─ getLabSystems()
             │   └─ [Hive operations]
             │
             ├─→ LabLocalDataSourceImpl
             │   ├─ getLastSavedLabData()
             │   ├─ updateLabSystem()
             │   └─ [depends on storage service]
             │
             └─→ LabRepositoryImpl
                 ├─ getLabSystems()
                 ├─ assignStudent()
                 └─ [depends on data source]

```

---

## Error Handling Flow

```
Storage Layer (LabStorageService)
  └─ Exception: "Failed to save lab systems: ..."
     ↓
Data Source Layer (LabLocalDataSourceImpl)
  └─ Exception: "Failed to update lab system: ..."
     ↓
Repository Layer (LabRepositoryImpl)
  └─ Exception: "Failed to assign student: ..."
     ↓
BLoC Event Handler
  └─ emit(LabError("Failed to assign student: ..."))
     ↓
UI State
  └─ Show error snackbar to user
```

---

## Testing Architecture

```
Unit Tests
├─ LabStorageService (Mock Hive)
├─ LabLocalDataSourceImpl (Mock Storage Service)
├─ LabRepositoryImpl (Mock Data Source)
└─ Models (Serialization/Deserialization)

Integration Tests
├─ Repository + Data Source + Storage
└─ LabBloc + Repository

Widget Tests
├─ UI Components
├─ Mock LabBloc
└─ Test UI state changes
```

---

## Benefits of This Architecture

✅ **Testability**: Each layer can be tested independently
✅ **Maintainability**: Clear separation of concerns
✅ **Scalability**: Easy to add new features
✅ **Flexibility**: Easy to swap implementations
✅ **Reusability**: Components used in multiple features
✅ **Type Safety**: Hive adapters ensure type validation
✅ **Performance**: In-memory cache with disk persistence
✅ **Documentation**: Self-documenting code structure
