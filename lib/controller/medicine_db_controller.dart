import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/medicine.dart';
import '../services/database_service.dart';


class MedicineDbController extends GetxController {
  var isLoading = true.obs;

  late TextEditingController searchTextController;
  ScrollController controller = ScrollController();

  List<Medicine> medicineList = [];
  int listLength = 20;
  int page = 0;


  @override
  void onInit() {
    searchTextController = TextEditingController();
    searchTextController.addListener(() {

    });
    fetchData();
    addItems();
    super.onInit();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  void fetchData() async {
    isLoading(true);
    var result = await DatabaseService.database.rawQuery("SELECT * FROM brand LIMIT $listLength offset $page");

    for (var element in result) {
      medicineList.add(Medicine.fromJson(element));
    }
    isLoading(false);
    update();
  }

  addItems() async {
    controller.addListener(() async{
      if (controller.position.maxScrollExtent == controller.position.pixels) {
        page += 20;
        var result = await DatabaseService.database.rawQuery("SELECT * FROM brand LIMIT $listLength offset $page");
        for (var element in result) {
          medicineList.add(Medicine.fromJson(element));
        }
        update();
      }
      print(page);

    });
  }





}

