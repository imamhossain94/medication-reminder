import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medication_reminder/models/medicine.dart';
import 'package:sizer/sizer.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  const MedicineCard({Key? key, required this.medicine}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      child: Material(
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: () {

          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 15.w,
                  width: 15.w,
                  padding: const EdgeInsets.all(5.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8.0)
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.table,
                    color: Colors.white,
                    size: 15.sp,
                  ),
                ),
                const SizedBox(width: 15,),
                Expanded(
                  child: SizedBox(
                    //width: screenWidth-107,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('${medicine.brandName!} (${medicine.strength!})', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),),
                        //SizedBox(height: 2,),
                        //Text(medicine.strength!, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign:TextAlign.justify, style: TextStyle(fontSize: 9.sp),),
                        const Divider(),
                        Text('Pack price: ${medicine.price}৳ • ${medicine.packsize}', style: TextStyle(fontSize: 9.sp),)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        color: Colors.transparent,
      ),
      //height: 76,
      width: screenWidth-16,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(8.0)
      ),
    );
  }
}
