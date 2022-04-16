import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medication_reminder/models/reminder.dart';
import 'package:medication_reminder/services/hive_helper.dart';
import 'package:medication_reminder/utils/constants.dart';


class HomeController extends GetxController {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController controller = ScrollController();

  var view = viewMode.grid.obs;
  var isLoading = false.obs;

  var reminderList = <Reminder>[].obs;

  @override
  void onInit() {
    fetchReminder();
    super.onInit();
  }

  @override
  void dispose() {

    super.dispose();
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

  void fetchReminder() {
    isLoading(true);
    reminderList.value = getReminderList();
    isLoading(false);
  }

}

