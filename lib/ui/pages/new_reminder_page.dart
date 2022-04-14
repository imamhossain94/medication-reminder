import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';
import '../../utils/constants.dart';
import '../components/build_text_field.dart';

class NewReminderPage extends StatelessWidget {
  NewReminderPage({Key? key}) : super(key: key);

  final controller = Get.put(ReminderController(), permanent: false);

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
                textController: controller.medicineNameTextController,
                textInputType: TextInputType.text,
              ),
              BuildTextField(
                title: 'Strength',
                hint: '120',
                symbol: 'mg/ml',
                textController: controller.medicineStrengthTextController,
                textInputType: TextInputType.number,
              ),

              Container(
                  margin: const EdgeInsets.all(7),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Form', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                  Text('Select Medicine Type', style: TextStyle(fontSize: 16),)
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 40,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: SvgPicture.asset(
                                emptySvg,
                                color: const Color(0xFF172B4D),
                                semanticsLabel: controller.medicine!.form
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        //padding: const EdgeInsets.all(8),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 70,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: medicineForms.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.all(5),
                                  height: 60,
                                  width: 60,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: SvgPicture.asset(
                                      medicineForms[index]['path']!,
                                      color: const Color(0xFF172B4D),
                                      semanticsLabel: controller.medicine!.form
                                  ),
                                );
                              }
                          ),
                        ),
                      )
                    ],
                  )
              ),


            ],
          ),
        ),
      ),
    );
  }
}
