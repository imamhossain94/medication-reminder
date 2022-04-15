import 'medicine.dart';

class Reminder {
  final List<dynamic> notificationIDs;
  final Medicine medicine;
  final int interval;
  final String startTime;

  Reminder({
    required this.notificationIDs,
    required this.medicine,
    required this.startTime,
    required this.interval,
  });

  Medicine get getMedicine => medicine;
  int get getInterval => interval;
  String get getStartTime => startTime;
  List<dynamic> get getIDs => notificationIDs;

  Map<String, dynamic> toJson() {
    return {
      "ids": notificationIDs,
      "medicine": medicine,
      "interval": interval,
      "start": startTime,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> parsedJson) {
    return Reminder(
      notificationIDs: parsedJson['ids'],
      medicine: parsedJson['medicine'],
      interval: parsedJson['interval'],
      startTime: parsedJson['start'],
    );
  }
}
