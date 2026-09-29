import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/prefs_service.dart';

/// Owns the light/dark choice and persists it.
class SettingsController extends GetxController {
  final PrefsService prefs = PrefsService.instance;

  ThemeMode get themeMode =>
      ThemeMode.values[prefs.themeModeIndex.clamp(0, ThemeMode.values.length - 1)];

  bool get isDark => Get.isDarkMode;

  void setThemeMode(ThemeMode mode) {
    prefs.themeModeIndex = mode.index;
    Get.changeThemeMode(mode);
    update();
  }

  void toggleTheme() =>
      setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
}
