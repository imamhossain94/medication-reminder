import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/reminder.dart';
import '../services/database_downloader.dart';
import '../services/database_service.dart';
import '../services/hive_helper.dart';
import '../services/notification_service.dart';
import '../services/prefs_service.dart';

/// Owns the startup sequence: local storage → medicine database → home screen.
class BootstrapController extends GetxController {
  final Rx<BootstrapStage> stage = BootstrapStage.opening.obs;
  final RxDouble progress = 0.0.obs;
  final RxString statusText = 'Starting up…'.obs;
  final RxString detailText = ''.obs;
  final RxnString error = RxnString();

  final DatabaseDownloader downloader = DatabaseDownloader();

  bool get isWorking => stage.value != BootstrapStage.ready &&
      stage.value != BootstrapStage.failed;

  @override
  void onInit() {
    super.onInit();
    bootstrap();
  }

  Future<void> bootstrap() async {
    error.value = null;
    try {
      stage.value = BootstrapStage.opening;
      statusText.value = 'Opening your reminders…';
      progress.value = 0.1;

      final List<Reminder> reminders = HiveHelper.instance.all();

      stage.value = BootstrapStage.checkingDatabase;
      statusText.value = 'Checking the medicine library…';
      progress.value = 0.35;

      bool installed = await DatabaseService.isInstalled();
      if (installed) {
        try {
          await DatabaseService.instance.open();
        } catch (e) {
          debugPrint('Existing database could not be opened: $e');
          await DatabaseService.instance.delete();
          installed = false;
        }
      }

      if (!installed) {
        await downloadDatabase();
      } else {
        progress.value = 1;
      }

      stage.value = BootstrapStage.ready;
      statusText.value = 'Ready';
      _registerReminders(reminders);
    } catch (e) {
      error.value = '$e';
      stage.value = BootstrapStage.failed;
      statusText.value = 'Something went wrong';
    }
  }

  Future<void> downloadDatabase() async {
    stage.value = BootstrapStage.downloading;
    statusText.value = 'Downloading medicine library…';

    await downloader.fetch(
      onProgress: (DatabaseDownloadProgress p) {
        final double? fraction = p.fraction;
        progress.value = fraction == null
            ? 0.6
            : 0.35 + (fraction * 0.6).clamp(0.0, 0.65);
        detailText.value = fraction == null
            ? 'via ${p.mirrorLabel}'
            : '${(fraction * 100).toStringAsFixed(0)}% • ${p.mirrorLabel}';
      },
    );

    PrefsService.instance.dbUpdatedAt = DateTime.now();
    progress.value = 1;
    detailText.value = '';
  }

  /// Re-schedules notifications for reminders saved by a previous session.
  Future<void> _registerReminders(List<Reminder> reminders) async {
    if (reminders.isEmpty) return;
    try {
      if (!NotificationService.instance.isReady) {
        await NotificationService.instance.init();
      }
      for (final Reminder reminder in reminders) {
        final List<int> ids =
            await NotificationService.instance.schedule(reminder);
        reminder.notificationIDs = ids;
      }
    } catch (e) {
      debugPrint('Could not restore notifications: $e');
    }
  }

  /// Re-downloads the medicine database (drawer → "Update database").
  Future<bool> updateDatabase() async {
    try {
      statusText.value = 'Updating medicine library…';
      progress.value = 0.4;
      await DatabaseService.instance.delete();
      await downloadDatabase();
      stage.value = BootstrapStage.ready;
      return true;
    } catch (e) {
      error.value = '$e';
      stage.value = BootstrapStage.failed;
      return false;
    }
  }

  Future<void> retry() => bootstrap();
}

enum BootstrapStage { opening, checkingDatabase, downloading, ready, failed }
