import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/medicine.dart';
import '../utils/constants.dart';
import '../utils/time_utils.dart';
import 'home_controller.dart';

/// Backing controller for the "new reminder" form.
class ReminderFormController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController strengthController = TextEditingController();

  /// The database row this reminder is based on (null for a manual entry).
  final Rxn<Medicine> sourceMedicine = Rxn<Medicine>();

  final Rx<MedicineForm> form = defaultMedicineForm.obs;
  final RxInt interval = 6.obs;
  final Rx<TimeOfDay> startTime = const TimeOfDay(hour: 8, minute: 0).obs;
  final RxBool saving = false.obs;

  @override
  void onInit() {
    super.onInit();
    final Object? arg = Get.arguments;
    if (arg is Medicine) {
      sourceMedicine.value = arg;
      nameController.text = arg.brandName;
      strengthController.text = arg.strength;
      form.value = arg.medicineForm;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    strengthController.dispose();
    super.onClose();
  }

  /// Quick presets shown as chips under the interval selector.
  static const List<int> intervalPresets = <int>[4, 6, 8, 12, 24];

  String get summaryLine =>
      'Every ${interval.value}h • starts ${formatTimeOfDay12(startTime.value)}';

  Medicine _buildMedicine() {
    final Medicine? source = sourceMedicine.value;
    return Medicine(
      brandId: source?.brandId ?? '',
      genericId: source?.genericId ?? '',
      companyId: source?.companyId ?? '',
      brandName: nameController.text.trim(),
      form: form.value.name,
      strength: strengthController.text.trim(),
      price: source?.price ?? '',
      packsize: source?.packsize ?? '',
      companyName: source?.companyName,
    );
  }

  /// Returns `true` when the reminder was stored.
  Future<bool> submit() async {
    if (saving.value) return false;

    final String name = nameController.text.trim();
    if (name.isEmpty) {
      _toast('Please enter a medicine name.');
      return false;
    }

    saving.value = true;
    try {
      final HomeController home = Get.find<HomeController>();
      await home.addReminder(
        medicine: _buildMedicine(),
        interval: interval.value,
        startTime: startTime.value,
      );
      return true;
    } catch (e) {
      _toast('Could not save the reminder: $e');
      return false;
    } finally {
      saving.value = false;
    }
  }

  void _toast(String message) {
    Get.snackbar(
      'Almost there',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      duration: const Duration(seconds: 3),
    );
  }
}
