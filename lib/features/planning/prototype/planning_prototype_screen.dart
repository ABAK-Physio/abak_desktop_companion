import 'dart:async';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../data/planning_repository.dart';
import 'planning_calendar_adapter.dart';

import 'planning_demo_events.dart';
import 'planning_event_dialog.dart';
import 'planning_event_drag.dart';
import 'planning_overlaps.dart';
import 'planning_stack_arranger.dart';

enum _PlanningView { day, week, month }

typedef _EventAction = ({CalendarEventData<Object?> event, bool delete});

class PlanningPrototypeScreen extends StatefulWidget {
  const PlanningPrototypeScreen({super.key, this.repository});

  final PlanningRepository? repository;

  @override
  State<PlanningPrototypeScreen> createState() =>
      _PlanningPrototypeScreenState();
}

class _PlanningPrototypeScreenState extends State<PlanningPrototypeScreen> {
  late final EventController<Object?> _controller;
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  _PlanningView _view = _PlanningView.week;
  int _revision = 0;
  bool _loading = false;
  bool _busy = false;
  Completer<void>? _pending;
  bool _loadFailed = false;
  bool get _blocked => _loading || _busy || _loadFailed;
  final _calendarViewportKey = GlobalKey();
  static const _overlapColor = Color(0xFFB42318);

  String _overlapDetails(CalendarEventData<Object?> event) {
    return planningOverlaps(event, _controller.allEvents)
        .map((overlap) {
          final start = DateFormat.Hm().format(overlap.start);
          final end = DateFormat.Hm().format(overlap.end);
          return 'Chevauchement $start – $end avec ${overlap.event.title}';
        })
        .join('\n');
  }

  @override
  void initState() {
    super.initState();
    _controller = EventController<Object?>();
    if (widget.repository == null) {
      _controller.addAll(planningDemoEvents(_date));
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final items = await widget.repository!.listAll();
      if (!mounted) return;
      _controller.clear();
      _controller.addAll(items.map(planningCalendarEvent).toList());
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _write(
    Future<void> Function() persist,
    VoidCallback apply, {
    VoidCallback? retry,
  }) async {
    if (_blocked) return false;
    final pending = _pending = Completer<void>();
    setState(() => _busy = true);
    try {
      await persist();
      if (!mounted) return true;
      apply();
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Enregistrement impossible. Vérifiez l’accès au disque et réessayez.',
            ),
            action: retry == null
                ? null
                : SnackBarAction(label: 'Réessayer', onPressed: retry),
          ),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
      _pending = null;
      pending.complete();
    }
  }

  Future<bool> _saveEvent(
    CalendarEventData<Object?> result,
    CalendarEventData<Object?>? previous, {
    bool navigate = true,
  }) {
    if (previous != null && !_controller.allEvents.contains(previous)) {
      return Future.value(false);
    }
    final repository = widget.repository;
    final saved = repository == null
        ? result
        : result.copyWith(
            event: previous?.event as String? ?? const Uuid().v4(),
          );
    return _write(
      () async {
        if (repository == null) return;
        final item = planningAppointmentFromCalendar(
          saved,
          id: saved.event as String,
        );
        if (previous == null) {
          await repository.insert(item);
        } else {
          await repository.update(item);
        }
      },
      () {
        if (previous == null) {
          _controller.add(saved);
        } else {
          _controller.update(previous, saved);
        }
        if (navigate) {
          _goTo(saved.date);
        } else {
          setState(() => _date = saved.date);
        }
      },
      retry: navigate
          ? null
          : () => _saveEvent(result, previous, navigate: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(DateTime date) {
    setState(() {
      _date = DateUtils.dateOnly(date);
      _revision++;
    });
  }

  void _move(int direction) {
    if (_view == _PlanningView.month) {
      final first = DateTime(_date.year, _date.month + direction);
      final lastDay = DateUtils.getDaysInMonth(first.year, first.month);
      _goTo(DateTime(first.year, first.month, _date.day.clamp(1, lastDay)));
    } else {
      final days = _view == _PlanningView.week ? 7 : 1;
      _goTo(DateTime(_date.year, _date.month, _date.day + days * direction));
    }
  }

  void _pageChanged(DateTime date, int index) {
    setState(() {
      // Preserve the selected weekday/day when paging the containing period.
      _date = switch (_view) {
        _PlanningView.day => date,
        _PlanningView.week => DateTime(
          date.year,
          date.month,
          date.day + _date.weekday - 1,
        ),
        _PlanningView.month => DateTime(
          date.year,
          date.month,
          _date.day.clamp(1, DateUtils.getDaysInMonth(date.year, date.month)),
        ),
      };
    });
  }

  String get _periodLabel {
    if (_view == _PlanningView.month) {
      return DateFormat.yMMMM('fr_FR').format(_date);
    }
    if (_view == _PlanningView.day) {
      return DateFormat.yMMMMEEEEd('fr_FR').format(_date);
    }
    final monday = DateTime(
      _date.year,
      _date.month,
      _date.day - _date.weekday + 1,
    );
    final sunday = DateTime(monday.year, monday.month, monday.day + 6);
    return '${DateFormat.MMMMd('fr_FR').format(monday)} – ${DateFormat.yMMMMd('fr_FR').format(sunday)}';
  }

  Future<void> _editEvent({
    CalendarEventData<Object?>? event,
    DateTime? date,
  }) async {
    if (_blocked) return;
    await showDialog<CalendarEventData<Object?>>(
      context: context,
      builder: (_) => PlanningEventDialog(
        event: event,
        persistent: widget.repository != null,
        onSave: (result) => _saveEvent(result, event),
        date: date ?? DateTime(_date.year, _date.month, _date.day, 9),
      ),
    );
  }

  Future<void> _showEvents(
    List<CalendarEventData<Object?>> events,
    DateTime date,
  ) async {
    if (_blocked) return;
    final selected = await showDialog<_EventAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DateFormat.yMMMMEEEEd('fr_FR').format(date)),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: events
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${event.title}\n${event.isFullDayEvent ? 'Toute la journée' : '${DateFormat.Hm().format(event.startTime!)} – ${DateFormat.Hm().format(event.endTime!)}'}\n${event.description ?? ''}',
                          ),
                          if (_overlapDetails(event).isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _overlapDetails(event),
                                style: const TextStyle(
                                  color: _overlapColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Wrap(
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Modifier'),
                                onPressed: () => Navigator.pop(context, (
                                  event: event,
                                  delete: false,
                                )),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Supprimer'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                                onPressed: () => Navigator.pop(context, (
                                  event: event,
                                  delete: true,
                                )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
    if (!mounted || selected == null) return;
    if (selected.delete) {
      _deleteEvent(selected.event);
    } else {
      await _editEvent(event: selected.event);
    }
  }

  Future<void> _deleteEvent(CalendarEventData<Object?> event) async {
    if (!_controller.allEvents.contains(event)) return;
    final success = await _write(
      () async {
        await widget.repository?.delete(event.event as String);
      },
      () => _controller.remove(event),
      retry: () => _deleteEvent(event),
    );
    if (!mounted || !success) return;
    final messenger = ScaffoldMessenger.of(context);
    // The undo action always refers to the most recently deleted appointment.
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('« ${event.title} » supprimé.'),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            if (mounted && !_controller.allEvents.contains(event)) {
              _restoreEvent(event);
            }
          },
        ),
      ),
    );
  }

  Future<bool> _restoreEvent(CalendarEventData<Object?> event) async {
    await _pending?.future;
    if (!mounted || _controller.allEvents.contains(event)) return false;
    return _write(
      () async {
        final repository = widget.repository;
        if (repository != null) {
          await repository.insert(
            planningAppointmentFromCalendar(event, id: event.event as String),
          );
        }
      },
      () => _controller.add(event),
      retry: () => _restoreEvent(event),
    );
  }

  Widget _eventTile(
    DateTime date,
    List<CalendarEventData<Object?>> events,
    Rect boundary,
    DateTime start,
    DateTime end, {
    required double columnWidth,
  }) {
    final event = events.first;
    final overlapDetails = _overlapDetails(event);
    final overlaps = overlapDetails.isNotEmpty;
    final time =
        '${DateFormat.Hm().format(event.startTime!)} – ${DateFormat.Hm().format(event.endTime!)}';
    return PlanningEventDrag(
      key: ObjectKey(event),
      event: event,
      boundary: boundary,
      columnWidth: columnWidth,
      weekView: _view == _PlanningView.week,
      viewportKey: _calendarViewportKey,
      onChanged: (updated) => _saveEvent(updated, event, navigate: false),
      child: Tooltip(
        message: '${event.title}\n$time${overlaps ? '\n$overlapDetails' : ''}',
        child: Container(
          margin: const EdgeInsets.all(1),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: event.color,
            border: overlaps
                ? Border.all(color: _overlapColor, width: 2)
                : null,
            borderRadius: BorderRadius.circular(4),
            boxShadow: overlaps
                ? const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 3,
                      offset: Offset(-2, 2),
                    ),
                  ]
                : null,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxHeight < 20) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: Text(
                    event.title,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (overlaps) ...[
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: _overlapColor,
                          size: 14,
                          semanticLabel: 'Chevauchement',
                        ),
                        const SizedBox(width: 3),
                      ],
                      Expanded(
                        child: Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (constraints.maxHeight >= 28)
                    Text(
                      time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _calendar(double width) {
    final key = ValueKey((_view, _revision));
    switch (_view) {
      case _PlanningView.day:
        return DayView<Object?>(
          key: key,
          controller: _controller,
          initialDay: _date,
          startHour: 7,
          endHour: 21,
          heightPerMinute: 1,
          timeLineWidth: 65,
          timeLineBuilder: (date) => Text(DateFormat.Hm().format(date)),
          dayTitleBuilder: (_) => const SizedBox.shrink(),
          eventArranger: const PlanningStackArranger<Object?>(),
          eventTileBuilder: (date, events, boundary, start, end) => _eventTile(
            date,
            events,
            boundary,
            start,
            end,
            columnWidth: width - 80,
          ),
          onPageChange: _pageChanged,
          onEventTap: _showEvents,
          minuteSlotSize: MinuteSlotSize.minutes15,
          onDateTap: (date) => _editEvent(date: date),
        );
      case _PlanningView.week:
        return WeekView<Object?>(
          key: key,
          controller: _controller,
          initialDay: _date,
          startHour: 7,
          endHour: 21,
          heightPerMinute: 1,
          timeLineWidth: 65,
          timeLineStringBuilder: (date, {secondaryDate}) =>
              DateFormat.Hm().format(date),
          weekPageHeaderBuilder: (_, _) => const SizedBox.shrink(),
          weekDayBuilder: (date) =>
              Center(child: Text(DateFormat('EEE d', 'fr_FR').format(date))),
          fullDayHeaderTitle: 'Journée',
          weekNumberBuilder: (_) => const SizedBox.shrink(),
          eventArranger: const PlanningStackArranger<Object?>(),
          eventTileBuilder: (date, events, boundary, start, end) => _eventTile(
            date,
            events,
            boundary,
            start,
            end,
            columnWidth: (width - 70) / 7,
          ),
          onPageChange: _pageChanged,
          onEventTap: _showEvents,
          minuteSlotSize: MinuteSlotSize.minutes15,
          onDateTap: (date) => _editEvent(date: date),
        );
      case _PlanningView.month:
        return MonthView<Object?>(
          key: key,
          controller: _controller,
          monthViewStyle: MonthViewStyle(
            initialMonth: _date,
            useAvailableVerticalSpace: true,
          ),
          monthViewBuilders: MonthViewBuilders<Object?>(
            headerBuilder: (_) => const SizedBox.shrink(),
            weekDayStringBuilder: (day) => const [
              'lun.',
              'mar.',
              'mer.',
              'jeu.',
              'ven.',
              'sam.',
              'dim.',
            ][day],
            onPageChange: _pageChanged,
            onCellTap: (events, date) {
              setState(() => _view = _PlanningView.day);
              _goTo(date);
            },
            onEventTap: (event, date) => _showEvents([event], date),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning — Prototype'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: _blocked ? null : () => _editEvent(),
              icon: const Icon(Icons.add),
              label: const Text('Nouveau rendez-vous'),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadFailed
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Impossible de charger les rendez-vous.'),
                  TextButton(onPressed: _load, child: const Text('Réessayer')),
                ],
              ),
            )
          : AbsorbPointer(
              absorbing: _busy,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.repository == null
                          ? 'Données fictives · Aucune sauvegarde · Cliquez sur un rendez-vous pour le consulter.'
                          : _busy
                          ? 'Enregistrement en cours…'
                          : 'Rendez-vous enregistrés sur cet ordinateur.',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SegmentedButton<_PlanningView>(
                          segments: const [
                            ButtonSegment(
                              value: _PlanningView.day,
                              label: Text('Jour'),
                            ),
                            ButtonSegment(
                              value: _PlanningView.week,
                              label: Text('Semaine'),
                            ),
                            ButtonSegment(
                              value: _PlanningView.month,
                              label: Text('Mois'),
                            ),
                          ],
                          selected: {_view},
                          onSelectionChanged: (selection) =>
                              setState(() => _view = selection.single),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Période précédente',
                              onPressed: () => _move(-1),
                              icon: const Icon(Icons.chevron_left),
                            ),
                            TextButton(
                              onPressed: () => _goTo(DateTime.now()),
                              child: const Text('Aujourd’hui'),
                            ),
                            IconButton(
                              tooltip: 'Période suivante',
                              onPressed: () => _move(1),
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                        Text(
                          _periodLabel,
                          key: const ValueKey('planning-period'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_view != _PlanningView.month) ...[
                      const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: _overlapColor,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Cartes superposées : rendez-vous qui se chevauchent. Survolez ou cliquez pour voir la plage commune.',
                              style: TextStyle(
                                color: _overlapColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (_view != _PlanningView.month)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Glissez une carte pour la déplacer ; tirez sa poignée du bas pour ajuster la durée (pas de 15 min).',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    Expanded(
                      child: SizedBox(
                        key: _calendarViewportKey,
                        child: LayoutBuilder(
                          builder: (_, constraints) =>
                              _calendar(constraints.maxWidth),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
