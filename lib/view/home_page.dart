import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supercharged/supercharged.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:presensi_app/view/profile_page.dart';
import 'package:presensi_app/models/model_karyawan.dart';
import 'package:presensi_app/provider/presensi.dart';

class HomePage extends StatefulWidget {
  HomePage(this.predictedKaryawan, {Key? key}) : super(key: key);
  final ModelKaryawan predictedKaryawan;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primary = '3546AB'.toColor();
  final Color green = '3AA969'.toColor();
  final Color red = 'F6404F'.toColor();
  bool isInit = true;

  @override
  void didChangeDependencies() {
    if (isInit) {
      Provider.of<Presensi>(context)
          .getPresensi(widget.predictedKaryawan.idKaryawan!);
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final providerPresensi = Provider.of<Presensi>(context, listen: false);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double appBar = AppBar().preferredSize.height;

    // double statusBar = MediaQuery.of(context).padding.top;

    List dataPresensi = providerPresensi.dataPresensi;
    String now = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var data = dataPresensi.where((element) => element.tanggal == now);

    if (data.isEmpty) {
      print("data ksong");
    } else {
      print("data ada");
      print(data);
    }

    return SingleChildScrollView(
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: appBar),
            buildText("Home", 35, Colors.black),
            SizedBox(height: 20),

            ///card karyawan
            Container(
              padding: EdgeInsets.all(10),
              height: height * 0.2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: RadialGradient(
                    colors: [
                      '#0575E6'.toColor(),
                      primary,
                    ],
                    center: Alignment(-1.0, -1.0),
                    focal: Alignment(0.3, -0.1),

                    focalRadius: 3,
                    // radius: 2,
                  )),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      color: Colors.white,
                      width: (width - 20) * 0.38,
                      height: (height * 0.2) - 20,
                      child: Image.network(
                        'https://ef00-103-132-53-169.ngrok.io/presensi_app/upload/profil/' +
                            widget.predictedKaryawan.profilImg!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText(
                            "${widget.predictedKaryawan.namaDepan} ${widget.predictedKaryawan.namaBelakang}",
                            20,
                            Colors.white,
                          ),
                          Spacer(),
                          buildText(widget.predictedKaryawan.jabatan!, 15,
                              Colors.white),
                          Spacer(),
                          Container(
                            width: (width - 20) * 0.45,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.white, width: 2.0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfilePage(),
                                      ));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.visibility_rounded,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    buildText("Detail", 15, Colors.white)
                                  ],
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),

            ///presensi hari ini
            Container(
              alignment: Alignment.centerLeft,
              child: buildText("Presensi Hari Ini", 18, Colors.black),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              padding: EdgeInsets.all(10),
              height: height * 0.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: data.isNotEmpty ? green : red,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FaIcon(
                    data.isNotEmpty
                        ? FontAwesomeIcons.checkCircle
                        : FontAwesomeIcons.timesCircle,
                    color: Colors.white,
                    size: (height * 0.09) - 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildText(
                        data.isNotEmpty
                            ? "Sudah Melakukan Presensi"
                            : "Belum Melakukan Presensi",
                        15,
                        Colors.white,
                      ),
                      () {
                        if (data.isNotEmpty) {
                          int index = dataPresensi
                              .indexWhere((element) => element.tanggal == now);

                          return buildText("${dataPresensi[index].jamMasuk}",
                              15, Colors.white);
                        } else {
                          return buildText("N/A", 15, Colors.white);
                        }
                      }(),
                    ],
                  )
                ],
              ),
            ),

            SizedBox(
              height: 20,
            ),

            ///kehadiran bulan ini
          ],
        ),
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
