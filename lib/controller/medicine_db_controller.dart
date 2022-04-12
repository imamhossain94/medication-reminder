import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class MedicineDbController extends GetxController {
  late TextEditingController searchTextController;
  var isLoading = true.obs;


  @override
  void onInit() {
    searchTextController = TextEditingController();

    searchTextController.addListener(() {

    });
    fetchData();
    super.onInit();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  void fetchData() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "medicine.db");
    var db = await openDatabase(path);
    var result = await db.rawQuery("SELECT * FROM brand WHERE brand_name = 'Napa' LIMIT 3");
    print(result);
  }

}

