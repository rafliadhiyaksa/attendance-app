import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:presensi_app/service/camera_service.dart';
import 'package:presensi_app/service/face_recognition_service.dart';
import 'package:presensi_app/service/ml_kit_service.dart';
import 'package:presensi_app/widgets/auth_action_button.dart';
import 'package:presensi_app/widgets/face_painter.dart';
import 'package:presensi_app/widgets/navigation_bar.dart';
import 'package:supercharged/supercharged.dart';

class LoginDetection extends StatefulWidget {
  final CameraDescription cameraDescription;

  const LoginDetection({
    Key? key,
    required this.cameraDescription,
  }) : super(key: key);

  @override
  _LoginDetectionState createState() => _LoginDetectionState();
}

class _LoginDetectionState extends State<LoginDetection> {
  final Color primary = '3546AB'.toColor();

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

  Map<String, dynamic>? predictedKaryawan;

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
  void dispose() {
    this._faceRecognitionService.setPredictedData(null);
    _cameraService.dispose();
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

    _frameFaces();
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

  dynamic _predictKaryawan() {
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

  @override
  Widget build(BuildContext context) {
    final double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            color: Colors.black,
            iconSize: 35,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: buildText("Face Login", 24, Colors.black)),
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
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ///tombol informasi
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.info_outline_rounded,
                    size: 30,
                  ),
                ),

                ///tombol capture
                ElevatedButton(
                  child: Container(
                      child: !_buttonClicked
                          ? Image(
                              image: AssetImage('assets/icon/face-id.png'),
                              width: 25,
                            )
                          : Icon(Icons.done_rounded,
                              size: 25, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(20),
                    primary: !_buttonClicked ? primary : Colors.green,
                    enableFeedback: true,
                    shape: CircleBorder(),
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
                          dynamic karyawan = _predictKaryawan();
                          if (karyawan != null) {
                            predictedKaryawan = karyawan;
                            print(predictedKaryawan);
                          } else {
                            print("tidak ada prediksi wajah");
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              NavigationBar(predictedKaryawan!),
                        ),
                      );
                    }
                  },
                ),

                ///tombol refresh
                IconButton(
                  onPressed: () {
                    _reload();
                    _start();
                  },
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   height: height * 0.16,
          //   alignment: Alignment.center,
          //   child: AuthActionButton(
          //     _initializeControllerFuture,
          //     onPressed: onShoot,
          //     isLogin: true,
          //     reload: _reload,
          //   ),
          // ),
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
