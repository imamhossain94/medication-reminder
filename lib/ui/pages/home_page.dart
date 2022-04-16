import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:medication_reminder/ui/pages/medicine_db_page.dart';

import '../../controller/home_controller.dart';
import '../../utils/constants.dart';
import '../../utils/extensions.dart';
import '../components/main_drawer.dart';
import '../components/reminder_card.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final controller = Get.put(HomeController(), permanent: true,);

  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: mainPageSystemOverlay(Theme.of(context).brightness),
      child: SafeArea(
        child: Scaffold(
          key: controller.scaffoldKey,
          appBar: AppBar(
            elevation: 0.5,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
            titleSpacing: 0,
            title: Text(
              appName,
              style: Theme.of(context).textTheme.headline3,
            ),
            //centerTitle: true,
            leading: IconButton(
                onPressed: controller.openDrawer,
                icon: const Icon(
                  FontAwesomeIcons.bars,
                  size: 22,
                )),
            actions: [
              IconButton(
                  onPressed: () {
                    controller.toggleViewMode();
                  },
                  icon: Obx(() => Icon(
                        controller.view.value == viewMode.list
                            ? FontAwesomeIcons.tableList
                            : FontAwesomeIcons.tableCellsLarge,
                        size: 22,
                      )))
            ],
          ),
          drawerScrimColor: Colors.transparent,
          drawer: const MainDrawer(),
          body: GetBuilder<HomeController>(
            init: controller,
            global: false,
            builder: (value) {
              if(value.reminderList.isEmpty){
                return emptyScreen('No Medicine Found');
              }else{
                return ListView.builder(
                  controller: value.controller,
                  itemCount: value.reminderList.length,
                  itemBuilder: (context, index) {
                    return Obx(()=>ReminderCard(
                      mode: controller.view.value,
                      reminder: value.reminderList[index],
                      onTap: () {
                        print('he he');
                      },
                    ));
                  },
                );
              }

            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF172B4D),
            child: const Icon(
              Icons.add,
              size: 40,
              color: Colors.white,
            ),
            onPressed: () {
              Get.to(()=> MedicineDbPage());
            },
          ),
        ),
      ),
    );
  }
}
