import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/medicine.dart';
import '../models/reminder.dart';
import '../services/hive_helper.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../utils/time_utils.dart';

/// Backing controller for the home screen.
class HomeController extends GetxController {
  final Rxn<Reminder> highlighted = Rxn<Reminder>();
  final RxList<Reminder> reminders = <Reminder>[].obs;
  final RxBool loading = false.obs;

  Timer? _ticker;

  /// Dose time that is next across every reminder, or `null` when empty.
  DateTime? get nextDose {
    DateTime? best;
    for (final Reminder r in reminders) {
      final DateTime next = r.nextDose();
      if (best == null || next.isBefore(best)) best = next;
    }
    return best;
  }

  int get totalDosesPerDay {
    int total = 0;
    for (final Reminder r in reminders) {
      total += r.schedule.length;
    }
    return total;
  }

  Duration? get countdown {
    final DateTime? next = nextDose;
    if (next == null) return null;
    final Duration d = next.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  @override
  void onInit() {
    super.onInit();
    reload();
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isClosed) reminders.refresh();
    });
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  Future<void> reload() async {
    loading.value = true;
    reminders.assignAll(HiveHelper.instance.all());
    loading.value = false;
  }

  void highlight(Reminder reminder) {
    highlighted.value = reminder;
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (highlighted.value?.id == reminder.id) highlighted.value = null;
    });
  }

  /// Creates a reminder, persists it and schedules its notifications.
  Future<Reminder?> addReminder({
    required Medicine medicine,
    required int interval,
    required TimeOfDay startTime,
  }) async {
    final Reminder reminder = Reminder(
      notificationIDs: <dynamic>[],
      medicine: medicine,
      interval: interval.clamp(1, 24),
      startTime: serializeTimeOfDay(startTime),
      id: newReminderId(),
    );

    try {
      final List<int> ids = await NotificationService.instance.schedule(reminder);
      reminder.notificationIDs = ids;
    } catch (e) {
      debugPrint('Could not schedule reminder: $e');
    }

    await HiveHelper.instance.save(reminder);
    await reload();
    return reminder;
  }

  /// Deletes a reminder *and* cancels the alarms that belong to it.
  Future<void> deleteReminder(Reminder reminder) async {
    try {
      await NotificationService.instance.cancel(reminder);
    } catch (e) {
      debugPrint('Could not cancel notifications: $e');
    }
    await HiveHelper.instance.delete(reminder.id);
    await reload();
  }

  /// Colours used to tint the reminder cards so the list stays lively.
  List<Color> get cardColors => <Color>[
        brandPrimary,
        brandSecondary,
        brandAccent,
        brandAmber,
        brandBlue,
        const Color(0xFFEC5F9E),
      ];

  Color colorFor(int index) => cardColors[index % cardColors.length];
}
