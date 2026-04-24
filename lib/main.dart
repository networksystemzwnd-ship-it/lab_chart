import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_chart/features/lab/data/service_providers/lab_service_provider.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_bloc.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_event.dart';
import 'package:lab_chart/features/lab/presentation/pages/lab_overview_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all lab feature dependencies
  // This sets up Hive storage, data sources, and repositories
  await LabServiceProvider.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LabBloc>(
          create: (context) =>
              LabBloc(labRepository: LabServiceProvider.repository)
                ..add(LoadLabSystems()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab Chart',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const LabOverviewPage(),
    );
  }
}
