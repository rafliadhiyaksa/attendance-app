import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:presensi_app/view/presensi_page.dart';
import 'package:supercharged/supercharged.dart';

import 'package:presensi_app/service/face_recognition_service.dart';
import 'package:presensi_app/service/ml_kit_service.dart';
import 'package:presensi_app/view/history_page.dart';
import 'package:presensi_app/view/home_page.dart';

class NavigationBar extends StatefulWidget {
  NavigationBar(this.predictedKaryawan, {Key? key}) : super(key: key);
  final Map<String, dynamic> predictedKaryawan;

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  //Service Injection
  FaceRecognitionService _faceRecognitionService = FaceRecognitionService();
  MLKitService _mlKitService = MLKitService();

  CameraDescription? _cameraDescription;
  CameraDescription? get cameraDescription => _cameraDescription;

  final Color primary = '3546AB'.toColor();
  final Color background = 'ffffff'.toColor();

  int _currentIndex = 0;

  final iconList = <IconData>[
    Icons.home_rounded,
    Icons.history_rounded,
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _startUp();
  }

  ///menentukan kamera yang tersedia di device dan meload model facenet
  _startUp() async {
    List<CameraDescription> cameras = await availableCameras();
    // menggunakan kamera depan
    _cameraDescription = cameras.firstWhere((CameraDescription camera) =>
        camera.lensDirection == CameraLensDirection.front);
    //mulai service
    await _faceRecognitionService.loadModel();
    _mlKitService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    double statusBar = MediaQuery.of(context).padding.top;
    final List _screens = [
      HomePage(widget.predictedKaryawan),
      HistoryPage(key: PageStorageKey('key-history')),
    ];
    return Scaffold(
      extendBody: true,
      backgroundColor: primary,
      body: Padding(
        padding: EdgeInsets.only(top: statusBar),
        child: PageStorage(
          bucket: bucket,
          child: _screens[_currentIndex],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        isExtended: true,
        child: Image(
          image: AssetImage('assets/icon/face-id.png'),
          width: 25,
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  PresensiPage(cameraDescription: cameraDescription!),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        elevation: 10,
        height: 70,
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? primary : Colors.black;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList[index],
                size: 40,
                color: color,
              ),
            ],
          );
        },
        backgroundColor: Colors.white,
        activeIndex: _currentIndex,
        splashColor: primary,
        splashSpeedInMilliseconds: 900,
        notchSmoothness: NotchSmoothness.softEdge,
        gapLocation: GapLocation.center,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  Text buildText(String text, double size, Color color,
      {int? maxLines, TextOverflow? overflow}) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontFamily: "ProductSans",
        fontSize: size,
        fontWeight: FontWeight.w700,
      ),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
