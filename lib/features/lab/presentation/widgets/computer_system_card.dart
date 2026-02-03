import 'package:flutter/material.dart';

import '../../domain/entities/lab_system.dart'; // Import your entities

class ComputerSystemCard extends StatelessWidget {
  final LabSystem system;
  final VoidCallback onTap;

  const ComputerSystemCard({
    super.key,
    required this.system,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = system.currentAssignment != null;

    // Determine Color: Teacher's color if occupied, Grey if free
    final cardColor = isOccupied
        ? system.currentAssignment!.teacherColor
        : Colors.grey[200];

    final textColor = isOccupied ? Colors.white : Colors.black87;

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
                system.currentAssignment!.studentName,
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${_formatTime(system.currentAssignment!.startTime)} - ${_formatTime(system.currentAssignment!.endTime)}",
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
