import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder.dart';
import '../utils/time_utils.dart';

/// Wraps `flutter_local_notifications` so the rest of the app only deals with
/// [Reminder] objects.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'medication_reminders';
  static const String _channelName = 'Medication reminders';
  static const String _channelDescription =
      'Alerts that tell you it is time to take a medicine.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  bool get isReady => _ready;

  /// Must be called once at startup, before any scheduling happens.
  Future<void> init() async {
    if (_ready) return;

    tzdata.initializeTimeZones();
    try {
      final String name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (e) {
      debugPrint('Falling back to UTC timezone: $e');
    }

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOS = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: iOS),
    );

    _ready = true;
    await requestPermissions();
  }

  /// Asks for the Android 13+ notification permission (no-op on older versions).
  Future<void> requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
  }

  /// `(Re)schedules every dose of [reminder] and returns the notification ids
  /// that were registered.
  Future<List<int>> schedule(Reminder reminder) async {
    await cancel(reminder);

    final NotificationDetails details = _detailsFor(reminder);
    final List<int> ids = <int>[];

    for (int i = 0; i < reminder.schedule.length; i++) {
      final TimeOfDay time = reminder.schedule[i];
      final int id = notificationIdFrom('${reminder.id}#$i');
      ids.add(id);

      final DateTime next = _nextOccurrence(time);
      await _plugin.zonedSchedule(
        id,
        _titleFor(reminder),
        _bodyFor(reminder),
        tz.TZDateTime.from(next, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: reminder.id,
      );
    }

    return ids;
  }

  DateTime _nextOccurrence(TimeOfDay time) {
    final DateTime now = DateTime.now();
    DateTime candidate =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  String _titleFor(Reminder reminder) {
    final String name = reminder.medicine.displayName;
    return 'Time for $name';
  }

  String _bodyFor(Reminder reminder) {
    final String form = reminder.medicine.formLabel.toLowerCase();
    if (form == 'unspecified') {
      return 'It is time to take your medicine, according to your schedule.';
    }
    return 'It is time to take your $form, according to your schedule.';
  }

  NotificationDetails _detailsFor(Reminder reminder) {
    final Color color = reminder.medicine.medicineForm.color;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        color: color,
        colorized: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(
          _bodyFor(reminder),
          contentTitle: _titleFor(reminder),
        ),
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  /// Cancels every notification that belongs to [reminder].
  ///
  /// Falls back to re-deriving the ids from the schedule for reminders created
  /// by older versions of the app.
  Future<void> cancel(Reminder reminder) async {
    final Set<int> ids = <int>{};
    for (final Object? raw in reminder.notificationIDs) {
      final int? id = int.tryParse('$raw');
      if (id != null) ids.add(id);
    }
    if (ids.isEmpty) {
      for (int i = 0; i < reminder.schedule.length; i++) {
        ids.add(notificationIdFrom('${reminder.id}#$i'));
      }
    }
    for (final int id in ids) {
      await _plugin.cancel(id);
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  bool get supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}
