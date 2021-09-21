import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:supercharged/supercharged.dart';
import 'package:provider/provider.dart';

import './views/profile_page.dart';
import './views/login_page.dart';
import './views/registration_page.dart';
import './provider/alamat.dart';
import './provider/presensi.dart';
import './service/face_recognition_service.dart';
import './widgets/navigation_bar.dart';
import './provider/karyawan.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Karyawan()),
        ChangeNotifierProvider(create: (context) => Alamat()),
        ChangeNotifierProvider(create: (context) => FaceRecognitionService()),
        ChangeNotifierProxyProvider<Karyawan, Presensi>(
            create: (context) => Presensi(),
            update: (context, karyawan, presensi) =>
                presensi!..id(karyawan.dataKaryawan.idKaryawan)),
      ],
      builder: (context, child) => Consumer<Karyawan>(
        builder: (context, karyawan, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: '3546AB'.toColor(),
            primarySwatch: Colors.indigo,
            fontFamily: "ProductSans",
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: TextTheme(
              bodyText2: TextStyle(
                  fontFamily: "ProductSans",
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
              button: TextStyle(
                  fontFamily: "ProductSans", fontWeight: FontWeight.w700),
            ),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              elevation: 0,
              toolbarTextStyle: TextStyle(
                  fontFamily: "ProductSans",
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
          ),
          builder: (context, child) => Stack(
            children: [child!, DropdownAlert()],
          ),
          home: karyawan.isAuth
              ? NavigationBar()
              : FutureBuilder(
                  future: karyawan.autoLogin(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Scaffold(
                          body: Center(
                        child: CircularProgressIndicator(),
                      ));
                    }
                    return Login();
                  }),
          routes: {
            'login': (context) => Login(),
            'registration': (context) => RegistrationPage(),
            'navigation-bar': (context) => NavigationBar(),
            'profil': (context) => ProfilePage(),
          },
        ),
      ),
    );
  }
}
