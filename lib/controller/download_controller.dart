import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio_response;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class DownloadController extends GetxController {

  var isLoading = true.obs;
  var dio = Dio();
  static const databaseUrl = 'https://github.com/imamhossain94/medicinedb/blob/main/medicine.db';


  @override
  void onInit() {
    super.onInit();


  }

  void downloadFile() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path + "/medicine.db";

    print(appDocPath);

    download2(databaseUrl, appDocPath);

  }


  Future download2(String url, String savePath) async {
    try {
      dio_response.Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print(response.headers);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }



}

