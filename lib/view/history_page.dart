import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Color primary = '3546AB'.toColor();
  final Color green = '3AA969'.toColor();

  Map<DateTime, List<dynamic>>? _events;
  List<dynamic>? _selectedEvents;

  List<CleanCalendarEvent> _todaysEvents = [
    CleanCalendarEvent(
      'Event A',
      startTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 0),
      endTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0),
      description: 'A special event',
    ),
  ];

  // final Map<DateTime, List<NeatCleanCalendarEvent>> _events = {
  //   DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 2):
  //       [
  //     NeatCleanCalendarEvent('Event B',
  //         startTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 10, 0),
  //         endTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 12, 0),
  //         color: Colors.orange),
  //     NeatCleanCalendarEvent('Event C',
  //         startTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 14, 30),
  //         endTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 17, 0),
  //         color: Colors.pink),
  //     NeatCleanCalendarEvent('Event D',
  //         startTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 14, 30),
  //         endTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 17, 0),
  //         color: Colors.pink),
  //   ],
  //   DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 3):
  //       [
  //     NeatCleanCalendarEvent('Event B',
  //         startTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 10, 0),
  //         endTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 12, 0),
  //         color: Colors.orange),
  //     NeatCleanCalendarEvent('Event C',
  //         startTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 14, 30),
  //         endTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 17, 0),
  //         color: Colors.pink),
  //     NeatCleanCalendarEvent('Event D',
  //         startTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 14, 30),
  //         endTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 17, 0),
  //         color: Colors.amber),
  //     NeatCleanCalendarEvent('Event E',
  //         startTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 14, 30),
  //         endTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 17, 0),
  //         color: Colors.deepOrange),
  //     NeatCleanCalendarEvent('Event F',
  //         startTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 14, 30),
  //         endTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 17, 0),
  //         color: Colors.green),
  //     NeatCleanCalendarEvent('Event G',
  //         startTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 14, 30),
  //         endTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 17, 0),
  //         color: Colors.indigo),
  //     NeatCleanCalendarEvent('Event H',
  //         startTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 14, 30),
  //         endTime: DateTime(DateTime.now().year, DateTime.now().month,
  //             DateTime.now().day + 2, 17, 0),
  //         color: Colors.brown),
  //   ],
  // };

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedEvents = [];
    // Force selection of today on first load, so that the list of today's events gets shown.
    // _handleNewDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
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
                buildText("Riwayat", 25, Colors.white),
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
            height: (height - statusBar) * 0.9,
            padding: EdgeInsets.only(top: 15),
            child: Calendar(
              startOnMonday: true,
              weekDays: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
              // events: _events,
              isExpandable: true,
              eventDoneColor: Colors.green,
              selectedColor: primary,
              todayColor: Colors.blue,
              initialDate: DateTime.now(),
              onDateSelected: (date) {
                _handleNewDate(date);
              },
              eventListBuilder: (BuildContext context,
                  List<CleanCalendarEvent> _selectedEvents) {
                return Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: green,
                        size: MediaQuery.of(context).size.width * 0.17,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        height: MediaQuery.of(context).size.width * 0.17,
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildText(
                                "Telah Melakukan Presensi Masuk", 13, green),
                            buildText("08.31 (Tepat Waktu)", 13, Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              locale: 'id_ID',
              hideTodayIcon: true,
              expandableDateFormat: 'EEEE, dd MMMM yyyy',
              dayOfWeekStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNewDate(date) {
    print('Date selected: $date');
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
