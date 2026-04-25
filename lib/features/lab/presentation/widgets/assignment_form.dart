import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_chart/features/lab/domain/entities/student_assignment.dart';
import 'package:lab_chart/features/lab/domain/entities/teacher.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_bloc.dart';
import 'package:lab_chart/features/lab/presentation/bloc/lab_event.dart';
import 'package:lab_chart/features/time_line_slot_picker_widget/time_line_slot_picker_widget.dart';

class AssignmentForm extends StatefulWidget {
  final String systemId;
  final StudentAssignment? existingAssignment;
  final List<Teacher> availableTeachers;
  final TimeSlot selectedTimeSlot;

  const AssignmentForm({
    super.key,
    required this.systemId,
    required this.availableTeachers,
    required this.selectedTimeSlot,
    this.existingAssignment,
  });

  @override
  State<AssignmentForm> createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<AssignmentForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTeacher;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingAssignment != null) {
      _nameController.text = widget.existingAssignment!.studentName;
      _selectedTeacher = widget.existingAssignment!.teacherName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableTeacherOptions = [
      ...widget.availableTeachers,
    ];

    if (widget.existingAssignment != null &&
        !availableTeacherOptions.any((teacher) =>
            teacher.name == widget.existingAssignment!.teacherName)) {
      availableTeacherOptions.insert(
        0,
        Teacher(
          name: widget.existingAssignment!.teacherName,
          color: widget.existingAssignment!.teacherColor,
        ),
      );
    }

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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a student name';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: "Student Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _selectedTeacher,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a teacher';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: "Select Teacher",
                border: OutlineInputBorder(),
              ),
              items: availableTeacherOptions
                  .map((teacher) => DropdownMenuItem(
                        value: teacher.name,
                        child: Text(teacher.name),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedTeacher = val),
            ),
            const SizedBox(height: 12),

            Text(
              'Selected time slot: ${_formatTime(widget.selectedTimeSlot.start)} - ${_formatTime(widget.selectedTimeSlot.end)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _selectedTeacher != null) {
                        final selectedTeacher = availableTeacherOptions.firstWhere(
                          (teacher) => teacher.name == _selectedTeacher,
                          orElse: () => Teacher(name: _selectedTeacher!, color: Colors.grey),
                        );

                        final assignment = StudentAssignment(
                          studentName: _nameController.text.trim(),
                          teacherName: selectedTeacher.name,
                          teacherColor: selectedTeacher.color,
                          startTime: widget.selectedTimeSlot.start,
                          endTime: widget.selectedTimeSlot.end,
                        );

                        if (widget.existingAssignment != null) {
                          context.read<LabBloc>().add(
                                UpdateStudentAssignment(
                                  systemId: widget.systemId,
                                  oldAssignment: widget.existingAssignment!,
                                  updatedAssignment: assignment,
                                ),
                              );
                        } else {
                          context.read<LabBloc>().add(
                                AssignStudent(
                                  systemId: widget.systemId,
                                  studentName: assignment.studentName,
                                  teacherName: assignment.teacherName,
                                ),
                              );
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: Text(widget.existingAssignment != null ? 'Update Assignment' : 'Save Assignment'),
                  ),
                ),
                if (widget.existingAssignment != null) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.redAccent,
                    tooltip: 'Delete assignment',
                    onPressed: () {
                      context.read<LabBloc>().add(
                            DeleteStudentAssignment(
                              systemId: widget.systemId,
                              assignment: widget.existingAssignment!,
                            ),
                          );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Color _getTeacherColor(String teacherName) {
    final teacher = widget.availableTeachers.firstWhere(
      (teacher) => teacher.name == teacherName,
      orElse: () => Teacher(name: teacherName, color: Colors.grey),
    );
    return teacher.color;
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
