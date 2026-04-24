import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lab_chart/features/lab/domain/entities/student_assignment.dart';
import 'package:lab_chart/features/time_line_slot_picker_widget/time_line_slot_picker_widget.dart';

import '../../domain/entities/lab_system.dart';

class ComputerSystemCard extends StatelessWidget {
  final LabSystem system;
  final TimeSlot timeslot;
  final VoidCallback onTap;

  const ComputerSystemCard({
    super.key,
    required this.system,
    required this.timeslot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = system.studentAssignments.any((assign) {
      return assign.endTime.isAfter(timeslot.start) &&
          assign.startTime.isBefore(timeslot.end);
    });

    final StudentAssignment? currentAssignment = system.studentAssignments
        .firstWhereOrNull(
          (a) =>
              a.endTime.isAfter(timeslot.start) &&
              a.startTime.isBefore(timeslot.end),
        );

    // Determine Color: Teacher's color if occupied, Grey if free
    final cardColor = isOccupied
        ? currentAssignment!.teacherColor
        : Colors.grey[200];

    final textColor = isOccupied ? Colors.white : Colors.black38;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PC Number
            Text(
              system.systemNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 10, width: 10),
            // Student Details (if occupied)
            if (isOccupied) ...[
              Text(
                currentAssignment!.studentName,
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${_formatTime(currentAssignment!.startTime)} - ${_formatTime(currentAssignment!.endTime)}",
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.9),
                ),
              ),
            ] else ...[
              Center(
                child: Text(
                  "Available",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
