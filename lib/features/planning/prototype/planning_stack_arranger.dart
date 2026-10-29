import 'package:calendar_view/calendar_view.dart';

/// Partially overlaps simultaneous cards while preserving their time bounds.
/// Each column keeps an exposed left edge so every appointment stays clickable.
class PlanningStackArranger<T extends Object?> extends EventArranger<T> {
  const PlanningStackArranger();

  @override
  List<OrganizedCalendarEventData<T>> arrange({
    required List<CalendarEventData<T>> events,
    required double height,
    required double width,
    required double heightPerMinute,
    required int startHour,
    required DateTime calendarViewDate,
  }) {
    final columns = SideEventArranger<T>().arrange(
      events: events,
      height: height,
      width: width,
      heightPerMinute: heightPerMinute,
      startHour: startHour,
      calendarViewDate: calendarViewDate,
    );
    final stacked = columns
        .map(
          (item) => OrganizedCalendarEventData<T>(
            left: item.left * 0.7,
            right: item.right * 0.7,
            top: item.top,
            bottom: item.bottom,
            startDuration: item.startDuration,
            endDuration: item.endDuration,
            events: item.events,
            calendarViewDate: item.calendarViewDate,
          ),
        )
        .toList();
    // Paint right-hand columns last, keeping left edges exposed even for
    // appointments with identical starts or nested durations.
    stacked.sort((a, b) => a.left.compareTo(b.left));
    return stacked;
  }
}
