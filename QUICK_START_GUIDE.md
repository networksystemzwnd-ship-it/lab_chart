# QUICK START GUIDE - Local Data Source Integration

## 🚀 Setup Instructions (First Time)

### Step 1: Install Dependencies
```bash
cd lab_chart
flutter pub get
```

### Step 2: Generate Hive Adapters
```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates the `.g.dart` files for model serialization:
- `student_assignment_model.g.dart`
- `lab_system_model.g.dart`

### Step 3: Run the App
```bash
flutter run
```

---

## 📋 Verify Installation

### Check Generated Files
After running build_runner, verify these files exist:
```
lib/features/lab/data/models/
├── student_assignment_model.dart
├── student_assignment_model.g.dart  ← Generated
├── lab_system_model.dart
└── lab_system_model.g.dart          ← Generated
```

### Test Data Persistence
1. Run the app: `flutter run`
2. Assign a student to a system
3. Kill the app (close or stop in terminal)
4. Relaunch: `flutter run`
5. Verify the assignment is still visible ✓

---

## 🔧 How It Works

### Data is automatically persisted when:
- ✅ You assign a student to a system
- ✅ App loads (retrieves from storage)
- ✅ You sync data manually

### Storage Location:
```
Android:  /data/data/com.example.lab_chart/files/hive/
iOS:      Library/Documents/hive/
Windows:  AppData/Local/lab_chart/
```

### View Stored Data (Dev Only):
```dart
// In your app or debug console
final storageService = LabServiceProvider.storageService;
final systems = await storageService.getLabSystems();
print(systems.length); // Number of systems stored
```

---

## 📝 Common Tasks

### Clear All Cached Data
```dart
await LabServiceProvider.repository.clearLocalData();
```

### Sync Fresh Data
```dart
final systems = [/* your system list */];
await LabServiceProvider.repository.syncLabSystems(systems);
```

### Get Specific System
```dart
final system = await LabServiceProvider.repository
    .getLabSystems()
    .then((systems) => systems.firstWhere((s) => s.id == 'lab_system_1'));
```

### Add Assignment (From BLoC)
```dart
context.read<LabBloc>().add(
  AssignStudent(
    systemId: 'lab_system_1',
    studentName: 'John Doe',
    teacherName: 'Teacher 1',
  ),
);
```

---

## 🐛 Troubleshooting

### Issue: "LabSystemModelAdapter not registered"
**Solution:**
```bash
dart run build_runner build --delete-conflicting-outputs
flutter pub get
flutter run
```

### Issue: "LabRepository not initialized"
**Cause:** `LabServiceProvider.initialize()` not called in `main()`
**Solution:** Make sure `main()` is async and has:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LabServiceProvider.initialize();  // ← This line
  runApp(const MyApp());
}
```

### Issue: Data not persisting
**Check:**
1. Is `LabBloc` properly dispatching events?
2. Is `assignStudent` being called in repository?
3. Is data being written to Hive box?

**Debug:**
```dart
// Add to LabLocalDataSourceImpl
@override
Future<void> updateLabSystem(LabSystemModel system) async {
  print('Updating system: ${system.id}');
  try {
    await storageService.saveLabSystem(system, index);
    print('✓ System updated successfully');
  } catch (e) {
    print('✗ Failed: $e');
    rethrow;
  }
}
```

### Issue: Hive box is empty after restart
**Possible causes:**
- Data was never persisted (check assignment logic)
- Device storage was cleared
- App was uninstalled/reinstalled

**Verify:** Check that `cacheLabData()` is being called

---

## 📚 Architecture Files

### Documentation
- **ARCHITECTURE.md** - Complete architecture guide
- **ARCHITECTURE_DIAGRAM.md** - Visual diagrams and data flows
- **LOCAL_DATA_SOURCE_SUMMARY.md** - Implementation summary
- **QUICK_START_GUIDE.md** - This file

### Source Files

**Data Layer - Storage & Persistence:**
- `lib/features/lab/data/datasources/lab_storage_service.dart`
- `lib/features/lab/data/datasources/lab_local_data_source.dart`
- `lib/features/lab/data/repositories/lab_repository_impl.dart`

**Models - Serialization:**
- `lib/features/lab/data/models/lab_system_model.dart`
- `lib/features/lab/data/models/student_assignment_model.dart`

**Service Provider - DI:**
- `lib/features/lab/data/service_providers/lab_service_provider.dart`

---

## ✅ Checklist Before Deployment

- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] All `.g.dart` files are generated
- [ ] `flutter analyze` shows no errors
- [ ] `flutter test` passes all tests
- [ ] Tested data persistence locally
- [ ] Tested on Android/iOS/Windows
- [ ] Reviewed ARCHITECTURE.md
- [ ] Updated team on new structure

---

## 🤝 Integration with Team

### When Adding New Features:
1. Add method to domain `LabRepository` contract
2. Implement in `LabRepositoryImpl`
3. Add to `LabLocalDataSourceImpl` if needed
4. Create BLoC event and handler
5. Update UI

### Team Handoff:
Share these files with team:
- ARCHITECTURE.md
- LOCAL_DATA_SOURCE_SUMMARY.md
- ARCHITECTURE_DIAGRAM.md

---

## 📞 Support

For issues or questions:
1. Check ARCHITECTURE.md
2. Review the relevant source file
3. Check error messages in debug console
4. Verify initialization in main.dart

---

## 🎯 Next: Adding More Features

### Example: Add "Clear Specific System"
```dart
// 1. Add to domain repository contract
abstract class LabRepository {
  Future<void> clearSystem(String systemId);
}

// 2. Implement in LabRepositoryImpl
@override
Future<void> clearSystem(String systemId) async {
  final systemModel = await localDataSource.getLabSystemById(systemId);
  if (systemModel != null) {
    final cleared = LabSystemModel(
      id: systemModel.id,
      systemNumber: systemModel.systemNumber,
      studentAssignments: [], // Clear assignments
    );
    await localDataSource.updateLabSystem(cleared);
  }
}

// 3. Add BLoC event and handler
class ClearSystem extends LabEvent {
  final String systemId;
  const ClearSystem({required this.systemId});
}

// 4. Add handler in LabBloc
on<ClearSystem>((event, emit) {
  // Call repository and update state
});
```

That's it! The architecture handles the rest.
