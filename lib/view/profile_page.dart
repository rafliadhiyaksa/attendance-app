import 'package:flutter/material.dart';
import 'package:presensi_app/widgets/build_profile_picture.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: height * 0.25,
              ),
              Positioned(
                bottom: -80,
                child: ProfilePicture(),
              ),
            ],
          ),
          SizedBox(
            height: 80,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildText("Nama Karyawan", 20, Colors.black),
                    buildText("Jabatan", 15, Colors.grey),
                  ],
                ),
                Container(
                  child: buildText("Email", 15, Colors.grey),
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
          fontSize: size,
          fontFamily: 'ProductSans',
          fontWeight: FontWeight.bold),
    );
  }
}
