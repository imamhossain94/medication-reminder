
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/get_storage_service.dart';
import '../../utils/constants.dart';
import '../../utils/extensions.dart';
import '../pages/privacy_policy_page.dart';
import 'drawer_item.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Drawer(
      backgroundColor: Theme.of(context).backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.5, horizontal: 15),
                    child: Text(
                      appName,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const Divider(),
                  DrawerItem(
                      icon: const Icon(FontAwesomeIcons.solidStar, color: Color(0xFFF5365C),),
                      text: 'Rate The App',
                      onTap: () {
                        Get.back();
                        showRatingDialogue(context);
                      }),
                  DrawerItem(
                      icon: const Icon(FontAwesomeIcons.shareAlt, color: Color(0xFF11CDEF),),
                      text: 'Share',
                      onTap: () {
                        Get.back();
                        Share.share('Hey check out this android app $appLink');
                      }),
                  DrawerItem(
                      icon: const Icon(FontAwesomeIcons.googlePlay, color: Color(0xFFFCB840),),
                      text: 'Other Apps',
                      onTap: () async{
                        String url = storeLink;
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      }),
                  const Divider(),
                  DrawerItem(
                      icon: const Icon(FontAwesomeIcons.solidAddressCard, color: Color(0xFF5E72E4),),
                      text: 'Contact',
                      onTap: () async {
                        String url = contactMail;
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      }),
                  DrawerItem(
                      icon: const Icon(FontAwesomeIcons.shieldAlt, color: Color(0xFF2DCE89),),
                      text: 'Privacy Policy',
                      onTap: () async {
                        Get.back();
                        Get.to(() => const PrivacyPolicy());
                      }),
                  DrawerItem(
                      icon: const Icon(FontAwesomeIcons.solidFileAlt, color: Color(0xFF172B4D),),
                      text: 'About',
                      onTap: () async {
                        Get.back();
                        showAboutDialogue(context);
                      }),
                ],
              )
          ),
          const Divider(height: 1,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Text("Version: v${getAppVersion()}", style: const TextStyle(fontWeight:FontWeight.bold, fontSize: 16),),
          ),
        ],
      ),
    );

  }
}
