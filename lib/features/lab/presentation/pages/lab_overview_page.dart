import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_chart/features/lab/domain/entities/lab_system.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_bloc.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_state.dart';
import 'package:lab_chart/features/lab/presentation/widgets/assignment_form.dart';
import 'package:lab_chart/features/lab/presentation/widgets/computer_system_card.dart';
import 'package:lab_chart/features/lab/presentation/widgets/teacher_legend.dart';
import 'package:lab_chart/features/time_line_slot_picker_widget/time_line_slot_picker_widget.dart';

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
            // 1. Prepare the data
            final systems = state.systems;
            final int total = systems.length;
            final int half = (total / 2).ceil();

            // This ensures Column 1 has 1-11 and Column 2 has 12-22
            final leftList = systems.sublist(0, half);
            final rightList = systems.sublist(half).reversed;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Pass dynamic color map from state
                  TeacherLegend(teacherColors: state.teacherColorMap),
                  const Divider(height: 30),

                  TimelineSlotPicker(
                    startTime: DateTime(2026, 1, 1, 9, 0),
                    endTime: DateTime(2026, 1, 1, 17, 30),
                    divisions: [
                      Duration(minutes: 30),
                      Duration(hours: 1),
                      Duration(hours: 1),
                      Duration(hours: 1),
                      Duration(hours: 1),
                      Duration(minutes: 30),
                      Duration(hours: 1),
                      Duration(hours: 1),
                      Duration(hours: 1),
                      Duration(minutes: 30),
                    ],
                  ),
                  const Divider(height: 30),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT COLUMN (1 to 11)
                      Expanded(
                        child: Column(
                          children: leftList
                              .map(
                                (system) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ComputerSystemCard(
                                    system: system,
                                    onTap: () =>
                                        _showAssignmentDialog(context, system),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),

                      Spacer(flex: 2),

                      // RIGHT COLUMN (12 to 22)
                      Expanded(
                        child: Column(
                          children: rightList
                              .map(
                                (system) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ComputerSystemCard(
                                    system: system,
                                    onTap: () =>
                                        _showAssignmentDialog(context, system),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
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
