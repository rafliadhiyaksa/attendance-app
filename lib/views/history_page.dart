import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supercharged/supercharged.dart';
import 'package:intl/intl.dart';

import '../provider/presensi.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Color primary = '3546AB'.toColor();
  final Color green = '3AA969'.toColor();
  final Color red = 'F44336'.toColor();

  bool isInit = true;
  bool loading = false;

  @override
  void didChangeDependencies() {
    _setLoading(true);
    if (isInit) {
      Provider.of<Presensi>(context).getPresensi();
      Provider.of<Presensi>(context).getSetting();
    }
    isInit = false;
    _setLoading(false);
    super.didChangeDependencies();
  }

  //show / hide loading logo
  _setLoading(bool value) {
    setState(() {
      loading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double statusBar = MediaQuery.of(context).padding.top;
    EdgeInsets hrzPadd = const EdgeInsets.symmetric(horizontal: 20);
    final presensiProvider = Provider.of<Presensi>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            '#0575E6'.toColor(),
            primary,
          ],
          center: Alignment(0, 0),
          focal: Alignment(0.3, -0.1),
          focalRadius: 3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: height * 0.08 + statusBar),
          Container(
            padding: hrzPadd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText("Riwayat", 40, Colors.white),
                buildText("Presensi", 25, Colors.white),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: 'F8F8F8'.toColor(),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              // height: 500,
              padding: EdgeInsets.only(top: 30),
              width: width,
              child: !loading
                  ? (presensiProvider.jumlahPresensi == 0 &&
                          presensiProvider.jumlahSetting == 0)
                      ? Container(
                          alignment: Alignment.center,
                          height: (height - statusBar) * 0.65,
                          child: buildText("Tidak Ada Data", 18, Colors.black),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(vertical: 5),
                          itemCount: presensiProvider.jumlahPresensi,
                          itemBuilder: (context, index) {
                            List dataPresensi =
                                presensiProvider.dataPresensi.reversed.toList();
                            List dataSetting = presensiProvider.dataSetting;
                            print(
                                "data setting = ${presensiProvider.jumlahSetting}");

                            DateTime dateTime = DateFormat('yyyy-MM-dd')
                                .parse(dataPresensi[index].tanggal);
                            dateTime = new DateTime(
                                dateTime.year, dateTime.month, dateTime.day);
                            var bulan = DateFormat('MMM').format(dateTime);
                            var tanggal = DateFormat('dd').format(dateTime);
                            // var tahun = DateFormat('yyyy').format(dateTime);
                            DateTime jamMasuk = DateTime.now();
                            if (dataPresensi[index].jamMasuk != null) {
                              jamMasuk = DateFormat('HH:mm:ss')
                                  .parse(dataPresensi[index].jamMasuk);
                              jamMasuk = new DateTime(
                                  dateTime.year,
                                  dateTime.month,
                                  dateTime.day,
                                  jamMasuk.hour,
                                  jamMasuk.minute,
                                  jamMasuk.second);
                            }
                            DateTime mulai = DateFormat('HH:mm:ss')
                                .parse(dataSetting[0].mulaiPresensi);
                            mulai = new DateTime(
                                dateTime.year,
                                dateTime.month,
                                dateTime.day,
                                mulai.hour,
                                mulai.minute,
                                mulai.second);
                            DateTime batas =
                                DateFormat('HH:mm:ss').parse('10:00:00');
                            batas = new DateTime(
                                dateTime.year,
                                dateTime.month,
                                dateTime.day,
                                batas.hour,
                                batas.minute,
                                batas.second);
                            DateTime telat = DateFormat('HH:mm:ss')
                                .parse(dataSetting[0].batasPresensi);
                            telat = new DateTime(
                                dateTime.year,
                                dateTime.month,
                                dateTime.day,
                                telat.hour,
                                telat.minute,
                                telat.second);

                            return Padding(
                              padding: EdgeInsets.only(
                                  right: 20,
                                  left: 20,
                                  top: 5,
                                  bottom: index ==
                                          presensiProvider.jumlahPresensi - 1
                                      ? 100
                                      : 5),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                        offset: Offset(0, 1),
                                      )
                                    ]),
                                height: 90,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        buildText(
                                            bulan.toUpperCase(), 12, primary),
                                        buildText(tanggal, 32, primary),
                                        // buildText(tahun, 12, primary),
                                      ],
                                    ),
                                    Container(
                                      width: width * 0.65,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          buildText(
                                              dataPresensi[index].jamMasuk !=
                                                      null
                                                  ? "Presensi ${() {
                                                      if (jamMasuk.isBetween(
                                                          mulai, batas)) {
                                                        return "Tepat Waktu";
                                                      } else if (jamMasuk
                                                          .isBetween(
                                                              batas, telat)) {
                                                        return "Terlambat";
                                                      }
                                                    }()}"
                                                  : "Belum Melakukan Presensi",
                                              15,
                                              Colors.black),
                                          buildText(
                                              "Waktu Masuk : ${() {
                                                if (dataPresensi[index]
                                                        .jamMasuk ==
                                                    null) {
                                                  return "N/A";
                                                } else {
                                                  return dataPresensi[index]
                                                      .jamMasuk;
                                                }
                                              }()}",
                                              13,
                                              Colors.grey.shade600),
                                          buildText(
                                              "Waktu Pulang : ${() {
                                                if (dataPresensi[index]
                                                        .jamPulang ==
                                                    null) {
                                                  return "N/A";
                                                } else {
                                                  return dataPresensi[index]
                                                      .jamPulang;
                                                }
                                              }()}",
                                              13,
                                              Colors.grey.shade600),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                  : Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
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
