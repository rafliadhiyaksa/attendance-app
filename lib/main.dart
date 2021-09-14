import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:presensi_app/provider/alamat.dart';
import 'package:presensi_app/provider/presensi.dart';
import 'package:presensi_app/widgets/navigation_bar.dart';
import 'package:supercharged/supercharged.dart';
import 'package:provider/provider.dart';

import 'package:presensi_app/view/login_page.dart';
import 'package:presensi_app/provider/karyawan.dart';
import 'package:presensi_app/view/registration_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Karyawan()),
        ChangeNotifierProvider(create: (context) => Alamat()),
        ChangeNotifierProvider(create: (context) => Presensi()),
      ],
      child: MaterialApp(
        title: 'Attendance App',
        debugShowCheckedModeBanner: false,
        color: '3546AB'.toColor(),
        theme: ThemeData(
            primaryColor: '3546AB'.toColor(),
            primarySwatch: Colors.indigo,
            fontFamily: "ProductSans",
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: TextTheme(
              bodyText2: TextStyle(
                fontFamily: "ProductSans",
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              button: TextStyle(
                  fontFamily: "ProductSans", fontWeight: FontWeight.w700),
            ),
            appBarTheme: AppBarTheme(
                // iconTheme: IconThemeData(color: Colors.white, size: 30),
                centerTitle: true,
                elevation: 0,
                textTheme: TextTheme(
                    headline6: TextStyle(
                        fontFamily: "ProductSans",
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)))),
        builder: EasyLoading.init(
          builder: (context, child) => Stack(
            children: [child!, DropdownAlert()],
          ),
        ),
        home: Login(),
        routes: {
          'login': (context) => Login(),
          'registration': (context) => RegistrationPage(),
          'navigation-bar': (context) => NavigationBar(),
        },
      ),
    );
  }
}
