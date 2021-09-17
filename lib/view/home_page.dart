import 'package:flutter/material.dart';
import 'package:presensi_app/provider/api.dart';
import 'package:presensi_app/provider/karyawan.dart';
import 'package:provider/provider.dart';
import 'package:supercharged/supercharged.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'package:presensi_app/provider/presensi.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

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
      Provider.of<Presensi>(context).getPresensi();
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final presensiProvider = Provider.of<Presensi>(context, listen: false);
    final karyawanProvider = Provider.of<Karyawan>(context, listen: false);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    EdgeInsets hrzPadd = const EdgeInsets.symmetric(horizontal: 20);
    double appBar = AppBar().preferredSize.height;
    double statusBar = MediaQuery.of(context).padding.top;

    List dataPresensi = presensiProvider.dataPresensi;

    String now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var data = dataPresensi.where((element) => element.tanggal == now);

    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Container(
                height: height * 0.3,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35)),
                  gradient: RadialGradient(
                    colors: [
                      '#0575E6'.toColor(),
                      primary,
                    ],
                    center: Alignment(-1.0, -1.0),
                    focal: Alignment(0.3, -0.1),
                    focalRadius: 3,
                  ),
                ),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildText("Home", 40, Colors.white),
                      buildText(
                          '${DateFormat.EEEE('id').format(DateTime.now())}, ${DateFormat('d MMM yyyy').format(DateTime.now())}',
                          13,
                          Colors.white),
                      SizedBox(
                        height: height * 0.05,
                      )
                    ],
                  ),
                )),
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  child: Column(
                    children: [
                      SizedBox(height: (height * 0.1) + 20),

                      ///presensi hari ini
                      Container(
                        margin: hrzPadd,
                        alignment: Alignment.centerLeft,
                        child: buildText("Presensi Hari Ini", 18, Colors.black),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        margin: hrzPadd,
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
                                    int index = dataPresensi.indexWhere(
                                        (element) => element.tanggal == now);

                                    return buildText(
                                        "${dataPresensi[index].jamMasuk}",
                                        15,
                                        Colors.white);
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
                    ],
                  ),
                ),
                Positioned(
                  top: -height * 0.1,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    height: height * 0.2,
                    width: width - 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade500,
                            blurRadius: 4,
                            spreadRadius: 1)
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            color: Colors.white,
                            width: (width - 20) * 0.38,
                            height: (height * 0.2) - 20,
                            child:
                                karyawanProvider.dataKaryawan.profilImg == null
                                    ? null
                                    : Image.network(
                                        '${BaseUrl.uploadAPI}' +
                                            '${karyawanProvider.dataKaryawan.profilImg!}',
                                        fit: BoxFit.cover,
                                      ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildText(
                                  "${karyawanProvider.dataKaryawan.namaDepan} ${karyawanProvider.dataKaryawan.namaBelakang}",
                                  20,
                                  Colors.black),
                              Spacer(),
                              buildText(
                                  karyawanProvider.dataKaryawan.jabatan ?? "",
                                  15,
                                  Colors.black),
                              SizedBox(
                                height: height * 0.01,
                              ),
                              Container(
                                width: (width - 20) * 0.45,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: primary,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: primary, width: 2.0),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    print(karyawanProvider
                                        .dataKaryawan.profilImg);
                                    Navigator.pushNamed(context, 'profil');
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.userAlt,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      buildText("Detail", 15, Colors.white)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
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
