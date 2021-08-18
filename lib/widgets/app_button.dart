import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final Color color;
  final double width;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = const Color.fromRGBO(53, 70, 171, 1.0),
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed(),
      child: Container(
        alignment: Alignment.center,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(5), color: color),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: width,
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
