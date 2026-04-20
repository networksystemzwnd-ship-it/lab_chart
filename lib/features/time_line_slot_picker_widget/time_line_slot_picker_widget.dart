import 'package:flutter/material.dart';

class TimeSlot {
  final DateTime start;
  final DateTime end;
  final bool isEnabled;

  TimeSlot({required this.start, required this.end, this.isEnabled = true});

  Duration get duration => end.difference(start);
}

class TimelineSlotPicker extends StatefulWidget {
  final DateTime startTime;
  final DateTime endTime;
  final List<Duration> divisions;

  final int initialIndex;
  final ValueChanged<TimeSlot>? onChanged;

  final double height;
  final Color backgroundColor;
  final Color highlightColor;
  final Color dividerColor;

  final bool showLabels;
  final bool showBoundaryLabels;
  final double labelSpacing; // distance from bar

  const TimelineSlotPicker({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.divisions,

    this.initialIndex = 0,
    this.onChanged,
    this.height = 20,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.highlightColor = Colors.blue,
    this.dividerColor = Colors.black26,
    this.showLabels = false,
    this.showBoundaryLabels = true,
    this.labelSpacing = 3,
  });

  @override
  State<TimelineSlotPicker> createState() => _TimelineSlotPickerState();
}

class _TimelineSlotPickerState extends State<TimelineSlotPicker> {
  late List<TimeSlot> slots;
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    slots = _generateSlots();
  }

  List<TimeSlot> _generateSlots() {
    final List<TimeSlot> result = [];

    DateTime cursor = widget.startTime;

    for (final division in widget.divisions) {
      final next = cursor.add(division);

      if (next.isAfter(widget.endTime)) break;

      result.add(TimeSlot(start: cursor, end: next));
      cursor = next;
    }

    return result;
  }

  Duration get totalDuration => widget.endTime.difference(widget.startTime);

  void _onTap(int index) {
    if (!slots[index].isEnabled) return;

    setState(() {
      selectedIndex = index;
    });

    widget.onChanged?.call(slots[index]);
  }

  double _widthFactor(TimeSlot slot) {
    return slot.duration.inMilliseconds / totalDuration.inMilliseconds;
  }

  List<DateTime> _getBoundaries() {
    final List<DateTime> points = [widget.startTime];

    DateTime cursor = widget.startTime;

    for (final division in widget.divisions) {
      cursor = cursor.add(division);

      if (cursor.isAfter(widget.endTime)) break;
      points.add(cursor);
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;

        /// Calculate pixel widths
        final widths = slots.map((s) => _widthFactor(s) * totalWidth).toList();

        final selectedLeft = widths
            .take(selectedIndex)
            .fold(0.0, (a, b) => a + b);

        final selectedWidth = widths[selectedIndex];

        final boundaries = _getBoundaries();

        final List<double> boundaryPositions = [];
        double acc = 0;

        for (int i = 0; i < widths.length; i++) {
          boundaryPositions.add(acc);
          acc += widths[i];
        }

        // Add final end position
        boundaryPositions.add(acc);

        return Stack(
          children: [
            /// Background bar
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),

            /// Animated highlight
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: selectedLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                width: selectedWidth,
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.highlightColor,
                  borderRadius: _getHighlightRadius(),
                ),
              ),
            ),

            /// Slots layer
            Row(
              children: List.generate(slots.length, (index) {
                final slot = slots[index];

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onTap(index),
                  child: SizedBox(
                    width: widths[index],
                    height: widget.height,
                    child: Stack(
                      children: [
                        /// Divider
                        if (index != 0)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 1,
                              height: widget.height * 0.6,
                              color: widget.dividerColor,
                            ),
                          ),

                        /// Label
                        if (widget.showLabels)
                          Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOutCubic,
                              style: TextStyle(
                                fontSize: 11,
                                color: index == selectedIndex
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              child: Text(_formatDurationHM(slot.duration)),
                            ),
                          ),

                        /// Disabled overlay
                        if (!slot.isEnabled)
                          Container(color: Colors.transparent.withOpacity(0.4)),
                      ],
                    ),
                  ),
                );
              }),
            ),

            if (widget.showBoundaryLabels)
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: List.generate(boundaries.length, (i) {
                      final x = boundaryPositions[i];

                      return Positioned(
                        left: x, // center adjust
                        top: widget.labelSpacing - 2,
                        child: RotatedBox(
                          quarterTurns: 3, // 1 = 90°, 2 = 180°, 3 = 270°
                          child: Text(
                            _formatTime(boundaries[i]),
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  BorderRadius _getHighlightRadius() {
    if (selectedIndex == 0) {
      return BorderRadius.horizontal(left: Radius.circular(widget.height / 2));
    } else if (selectedIndex == slots.length - 1) {
      return BorderRadius.horizontal(right: Radius.circular(widget.height / 2));
    }
    return BorderRadius.zero;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    final minute = time.minute == 0
        ? ''
        : ':${time.minute.toString().padLeft(2, '0')}';

    return '$hour$minute ${minute.isEmpty ? period : ''}';
  }

  String _formatDurationHM(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    final parts = <String>[];

    if (hours > 0) {
      parts.add('${hours}h');
    }
    if (minutes > 0) {
      parts.add('${minutes}m');
    }

    return parts.isNotEmpty ? parts.join(' ') : '0m';
  }
}
