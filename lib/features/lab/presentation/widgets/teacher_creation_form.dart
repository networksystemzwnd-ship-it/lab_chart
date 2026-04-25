import 'package:flutter/material.dart';
import 'package:lab_chart/features/lab/domain/entities/teacher.dart';

class TeacherCreationForm extends StatefulWidget {
  final List<Teacher> existingTeachers;
  final Teacher? existingTeacher;
  final void Function(String name, Color color) onSave;
  final void Function()? onDelete;

  const TeacherCreationForm({
    super.key,
    required this.existingTeachers,
    required this.onSave,
    this.existingTeacher,
    this.onDelete,
  });

  @override
  State<TeacherCreationForm> createState() => _TeacherCreationFormState();
}

class _TeacherCreationFormState extends State<TeacherCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    if (widget.existingTeacher != null) {
      _nameController.text = widget.existingTeacher!.name;
      _selectedColor = widget.existingTeacher!.color;
    }
  }

  static const Map<String, Color> _colorOptions = {
    'Red': Colors.red,
    'Blue': Colors.blueAccent,
    'Green': Colors.green,
    'Cyan': Colors.cyan,
    'Orange': Colors.orange,
    'Purple': Colors.deepPurple,
    'Amber': Colors.amber,
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingTeacher == null ? 'Create Teacher' : 'Edit Teacher'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Teacher name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a teacher name';
                }
                if (widget.existingTeachers.any(
                  (teacher) =>
                      teacher.name.toLowerCase() == value.trim().toLowerCase() &&
                      teacher.name.toLowerCase() !=
                          widget.existingTeacher?.name.toLowerCase(),
                )) {
                  return 'This teacher already exists';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<Color>(
              value: _selectedColor,
              decoration: const InputDecoration(
                labelText: 'Teacher color',
                border: OutlineInputBorder(),
              ),
              items: _colorOptions.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.value,
                      child: Text(entry.key),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedColor = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        if (widget.existingTeacher != null && widget.onDelete != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete?.call();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(_nameController.text.trim(), _selectedColor);
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.existingTeacher == null ? 'Save' : 'Update'),
        ),
      ],
    );
  }
}
