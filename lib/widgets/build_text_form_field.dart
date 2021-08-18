import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class BuildTextFormField extends StatelessWidget {
  BuildTextFormField({
    Key? key,
    required this.text,
    this.controller,
    this.isPassword = false,
    this.readOnly = false,
    this.type = TextInputType.text,
    this.maxlines = 1,
    this.prefixicon,
    this.suffixicon,
    this.ontap,
    this.maxlength,
    this.minlines,
    this.validator,
  }) : super(key: key);

  final Color primary = '3546AB'.toColor();
  final String text;
  final bool isPassword, readOnly;
  final TextInputType type;
  final int? maxlines, minlines;
  final TextEditingController? controller;
  final Icon? prefixicon, suffixicon;
  final Function()? ontap;
  final int? maxlength;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: maxlength,
      readOnly: this.readOnly,
      controller: this.controller,
      onTap: this.ontap,
      validator: this.validator,
      maxLines: this.maxlines,
      obscureText: this.isPassword,
      cursorColor: this.primary,
      keyboardType: this.type,
      textInputAction: TextInputAction.next,
      minLines: minlines,
      style: TextStyle(fontFamily: "ProductSans", fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: this.text,
        alignLabelWithHint: true,
        labelStyle:
            TextStyle(fontFamily: "ProductSans", fontWeight: FontWeight.w700),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: primary, width: 3),
            borderRadius: BorderRadius.circular(5)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primary, width: 3),
            borderRadius: BorderRadius.circular(5)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primary, width: 3),
            borderRadius: BorderRadius.circular(5)),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 3),
            borderRadius: BorderRadius.circular(5)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 3),
            borderRadius: BorderRadius.circular(5)),
        prefixIcon: this.prefixicon,
        suffixIcon: this.suffixicon,
      ),
    );
  }
}
