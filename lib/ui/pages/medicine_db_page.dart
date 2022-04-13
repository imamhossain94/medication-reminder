import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';
import '../../utils/constants.dart';
import '../components/medicine_card.dart';

class MedicineDbPage extends StatelessWidget {
  MedicineDbPage({Key? key}) : super(key: key);

  final controller = Get.put(MedicineDbController(), permanent: false);

  @override
  Widget build(BuildContext context) {



    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: mainPageSystemOverlay(Theme.of(context).brightness),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.5,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
            titleSpacing: 0,
            title: Text(
              "Medicine Database",
              style: Theme.of(context).textTheme.headline3,
            ),
            //centerTitle: true,
            // leading: IconButton(
            //     onPressed: controller.openDrawer,
            //     icon: const Icon(
            //       FontAwesomeIcons.bars,
            //       size: 22,
            //     )),
            actions: [
              IconButton(
                  onPressed: () {
                    // controller.toggleViewMode();
                  },
                  icon: const Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 22,
                  ))
            ],
          ),
          body: GetBuilder<MedicineDbController>(
            init: controller,
            global: false,
            builder: (value) => ListView.builder(
              controller: value.controller,
              itemCount: value.medicineList.length,
              itemBuilder: (context, index) {
                return MedicineCard(medicine: value.medicineList[index]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
