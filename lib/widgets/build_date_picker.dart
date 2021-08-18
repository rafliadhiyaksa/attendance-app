import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class BuildDatePickerTextField extends StatefulWidget {
  @override
  _BuildDatePickerTextFieldState createState() =>
      _BuildDatePickerTextFieldState();
}

class _BuildDatePickerTextFieldState extends State<BuildDatePickerTextField> {
  Color primary = '3546AB'.toColor();

  final dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: dateController,
      onTap: () async {
        var date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1960),
          lastDate: DateTime.now(),
        );
        dateController.text = date.toString().substring(0, 10);
      },
      readOnly: true,
      cursorColor: primary,
      textInputAction: TextInputAction.next,
      style: TextStyle(fontFamily: "ProductSans", fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: "Tanggal Lahir",
        labelStyle:
            TextStyle(fontFamily: "ProductSans", fontWeight: FontWeight.w700),
        suffixIcon: Icon(Icons.date_range_rounded),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primary, width: 3),
            borderRadius: BorderRadius.circular(5)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primary, width: 3),
            borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}
