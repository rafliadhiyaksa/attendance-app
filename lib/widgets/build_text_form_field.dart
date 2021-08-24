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
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsetsDirectional.only(start: 4.0),
          child: Text(
            this.text,
            style: TextStyle(fontSize: 15),
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
          style:
              TextStyle(fontFamily: "ProductSans", fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: this.text,
            alignLabelWithHint: true,
            fillColor: Colors.grey.shade300,
            filled: true,
            labelStyle: TextStyle(
                fontFamily: "ProductSans", fontWeight: FontWeight.w700),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(15)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(15)),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(15)),
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(15)),
            suffixIcon: this.suffixicon,
          ),
        ),
      ],
    );
  }
}
