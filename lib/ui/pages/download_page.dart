import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../controller/home_controller.dart';
import '../../utils/constants.dart';

class DownloadingPage extends StatelessWidget {
  DownloadingPage({Key? key}) : super(key: key);

  final controller = Get.put(HomeController());

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
                  Lottie.network(
                    'https://assets7.lottiefiles.com/packages/lf20_7k8jk8vi.json',
                    width: double.infinity,
                    //height: 200,
                    fit: BoxFit.fill,
                  ),
                  //const SizedBox(height: 50,),
                  Text(
                    appName.replaceAll(' ', ' '),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline2!.copyWith(
                        color: const Color(0xFF173D7A)
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Divider(),
                  ),
                  Text(
                    'Take medicine on time using the medication reminder app. This app helps you to remember all the pills you need to take no matter how complicated your treatment is.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: const Color(0xFF173D7A)
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: LinearPercentIndicator(
                      //width: MediaQuery.of(context).size.width - 50,
                      animation: true,
                      lineHeight: 20.0,
                      animationDuration: 2000,
                      percent: 0.9,
                      center: const Text("90.0%", style: TextStyle(color: Colors.white),),
                      barRadius: const Radius.circular(10),
                      progressColor: const Color(0xFF173D7A),
                    ),
                  ),

                  Text(
                    'Please wait while downloading..',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: const Color(0xFF173D7A)
                    ),
                  ),
                ],
              ),
            )
          ),
        ),
      ),
    );
  }
}
