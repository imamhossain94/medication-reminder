import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medication_reminder/models/medicine.dart';
import 'package:medication_reminder/models/reminder.dart';
import 'package:medication_reminder/utils/constants.dart';

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

  void createReminder() {

    String brandName = medicineNameTextController.text.toString();
    String strength = medicineStrengthTextController.text.toString();

    if(brandName.isNotEmpty && strength.isNotEmpty){
      int interval = selectedInterval.value;
      String startTime = selectedTime.value.replaceAll(':', '');

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



    }else{
      showMessage('Please enter all information.');
    }

  }


  List<int> makeIDs(double n) {
    var rng = Random();
    List<int> ids = [];
    for (int i = 0; i < n; i++) {
      ids.add(rng.nextInt(1000000000));
    }
    return ids;
  }
}
