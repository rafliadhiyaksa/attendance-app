import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'package:presensi_app/service/camera_service.dart';
import 'package:flutter/material.dart';

class MLKitService {
  static final MLKitService _cameraServiceService = MLKitService._internal();

  factory MLKitService() {
    return _cameraServiceService;
  }

  MLKitService._internal();

  CameraService _cameraService = CameraService();

  FaceDetector? _faceDetector;
  FaceDetector? get faceDetector => _faceDetector;

  void initialize() {
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        mode: FaceDetectorMode.fast,
      ),
    );
  }

  Future<List<Face>> getFacesFromImage(CameraImage image) async {
    //preprocess image
    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final InputImageFormat? inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw);

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    InputImageData _inputImageData = InputImageData(
      size: imageSize,
      imageRotation: _cameraService.cameraRotation,
      inputImageFormat: inputImageFormat!,
      planeData: planeData,
    );

    InputImage _inputImage = InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      inputImageData: _inputImageData,
    );

    //proses image dan membuat kesimpulan
    List<Face> faces = await this._faceDetector!.processImage(_inputImage);
    return faces;
  }

  void close() {
    _faceDetector!.close();
  }
}
