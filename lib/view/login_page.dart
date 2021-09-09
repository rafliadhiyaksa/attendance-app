import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:supercharged/supercharged.dart';

import 'package:presensi_app/service/face_recognition_service.dart';
import 'package:presensi_app/service/ml_kit_service.dart';
import 'package:presensi_app/view/face_login.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //Service Injection
  FaceRecognitionService _faceRecognitionService = FaceRecognitionService();
  MLKitService _mlKitService = MLKitService();

  CameraDescription? _cameraDescription;
  CameraDescription? get cameraDescription => _cameraDescription;

  bool loading = false;
  Color primary = '3546AB'.toColor();

  @override
  void initState() {
    super.initState();
    _startUp();
  }

  //menentukan kamera yang tersedia di device dan meload model facenet
  _startUp() async {
    _setLoading(true);

    List<CameraDescription> cameras = await availableCameras();

    // menggunakan kamera depan
    _cameraDescription = cameras.firstWhere((CameraDescription camera) =>
        camera.lensDirection == CameraLensDirection.front);

    //mulai service
    await _faceRecognitionService.loadModel();
    _mlKitService.initialize();

    _setLoading(false);
  }

  //show / hide loading logo
  _setLoading(bool value) {
    setState(() {
      loading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomheight = MediaQuery.of(context).size.height * 0.35;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: primary,
      body: !loading
          ? ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
              child: Container(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    //BACKGROUND IMAGE
                    Column(
                      children: [
                        SizedBox(
                          height: bottomheight / 3,
                        ),
                        Image.asset(
                          'assets/img/illustration2.png',
                          width: width * 0.90,
                        ),
                        SizedBox(
                          height: bottomheight / 3,
                        ),
                        buildText("Attendance", 35, Colors.white),
                        buildText(
                            "CV. Destinasi Computindo", 18.0, Colors.white),
                        Spacer(),
                      ],
                    ),
                    //CONTENT
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: bottomheight,
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            right: 15, left: 15, bottom: 15),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.16),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3))
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildText("Login Karyawan", 25.0, Colors.black),
                              buildText("Masuk Menggunakan Deteksi Wajah", 15.0,
                                  '878F95'.toColor()),
                              SizedBox(
                                height: bottomheight / 9,
                              ),
                              Container(
                                height: bottomheight / 3.5,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            FaceLogin(
                                                cameraDescription:
                                                    cameraDescription!),
                                      ),
                                    );
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image(
                                        image: AssetImage(
                                            'assets/icon/face-id.png'),
                                        width: 40,
                                      ),
                                      buildText(
                                          "Scan to Login", 25, Colors.white),
                                      // Icon(Icons.login_rounded)
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: bottomheight / 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buildText(
                                      "Tidak Punya Akun? ", 15.0, Colors.black),
                                  InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            'registration',
                                            arguments: cameraDescription);
                                      },
                                      child: buildText("Daftar Sekarang", 15.0,
                                          "#3546AB".toColor())),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Text buildText(String text, double size, Color color) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: size),
    );
  }
}
