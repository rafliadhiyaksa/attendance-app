import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:presensi_app/provider/karyawan.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tflite;
import 'package:image/image.dart' as imglib;

class FaceRecognitionService {
  static final FaceRecognitionService _faceRecognitionService =
      FaceRecognitionService._internal();

  factory FaceRecognitionService() {
    return _faceRecognitionService;
  }
  FaceRecognitionService._internal();

  tflite.Interpreter? _interpreter;

  double threshold = 1.0;

  List? _predictedData;
  List? get predictedData => this._predictedData;

  Karyawan _karyawan = Karyawan();

  //data user yang tersimpan
  dynamic data = [];

  Future loadModel() async {
    try {
      final gpuDelegateV2 = tflite.GpuDelegateV2(
        options: tflite.GpuDelegateOptionsV2(
          isPrecisionLossAllowed: false,
          inferencePreference: tflite.TfLiteGpuInferenceUsage.fastSingleAnswer,
          inferencePriority1: tflite.TfLiteGpuInferencePriority.minLatency,
          inferencePriority2: tflite.TfLiteGpuInferencePriority.auto,
          inferencePriority3: tflite.TfLiteGpuInferencePriority.auto,
        ),
      );
      var interpreterOptions = tflite.InterpreterOptions()
        ..addDelegate(gpuDelegateV2);
      this._interpreter = await tflite.Interpreter.fromAsset(
          'mobilefacenet.tflite',
          options: interpreterOptions);
      print('model loaded successfully');
    } catch (e) {
      print('Failed to load model');
      print(e);
    }
  }

  setCurrentPrediction(CameraImage cameraImage, Face face) {
    ///crop wajah dari gambar dan ubah ke bentuk array
    List input = _preProcess(cameraImage, face);

    /// reshape input dan output ke format model
    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    ///jalankan dan ubah data
    this._interpreter!.run(input, output);
    output = output.reshape([192]);

    this._predictedData = List.from(output);
  }

  dynamic predict() {
    return _searchResult(this._predictedData!);
  }

  ///preprocess : crop image agar lebih mudah untuk dideteksi
  ///dan transform ke bentuk model input
  ///[cameraImage] : current image
  ///[face] : face detected
  List _preProcess(CameraImage image, Face faceDetected) {
    ///crop wajah
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);

    //transformasikan wajah yang sudah dicrop ke data array
    Float32List imageAsList = imageToByteListFloat32(img);
    return imageAsList;
  }

  _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(
        convertedImage, x.round(), y.round(), w.round(), h.round());
  }

  imglib.Image _convertCameraImage(CameraImage image) {
    int width = image.width;
    int height = image.height;
    var img = imglib.Image(width, height);
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    var img1 = imglib.copyRotate(img, -90);
    return img1;
  }

  Float32List imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);

        buffer[pixelIndex++] = (imglib.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  dynamic _searchResult(List predictedData) {
    List<dynamic> data = _karyawan.dataKaryawan;

    if (data.length == 0) return null;
    double minDist = 999;
    double currDist = 0.0;
    dynamic predRes;

    data.forEach(
      (element) {
        currDist =
            _euclideanDistance(jsonDecode(element['face_pict']), predictedData);
        if (currDist <= threshold && currDist < minDist) {
          minDist = currDist;
          predRes = element;
        }
      },
    );
    return predRes;
  }

  double _euclideanDistance(List? e1, List? e2) {
    if (e1 == null || e2 == null) throw Exception("Null Argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  void setPredictedData(value) {
    this._predictedData = value;
  }
}
