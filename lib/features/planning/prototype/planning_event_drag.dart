import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Pure time calculation shared by the live preview and the final update.
CalendarEventData<Object?> shiftPlanningEvent(
  CalendarEventData<Object?> event, {
  required double minuteDelta,
  int dayDelta = 0,
  bool resize = false,
}) {
  final start = event.startTime!.hour * 60 + event.startTime!.minute;
  final end = event.endTime!.hour * 60 + event.endTime!.minute;
  final duration = end - start;
  int snap(double value) => (value / 15).round() * 15;
  final newStart = resize
      ? start
      : snap(start + minuteDelta).clamp(420, 1260 - duration);
  final newEnd = resize
      ? snap(end + minuteDelta).clamp(start + 15, 1260)
      : newStart + duration;
  final date = DateTime(
    event.date.year,
    event.date.month,
    event.date.day + (resize ? 0 : dayDelta),
  );
  DateTime at(int value) =>
      DateTime(date.year, date.month, date.day, value ~/ 60, value % 60);
  return event.copyWith(
    date: date,
    endDate: date,
    startTime: at(newStart),
    endTime: at(newEnd),
  );
}

/// Gesture layer for timed cards. Data changes only when a valid drop ends.
class PlanningEventDrag extends StatefulWidget {
  const PlanningEventDrag({
    super.key,
    required this.event,
    required this.boundary,
    required this.columnWidth,
    required this.weekView,
    required this.viewportKey,
    required this.onChanged,
    required this.child,
  });

  final CalendarEventData<Object?> event;
  final Rect boundary;
  final double columnWidth;
  final bool weekView;
  final GlobalKey viewportKey;
  final ValueChanged<CalendarEventData<Object?>> onChanged;
  final Widget child;

  @override
  State<PlanningEventDrag> createState() => _PlanningEventDragState();
}

class _PlanningEventDragState extends State<PlanningEventDrag> {
  final _focus = FocusNode();
  Offset? _pointerDown;
  Offset _origin = Offset.zero;
  Rect _viewport = Rect.zero;
  double _gridLeft = 0;
  double _gridTop = 0;
  double _initialGridTop = 0;
  bool _resizing = false;
  bool _valid = false;
  CalendarEventData<Object?>? _preview;
  OverlayEntry? _overlay;

  void _start(DragStartDetails details, bool resize) {
    final viewport =
        widget.viewportKey.currentContext?.findRenderObject() as RenderBox?;
    final box = context.findRenderObject() as RenderBox;
    if (viewport == null) return;
    _origin = box.localToGlobal(Offset.zero);
    _viewport = viewport.localToGlobal(Offset.zero) & viewport.size;
    final scrollable = Scrollable.maybeOf(context)?.context.findRenderObject();
    if (scrollable is RenderBox) {
      _viewport = _viewport.intersect(
        scrollable.localToGlobal(Offset.zero) & scrollable.size,
      );
    }
    _gridTop = _origin.dy - widget.boundary.top;
    _initialGridTop = _gridTop;
    _gridLeft =
        _origin.dx -
        widget.boundary.left -
        (widget.weekView
            ? (widget.event.date.weekday - 1) * widget.columnWidth
            : 0);
    _resizing = resize;
    _pointerDown ??= details.globalPosition;
    _preview = widget.event;
    _valid = true;
    _focus.requestFocus();
    _overlay = OverlayEntry(builder: (_) => _buildPreview());
    Overlay.of(context).insert(_overlay!);
    setState(() {});
  }

  void _update(DragUpdateDetails details) {
    if (_overlay == null) return;
    // Account for wheel scrolling while the pointer remains captured.
    final box = context.findRenderObject() as RenderBox;
    _origin = box.localToGlobal(Offset.zero);
    _gridTop = _origin.dy - widget.boundary.top;
    final pointer = details.globalPosition;
    final columns = widget.weekView ? 7 : 1;
    _valid =
        _viewport.contains(pointer) &&
        pointer.dy >= _gridTop &&
        pointer.dy <= _gridTop + 840 &&
        pointer.dx >= _gridLeft &&
        pointer.dx < _gridLeft + widget.columnWidth * columns;
    final targetDay = ((pointer.dx - _gridLeft) / widget.columnWidth)
        .floor()
        .clamp(0, columns - 1);
    _preview = shiftPlanningEvent(
      widget.event,
      minuteDelta: pointer.dy - _pointerDown!.dy + _initialGridTop - _gridTop,
      dayDelta: widget.weekView
          ? targetDay - (widget.event.date.weekday - 1)
          : 0,
      resize: _resizing,
    );
    _overlay!.markNeedsBuild();
  }

  void _finish({bool cancel = false}) {
    if (_overlay == null) return;
    final result = !cancel && _valid ? _preview : null;
    _overlay!.remove();
    _overlay!.dispose();
    _overlay = null;
    _preview = null;
    _pointerDown = null;
    _focus.unfocus();
    setState(() {});
    if (result != null && result != widget.event) widget.onChanged(result);
  }

  Widget _buildPreview() {
    final event = _preview!;
    final start = event.startTime!.hour * 60 + event.startTime!.minute;
    final end = event.endTime!.hour * 60 + event.endTime!.minute;
    final dayOffset = widget.weekView
        ? event.date.weekday - widget.event.date.weekday
        : 0;
    final position = Rect.fromLTWH(
      _origin.dx + dayOffset * widget.columnWidth - _viewport.left,
      _gridTop + start - 420 - _viewport.top,
      widget.boundary.width,
      (end - start).toDouble(),
    );
    final label =
        '${DateFormat('EEE d', 'fr_FR').format(event.date)} · ${DateFormat.Hm().format(event.startTime!)}–${DateFormat.Hm().format(event.endTime!)}';
    return Positioned.fromRect(
      rect: _viewport,
      child: IgnorePointer(
        child: ClipRect(
          child: Stack(
            children: [
              Positioned.fromRect(
                rect: position,
                child: Container(
                  decoration: BoxDecoration(
                    color: event.color.withValues(alpha: 0.9),
                    border: Border.all(
                      color: _valid ? Colors.teal.shade800 : Colors.red,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                top: 0,
                right: 8,
                child: Material(
                  color: _valid ? Colors.teal.shade800 : Colors.red.shade800,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      _valid
                          ? '${event.title} · $label · Échap pour annuler'
                          : 'Hors du calendrier : relâchez pour annuler',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlay?.remove();
    _overlay?.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focus,
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            _overlay != null) {
          _finish(cancel: true);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        cursor: _overlay == null
            ? SystemMouseCursors.grab
            : SystemMouseCursors.grabbing,
        child: GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          onPanDown: (details) => _pointerDown = details.globalPosition,
          onPanStart: (details) => _start(details, false),
          onPanUpdate: _update,
          onPanEnd: (_) => _finish(),
          onPanCancel: () {
            if (!_resizing) _finish(cancel: true);
          },
          child: Opacity(
            opacity: _overlay == null ? 1 : 0.35,
            child: Stack(
              fit: StackFit.expand,
              children: [
                widget.child,
                Positioned(
                  left: 2,
                  right: 2,
                  bottom: 0,
                  height: 8,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeUpDown,
                    child: GestureDetector(
                      key: ValueKey(('resize', widget.event)),
                      behavior: HitTestBehavior.opaque,
                      dragStartBehavior: DragStartBehavior.down,
                      onPanDown: (details) =>
                          _pointerDown = details.globalPosition,
                      onPanStart: (details) => _start(details, true),
                      onPanUpdate: _update,
                      onPanEnd: (_) => _finish(),
                      onPanCancel: () {
                        if (_resizing) _finish(cancel: true);
                      },
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          margin: const EdgeInsets.only(left: 4, bottom: 2),
                          width: 18,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
