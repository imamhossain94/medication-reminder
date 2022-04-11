import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medication_reminder/ui/pages/download_page.dart';
import 'package:path/path.dart';
import 'package:sizer/sizer.dart';
import 'package:sqflite/sqflite.dart';

import 'services/get_storage_service.dart';
import 'services/theme_service.dart';
import 'utils/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  setAppVersion();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Sizer(
        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
            title: 'Apk Extractor',
            theme: Themes.light,
            darkTheme: Themes.dark,
            themeMode: ThemeService().theme,
            debugShowCheckedModeBanner: false,
            home: DownloadingPage(),
          );
        }
    );
  }
}

