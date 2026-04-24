import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_bloc.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_event.dart';

class AssignmentForm extends StatefulWidget {
  final String systemId;
  const AssignmentForm({super.key, required this.systemId});

  @override
  State<AssignmentForm> createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<AssignmentForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTeacher;
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Assign System",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Student Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Select Teacher",
                border: OutlineInputBorder(),
              ),
              items: [
                'Teacher 1',
                'Teacher 2',
                'Teacher 3',
                'Teacher 4',
                'Teacher 5',
                'Teacher 6',
                'Teacher 7',
              ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _selectedTeacher = val),
            ),
            const SizedBox(height: 12),

            // Time Pickers would go here
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedTeacher != null) {
                    // Dispatch Event
                    context.read<LabBloc>().add(
                      AssignStudent(
                        systemId: widget.systemId,
                        studentName: _nameController.text,
                        teacherName: _selectedTeacher!
                      ),
                    );
                    Navigator.pop(context); // Close the sheet
                  }
                },
                child: const Text("Save Assignment"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
