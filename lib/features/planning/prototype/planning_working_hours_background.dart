import 'package:flutter/material.dart';
import '../models/planning_opening_hours.dart';

/// A visual layer only: never creates events or intercepts calendar gestures.
class PlanningWorkingHoursBackground extends StatelessWidget {
  const PlanningWorkingHoursBackground({
    super.key,
    required this.date,
    required this.hours,
    required this.heightPerMinute,
    this.leadingWidth = 0,
  });

  final DateTime date;
  final PlanningOpeningHours? hours;
  final double heightPerMinute;
  final double leadingWidth;
  // Translucency preserves the calendar's hour and column lines underneath.
  static const shade = Color(0x3360788A);

  @override
  Widget build(BuildContext context) {
    final periods = hours?.days[date.weekday];
    final gaps = <({int start, int end})>[];
    if (periods != null) {
      var cursor = 420;
      for (final period in periods) {
        if (period.start > cursor) gaps.add((start: cursor, end: period.start));
        cursor = period.end;
      }
      if (cursor < 1260) gaps.add((start: cursor, end: 1260));
    }
    return IgnorePointer(
      child: Stack(
        children: [
          for (final gap in gaps)
            Positioned(
              top: (gap.start - 420) * heightPerMinute,
              height: (gap.end - gap.start) * heightPerMinute,
              left: leadingWidth,
              right: 0,
              child: ColoredBox(color: shade),
            ),
        ],
      ),
    );
  }
}
