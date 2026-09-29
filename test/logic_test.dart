// Smoke tests for the pure logic that the app relies on.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medication_reminder/models/medicine.dart';
import 'package:medication_reminder/models/medicine_details.dart';
import 'package:medication_reminder/models/reminder.dart';
import 'package:medication_reminder/utils/time_utils.dart';

void main() {
  group('parseTimeOfDay', () {
    test('parses 24h format', () {
      expect(parseTimeOfDay('08:30').hour, 8);
      expect(parseTimeOfDay('08:30').minute, 30);
      expect(parseTimeOfDay('20:00').hour, 20);
    });

    test('parses the legacy 12h format', () {
      // The old app stored "8:00 PM"; this used to crash the scheduler.
      expect(parseTimeOfDay('8:00 PM').hour, 20);
      expect(parseTimeOfDay('8:00 PM').minute, 0);
      expect(parseTimeOfDay('12:05 am').hour, 0);
      expect(parseTimeOfDay('12:05 pm').hour, 12);
    });

    test('falls back instead of throwing', () {
      expect(parseTimeOfDay(null).hour, 8);
      expect(parseTimeOfDay('').hour, 8);
      expect(parseTimeOfDay('not a time').hour, 8);
    });
  });

  group('buildSchedule', () {
    test('wraps around midnight', () {
      // 20:00 +6h every time -> 20:00, 02:00, 08:00, 14:00
      final List<TimeOfDay> times =
          buildSchedule(const TimeOfDay(hour: 20, minute: 0), 6);
      expect(times.length, 4);
      expect(times.map((TimeOfDay t) => t.hour), <int>[20, 2, 8, 14]);
    });

    test('never produces more than 24 entries', () {
      expect(buildSchedule(const TimeOfDay(hour: 8, minute: 0), 1).length, 24);
    });

    test('drops the incomplete remainder for intervals that do not divide 24',
        () {
      // Every 5h from 22:00 -> 22:00, 03:00, 08:00, 13:00, 18:00.
      // The leftover 2h before midnight is dropped instead of wrapping back
      // onto a time that was already used.
      final List<TimeOfDay> times =
          buildSchedule(const TimeOfDay(hour: 22, minute: 0), 5);
      expect(times.length, 5);
      expect(times.map((TimeOfDay t) => t.hour), <int>[22, 3, 8, 13, 18]);
      expect(times.every((TimeOfDay t) => t.hour >= 0 && t.hour < 24), isTrue);
    });
  });

  group('form resolution', () {
    test('maps raw database values to a canonical form', () {
      expect(resolveFormName('Tablet'), 'Tablet');
      expect(resolveFormName('cap'), 'Capsule');
      expect(resolveFormName('SUSPENSION'), 'Suspension');
      expect(resolveFormName(''), 'Unspecified');
      expect(formToMedicineForm('Inhalation').name, 'Inhaler/Spray');
    });
  });

  group('Reminder', () {
    Medicine makeMedicine() => Medicine(
          brandId: '1',
          genericId: '1',
          companyId: '1',
          brandName: 'Napa',
          form: 'Tablet',
          strength: '500 mg',
          price: '12',
          packsize: "10's pack",
        );

    test('nextDose rolls over to tomorrow when every dose has passed', () {
      final Reminder reminder = Reminder(
        notificationIDs: <dynamic>[],
        medicine: makeMedicine(),
        interval: 6,
        startTime: '00:00',
        id: 'test-id',
      );
      // 00:00 only fires once a day, so the next dose is always in the future.
      final DateTime next = reminder.nextDose();
      expect(next.isAfter(DateTime.now()), isTrue);
    });

    test('serialised start time round trips', () {
      const TimeOfDay time = TimeOfDay(hour: 20, minute: 5);
      expect(parseTimeOfDay(serializeTimeOfDay(time)).hour, 20);
      expect(parseTimeOfDay(serializeTimeOfDay(time)).minute, 5);
    });

    test('notification ids are stable and unique per dose', () {
      final int a = notificationIdFrom('abc#0');
      final int b = notificationIdFrom('abc#1');
      expect(a, isNot(b));
      expect(notificationIdFrom('abc#0'), a);
    });
  });
}
