import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medication_reminder/utils/constants.dart';


class HomeController extends GetxController {
  late TextEditingController searchTextController;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  var view = viewMode.list.obs;
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

  void toggleViewMode() {
    if(view.value == viewMode.list){
      view.value = viewMode.grid;
    }else{
      view.value = viewMode.list;
    }
  }



}

