import 'package:hive_flutter/hive_flutter.dart';

import '../models/reminder.dart';
import '../utils/time_utils.dart';

/// Thin, typed wrapper around the Hive box that stores reminders.
class HiveHelper {
  HiveHelper._();
  static final HiveHelper instance = HiveHelper._();

  static const String boxName = 'reminderDatabase';

  late Box<dynamic> _box;
  bool _initialised = false;

  Box<dynamic> get box {
    if (!_initialised) {
      throw StateError('HiveHelper.init() has not been called yet.');
    }
    return _box;
  }

  Future<void> init() async {
    if (_initialised) return;
    _box = await Hive.openBox<dynamic>(boxName);
    _initialised = true;
    await _migrateLegacyEntries();
  }

  /// Older builds of the app did not persist a stable `id`, and stored
  /// notification ids as random strings. Give every legacy reminder an id and
  /// a predictable, id-derived list of notification ids so that deleting a
  /// reminder really cancels its alarms.
  Future<void> _migrateLegacyEntries() async {
    final List<dynamic> keys = _box.keys.toList(growable: false);

    for (final dynamic key in keys) {
      final dynamic raw = _box.get(key);
      if (raw is! Reminder) continue;

      final bool needsId = raw.id.isEmpty;
      final bool needsNotificationIds = raw.notificationIDs.isEmpty;

      if (needsId) {
        raw.id = newReminderId();
      }
      if (needsNotificationIds) {
        raw.notificationIDs = raw.schedule
            .asMap()
            .entries
            .map((MapEntry<int, dynamic> e) => notificationIdFor(raw.id, e.key))
            .toList();
      }

      if (needsId || needsNotificationIds) await _box.put(key, raw);
    }
  }

  static String newId() => newReminderId();

  static int notificationIdFor(String reminderId, int index) =>
      notificationIdFrom('$reminderId#$index');

  /// All reminders, newest first.
  List<Reminder> all() {
    final List<Reminder> reminders = _box.values
        .whereType<Reminder>()
        .toList(growable: true)
      ..sort((Reminder a, Reminder b) => b.id.compareTo(a.id));
    return reminders;
  }

  Reminder? byId(String id) {
    for (final dynamic value in _box.values) {
      if (value is Reminder && value.id == id) return value;
    }
    return null;
  }

  Future<void> save(Reminder reminder) async {
    if (reminder.id.isEmpty) reminder.id = newId();
    await _box.put(reminder.id, reminder);
  }

  Future<void> delete(String id) async {
    final List<dynamic> keys = _box.keys
        .where((dynamic k) {
          final dynamic value = _box.get(k);
          return value is Reminder && value.id == id;
        })
        .toList(growable: false);
    await _box.deleteAll(keys);
  }

  Future<void> clear() => _box.clear();

  Future<void> close() async {
    if (_initialised) {
      await _box.close();
      _initialised = false;
    }
  }
}
