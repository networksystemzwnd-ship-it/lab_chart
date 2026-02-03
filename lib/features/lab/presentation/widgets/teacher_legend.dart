import 'package:flutter/material.dart';

class TeacherLegend extends StatelessWidget {
  final Map<String, Color> teacherColors;

  const TeacherLegend({super.key, required this.teacherColors});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: teacherColors.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: entry.value, radius: 6),
                const SizedBox(width: 6),
                Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
