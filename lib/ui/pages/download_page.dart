import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../controller/controller.dart';
import '../../utils/constants.dart';

class DownloadingPage extends StatelessWidget {
  DownloadingPage({Key? key}) : super(key: key);

  final controller = Get.put(DownloadController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: mainPageSystemOverlay(Theme.of(context).brightness),
        child: SafeArea(
          child: Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              body: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/database.gif',
                      //height: 100,
                      width: double.infinity,
                    ),
                    // Lottie.network(
                    //   'https://assets7.lottiefiles.com/packages/lf20_7k8jk8vi.json',
                    //   width: double.infinity,
                    //   //height: 200,
                    //   fit: BoxFit.fill,
                    // ),
                    //const SizedBox(height: 50,),
                    Text(
                      appName.replaceAll(' ', ' '),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .copyWith(color: const Color(0xFF173D7A)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Divider(),
                    ),
                    Text(
                      'Take medicine on time using the medication reminder app. This app helps you to remember all the pills you need to take no matter how complicated your treatment is.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: const Color(0xFF173D7A)),
                    ),
                    const Spacer(),
                    Obx(()=>controller.isDownloading.value?Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Obx(() => LinearPercentIndicator(
                        //width: MediaQuery.of(context).size.width - 50,
                        //animation: true,
                        lineHeight: 20.0,
                        //animationDuration: 2000,
                        percent: controller.totalDownload.value,
                        center: Text(
                          (controller.totalDownload.value * 100)
                              .toStringAsFixed(0) +
                              "%",
                          style: const TextStyle(color: Colors.white),
                        ),
                        barRadius: const Radius.circular(10),
                        progressColor: const Color(0xFF173D7A),
                      )),
                    ):const CircularProgressIndicator()),
                    Obx(()=>controller.isDownloading.value?Text(
                      'Please wait while downloading..',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: const Color(0xFF173D7A)),
                    ):const SizedBox.shrink())
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
