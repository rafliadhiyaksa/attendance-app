import 'package:flutter/material.dart';

import 'package:presensi_app/service/face_recognition_service.dart';
import 'package:presensi_app/view/home_page.dart';
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

  Map<String, dynamic>? predictedKaryawan;

  dynamic _predictKaryawan() {
    dynamic karyawan = _faceRecognitionService.predict();
    return karyawan ?? null;
  }

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
              if (widget.isLogin) {
                dynamic karyawan = _predictKaryawan();

                if (karyawan != null) {
                  predictedKaryawan = karyawan;
                } else {
                  print("tidak ada prediksi wajah");
                }
              }
            }
          } catch (e) {
            //jika error akan diprint ke konsol
            print(e);
          }
        } else {
          if (widget.isLogin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => HomePage(predictedKaryawan!),
              ),
            );
          } else {
            Navigator.pop(context);
          }
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
}
