import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:presensi_app/provider/karyawan.dart';
import 'package:presensi_app/service/camera_service.dart';
import 'package:presensi_app/service/face_recognition_service.dart';
import 'package:presensi_app/service/ml_kit_service.dart';
import 'package:presensi_app/widgets/error_bottom_sheet.dart';
import 'package:presensi_app/widgets/face_painter.dart';
import 'package:provider/provider.dart';
import 'package:supercharged/supercharged.dart';

class FaceLogin extends StatefulWidget {
  final CameraDescription cameraDescription;

  const FaceLogin({
    Key? key,
    required this.cameraDescription,
  }) : super(key: key);

  @override
  _FaceLoginState createState() => _FaceLoginState();
}

class _FaceLoginState extends State<FaceLogin> {
  final Color primary = '3546AB'.toColor();
  bool isInit = true;
  bool isLoading = true;

  String? imagePath;
  Face? faceDetected;

  Size _imageSize = Size(0, 0);
  Size get imageSize => this._imageSize;

  bool _detectingFaces = false;
  bool pictureTaked = false;
  bool facePredicted = false;

  bool isLogin = false;

  late Future _initializeControllerFuture;
  bool cameraInitialized = false;

  //service injection
  MLKitService _mlKitService = MLKitService();
  CameraService _cameraService = CameraService();
  FaceRecognitionService _faceRecognitionService = FaceRecognitionService();

  ErrorBottomSheet _errorBottomSheet = ErrorBottomSheet();

  @override
  void initState() {
    super.initState();

    ///start kamera & mulai framing wajah
    _start();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      Provider.of<Karyawan>(context, listen: true).getDataWajah().then((value) {
        setState(() {
          isLoading = false;
        });
        _frameFaces();
      }).catchError((err) {
        print(err);
        return _errorBottomSheet.errorBottomSheet(
            context: context,
            onPressedRetry: () {
              isInit = true;
            });
      });
    }
    isInit = false;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _cameraService.dispose();

    // hapus data wajah yang baru saja terdeteksi
    this._faceRecognitionService.setCurrFaceData([]);

    super.dispose();
  }

  ///mulai kamera dan mulai framing wajah
  _start() async {
    _initializeControllerFuture =
        _cameraService.startService(widget.cameraDescription);
    await _initializeControllerFuture;
    setState(() {
      cameraInitialized = true;
    });
  }

  /// membuat bounding box ketika mendeteksi wajah dan mendapatkan data wajah
  /// selanjutnya memprediksi wajah dengan membandingkan data wajah sekarang dg data wajah pada db
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
            setState(() {
              faceDetected = faces[0];
            });
            final karyawanProvider =
                Provider.of<Karyawan>(context, listen: false);
            if (karyawanProvider.dataWajah.length != 0) {
              // Future.delayed(Duration(milliseconds: 500), () {});
              _faceRecognitionService.setCurrentPrediction(
                  image, faceDetected!);
              dynamic idKaryawan = _predictUser();
              if (idKaryawan != null) {
                setState(() {
                  isLogin = true;
                });
                await _cameraService.cameraController.stopImageStream();
                try {
                  karyawanProvider.getKaryawan(idKaryawan).then((value) {
                    karyawanProvider.setDataWajah([]);
                    karyawanProvider.saveDataToPref().then((value) =>
                        Navigator.pushNamedAndRemoveUntil(
                            context, 'navigation-bar', (route) => false));
                  });
                } catch (err) {
                  print(err);
                }
              }
              // else {
              //   await _cameraService.cameraController.stopImageStream();
              //   errorShowDialog(context, content: "Wajah Anda Belum Terdaftar",
              //       onPressed: () {
              //     _frameFaces();
              //     Navigator.pop(context);
              //   });

              //   setState(() {
              //     isLogin = false;
              //   });
              // }
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
    dynamic user = _faceRecognitionService.predict();
    return user ?? null;
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
            iconSize: 20,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: buildText("Face Login", 20, Colors.black)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                  width: width * 0.90,
                  height: height * 0.70,
                  child: !isLoading
                      ? isLogin
                          ? Container(
                              alignment: Alignment.center,
                              color: Colors.green,
                              child: FaIcon(
                                FontAwesomeIcons.solidCheckCircle,
                                size: 70,
                                color: Colors.white,
                              ),
                            )
                          : FutureBuilder<void>(
                              future: _initializeControllerFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Transform.scale(
                                    scale: 1.0,
                                    child: AspectRatio(
                                      aspectRatio: MediaQuery.of(context)
                                          .size
                                          .aspectRatio,
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: Container(
                                          width: width,
                                          height: width *
                                              _cameraService.cameraController
                                                  .value.aspectRatio,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              CameraPreview(_cameraService
                                                  .cameraController),
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
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                              },
                            )
                      : Center(child: CircularProgressIndicator())),
            ),
          ),
          buildText(isLogin ? "Verified" : "Scanning...", 20,
              isLogin ? Colors.green : Colors.black),
        ],
      ),
    );
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
