import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:provider/provider.dart';
import 'package:supercharged/supercharged.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:intl/intl.dart';

import '../provider/presensi.dart';
import '../provider/karyawan.dart';
import '../service/camera_service.dart';
import '../service/face_recognition_service.dart';
import '../service/ml_kit_service.dart';
import '../widgets/face_painter.dart';

class PresensiPage extends StatefulWidget {
  final CameraDescription cameraDescription;

  const PresensiPage({
    Key? key,
    required this.cameraDescription,
  }) : super(key: key);

  @override
  _PresensiPageState createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  final Color primary = '3546AB'.toColor();
  bool isInit = true;

  Face? faceDetected;

  Size _imageSize = Size(0, 0);
  Size get imageSize => this._imageSize;

  bool _detectingFaces = false;

  late Future _initializeControllerFuture;
  bool cameraInitialized = false;

  bool isResponseDone = false;
  Widget? statusPresensi;

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
    final karyawanProvider = Provider.of<Karyawan>(context, listen: false);
    _faceRecognitionService
        .setPredictedData(karyawanProvider.dataKaryawan.dataWajah);
    try {
      if (isInit) {
        await Provider.of<Presensi>(context, listen: false).getSetting();
        await Provider.of<Presensi>(context, listen: false).getPresensi();
      }
      isInit = false;
    } catch (e) {
      throw e;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _faceRecognitionService.dispose();
    _faceRecognitionService.setCurrFaceData([]);
    _mlKitService.close();
    super.dispose();
  }

  ///mulai kamera dan mulai framing wajah
  _start() async {
    try {
      _initializeControllerFuture =
          _cameraService.startService(widget.cameraDescription);
      await _initializeControllerFuture;
      if (!mounted) return;
      setState(() {
        cameraInitialized = true;
      });
      _frameFaces();
    } catch (e) {
      throw e;
    }
  }

  ///membuat bounding box ketika mendeteksi wajah
  _frameFaces() {
    _imageSize = _cameraService.getImageSize();

    _cameraService.cameraController.startImageStream((image) async {
      if (_cameraService.cameraController !=
          CameraController(
              CameraDescription(
                  name: "Presensi Camera",
                  lensDirection: CameraLensDirection.front,
                  sensorOrientation: 0),
              ResolutionPreset.high)) {
        if (_detectingFaces) return;

        _detectingFaces = true;

        try {
          List<Face> faces = await _mlKitService.getFacesFromImage(image);

          if (faces.length > 0) {
            if (!mounted) return;
            setState(() {
              faceDetected = faces[0];
            });
            Future.delayed(Duration(milliseconds: 500), () {
              _faceRecognitionService.setCurrentPrediction(
                  image, faceDetected!);
            });
            dynamic karyawan = _predictUser();
            if (karyawan['status'] == 1) {
              print("build");
              Widget widget = presensiCondition();

              setState(() {
                statusPresensi = widget;
              });

              await _cameraService.cameraController.stopImageStream();
            } else {
              print("WAJAH TIDAK SESUAI");
            }
          } else {
            if (!mounted) return;
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
    _start();
    setState(() {
      cameraInitialized = false;
      statusPresensi = null;
      isResponseDone = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    offset: Offset(0, 3),
                  ),
                ]),
                width: width * 0.90,
                height: height * 0.60,
                child: statusPresensi != null
                    ? statusPresensi
                    : FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
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
                                            .cameraController.value.aspectRatio,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CameraPreview(
                                            _cameraService.cameraController),
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

                ///tombol refresh
                IconButton(
                  onPressed: () {
                    _reload();
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

  Widget presensiStatus({Color? color, IconData? icon, String text = ""}) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FaIcon(
            icon,
            size: 60,
            color: Colors.white,
          ),
          SizedBox(
            height: 10,
          ),
          Center(child: buildText(text, 15, Colors.white))
        ],
      ),
    );
  }

  Widget presensiCondition() {
    final presensiProvider = Provider.of<Presensi>(context, listen: false);
    List dataSetting = presensiProvider.dataSetting;
    List dataPresensi = presensiProvider.dataPresensi;

    DateTime now = DateTime.now();
    DateFormat dateFormat = new DateFormat('HH:mm:ss');
    DateTime start = dateFormat.parse(dataSetting[0].mulaiPresensi);
    start = new DateTime(
        now.year, now.month, now.day, start.hour, start.minute, start.second);
    DateTime end = dateFormat.parse(dataSetting[0].batasPresensi);
    end = new DateTime(
        now.year, now.month, now.day, end.hour, end.minute, end.second);
    DateTime goHome = dateFormat.parse(dataSetting[0].presensiPulang);
    goHome = new DateTime(now.year, now.month, now.day, goHome.hour,
        goHome.minute, goHome.second);

    if (now.isBetween(start, end)) {
      presensiProvider.presensiMasuk().then((value) {
        if (presensiProvider.dataResponse['value'] == 1) {
          return presensiStatus(
              color: Colors.green,
              icon: FontAwesomeIcons.solidCheckCircle,
              text: "Presensi Berhasil");
        } else if (presensiProvider.dataResponse['value'] == 2) {
          return presensiStatus(
              color: Colors.orange,
              icon: FontAwesomeIcons.exclamationCircle,
              text: "Sudah Presensi");
        } else {
          return presensiStatus(
              color: Colors.red,
              icon: FontAwesomeIcons.timesCircle,
              text: "Presensi Gagal");
        }
      });
    } else if (now.isAfter(end)) {
      var tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var data = dataPresensi.where((element) => element.tanggal == tanggal);
      if (data.isNotEmpty) {
        if (now.isAfter(goHome)) {
          print("presensi pulang");
          int index =
              dataPresensi.indexWhere((element) => element.tanggal == tanggal);
          presensiProvider
              .presensiPulang(dataPresensi[index].idPresensi)
              .then((value) {
            setState(() {
              isResponseDone = true;
            });
          });

          if (isResponseDone) {
            _detectingFaces = false;
            isResponseDone = false;

            if (presensiProvider.dataResponse['value'] == 1) {
              return presensiStatus(
                  color: Colors.green,
                  icon: FontAwesomeIcons.solidCheckCircle,
                  text: "Presensi Berhasil");
            } else if (presensiProvider.dataResponse['value'] == 2) {
              print("value 2");
              return presensiStatus(
                  color: Colors.red,
                  icon: FontAwesomeIcons.timesCircle,
                  text: "Belum Presensi Masuk");
            } else if (presensiProvider.dataResponse['value'] == 3) {
              print("value 3");

              return presensiStatus(
                  color: Colors.orange,
                  icon: FontAwesomeIcons.exclamationCircle,
                  text: "Sudah Presensi Pulang");
            } else {
              return presensiStatus(
                  color: Colors.red,
                  icon: FontAwesomeIcons.timesCircle,
                  text: "Presensi Pulang Gagal");
            }
          }
          return Center(child: CircularProgressIndicator(color: primary));
        } else {
          return presensiStatus(
              color: Colors.orange,
              icon: FontAwesomeIcons.exclamationCircle,
              text: "Belum Saatnya Presensi Pulang");
        }
      } else {
        return presensiStatus(
            color: Colors.red,
            icon: FontAwesomeIcons.timesCircle,
            text: "Belum Presensi Masuk");
      }
    } else {
      return presensiStatus(
          color: Colors.orange,
          icon: FontAwesomeIcons.exclamationCircle,
          text: "Belum Saatnya Presensi");
    }
    return Container();
  }

  Future<dynamic> errorShowDialog(BuildContext context,
      {required String content, required Function() onPressed}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          content: buildText(content, 15, Colors.black),
          actions: [
            TextButton(
                onPressed: onPressed, child: buildText("OK", 15, primary)),
          ],
        );
      },
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
