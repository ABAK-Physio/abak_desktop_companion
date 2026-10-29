import 'package:flutter/material.dart';

/// calendar_view's built-in slots do not include 20 minutes.
/// Keep tapping independent of the event layout and vertical scrolling.
class PlanningSlotDetector extends StatelessWidget {
  const PlanningSlotDetector({
    super.key,
    required this.date,
    required this.height,
    required this.width,
    required this.heightPerMinute,
    required this.stepMinutes,
    required this.onDateTap,
  });

  final DateTime date;
  final double height;
  final double width;
  final double heightPerMinute;
  final int stepMinutes;
  final ValueChanged<DateTime> onDateTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: (details) {
        final slot =
            (details.localPosition.dy / (heightPerMinute * stepMinutes))
                .floor()
                .clamp(0, 840 ~/ stepMinutes - 1);
        onDateTap(
          DateTime(
            date.year,
            date.month,
            date.day,
            0,
            420 + slot * stepMinutes,
          ),
        );
      },
      child: const SizedBox.expand(),
    ),
  );
}
