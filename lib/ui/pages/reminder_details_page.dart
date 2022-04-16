import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medication_reminder/models/reminder.dart';
import 'package:sizer/sizer.dart';

import '../../services/hive_helper.dart';
import '../../utils/constants.dart';
import '../../utils/extensions.dart';
import '../components/medicine_card.dart';

class ReminderDetailsPage extends StatelessWidget {
  final Reminder reminder;

  const ReminderDetailsPage({Key? key, required this.reminder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    possibleRemindTime();

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
              "Reminder Details",
              style: Theme.of(context).textTheme.headline3,
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    removeReminder(reminder);
                  },
                  icon: const Icon(
                    FontAwesomeIcons.trash,
                    size: 22,
                  ))
            ],
          ),
          body: Column(
            children: [
              MedicineCard(
                medicine: reminder.medicine,
                onTap: null,
              ),
              Row(
                children: [
                  item('Name', reminder.medicine.brandName),
                  item('Strength', reminder.medicine.strength),
                ],
              ),
              Row(
                children: [
                  item('Price', '${reminder.medicine.price}৳'),
                  item('Pack Size', reminder.medicine.packsize),
                ],
              ),
              Row(
                children: [
                  item('Form', reminder.medicine.form),
                  item('Reminder', 'Every ${reminder.interval} hours'),
                ],
              ),
              Row(
                children: [
                  item('Start Time', reminder.startTime),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 40,
                            child: FutureBuilder<List<String>>(
                              future: possibleRemindTime(), // async work
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<String>> snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return const CircularProgressIndicator();
                                  default:
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: snapshot.data!.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 15),
                                              margin: EdgeInsets.fromLTRB(index==0?0:5, 5, index == snapshot.data!.length?5:0, 5),
                                              decoration: BoxDecoration(
                                                  color:
                                                      scaffoldBackgroundLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              child: Text(snapshot.data![index],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            );
                                          });
                                    }
                                }
                              },
                            ),
                          ),
                          const Divider(),
                          Text(
                            'Possible Remind Time',
                            style: TextStyle(fontSize: 11.sp),
                          )
                        ],
                      ),
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget item(String title, String value) {
    return Expanded(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text(
              title,
              style: TextStyle(fontSize: 11.sp),
            )
          ],
        ),
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  Future<List<String>> possibleRemindTime() async {
    List<String> times = [];

    String time =
        time12to24Format(reminder.startTime).trim().replaceAll(':', '');
    var hour = int.parse(time[0] + time[1]);
    var ogValue = hour;
    var minute = int.parse(time[2] + time[3]);
    for (int i = 0; i < (24 / reminder.interval).floor(); i++) {
      if ((hour + (reminder.interval * i) > 23)) {
        hour = hour + (reminder.interval * i) - 24;
      } else {
        hour = hour + (reminder.interval * i);
      }
      DateTime tempDate = DateFormat("hh:mm").parse('$hour:$minute');
      times.add(DateFormat("h:mm a").format(tempDate));
      hour = ogValue;
    }

    return times;
  }
}
