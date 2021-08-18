import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color primary = '3546AB'.toColor();
  Color white = Colors.white;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Home")),
        drawer: Drawer(
            child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 4,
              color: primary,
              alignment: Alignment.bottomLeft,
              child: buildText("Menu Lanjutan", 20, white),
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              focusColor: primary,
              leading: Icon(
                Icons.settings_outlined,
                color: Colors.black,
              ),
              title: buildText("Setting", 15, Colors.black),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.info_outline_rounded,
                color: Colors.black,
              ),
              title: buildText("About", 15, Colors.black),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.exit_to_app_rounded,
                color: Colors.black,
              ),
              title: buildText("Logout", 15, Colors.black),
              onTap: () {},
            ),
          ],
        )),
        body: SingleChildScrollView(
          child: Column(
            children: [
              //TANGGAL
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  // mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(10)),
                      width: 45.0,
                      height: 40.0,
                      child: Center(
                        child: Text(
                          DateFormat.d('ID').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "ProductSans",
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        DateFormat.yMMMM('ID').format(DateTime.now()),
                        style: TextStyle(
                          fontFamily: "ProductSans",
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //CARD PROFILE
              Container(),

              //NOTIFIKASI BERHASIL ABSEN
              //RIWAYAT ABSEN
            ],
          ),
        ));
  }

  Text buildText(String text, double size, Color color) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: size),
    );
  }
}
