import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './api.dart';

class Alamat with ChangeNotifier {
  // menyimpan data provinsi
  List<dynamic> _dataProvinsi = [];
  List<dynamic> get dataProvinsi => _dataProvinsi;

  // menyimpan data kota
  List<dynamic> _dataKota = [];
  List<dynamic> get dataKota => _dataKota;

  //menyimpan data kecamatan
  List<dynamic> _dataKecamatan = [];
  List<dynamic> get dataKecamatan => _dataKecamatan;

  //menyimpan data kelurahan
  List<dynamic> _dataKelurahan = [];
  List<dynamic> get dataKelurahan => _dataKelurahan;

  /// mengambil data provinsi dari api
  void getProvinsi() async {
    var response = await http.get(Uri.parse(BaseUrl.alamatAPI + "provinsi"));

    _dataProvinsi = json.decode(response.body)["provinsi"];
    notifyListeners();
  }

  /// mengambil data kota dari api
  void getKota(dynamic idProvinsi) async {
    var response = await http
        .get(Uri.parse(BaseUrl.alamatAPI + "kota?id_provinsi=$idProvinsi"));

    _dataKota = jsonDecode(response.body)["kota_kabupaten"];
    notifyListeners();
  }

  /// mengambil data kecamatan dari api
  void getKecamatan(dynamic idKota) async {
    var response = await http
        .get(Uri.parse(BaseUrl.alamatAPI + "kecamatan?id_kota=$idKota"));

    _dataKecamatan = jsonDecode(response.body)["kecamatan"];
    notifyListeners();
  }

  /// mengambil data kelurahan dari api
  void getKelurahan(dynamic idKec) async {
    var response = await http
        .get(Uri.parse(BaseUrl.alamatAPI + "kelurahan?id_kecamatan=$idKec"));

    _dataKelurahan = jsonDecode(response.body)["kelurahan"];
    notifyListeners();
  }
}
