import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Small typed wrapper around `GetStorage` for app preferences.
class PrefsService {
  PrefsService._();
  static final PrefsService instance = PrefsService._();

  static const String _keyThemeMode = 'theme_mode';
  static const String _keyVersion = 'app_version';
  static const String _keyDbUpdatedAt = 'db_updated_at';

  final GetStorage _box = GetStorage();

  /// 0 = system, 1 = light, 2 = dark
  int get themeModeIndex => _box.read<int>(_keyThemeMode) ?? 0;
  set themeModeIndex(int value) => _box.write(_keyThemeMode, value);

  String get appVersion => _box.read<String>(_keyVersion) ?? '';
  DateTime? get dbUpdatedAt {
    final int? millis = _box.read<int>(_keyDbUpdatedAt);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  set dbUpdatedAt(DateTime? value) => value == null
      ? _box.remove(_keyDbUpdatedAt)
      : _box.write(_keyDbUpdatedAt, value.millisecondsSinceEpoch);

  /// Reads the app version from the platform once per launch.
  Future<void> loadVersion() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      _box.write(_keyVersion, '${info.version}+${info.buildNumber}');
    } catch (_) {
      // Keep whatever was cached before.
    }
  }

  String get versionLabel {
    final String v = appVersion;
    return v.isEmpty ? '1.0.0' : v.split('+').first;
  }
}
