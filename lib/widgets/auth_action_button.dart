import 'package:flutter/material.dart';

import 'package:presensi_app/service/face_recognition_service.dart';

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

  _faceRegistration(context) {
    List? predictedData = _faceRecognitionService.predictedData;

    print(predictedData!.length);
    print(predictedData);

    Navigator.of(context).pop();
  }

  _login(context) {}

  String? _predictUser() {
    String? user = _faceRecognitionService.predict();
    return user ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (_buttonClicked == false) {
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

              // PersistentBottomSheetController bottomSheetController =
              //     Scaffold.of(context)
              //         .showBottomSheet((context) => signSheet(context));
              // bottomSheetController.closed.whenComplete(() => widget.reload!());
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
          borderRadius: BorderRadius.circular(10),
          color: !_buttonClicked ? Colors.indigo : Colors.green,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(!_buttonClicked ? "Capture" : "Done",
                style: TextStyle(color: Colors.white)),
            SizedBox(width: 10),
            Icon(Icons.camera_alt_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  signSheet(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              children: [
                Container(
                  child: !widget.isLogin
                      ? buildText("Wajah Anda telah terdeteksi dan terdaftar",
                          20, Colors.black)
                      : null,
                ),
                SizedBox(
                  height: 20,
                ),
                !widget.isLogin
                    ?
                    //TOMBOL
                    Container(
                        height: 50.0,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 10.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            _faceRegistration(context);
                            // Navigator.of(context).pop();
                            // Navigator.of(context).pop();
                          },
                          child: buildText("DONE", 20, Colors.white),
                        ),
                      )
                    : Container(),
              ],
            ),
          )
        ],
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
