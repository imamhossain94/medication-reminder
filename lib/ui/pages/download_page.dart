import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controller/home_controller.dart';
import '../../utils/constants.dart';

class DownloadingPage extends StatelessWidget {
  DownloadingPage({Key? key}) : super(key: key);

  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: mainPageSystemOverlay(Theme.of(context).brightness),
      child: SafeArea(
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                appName.replaceAll(' ', '\n'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline3,
              ),

            ],
          )
        ),
      ),
    );
  }
}
