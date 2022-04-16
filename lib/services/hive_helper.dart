import 'package:hive/hive.dart';

import '../models/reminder.dart';

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

void closeHive() {
  HiveHelper.reminderBox.close();
}

