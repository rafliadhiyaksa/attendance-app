import 'package:flutter/material.dart';
// import 'package:presensi_app/view/login_page.dart';
import 'package:supercharged/supercharged.dart';

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> with TickerProviderStateMixin {
  Color primary = '3546AB'.toColor();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          //BACKGROUND IMAGE
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/img/face-recognition.jpg'),
                        fit: BoxFit.cover)),
              ),
            ],
          ),
          //CONTENT
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.33,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3))
                  ]),
              width: double.infinity,
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Face Recognition'),
                  SizedBox(
                    height: 15,
                  ),
                  //Deskripsi
                  Text(
                    'Gunakan Wajah Anda Untuk Melakukan Presensi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: '878787'.toColor(),
                        fontSize: 15.0,
                        letterSpacing: 1.0,
                        height: 2.0),
                  ),
                  Spacer(),
                  //TOMBOL NEXT

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size.square(50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                enableFeedback: true),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('login');
                            },
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 30,
                            )),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
