import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:presensi_app/service/camera_service.dart';
import 'package:presensi_app/service/face_recognition_service.dart';
import 'package:presensi_app/service/ml_kit_service.dart';
import 'package:presensi_app/widgets/auth_action_button.dart';
import 'package:presensi_app/widgets/camera_header.dart';
import 'package:presensi_app/widgets/face_painter.dart';

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
  // Service injection
  CameraService _cameraService = CameraService();
  MLKitService _mlKitService = MLKitService();
  FaceRecognitionService _faceRecognitionService = FaceRecognitionService();

  late Future _initializeControllerFuture;

  bool cameraInitialized = false;
  bool _detectingFaces = false;
  bool pictureTaked = false;

  bool _saving = false;

  String? imagePath;

  late Size _imageSize;
  Size get imageSize => this._imageSize;

  Face? faceDetected;
  bool _bottomSheetVisible = false;

  @override
  void initState() {
    super.initState();

    _start();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  _start() async {
    _initializeControllerFuture =
        _cameraService.startService(widget.cameraDescription);
    await _initializeControllerFuture;

    setState(() {
      cameraInitialized = true;
    });

    _frameFaces();
  }

  /// membuat bounding box ketika mendeteksi wajah
  _frameFaces() {
    _imageSize = _cameraService.getImageSize();

    _cameraService.cameraController!.startImageStream((image) async {
      if (_cameraService.cameraController != null) {
        if (_detectingFaces) return;
        _detectingFaces = true;
        try {
          List<Face> faces = await _mlKitService.getFacesFromImage(image);

          // ignore: unnecessary_null_comparison
          if (faces != null) {
            if (faces.length > 0) {
              setState(() {
                faceDetected = faces[0];
              });
              if (_saving) {
                _saving = false;
                _faceRecognitionService.setCurrentPrediction(
                    image, faceDetected!);
              }
            } else {
              setState(() {
                faceDetected = null;
              });
            }
          }
          _detectingFaces = false;
        } catch (e) {
          print(e);
          _detectingFaces = false;
        }
      }
    });
  }

  Future<bool> onShot() async {
    if (faceDetected == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Tidak ada wajah yang terdeteksi"),
          );
        },
      );
      return false;
    } else {
      _saving = true;

      await Future.delayed(Duration(milliseconds: 500));
      await _cameraService.cameraController!.stopImageStream();
      await Future.delayed(Duration(milliseconds: 200));
      XFile file = await _cameraService.takePicture();

      setState(() {
        pictureTaked = true;
        imagePath = file.path;
      });
      return true;
    }
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  _reload() {
    setState(() {
      _bottomSheetVisible = false;
      cameraInitialized = false;
      pictureTaked = false;
    });
    this._start();
  }

  @override
  Widget build(BuildContext context) {
    final double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (pictureTaked) {
                    return Container(
                      width: width,
                      height: height,
                      child: Transform(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Image.file(File(imagePath!)),
                        ),
                        transform: Matrix4.rotationY(mirror),
                      ),
                    );
                  } else {
                    return Transform.scale(
                      scale: 1.0,
                      child: AspectRatio(
                        aspectRatio: MediaQuery.of(context).size.aspectRatio,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Container(
                            width: width,
                            height: width *
                                _cameraService
                                    .cameraController!.value.aspectRatio,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CameraPreview(_cameraService.cameraController!),
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
              }),
          CameraHeader(
            title: "Login",
            onBackPressed: _onBackPressed,
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !_bottomSheetVisible
          ? AuthActionButton(
              _initializeControllerFuture,
              onPressed: onShot,
              isLogin: true,
              reload: _reload,
            )
          : Container(),
    );
  }
}