import 'package:get/get.dart';

import '../models/medicine.dart';
import '../models/medicine_details.dart';
import '../services/database_service.dart';

/// Loads the full drug monograph for a single brand.
class MedicineDetailsController extends GetxController {
  MedicineDetailsController(this.medicine);

  final Medicine medicine;

  final Rxn<MedicineDetails> details = Rxn<MedicineDetails>();
  final RxList<Medicine> alternatives = <Medicine>[].obs;
  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final MedicineDetails? info =
          await DatabaseService.instance.detailsForBrand(medicine.brandId);
      details.value = info;

      if (medicine.genericId.isNotEmpty) {
        alternatives.assignAll(await DatabaseService.instance.alternativesFor(
          medicine.genericId,
          excludeBrandId: medicine.brandId,
        ));
      }
    } finally {
      loading.value = false;
    }
  }
}
