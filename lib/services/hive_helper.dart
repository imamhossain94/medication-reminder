import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/reminder.dart';
import '../ui/pages/home_page.dart';

class HiveHelper {
  static late Box reminderBox;

  Future init() async {
    reminderBox = await Hive.openBox('reminderDatabase');
  }
}

// Reminder
List<Reminder> getReminderList() {
  List _routineDatabase = <Reminder>[];
  _routineDatabase = HiveHelper.reminderBox.values.toList();
  _routineDatabase = _routineDatabase.reversed.toList();
  return List<Reminder>.from(_routineDatabase).toList();
}

void addNewReminder(Reminder reminder) async{
  await HiveHelper.reminderBox.add(reminder);
}

void removeReminder(Reminder reminder) async{
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  List<Reminder> reminderList = getReminderList();
  reminderList.removeWhere(
          (medicine) => medicine.notificationIDs == reminder.notificationIDs);
  for (int i = 0; i < (24 / reminder.interval).floor(); i++) {
    flutterLocalNotificationsPlugin.cancel(int.parse(reminder.notificationIDs[i]));
  }

  await HiveHelper.reminderBox.clear();
  for (var element in reminderList.reversed) {
    addNewReminder(element);
  }

  Get.deleteAll(force: true).then((value) => Get.offAll(()=> HomePage()));

}

void closeHive() {
  HiveHelper.reminderBox.close();
}

