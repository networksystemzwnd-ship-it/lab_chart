import 'package:flutter/material.dart';
import 'package:lab_chart/features/lab/domain/entities/teacher.dart';
import 'package:lab_chart/features/lab/presentation/widgets/teacher_creation_form.dart';

class TeacherManagementDialog extends StatelessWidget {
  final List<Teacher> teachers;
  final void Function(String name, Color color) onCreate;
  final void Function(String originalName, String name, Color color) onEdit;
  final void Function(String name) onDelete;

  const TeacherManagementDialog({
    super.key,
    required this.teachers,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  void _showCreateTeacherDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return TeacherCreationForm(
          existingTeachers: teachers,
          onSave: onCreate,
        );
      },
    );
  }

  void _showEditTeacherDialog(BuildContext context, Teacher teacher) {
    showDialog(
      context: context,
      builder: (ctx) {
        return TeacherCreationForm(
          existingTeachers: teachers,
          existingTeacher: teacher,
          onSave: (name, color) {
            onEdit(teacher.name, name, color);
          },
          onDelete: () {
            Navigator.of(ctx).pop();
            onDelete(teacher.name);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Teachers'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final teacher in teachers)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                leading: CircleAvatar(
                  backgroundColor: teacher.color,
                  child: Text(
                    teacher.name.isNotEmpty ? teacher.name[0] : '',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(teacher.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditTeacherDialog(context, teacher),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => onDelete(teacher.name),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () => _showCreateTeacherDialog(context),
          child: const Text('Add Teacher'),
        ),
      ],
    );
  }
}
