import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'medicine.dart';
import '../utils/time_utils.dart';

part 'reminder.g.dart';

/// A scheduled medication reminder.
@HiveType(typeId: 1)
class Reminder {
  /// Ids of the OS level notifications backing this reminder.
  @HiveField(0)
  List<dynamic> notificationIDs;

  @HiveField(1)
  final Medicine medicine;

  /// Hours between two doses (1 – 24).
  @HiveField(2)
  final int interval;

  /// First dose of the day, stored as 24h `HH:mm`.
  /// Legacy records may hold a 12h string such as `8:00 PM`; [startTimeOfDay]
  /// parses both.
  @HiveField(3)
  final String startTime;

  /// Stable identifier, used for storage lookups and notification ids.
  @HiveField(4)
  String id;

  Reminder({
    required this.notificationIDs,
    required this.medicine,
    required this.startTime,
    required this.interval,
    String? id,
  }) : id = id ?? newReminderId();

  Medicine get getMedicine => medicine;
  int get getInterval => interval;
  String get getStartTime => startTime;
  List<dynamic> get getIDs => notificationIDs;

  TimeOfDay get startTimeOfDay => parseTimeOfDay(startTime);

  String get startTimeLabel => formatTimeOfDay12(startTimeOfDay);

  /// Every time of day this reminder fires at.
  List<TimeOfDay> get schedule {
    return buildSchedule(startTimeOfDay, interval);
  }

  /// The next dose that is still ahead of [from] (defaults to now).
  DateTime nextDose({DateTime? from}) {
    final DateTime reference = from ?? DateTime.now();
    final List<TimeOfDay> times = schedule;
    for (final TimeOfDay t in times) {
      final DateTime today = DateTime(
        reference.year,
        reference.month,
        reference.day,
        t.hour,
        t.minute,
      );
      if (today.isAfter(reference)) return today;
    }
    // Everything already passed today → first dose tomorrow.
    final TimeOfDay first = times.first;
    return DateTime(
      reference.year,
      reference.month,
      reference.day + 1,
      first.hour,
      first.minute,
    );
  }

  Reminder copyWith({
    Medicine? medicine,
    int? interval,
    String? startTime,
  }) =>
      Reminder(
        notificationIDs: notificationIDs,
        medicine: medicine ?? this.medicine,
        interval: interval ?? this.interval,
        startTime: startTime ?? this.startTime,
        id: id,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'ids': notificationIDs,
        'medicine': medicine,
        'interval': interval,
        'start': startTime,
      };

  factory Reminder.fromJson(Map<String, dynamic> parsedJson) => Reminder(
        notificationIDs:
            (parsedJson['ids'] as List?)?.cast<dynamic>() ?? <dynamic>[],
        medicine: parsedJson['medicine'] as Medicine,
        interval: parsedJson['interval'] as int,
        startTime: parsedJson['start'] as String,
        id: parsedJson['id'] as String?,
      );

  @override
  bool operator ==(Object other) => other is Reminder && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
