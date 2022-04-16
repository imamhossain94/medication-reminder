import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:medication_reminder/models/medicine.dart';
import 'package:medication_reminder/models/reminder.dart';
import 'package:medication_reminder/services/hive_helper.dart';
import 'package:medication_reminder/utils/constants.dart';
import 'package:timezone/data/latest.dart' as tz;
//import 'package:timezone/timezone.dart' as tz;
import '../ui/pages/home_page.dart';
import '../utils/extensions.dart';

class ReminderController extends GetxController {
  Medicine? medicine;
  late TextEditingController medicineNameTextController;
  late TextEditingController medicineStrengthTextController;
  var selectedForm = medicineForms.last.obs;

  var time = const TimeOfDay(hour: 0, minute: 00).obs;
  var selectedTime = '8:00'.obs;
  var selectedTimePeriod = 'PM'.obs;
  var selectedInterval = 3.obs;

  @override
  void onInit() {
    medicineNameTextController = TextEditingController();
    medicineStrengthTextController = TextEditingController();

    medicine = Get.arguments;

    if (medicine != null) {
      medicineNameTextController.text = medicine!.brandName;
      medicineStrengthTextController.text = medicine!.strength;
      selectedForm.value = formToMap(medicine!.form.toLowerCase());
    }

    super.onInit();
  }

  @override
  void dispose() {
    medicineNameTextController.dispose();
    medicineStrengthTextController.dispose();
    super.dispose();
  }

  Future initializetimezone() async {
    tz.initializeTimeZones();
  }

  List<int> makeIDs(double n) {
    var rng = Random();
    List<int> ids = [];
    for (int i = 0; i < n; i++) {
      ids.add(rng.nextInt(1000000000));
    }
    return ids;
  }

  void createReminder() {

    String brandName = medicineNameTextController.text.toString();
    String strength = medicineStrengthTextController.text.toString();

    if(brandName.isNotEmpty && strength.isNotEmpty){
      int interval = selectedInterval.value;
      String startTime = selectedTime.value;

      List<int> intIDs = makeIDs(24 / interval);

      List<String> notificationIDs =
      intIDs.map((i) => i.toString()).toList(); //for Shared preference

      Reminder newReminder = Reminder(
        notificationIDs: notificationIDs,
        medicine: medicine ??
            Medicine(
                brandId: '0',
                genericId: '0',
                companyId: '0',
                brandName: medicineNameTextController.text.toString(),
                form: selectedForm['name']!,
                strength: medicineStrengthTextController.text.toString(),
                price: '0.0',
                packsize: '0'),
        interval: interval,
        startTime: startTime,
      );
      addNewReminder(newReminder);
      scheduleNotification(newReminder);

    }else{
      showMessage('Please enter all information.');
    }

  }


  initializeNotifications() async {
    var initializationSettingsAndroid =
    const AndroidInitializationSettings('@drawable/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await FlutterLocalNotificationsPlugin().initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    Get.to(()=>HomePage());
  }


  Future<void> scheduleNotification(Reminder reminder) async {
    //await initializetimezone();

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    String time = time12to24Format('${reminder.startTime} $selectedTimePeriod').trim().replaceAll(':', '');

    print(time);

    var hour = int.parse(time[0] + time[1]);
    var ogValue = hour;
    var minute = int.parse(time[2] + time[3]);

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'channel id',
      'Medication Reminder',
      //'repeatDailyAtTime description',
      importance: Importance.max,
      //sound: AndroidNotificationSound(),
      icon: 'ic_launcher',
      ledColor: Color(0xFF3EB16F),
      ledOffMs: 1000,
      ledOnMs: 1000,
      enableLights: true,
    );
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    for (int i = 0; i < (24 / reminder.interval).floor(); i++) {

      if ((hour + (reminder.interval * i) > 23)) {
        hour = hour + (reminder.interval * i) - 24;
      } else {
        hour = hour + (reminder.interval * i);
      }
      await flutterLocalNotificationsPlugin.showDailyAtTime(
          int.parse(reminder.notificationIDs[i]),
          'Medication Reminder: ${reminder.medicine.brandName}',
          reminder.medicine.form.toString() != 'Unspecified'
              ? 'It is time to take your ${reminder.medicine.form.toLowerCase()}, according to schedule'
              : 'It is time to take your medicine, according to schedule',
          Time(hour, minute, 0),
          platformChannelSpecifics);


      // Duration offsetTime= DateTime.now().timeZoneOffset;
      // tz.TZDateTime zonedTime = tz.TZDateTime.local(DateTime.now().year,DateTime.now().month,DateTime.now().day,hour,
      //     minute).subtract(offsetTime);
      //
      //
      // await flutterLocalNotificationsPlugin.zonedSchedule(
      //     int.parse(reminder.notificationIDs[i]),
      //     'Medication Reminder: ${reminder.medicine.brandName}',
      //     reminder.medicine.form.toString() != 'Unspecified'
      //         ? 'It is time to take your ${reminder.medicine.form.toLowerCase()}, according to schedule'
      //         : 'It is time to take your medicine, according to schedule',
      //     zonedTime,
      //     platformChannelSpecifics,
      //     androidAllowWhileIdle: true,
      //     uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime);


      hour = ogValue;
    }
    //await flutterLocalNotificationsPlugin.cancelAll();
    Get.deleteAll(force: true).then((value) => Get.offAll(()=> HomePage()));

  }




}
