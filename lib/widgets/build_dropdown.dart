import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class BuildDropdown extends StatelessWidget {
  BuildDropdown({
    Key? key,
    required this.items,
    required this.label,
    this.onchanged,
    this.value,
  }) : super(key: key);

  final List<DropdownMenuItem<Object>>? items;
  final String label;
  final Function(Object?)? onchanged;
  final Color primary = '3546AB'.toColor();
  final Object? value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      value: value,
      items: items,
      isExpanded: true,
      onChanged: onchanged,
      validator: (value) => value == null ? "Required*" : null,
      style: TextStyle(
        fontFamily: "ProductSans",
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        fillColor: Colors.grey.shade200,
        filled: true,
        labelStyle:
            TextStyle(fontFamily: "ProductSans", fontWeight: FontWeight.w700),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primary, width: 3),
            borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primary, width: 3),
            borderRadius: BorderRadius.circular(15)),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 3),
            borderRadius: BorderRadius.circular(15)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 3),
            borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
