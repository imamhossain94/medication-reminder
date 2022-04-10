import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/constants.dart';

class PrivacyPolicy extends StatelessWidget{
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: mainPageSystemOverlay(Theme.of(context).brightness),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(size: 22),
            title: Text(
              "Privacy Policy",
              style: Theme.of(context).textTheme.headline3,
            ),
            titleSpacing: 0,
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(FontAwesomeIcons.arrowLeft)),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: WebView(
                javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: privacyPolicyUrl,
                onWebViewCreated: (WebViewController c) {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}
