import 'dart:io';

import 'package:abak_desktop_companion/features/planning/data/planning_repository.dart';
import 'package:abak_desktop_companion/features/planning/data/planning_schema.dart';
import 'package:abak_desktop_companion/features/planning/models/planning_appointment.dart';
import 'package:abak_desktop_companion/features/planning/prototype/planning_calendar_adapter.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Directory temporary;
  late Database db;
  late PlanningRepository repository;
  final day = DateTime(2026, 10, 25);

  PlanningAppointment appointment(String id, {int start = 540}) =>
      PlanningAppointment(
        id: id,
        title: 'Séance Élodie',
        date: day,
        startMinute: start,
        endMinute: start + 45,
        notes: 'Notes\nsur deux lignes',
        colorArgb: 0x80FFAB12,
      );

  Future<List<PlanningAppointment>> items() =>
      repository.list(from: day, until: DateTime(2026, 10, 26));

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('abak_planning_sqlite_');
    db = await databaseFactoryFfi.openDatabase('${temporary.path}/test.db');
    await db.execute(
      'CREATE TABLE patients (patient_id TEXT PRIMARY KEY, last_name TEXT, first_name TEXT, archived_at INTEGER)',
    );
    await createPlanningTables(db);
    repository = PlanningRepository(database: () async => db);
  });

  tearDown(() async {
    await db.close();
    await temporary.delete(recursive: true);
  });

  test(
    'save, reopen, edit, delete and undo retain the same identity',
    () async {
      final original = appointment('stable-id');
      await repository.insert(original);
      await db.close();
      db = await databaseFactoryFfi.openDatabase('${temporary.path}/test.db');
      expect((await items()).single.toMap(), original.toMap());

      final moved = appointment('stable-id', start: 600);
      await repository.update(moved);
      expect((await items()).single.toMap(), moved.toMap());
      await repository.delete(moved.id);
      expect(await items(), isEmpty);
      await repository.insert(moved);
      expect((await items()).single.toMap(), moved.toMap());
    },
  );

  test(
    'period boundaries and overlapping appointments are preserved',
    () async {
      await repository.insert(appointment('a'));
      await repository.insert(appointment('b', start: 555));
      final allDay = PlanningAppointment(
        id: 'all-day',
        title: 'Congé',
        date: day,
      );
      await repository.insert(allDay);
      await repository.insert(
        PlanningAppointment(
          id: 'tomorrow',
          title: 'Demain',
          date: DateTime(2026, 10, 26),
        ),
      );
      expect((await items()).map((e) => e.id), ['all-day', 'a', 'b']);
      expect((await items()).first.toMap(), allDay.toMap());
      expect(
        await repository.list(from: DateTime(2026, 10, 24), until: day),
        isEmpty,
      );
      await expectLater(
        repository.list(from: day, until: day),
        throwsArgumentError,
      );
    },
  );

  test(
    'duplicate IDs, missing rows and malformed times fail explicitly',
    () async {
      final original = appointment('a');
      await repository.insert(original);
      await expectLater(
        repository.insert(appointment('a', start: 600)),
        throwsA(isA<DatabaseException>()),
      );
      expect((await items()).single.toMap(), original.toMap());
      await expectLater(
        repository.update(appointment('missing')),
        throwsStateError,
      );
      await expectLater(repository.delete('missing'), throwsStateError);
      for (final values in [
        {'start_minute': null, 'end_minute': 600},
        {'start_minute': 600, 'end_minute': null},
        {'start_minute': 600, 'end_minute': 600},
        {'start_minute': -1, 'end_minute': 600},
        {'start_minute': 600, 'end_minute': 1441},
      ]) {
        await expectLater(
          db.insert('planning_appointments', {
            ...original.toMap(),
            'appointment_id': 'invalid',
            ...values,
          }),
          throwsA(isA<DatabaseException>()),
        );
      }
      expect(
        () => PlanningAppointment.fromMap({
          ...original.toMap(),
          'appointment_date': '2026-02-31',
        }),
        throwsFormatException,
      );
      expect(
        () => PlanningAppointment(
          id: 'bad',
          title: 'Bad',
          date: day,
          startMinute: 600,
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'schema creation is repeatable and leaves existing tables intact',
    () async {
      await db.execute('CREATE TABLE existing_data (value TEXT NOT NULL)');
      await db.insert('existing_data', {'value': 'à conserver'});
      await repository.insert(appointment('a'));
      await db.transaction((txn) async => createPlanningTables(txn));
      expect(await db.query('existing_data'), [
        {'value': 'à conserver'},
      ]);
      expect((await items()).single.id, 'a');
      expect(await db.getVersion(), 0); // No Companion version change here.
    },
  );

  test(
    'calendar conversion preserves identity, civil date, notes and color',
    () {
      for (final original in [
        appointment('timed'),
        PlanningAppointment(id: 'full-day', title: 'Congé', date: day),
        PlanningAppointment(
          id: 'midnight',
          title: 'Soir',
          date: day,
          startMinute: 1380,
          endMinute: 1440,
        ),
      ]) {
        final event = planningCalendarEvent(original);
        expect(event.event, original.id);
        expect(
          planningAppointmentFromCalendar(event, id: original.id).toMap(),
          original.toMap(),
        );
      }
      expect(
        () => planningAppointmentFromCalendar(
          CalendarEventData<Object?>(
            title: 'Plusieurs jours',
            date: day,
            endDate: DateTime(2026, 10, 26),
          ),
          id: 'range',
        ),
        throwsArgumentError,
      );
    },
  );
}
