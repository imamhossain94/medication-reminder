import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medication_reminder/models/medicine.dart';
import 'package:medication_reminder/utils/constants.dart';

import '../utils/extensions.dart';


class ReminderController extends GetxController {

  Medicine? medicine;
  late TextEditingController medicineNameTextController;
  late TextEditingController medicineStrengthTextController;
  var selectedForm = medicineForms.last.obs;

  var time = const TimeOfDay(hour: 0, minute: 00).obs;
  var selectedTime = '0:00'.obs;


  @override
  void onInit() {
    medicineNameTextController = TextEditingController();
    medicineStrengthTextController = TextEditingController();

    medicine = Get.arguments;

    if(medicine != null) {
      medicineNameTextController.text = medicine!.brandName;
      medicineStrengthTextController.text = medicine!.strength;
    }


    super.onInit();
  }

  @override
  void dispose() {
    medicineNameTextController.dispose();
    medicineStrengthTextController.dispose();
    super.dispose();
  }


  void selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time.value,
    );
    if (picked != null && picked != time.value) {
      time.value = picked;
      print(picked);
      selectedTime.value = convertTime(time.value.hour.toString()) +
          convertTime(time.value.minute.toString());
    }
  }



}

