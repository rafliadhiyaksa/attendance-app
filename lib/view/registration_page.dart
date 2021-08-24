import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:presensi_app/provider/alamat.dart';
import 'package:presensi_app/widgets/form_registration.dart';
import 'package:provider/provider.dart';

import 'package:supercharged/supercharged.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  Color primary = '3546AB'.toColor();
  bool isInit = true;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      Provider.of<Alamat>(context, listen: false).getProvinsi();
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          iconSize: 35,
          onPressed: () {
            buildShowDialog(context);
          },
        ),
      ),
      backgroundColor: primary,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40.0,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: buildText("Registrasi", 40, Colors.white)),
              Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: buildText("Data Diri Karyawan", 22, Colors.white)),
              SizedBox(
                height: 30.0,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35))),
                width: double.infinity,
                padding: const EdgeInsets.all(32.0),
                child: FormRegistration(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> buildShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: buildText("Keluar Registrasi", 20, Colors.black),
          content:
              buildText("Apakah Anda Yakin Ingin Keluar?", 15, Colors.black),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: buildText("Tidak", 15, primary)),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: buildText("Ya", 15, primary))
          ],
        );
      },
    );
  }

  Text buildText(String text, double size, Color color) {
    return Text(
      text,
      style: TextStyle(
          color: color,
          fontSize: size,
          fontFamily: 'ProductSans',
          fontWeight: FontWeight.bold),
    );
  }
}
