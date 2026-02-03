import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_chart/features/lab/domain/entities/lab_system.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_bloc.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_state.dart';
import 'package:lab_chart/features/lab/presentation/widgets/assignment_form.dart';
import 'package:lab_chart/features/lab/presentation/widgets/computer_system_card.dart';
import 'package:lab_chart/features/lab/presentation/widgets/teacher_legend.dart';

class LabOverviewPage extends StatelessWidget {
  const LabOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CS Lab - Floor 1 s")),

      // Use BlocBuilder to listen to state changes
      body: BlocBuilder<LabBloc, LabState>(
        builder: (context, state) {
          if (state is LabInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LabLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LabLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pass dynamic color map from state
                  TeacherLegend(teacherColors: state.teacherColorMap),
                  const Divider(height: 30),

                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: state.systems.length,
                      itemBuilder: (context, index) {
                        final system = state.systems[index];
                        return ComputerSystemCard(
                          system: system,
                          onTap: () {
                            _showAssignmentDialog(context, system);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is LabError) {
            return Center(child: Text('Here is the message ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAssignmentDialog(BuildContext context, LabSystem system) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        // IMPORTANT: Pass the existing Bloc to the BottomSheet
        return BlocProvider.value(
          value: BlocProvider.of<LabBloc>(context),
          child: AssignmentForm(systemId: system.id),
        );
      },
    );
  }
}
