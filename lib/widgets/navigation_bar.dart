import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:presensi_app/view/history_page.dart';
import 'package:presensi_app/view/home_page.dart';
import 'package:presensi_app/view/presensi_page.dart';
import 'package:supercharged/supercharged.dart';

class NavigationBar extends StatefulWidget {
  const NavigationBar(this.dataKaryawan, {Key? key}) : super(key: key);
  final Map<String, dynamic> dataKaryawan;

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  final Color primary = '3546AB'.toColor();
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    PresensiPage(),
    HistoryPage(),
  ];

  PageController controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        itemCount: 3,
        controller: controller,
        onPageChanged: (page) {
          _selectedIndex = page;
        },
        itemBuilder: (context, position) {
          return SafeArea(
              child: Container(
            child: Stack(
              children: [
                _widgetOptions[position],
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  margin: EdgeInsets.only(left: 12, right: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: IconButton(
                          iconSize: 28,
                          icon: Icon(Icons.settings_rounded),
                          onPressed: () {},
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ));
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
            child: GNav(
              gap: 8,
              activeColor: primary,
              iconSize: 24,
              textStyle: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
              tabMargin: EdgeInsets.all(10),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.indigo.shade100,
              color: Colors.black,
              tabs: [
                GButton(
                  icon: Icons.home_rounded,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.face_rounded,
                  text: 'Presensi',
                ),
                GButton(
                  icon: Icons.history_rounded,
                  text: 'History',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                controller.jumpToPage(index);
              },
            ),
          ),
        ),
      ),
    );
  }
}
