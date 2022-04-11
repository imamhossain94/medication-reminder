import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio_response;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class DownloadController extends GetxController {

  var isDownloading = true.obs;
  var dio = Dio();
  var totalDownload = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    downloadFile();
  }


  Future downloadFile() async {

    String url = 'https://firebasestorage.googleapis.com/v0/b/universal-a4a51.appspot.com/o/medication_reminder%2Fmedicine.db?alt=media&token=7783db6c-b692-46e2-beb5-b3f62918f6d0';//';
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String savePath = appDocDir.path + "/medicine.db";


    try {
      isDownloading(true);
      dio_response.Response response = await dio.get(
        url,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // print((received / total * 100).toStringAsFixed(0) + "%");
            // print("Downloaded: ${received/total}");
            totalDownload.value = (received/total);
          }
        },
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      // print(response.headers);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      // print(await File(savePath).exists());

      isDownloading(false);
    } catch (e) {
      // print(e);
      isDownloading(false);
    }
  }

}

