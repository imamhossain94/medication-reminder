import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medication_reminder/utils/constants.dart';


class HomeController extends GetxController {

  var scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController controller = ScrollController();

  var view = viewMode.list.obs;
  var isLoading = true.obs;

  List<String> reminderList = [];


  // @override
  // void onInit() {
  //   super.onInit();
  // }

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

