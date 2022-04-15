import 'package:flutter/material.dart';

class BuildTextField extends StatelessWidget {
  final String? title, hint, symbol;
  final TextInputType textInputType;
  final TextEditingController? textController;

  const BuildTextField({Key? key,
    required this.title,
    required this.hint,
    required this.textController,
    required this.symbol, required this.textInputType,}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.all(7),
      //height: 60,
      alignment: Alignment.centerLeft,
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
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.only(left: 8,),
        //height: 44,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                title!,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8,),
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                          enabled: true,
                          controller: textController,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            prefix: const SizedBox(
                              width: 8,
                            ),
                            border: InputBorder.none,
                            hintText: hint,
                          ),
                          keyboardType: textInputType,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          obscureText: false,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 5,),
                    Text(
                      symbol??'',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
