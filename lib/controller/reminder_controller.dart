import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medication_reminder/models/medicine.dart';
import 'package:medication_reminder/utils/constants.dart';


class ReminderController extends GetxController {

  Medicine? medicine;
  late TextEditingController medicineNameTextController;
  late TextEditingController medicineStrengthTextController;

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






}

