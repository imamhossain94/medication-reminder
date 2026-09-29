import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Parses a stored time string into a [TimeOfDay].
///
/// Accepts both the 24h format used by the app (`20:00`, `08:30`) and the
/// legacy 12h format (`8:00 PM`, `12:05 am`). Returns 08:00 for anything that
/// cannot be understood instead of throwing.
TimeOfDay parseTimeOfDay(String? raw) {
  if (raw == null) return const TimeOfDay(hour: 8, minute: 0);

  final String value = raw.trim().toLowerCase();
  final Match? match =
      RegExp(r'^(\d{1,2})\s*[:.\-h]?\s*(\d{2})?\s*(am|pm)?').firstMatch(value);
  if (match == null) return const TimeOfDay(hour: 8, minute: 0);

  int hour = int.tryParse(match.group(1) ?? '') ?? 8;
  int minute = int.tryParse(match.group(2) ?? '') ?? 0;
  final String? meridiem = match.group(3);

  if (meridiem != null) {
    if (hour > 12) hour = 12;
    if (meridiem == 'pm' && hour != 12) hour += 12;
    if (meridiem == 'am' && hour == 12) hour = 0;
  }

  return TimeOfDay(
    hour: hour.clamp(0, 23),
    minute: minute.clamp(0, 59),
  );
}

/// Formats a [TimeOfDay] using the device locale, e.g. `8:00 PM`.
String formatTimeOfDay(BuildContext context, TimeOfDay time) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: time.hour, minute: time.minute),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

/// Convenience wrapper for when there is no [BuildContext] handy (e.g. inside
/// Hive helpers). Falls back to a US style 12h representation.
String formatTimeOfDay12(TimeOfDay time) {
  final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final String period = time.hour < 12 ? 'AM' : 'PM';
  return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
}

/// Serialises a [TimeOfDay] to the 24h `HH:mm` format stored by the app.
String serializeTimeOfDay(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

/// Builds every dose time of a day for an [interval] (in hours).
///
/// For intervals that do not divide 24 evenly (e.g. every 5 hours) the last
/// remainder is dropped instead of producing a duplicate or an out of range
/// hour, which is what the previous implementation did.
List<TimeOfDay> buildSchedule(TimeOfDay start, int interval) {
  final int step = interval.clamp(1, 24);
  final List<TimeOfDay> result = <TimeOfDay>[];
  for (int h = 0; h < 24; h += step) {
    result.add(TimeOfDay(hour: (start.hour + h) % 24, minute: start.minute));
  }
  if (result.isEmpty) result.add(start);
  return result;
}

/// Compact "in 2h 15m" / "in 40m" / "now" label for the next dose.
String countdownLabel(Duration delta) {
  if (delta.isNegative) return 'now';
  if (delta.inMinutes < 1) return 'now';
  if (delta.inMinutes < 60) return 'in ${delta.inMinutes}m';
  final int hours = delta.inHours;
  final int minutes = delta.inMinutes.remainder(60);
  if (minutes == 0) return 'in ${hours}h';
  return 'in ${hours}h ${minutes}m';
}

/// Human friendly greeting used on the home header.
String greetingFor(DateTime now) {
  final int hour = now.hour;
  if (hour < 5) return 'Good night';
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// A stable 31 bit FNV-1a hash. Used to derive deterministic notification ids
/// from a reminder id so they can be cancelled later without storing them.
int stableHash(String value) {
  int hash = 0x811c9dc5;
  for (int i = 0; i < value.length; i++) {
    hash ^= value.codeUnitAt(i);
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

/// A stable, non negative notification id for [seed].
int notificationIdFrom(String seed) {
  return stableHash(seed) % 2000000000 + 1;
}

String newReminderId() {
  final int stamp = DateTime.now().microsecondsSinceEpoch;
  final int salt = math.Random().nextInt(1 << 24);
  return '${stamp.toString().padLeft(20, '0')}.${salt.toString().padLeft(6, '0')}';
}
