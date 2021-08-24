import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage(this.dataKaryawan, {Key? key}) : super(key: key);
  final Map<String, dynamic> dataKaryawan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(),
    );
  }
}
