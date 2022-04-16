import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ui/components/list_wheel_scroll_view_x.dart';
import 'constants.dart';


String generateRandomString(int len) {
  var r = Random();
  const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}

String convertTime(String minutes) {
  if (minutes.length == 1) {
    return "0" + minutes;
  } else {
    return minutes;
  }
}


String formToSvgAssetsPath(String form) {

  // capsule 1
  if(form.contains(FormPossibility.capsule)) return capsuleSvg;
  // suppository 1
  if(form.contains(FormPossibility.suppository)) return suppositorySvg;
  // drops 1
  if(form.contains(FormPossibility.drops)) return dropsSvg;
  // soap 1
  if(form.contains(FormPossibility.soap)) return soapSvg;

  // Tablet 2
  for (var element in FormPossibility.tablet) {
    if(form.contains(element)){
      return tabletsSvg;
    }
  }
  // powder 2
  for (var element in FormPossibility.powder) {
    if(form.contains(element)){
      return powderSvg;
    }
  }
  // bandage 2
  for (var element in FormPossibility.bandage) {
    if(form.contains(element)){
      return bandageSvg;
    }
  }
  // inhaler 3
  for (var element in FormPossibility.inhaler) {
    if(form.contains(element)){
      return spraySvg;
    }
  }
  // injection 5
  for (var element in FormPossibility.injection) {
    if(form.contains(element)){
      return injectionSvg;
    }
  }
  //tube 6
  for (var element in FormPossibility.tube) {
    if(form.contains(element)){
      return creamSvg;
    }
  }
  // Bottle 8
  for (var element in FormPossibility.bottle) {
    if(form.contains(element)){
      return bottleSvg;
    }
  }

  return unknownSvg;
}


Map<String, String> formToMap(String form) {

  // capsule 1
  if(form.contains(FormPossibility.capsule)) return medicineForms[2];
  // suppository 1
  if(form.contains(FormPossibility.suppository)) return medicineForms[9];
  // drops 1
  if(form.contains(FormPossibility.drops)) return medicineForms[4];
  // soap 1
  if(form.contains(FormPossibility.soap)) return medicineForms[7];

  // Tablet 2
  for (var element in FormPossibility.tablet) {
    if(form.contains(element)){
      return medicineForms[10];
    }
  }
  // powder 2
  for (var element in FormPossibility.powder) {
    if(form.contains(element)){
      return medicineForms[6];
    }
  }
  // bandage 2
  for (var element in FormPossibility.bandage) {
    if(form.contains(element)){
      return medicineForms[0];
    }
  }
  // inhaler 3
  for (var element in FormPossibility.inhaler) {
    if(form.contains(element)){
      return medicineForms[8];
    }
  }
  // injection 5
  for (var element in FormPossibility.injection) {
    if(form.contains(element)){
      return medicineForms[5];
    }
  }
  //tube 6
  for (var element in FormPossibility.tube) {
    if(form.contains(element)){
      return medicineForms[3];
    }
  }
  // Bottle 8
  for (var element in FormPossibility.bottle) {
    if(form.contains(element)){
      return medicineForms[1];
    }
  }

  return medicineForms[11];
}

String time12to24Format(String time) {
// var time = "12:01 AM";
  int h = int.parse(time.split(":").first);
  int m = int.parse(time.split(":").last.split(" ").first);
  String meridium = time.split(":").last.split(" ").last.toLowerCase();
  if (meridium == "pm") {
    if (h != 12) {
      h = h + 12;
    }
  }
  if (meridium == "am") {
    if (h == 12) {
      h = 00;
    }
  }
  String newTime = "${h == 0 ? "00" : h}:${m == 0 ? "00" : m}";
  print(newTime);

  return newTime;
}

void showAboutDialogue(BuildContext context) async {
  return showDialog(
    barrierColor: Colors.black12,
    context: context,
    barrierDismissible: true,
    useSafeArea: true,
    builder: (context) {
      return Center(
        child: Wrap(children: [
          Container(
            clipBehavior: Clip.none,
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 5,
                      offset: Offset.zero)
                ]),
            child: Column(
              children: [
                const Text(
                  'About',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8,),
                const Divider(thickness: 1,),
                aboutDialogueItem('App Developer:', developerName),
                const Divider(),
                aboutDialogueItem('Designer Name:', designerName),
                const Divider(),
                aboutDialogueItem('App Icon:', "fontawesome.com,\nsvgrepo.com"),
              ],
            ),
          ),
        ]),
      );
    },
  );
}

Widget aboutDialogueItem(String title, String description) {
  return SizedBox(
    height: 30,
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          description,
          style: const TextStyle(
            decoration: TextDecoration.none,
            fontSize: 14,
            color: Colors.black54,
          ),)
      ],
    ),
  );
}

Widget emptyScreen(String message) {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
            emptySvg,
            height: 80,
            width: 80,
            color: const Color(0xFF172B4D),
            semanticsLabel: 'Open Pill'
        ),
        const SizedBox(height: 30,),
        Text(message, style: TextStyle(fontSize: 11.sp),),
      ],
    ),
  );
}

void showRatingDialogue(BuildContext context) async {
  return showDialog(
    barrierColor: Colors.black12,
    context: context,
    barrierDismissible: true,
    useSafeArea: true,
    builder: (context) {
      return Center(
        child: Wrap(children: [
          Container(
            clipBehavior: Clip.none,
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 5,
                      offset: Offset.zero)
                ]),
            child: Column(
              children: [
                const Text(
                  'Rate The App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8,),
                const Divider(thickness: 1,),
                const SizedBox(height: 8,),
                const Text(
                  "Please rate the app 5 stars on Google Play to help spread the world!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: RatingBar.builder(
                    initialRating: 1,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const FaIcon(
                      FontAwesomeIcons.solidStar,
                      color: Color(0xFFF5365C),
                    ),
                    onRatingUpdate: (rating) async{
                      if(rating == 5){
                        Get.back();
                        String url = appLink;
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      }else{
                        Get.back();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Thank you for the rating!'),
                          ),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ]),
      );
    },
  );
}


void showMessage(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0
  );
}


extension TimeOfDayExtensions on TimeOfDay {
  String format12Hour(BuildContext context) {
    TimeOfDay time = replacing(hour: hourOfPeriod);
    //MaterialLocalizations localizations = MaterialLocalizations.of(context);

    final StringBuffer buffer = StringBuffer();

    buffer..write(time.format(context))..write(' ');
      // ..write(
      //   period == DayPeriod.am
      //       ? localizations.anteMeridiemAbbreviation
      //       : localizations.postMeridiemAbbreviation);

    return '$buffer';
  }
}



//Time picker bottom sheet
Widget timePickerSheet(BuildContext context, ValueChanged<Map<String, String>> onFinished) {

  String hour = '01';
  String minute = '00';
  String period = 'AM';

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: const Offset(0, 3), // changes position of shadow
        ),
      ],
    ),
    child: Wrap(
      children: [
        Row(
          children: [
            const Text(
              'Select Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5.0),
                  onTap: (){
                    onFinished({
                      'h':hour,
                      'm':minute,
                      'p':period,
                      't':'$hour:$minute$period'
                    });
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: FaIcon(FontAwesomeIcons.check, size: 16,),
                  ),
                ),
              ),
            )
          ],
        ),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 150,
                width: ((MediaQuery.of(context).size.width - 78) / 3),
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListWheelScrollViewX(
                        //controller: _controller,
                        scrollDirection: Axis.vertical,
                        itemExtent: 40,
                        diameterRatio: 0.7,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (v) {
                          hour = '${'${v+1}'.length == 1 ? '0' : ''}${v+1}';
                        },
                        children: [
                          for (var i = 1; i <= 12; i += 1)
                            '${'$i'.length == 1 ? '0' : ''}$i'
                        ].map((e) {
                          return Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                color: const Color(0xFF172B4D),
                                borderRadius: BorderRadius.circular(5.0)),
                            child: Text(
                              e,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(),
                    const Center(
                        child: Text(
                          'HOURS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 150,
                width: ((MediaQuery.of(context).size.width - 78) / 3),
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListWheelScrollViewX(
                        //controller: _controller,
                        scrollDirection: Axis.vertical,
                        itemExtent: 40,
                        diameterRatio: 0.7,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (v) {
                          minute = '${'$v'.length == 1 ? '0' : ''}$v';
                        },
                        children: [
                          for (var i = 0; i <= 59; i += 1)
                            '${'$i'.length == 1 ? '0' : ''}$i'
                        ].map((e) {
                          return Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                color: const Color(0xFF172B4D),
                                borderRadius: BorderRadius.circular(5.0)),
                            child: Text(
                              e,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(),
                    const Center(
                        child: Text(
                          'MINUTES',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 150,
                width: ((MediaQuery.of(context).size.width - 78) / 3),
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListWheelScrollViewX(
                        //controller: _controller,
                        scrollDirection: Axis.vertical,
                        itemExtent: 40,
                        diameterRatio: 0.7,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (v) {
                          period = ['AM', 'PM'][v];
                        },
                        children: ['AM', 'PM'].map((e) {
                          return Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                color: const Color(0xFF172B4D),
                                borderRadius: BorderRadius.circular(5.0)),
                            child: Text(
                              e,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(),
                    const Center(
                        child: Text(
                          'PERIOD',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    ),
  );
}

// Interval picker bottom sheet
Widget intervalPickerSheet(BuildContext context, ValueChanged<String> onFinished) {

  String hour = '01';

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: const Offset(0, 3), // changes position of shadow
        ),
      ],
    ),
    child: Wrap(
      children: [
        Row(
          children: [
            const Text(
              'Select Interval',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5.0),
                  onTap: (){
                    onFinished(hour);
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: FaIcon(FontAwesomeIcons.check, size: 16,),
                  ),
                ),
              ),
            )
          ],
        ),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 150,
                width: ((MediaQuery.of(context).size.width - 78) / 3),
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListWheelScrollViewX(
                        //controller: _controller,
                        scrollDirection: Axis.vertical,
                        itemExtent: 40,
                        diameterRatio: 0.7,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (v) {
                          hour = '${'${v+1}'.length == 1 ? '0' : ''}${v+1}';
                        },
                        children: [
                          for (var i = 1; i <= 24; i += 1)
                            '${'$i'.length == 1 ? '0' : ''}$i'
                        ].map((e) {
                          return Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                color: const Color(0xFF172B4D),
                                borderRadius: BorderRadius.circular(5.0)),
                            child: Text(
                              e,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(),
                    const Center(
                        child: Text(
                          'HOURS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    ),
  );
}



