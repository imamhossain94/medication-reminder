import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';
import '../../utils/constants.dart';
import '../components/build_text_field.dart';

class NewReminderPage extends StatelessWidget {
  NewReminderPage({Key? key}) : super(key: key);

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
              "Create New Reminder",
              style: Theme.of(context).textTheme.headline3,
            ),
            actions: const [

            ],
          ),
          body: Column(
            children: [
              BuildTextField(
                title: 'Medicine Name',
                hint: 'Napa',
                symbol: null,
                textController: null,
                textInputType: TextInputType.text,
              ),
              BuildTextField(
                title: 'Strength',
                hint: '120',
                symbol: 'mg/ml',
                textController: null,
                textInputType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
