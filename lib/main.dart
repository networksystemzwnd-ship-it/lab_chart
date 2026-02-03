import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_chart/features/lab/data/datasources/lab_local_data_source.dart';
import 'package:lab_chart/features/lab/data/repositories/lab_repository_impl.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_bloc.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_event.dart';
import 'package:lab_chart/features/lab/presentation/pages/lab_overview_page.dart';

void main() {
  // 1. Create the Data Source
  final dataSource = LabLocalDataSourceImpl();
  // 2. Create the Repository (injecting Data Source)
  final labRepository = LabRepositoryImpl(localDataSource: dataSource);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LabBloc>(
          create: (context) =>
              LabBloc(labRepository: labRepository)..add(LoadLabSystems()),
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
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const LabOverviewPage(),
    );
  }
}
