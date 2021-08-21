import 'package:flutter/material.dart';

import 'package:presensi_app/service/face_recognition_service.dart';
import 'package:supercharged/supercharged.dart';

class AuthActionButton extends StatefulWidget {
  final Future _initializeControllerFuture;
  final Function onPressed;
  final Function? reload;
  final bool isLogin;

  AuthActionButton(
    this._initializeControllerFuture, {
    Key? key,
    required this.onPressed,
    required this.isLogin,
    this.reload,
  }) : super(key: key);

  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  /// service injection
  final FaceRecognitionService _faceRecognitionService =
      FaceRecognitionService();

  bool _buttonClicked = false;
  final Color primary = '3546AB'.toColor();

  _faceRegistration(context) {
    List? predictedData = _faceRecognitionService.predictedData;

    print(predictedData!.length);
    print(predictedData);

    Navigator.of(context).pop();
  }

  // _login(context) {}

  // String? _predictUser() {
  //   String? user = _faceRecognitionService.predict();
  //   return user ?? null;
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (!_buttonClicked) {
          try {
            //memastikan kamera telah diinisialisasi
            await widget._initializeControllerFuture;
            //onshoot event (ambil gambar dan memprediksi output)
            bool faceDetected = await widget.onPressed();

            if (faceDetected) {
              setState(() {
                _buttonClicked = !_buttonClicked;
              });
              // if (widget.isLogin) {
              //   var user = _predictUser();
              //   if (user != null) {}
              // }
            }
          } catch (e) {
            //jika error akan diprint ke konsol
            print(e);
          }
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: !_buttonClicked ? primary : Colors.green,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 60,
        child:
            buildText(!_buttonClicked ? "Capture" : "Done", 20, Colors.white),
      ),
    );
  }

  Text buildText(String text, double size, Color color) {
    return Text(
      text,
      style: TextStyle(
          color: color,
          fontFamily: "ProductSans",
          fontSize: size,
          fontWeight: FontWeight.w700),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
