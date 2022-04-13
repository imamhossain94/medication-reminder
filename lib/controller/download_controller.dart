import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio_response;
import 'package:get/get.dart';
import 'package:medication_reminder/ui/pages/home_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../services/database_service.dart';

class DownloadController extends GetxController {
  var isDownloading = false.obs;
  var dio = Dio();
  var totalDownload = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    checkDatabase();
  }

  void checkDatabase() async {
    final exists = await databaseExists(DatabaseService.path);
    if(exists){
      await Future.delayed(const Duration(seconds: 2), () {
        navigateScreen();
      });
    }else{
      downloadFile();
    }
  }

  Future downloadFile() async {
    String url =
        'https://firebasestorage.googleapis.com/v0/b/universal-a4a51.appspot.com/o/medication_reminder%2Fmedicine.db?alt=media&token=7783db6c-b692-46e2-beb5-b3f62918f6d0'; //';
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String savePath = appDocDir.path + "/medicine.db";

    try {
      isDownloading(true);
      dio_response.Response response = await dio.get(
        url,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            totalDownload.value = (received / total);
          }
        },
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );

      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      importData(savePath);
    } catch (e) {
      isDownloading(false);
    }
  }

  void importData(String downloadedDbPath) async {
    // Check if we have an existing copy first

    final exists = await databaseExists(DatabaseService.path);

    if (!exists) {
      try {
        File file = File(downloadedDbPath);
        await file.exists();

        try {
          file.copy(DatabaseService.path).then((value) {
            navigateScreen();
          });
        } catch (_) {}
      } catch (e) {
        isDownloading(false);
      }
    } else {
      navigateScreen();
    }
    isDownloading(false);
  }

  void navigateScreen() {
    Get.to(HomePage());
  }
}
