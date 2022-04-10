import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio_response;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class DownloadController extends GetxController {

  var isLoading = true.obs;

  static const imgUrl = 'http://212.183.159.230/20MB.zip';
  var dio = Dio();


  @override
  void onInit() {
    super.onInit();


  }

  void downloadFile() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path + "/video.mp4'";

    print(appDocPath);

    download2(dio, imgUrl, appDocPath);

  }


  Future download2(Dio dio, String url, String savePath) async {
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

