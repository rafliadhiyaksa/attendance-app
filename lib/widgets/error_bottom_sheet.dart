import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:system_settings/system_settings.dart';

class ErrorBottomSheet {
  static final ErrorBottomSheet _errorBottomSheet =
      ErrorBottomSheet._internal();
  factory ErrorBottomSheet() {
    return _errorBottomSheet;
  }
  ErrorBottomSheet._internal();

  Future<dynamic> errorBottomSheet(
      BuildContext context, Function onPressedRetry) {
    Color primary = '3546AB'.toColor();

    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                'assets/img/error.png',
                width: MediaQuery.of(context).size.width * 0.6,
              ),
              Column(
                children: [
                  Text("Connection Failed"),
                  Text("Check Your Internet Connection",
                      style: TextStyle(fontSize: 15)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: 45.0,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          onPressedRetry();
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Retry",
                          style: TextStyle(fontSize: 20),
                        )),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: 45.0,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () => SystemSettings.wireless(),
                        child: Text(
                          "Setting",
                          style: TextStyle(fontSize: 20),
                        )),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      // shape: ,
      enableDrag: false,
      isDismissible: false,
      barrierColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
    );
  }
}
