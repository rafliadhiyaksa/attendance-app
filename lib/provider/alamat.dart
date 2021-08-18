import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:presensi_app/provider/api.dart';

class Alamat with ChangeNotifier {
  // Map<String, dynamic> _dataProvinsi = {};
  // Map<String, dynamic> get dataProvinsi => _dataProvinsi;

  List<dynamic> _dataProvinsi = [];
  List<dynamic> _dataKota = [];
  List<dynamic> _dataKecamatan = [];
  List<dynamic> _dataKelurahan = [];

  List<dynamic> get dataProvinsi => _dataProvinsi;
  List<dynamic> get dataKota => _dataKota;
  List<dynamic> get dataKecamatan => _dataKecamatan;
  List<dynamic> get dataKelurahan => _dataKelurahan;

  int get jumlahDataProvinsi => _dataProvinsi.length;
  int get jumlahDataKota => _dataKota.length;
  int get jumlahDataKecamatan => _dataKecamatan.length;
  int get jumlahDataKelurahan => _dataKelurahan.length;

  // String baseUrl = "https://dev.farizdotid.com/api/daerahindonesia/";

  void getProvinsi() async {
    var hasilGetData =
        await http.get(Uri.parse(BaseUrl.alamatAPI + "provinsi"));

    _dataProvinsi = json.decode(hasilGetData.body)["provinsi"];

    notifyListeners();
  }

  void getKota(dynamic idProvinsi) async {
    var response = await http.get(
        Uri.parse(BaseUrl.alamatAPI + "kota?id_provinsi=" + "$idProvinsi"));

    _dataKota = jsonDecode(response.body)["kota_kabupaten"];
    notifyListeners();

    // print(dataKota);
  }

  void getKecamatan(dynamic idKota) async {
    var response = await http
        .get(Uri.parse(BaseUrl.alamatAPI + "kecamatan?id_kota=" + "$idKota"));

    _dataKecamatan = jsonDecode(response.body)["kecamatan"];
    notifyListeners();

    // print(dataKota);
  }

  void getKelurahan(dynamic idKec) async {
    var response = await http.get(
        Uri.parse(BaseUrl.alamatAPI + "kelurahan?id_kecamatan=" + "$idKec"));

    _dataKelurahan = jsonDecode(response.body)["kelurahan"];
    notifyListeners();

    // print(dataKota);
  }
}
