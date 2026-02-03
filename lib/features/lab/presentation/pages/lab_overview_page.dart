import 'package:flutter/material.dart';
import 'package:lab_chart/features/lab/domain/entities/lab_system.dart';
import 'package:lab_chart/features/lab/domain/entities/student_assignment.dart';
import 'package:lab_chart/features/lab/presentation/widgets/assignment_form.dart';

import '../widgets/computer_system_card.dart';
import '../widgets/teacher_legend.dart';
// Import your Cubit/Bloc here

class LabOverviewPage extends StatelessWidget {
  const LabOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MOCK DATA (In real app, get this from Bloc/Provider state)
    final List<LabSystem> systems = _getMockSystems();
    final Map<String, Color> legendData = {
      'Mr. Smith': Colors.blueAccent,
      'Ms. Johnson': Colors.green,
      'Mrs. Davis': Colors.orangeAccent,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("CS Lab - Floor 1"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Legend Section
            TeacherLegend(teacherColors: legendData),
            const Divider(height: 30),

            // 2. Grid Section
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 Columns
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: systems.length,
                itemBuilder: (context, index) {
                  return ComputerSystemCard(
                    system: systems[index],
                    onTap: () {
                      _showAssignmentDialog(context, systems[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignmentDialog(BuildContext context, LabSystem system) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => AssignmentForm(systemId: system.id),
    );
  }

  // Mock Data Helper
  List<LabSystem> _getMockSystems() {
    return List.generate(12, (index) {
      // Make every 3rd system occupied for demo
      if (index % 3 == 0) {
        return LabSystem(
          id: '$index',
          systemNumber: 'PC-${index + 1}',
          currentAssignment: StudentAssignment(
            studentName: "John Doe",
            teacherName: "Mr. Smith",
            teacherColor: Colors.blueAccent,
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
          ),
        );
      }
      return LabSystem(id: '$index', systemNumber: 'PC-${index + 1}');
    });
  }
}
