import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:presensi_app/view/history_page.dart';
import 'package:presensi_app/view/profile_page.dart';

class HomePage extends StatelessWidget {
  HomePage(this.predictedKaryawan, {Key? key}) : super(key: key);
  final Map<String, dynamic> predictedKaryawan;

  final Color primary = '3546AB'.toColor();
  final Color green = '3AA969'.toColor();

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double statusBar = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: (height - statusBar) * 0.1,
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildText("Home", 25, Colors.white),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35))),
            width: double.infinity,
            padding:
                const EdgeInsets.only(top: 30, right: 20, left: 20, bottom: 30),
            child: Column(
              children: [
                ///card karyawan
                Container(
                  padding: EdgeInsets.all(10),
                  height: height * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: primary,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          color: Colors.white,
                          width: (width - 20) * 0.38,
                          height: (height * 0.2) - 20,
                          child: Image.network(
                            'https://ae6d-36-72-243-74.ngrok.io/presensi_app/upload/profil/' +
                                predictedKaryawan['profil_pict'],
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
                                predictedKaryawan['nama'],
                                20,
                                Colors.white,
                              ),
                              buildText(predictedKaryawan['id_jabatan'], 15,
                                  Colors.white),
                              Spacer(),
                              Container(
                                width: (width - 20) * 0.45,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: primary,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                  child: buildText("Presensi Hari Ini", 20, Colors.black),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  height: height * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: green,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: (height * 0.1) - 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildText(
                              "Telah Melakukan Presensi", 15, Colors.white),
                          buildText("08.32 WIB (Tepat Waktu)", 15, Colors.white)
                        ],
                      )
                    ],
                  ),
                ),

                SizedBox(
                  height: 20,
                ),

                ///kehadiran bulan ini
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: buildText("Kehadiran", 20, Colors.black),
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HistoryPage(
                                  key: PageStorageKey('key-history'),
                                ),
                              ));
                        },
                        child: buildText("view all", 15, primary),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      )
                    ],
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: TableCalendar(
                    firstDay:
                        DateTime(DateTime.now().year, DateTime.now().month, 1),
                    lastDay: DateTime(DateTime.now().year, DateTime.now().month,
                        DateTime.now().day),
                    focusedDay: DateTime.now(),
                    currentDay: DateTime.now(),
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      titleTextStyle: TextStyle(fontSize: 15),
                      formatButtonVisible: false,
                    ),
                    locale: 'id_ID',
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(fontSize: 12),
                      weekendStyle: TextStyle(fontSize: 12),
                    ),
                    rowHeight: 40,
                    calendarStyle: CalendarStyle(
                      disabledTextStyle:
                          TextStyle(fontSize: 12, color: Colors.grey),
                      defaultTextStyle: TextStyle(fontSize: 12),
                      weekendTextStyle:
                          TextStyle(fontSize: 12, color: Colors.red),
                      todayTextStyle: TextStyle(fontSize: 12),
                      outsideTextStyle:
                          TextStyle(fontSize: 12, color: Colors.grey),
                      selectedTextStyle: TextStyle(fontSize: 12),
                      holidayTextStyle: TextStyle(fontSize: 12),
                      rangeEndTextStyle: TextStyle(fontSize: 12),
                      rangeStartTextStyle: TextStyle(fontSize: 12),
                      withinRangeTextStyle: TextStyle(fontSize: 12),
                      markerMargin: EdgeInsets.all(10),
                    ),
                  ),
                ),
                SizedBox(
                  height: 80,
                )
              ],
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
