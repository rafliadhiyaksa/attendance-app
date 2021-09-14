import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:presensi_app/provider/presensi.dart';
import 'package:provider/provider.dart';
import 'package:supercharged/supercharged.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:intl/intl.dart';

import 'package:presensi_app/service/camera_service.dart';
import 'package:presensi_app/service/face_recognition_service.dart';
import 'package:presensi_app/service/ml_kit_service.dart';
import 'package:presensi_app/widgets/face_painter.dart';

class PresensiPage extends StatefulWidget {
  final CameraDescription cameraDescription;
  final predictedUser;

  const PresensiPage({
    Key? key,
    required this.cameraDescription,
    required this.predictedUser,
  }) : super(key: key);

  @override
  _PresensiPageState createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  final Color primary = '3546AB'.toColor();
  bool isInit = true;

  String? imagePath;
  Face? faceDetected;

  late Size _imageSize;
  Size get imageSize => this._imageSize;

  bool _detectingFaces = false;
  bool pictureTaked = false;

  late Future _initializeControllerFuture;
  bool cameraInitialized = false;

  bool _saving = false;
  bool _buttonClicked = false;

  Map<String, dynamic> _predictedKaryawan = {};
  Map<String, dynamic> get predictedKaryawan => _predictedKaryawan;
  //service injection
  MLKitService _mlKitService = MLKitService();
  CameraService _cameraService = CameraService();
  FaceRecognitionService _faceRecognitionService = FaceRecognitionService();

  @override
  void initState() {
    super.initState();

    ///start kamera & mulai framing wajah
    _start();
  }

  @override
  void didChangeDependencies() async {
    try {
      if (isInit) {
        await Provider.of<Presensi>(context, listen: false).getSetting();
        await Provider.of<Presensi>(context, listen: false)
            .getPresensi(widget.predictedUser.idKaryawan);
      }
      isInit = false;
    } catch (e) {
      throw e;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    this._faceRecognitionService.setCurrFaceData(null);
    _cameraService.dispose();
    super.dispose();
  }

  ///mulai kamera dan mulai framing wajah
  _start() async {
    try {
      _initializeControllerFuture =
          _cameraService.startService(widget.cameraDescription);
      await _initializeControllerFuture;
      setState(() {
        cameraInitialized = true;
      });
      _frameFaces();
    } catch (e) {
      throw e;
    }
  }

  ///ngehandle ketika tombol capture ditekan
  Future<bool> onShoot() async {
    if (faceDetected == null) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Tidak ada wajah yang terdeteksi'),
            );
          });
      return false;
    } else {
      _saving = true;
      await Future.delayed(Duration(milliseconds: 500));
      await _cameraService.cameraController!.stopImageStream();
      await Future.delayed(Duration(milliseconds: 200));
      XFile file = await _cameraService.takePicture();
      imagePath = file.path;

      setState(() {
        pictureTaked = true;
        imagePath = file.path;
      });
      return true;
    }
  }

  ///membuat bounding box ketika mendeteksi wajah
  _frameFaces() {
    _imageSize = _cameraService.getImageSize();

    _cameraService.cameraController!.startImageStream((image) async {
      if (_cameraService.cameraController != null) {
        if (_detectingFaces) return;

        _detectingFaces = true;

        try {
          List<Face> faces = await _mlKitService.getFacesFromImage(image);

          if (faces.length > 0) {
            setState(() {
              faceDetected = faces[0];
            });

            if (_saving) {
              _faceRecognitionService.setCurrentPrediction(
                  image, faceDetected!);
              setState(() {
                _saving = false;
              });
            }
          } else {
            setState(() {
              faceDetected = null;
            });
          }
          _detectingFaces = false;
        } catch (e) {
          print(e);
          _detectingFaces = false;
        }
      }
    });
  }

  dynamic _predictUser() {
    dynamic karyawan = _faceRecognitionService.predict();
    return karyawan ?? null;
  }

  _reload() {
    setState(() {
      cameraInitialized = false;
      pictureTaked = false;
      _buttonClicked = false;
    });
    // this._start();
  }

  void _warning(String title, String message) {
    AlertController.show(
      title,
      message,
      TypeAlert.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    final presensiProvider = Provider.of<Presensi>(context, listen: false);
    final double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: FaIcon(FontAwesomeIcons.arrowLeft),
            color: Colors.black,
            iconSize: 25,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: buildText("Presensi", 24, Colors.black)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ]),
                width: width * 0.90,
                height: height * 0.55,
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (pictureTaked) {
                        return Transform(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image.file(File(imagePath!)),
                          ),
                          transform: Matrix4.rotationY(mirror),
                        );
                      } else {
                        return Transform.scale(
                          scale: 1.0,
                          child: AspectRatio(
                            aspectRatio:
                                MediaQuery.of(context).size.aspectRatio,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: Container(
                                width: width,
                                height: width *
                                    _cameraService
                                        .cameraController!.value.aspectRatio,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CameraPreview(
                                        _cameraService.cameraController!),
                                    CustomPaint(
                                      painter: FacePainter(
                                        face: faceDetected,
                                        imageSize: imageSize,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ),

          /// waktu presensi
          TimerBuilder.periodic(Duration(seconds: 1), builder: (context) {
            final now = DateTime.now();
            final String getSystemTime = DateFormat("HH:mm:ss").format(now);
            return buildText(getSystemTime, 35, Colors.green);
          }),

          ///bottom button
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ///tombol informasi
                IconButton(
                  onPressed: () {},
                  icon: FaIcon(
                    FontAwesomeIcons.infoCircle,
                    size: 30,
                  ),
                ),

                ///tombol capture
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(20),
                    primary: !_buttonClicked ? primary : Colors.green,
                    enableFeedback: true,
                    shape: CircleBorder(),
                  ),
                  child: Container(
                    child: !_buttonClicked
                        ? Image(
                            image: AssetImage('assets/icon/face-id.png'),
                            width: 30,
                          )
                        : FaIcon(FontAwesomeIcons.check,
                            size: 25, color: Colors.white),
                  ),
                  onPressed: () async {
                    if (!_buttonClicked) {
                      try {
                        await _initializeControllerFuture;
                        bool isFaceDetected = await onShoot();
                        if (isFaceDetected) {
                          setState(() {
                            _buttonClicked = !_buttonClicked;
                          });
                          dynamic user = _predictUser();
                          print(user['status']);
                          if (user != null) {
                            //presensi
                            List dataSetting = presensiProvider.dataSetting;
                            List dataPresensi = presensiProvider.dataPresensi;

                            DateTime now = DateTime.now();
                            DateFormat dateFormat = new DateFormat('HH:mm:ss');
                            DateTime start =
                                dateFormat.parse(dataSetting[0].mulaiPresensi);
                            start = new DateTime(now.year, now.month, now.day,
                                start.hour, start.minute, start.second);
                            DateTime end =
                                dateFormat.parse(dataSetting[0].batasPresensi);
                            end = new DateTime(now.year, now.month, now.day,
                                end.hour, end.minute, end.second);
                            DateTime goHome =
                                dateFormat.parse(dataSetting[0].presensiPulang);
                            goHome = new DateTime(now.year, now.month, now.day,
                                goHome.hour, goHome.minute, goHome.second);
                            // print(dateFormat.format(open));
                            if (now.isBetween(start, end)) {
                              print("presensi masuk");
                              presensiProvider.presensiMasuk(
                                idKaryawan: widget.predictedUser.idKaryawan,
                              );
                            } else if (now.isAfter(end)) {
                              var tanggal =
                                  DateFormat('yyyy-MM-dd').format(now);
                              var data = dataPresensi.where(
                                  (element) => element.tanggal == tanggal);

                              if (data.isNotEmpty) {
                                if (now.isAfter(goHome)) {
                                  print("presensi pulang");
                                  int index = dataPresensi.indexWhere(
                                      (element) => element.tanggal == tanggal);
                                  presensiProvider.presensiPulang(
                                      dataPresensi[index].idPresensi);
                                } else {
                                  _warning("Warning",
                                      "Belum Saatnya Presensi Pulang");
                                }
                              } else {
                                _warning("Warning",
                                    "Anda Belum Melakukan Presensi Masuk");
                              }
                            } else if (now.isBefore(start)) {
                              _warning("Warning", "Belum Saatnya Presensi");
                            }
                          } else {
                            print("Wajah Tidak Sesuai");
                            setState(() {
                              _buttonClicked = !_buttonClicked;
                            });
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Text('Wajah Belum Terdaftar'),
                                );
                              },
                            );
                          }
                        }
                      } catch (e) {
                        print(e);
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),

                ///tombol refresh
                IconButton(
                  onPressed: () {
                    _reload();
                    _start();
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.syncAlt,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
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
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
