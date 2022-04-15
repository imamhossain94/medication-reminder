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
  var selectedTime = '8:00'.obs;
  var selectedTimePeriod = 'PM'.obs;


  @override
  void onInit() {
    medicineNameTextController = TextEditingController();
    medicineStrengthTextController = TextEditingController();

    medicine = Get.arguments;

    if(medicine != null) {
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


  void selectTime(BuildContext context) async {
    // final TimeOfDay? picked = await showTimePicker(
    //   context: context,
    //   initialTime: time.value,
    //   initialEntryMode: TimePickerEntryMode.dial,
    //   confirmText: "OK",
    //   cancelText: "CANCEL",
    //   helpText: "START TIME",
    // );
    // if (picked != null && picked != time.value) {
    //   time.value = picked;
    //   selectedTime.value = convertTime(time.value.hour.toString()) +
    //       convertTime(time.value.minute.toString());
    //
    //   print(picked.format12Hour(context));
    //   print(selectedTime);
    //
    // }

    timePickerSheet(context, (value){
      selectedTime.value = "${value['h']}:${value['m']}";
      selectedTimePeriod.value = '${value['p']}';
    });


  }



}

