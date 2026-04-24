import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_chart/features/lab/domain/entities/lab_system.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_bloc.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_event.dart';
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
      body: BlocBuilder<LabBloc, LabState>(
        builder: (context, state) {
          if (state is LabInitial || state is LabLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LabLoaded) {
            final systems = state.systems;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 1000;

                final int total = systems.length;
                final int half = (total / 2).ceil();

                // Desktop logic
                final leftList = systems.sublist(0, half);
                final rightList = systems.sublist(half);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Pass dynamic color map from state
                  TeacherLegend(teacherColors: state.teacherColorMap),
                  if (state.message != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        state.message!,
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
                    onChanged: (value) {
                      context.read<LabBloc>().add(SelectTimeSlot(selectedTimeSlot: value));
                    },
                  ),
                  const Divider(height: 30),

                      // Mobile layout
                      if (!isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT COLUMN
                            Expanded(
                              child: Column(
                                children: leftList
                                    .map(
                                      (system) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: ComputerSystemCard(
                                          timeslot: state.selectedTimeSlot,
                                          system: system,
                                          onTap: () => _showAssignmentDialog(
                                            context,
                                            system,
                                            state.selectedTimeSlot,
                                          ),
                                          ),
                                        ),
                                    )
                                    .toList(),
                              ),
                            ),

                            Spacer(flex: 2),

                            // RIGHT COLUMN
                            Expanded(
                              child: Column(
                                children: rightList.reversed
                                    .map(
                                      (system) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: ComputerSystemCard(
                                          timeslot: state.selectedTimeSlot,
                                          system: system,
                                          onTap: () => _showAssignmentDialog(
                                            context,
                                            system,
                                            state.selectedTimeSlot,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        )
                      // Desktop layout
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // LEFT COLUMN (reversed first half)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: leftList.reversed
                                  .map(
                                    (system) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: ComputerSystemCard(
                                        timeslot: state.selectedTimeSlot,
                                        system: system,
                                        onTap: () => _showAssignmentDialog(
                                          context,
                                          system,
                                          state.selectedTimeSlot,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),

                            const SizedBox(height: 120),
                            // RIGHT COLUMN (normal second half)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: rightList
                                  .map(
                                    (system) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: ComputerSystemCard(
                                        timeslot: state.selectedTimeSlot,
                                        system: system,
                                        onTap: () => _showAssignmentDialog(
                                          context,
                                          system,
                                          state.selectedTimeSlot,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            );
          }

          if (state is LabError) {
            return Center(child: Text('Here is the message ${state.message}'));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAssignmentDialog(
    BuildContext context,
    LabSystem system,
    TimeSlot selectedTimeSlot,
  ) {
    final currentAssignment = system.studentAssignments.firstWhereOrNull(
      (assignment) =>
          assignment.endTime.isAfter(selectedTimeSlot.start) &&
          assignment.startTime.isBefore(selectedTimeSlot.end),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return BlocProvider.value(
          value: BlocProvider.of<LabBloc>(context),
          child: AssignmentForm(
            systemId: system.id,
            selectedTimeSlot: selectedTimeSlot,
            existingAssignment: currentAssignment,
          ),
        );
      },
    );
  }
}
