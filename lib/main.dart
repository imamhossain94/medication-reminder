import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'controllers/bootstrap_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/settings_controller.dart';
import 'models/medicine.dart';
import 'models/reminder.dart';
import 'services/database_service.dart';
import 'services/hive_helper.dart';
import 'services/notification_service.dart';
import 'services/prefs_service.dart';
import 'theme/app_theme.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/loading_page.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await GetStorage.init();
  await Hive.initFlutter();
  Hive
    ..registerAdapter(MedicineAdapter())
    ..registerAdapter(ReminderAdapter());
  await HiveHelper.instance.init();
  await PrefsService.instance.loadVersion();

  // Reminders must work even when the medicine database cannot be fetched, so
  // failures here are logged instead of blocking the app.
  try {
    await NotificationService.instance.init();
  } catch (e) {
    debugPrint('Notification service unavailable: $e');
  }

  runApp(const MedicationReminderApp());
}

class MedicationReminderApp extends StatelessWidget {
  const MedicationReminderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PrefsService prefs = PrefsService.instance;

    return GetMaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.values[prefs.themeModeIndex.clamp(0, 2)],
      builder: (BuildContext context, Widget? child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemOverlay(Theme.of(context).brightness),
          child: MediaQuery.withClampedTextScaling(
            minScaleFactor: 0.9,
            maxScaleFactor: 1.25,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      initialBinding: BindingsBuilder(() {
        Get.put<BootstrapController>(BootstrapController(), permanent: true);
        Get.put<HomeController>(HomeController(), permanent: true);
        Get.put<SettingsController>(SettingsController(), permanent: true);
      }),
      home: const _Root(),
    );
  }
}

/// Chooses between the loading screen and the home screen, and keeps the two in
/// sync with the bootstrap state.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final BootstrapController bootstrap = Get.find<BootstrapController>();

    return Obx(() {
      final bool ready = bootstrap.stage.value == BootstrapStage.ready;
      if (!ready) return const SplashPage();
      if (!DatabaseService.instance.isOpen) return const SplashPage();
      return const HomePage();
    });
  }
}
