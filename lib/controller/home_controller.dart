import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  late TextEditingController searchTextController;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  var isLoading = true.obs;

  @override
  void onInit() {
    searchTextController = TextEditingController();

    searchTextController.addListener(() {

    });

    super.onInit();
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }




}

