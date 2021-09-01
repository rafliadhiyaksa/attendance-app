import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({Key? key}) : super(key: key);

  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
              colors: [Colors.red.shade500, Colors.red.shade400]),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: new Offset(0.0, 5))
          ]),
      child: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: DateTime.now(),
        calendarStyle: CalendarStyle(
          canMarkersOverflow: true,
          markerDecoration: BoxDecoration(color: Colors.white),
          weekendTextStyle: TextStyle(color: Colors.white),
          todayDecoration: BoxDecoration(color: Colors.white54),
          todayTextStyle: TextStyle(
              color: Colors.redAccent,
              fontSize: 15,
              fontWeight: FontWeight.bold),
          selectedDecoration: BoxDecoration(color: Colors.red.shade900),
        ),
      ),
    );
  }
}
