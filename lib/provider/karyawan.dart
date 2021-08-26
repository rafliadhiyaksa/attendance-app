import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:presensi_app/provider/api.dart';
import 'package:presensi_app/widgets/build_profile_picture.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';

class Karyawan with ChangeNotifier {
  static final Karyawan _karyawan = Karyawan._internal();
  factory Karyawan() {
    return _karyawan;
  }
  Karyawan._internal();

  Map<String, dynamic> _dataResponse = {};
  Map<String, dynamic> get dataResponse => _dataResponse;

  List<dynamic> _dataKaryawan = [];
  List<dynamic> get dataKaryawan => _dataKaryawan;

  List<dynamic> _dataGender = [];
  List<dynamic> get dataGender => _dataGender;

  List<dynamic> _dataJabatan = [];
  List<dynamic> get dataJabatan => _dataJabatan;

  void _success(String message) {
    AlertController.show(
      "Success",
      message,
      TypeAlert.success,
    );
  }

  void _failed(String title, String message) {
    AlertController.show(
      title,
      message,
      TypeAlert.error,
    );
  }

  ///Post Data Karyawan
  Future<void> postData({
    required String nama,
    required String email,
    required String tempatLahir,
    required dynamic tanggalLahir,
    required String noHp,
    required String idGender,
    required dynamic idJabatan,
    required String alamat,
    required String provinsi,
    required String kota,
    required String kecamatan,
    required String kelurahan,
    required List facePict,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(BaseUrl.karyawanAPI));
    request.fields['nama'] = nama;
    request.fields['email'] = email;
    request.fields['tempat_lahir'] = tempatLahir;
    request.fields['tanggal_lahir'] = tanggalLahir;
    request.fields['id_gender'] = idGender;
    request.fields['no_hp'] = noHp;
    request.fields['id_jabatan'] = idJabatan.toString();
    request.fields['alamat'] = alamat;
    request.fields['provinsi'] = provinsi;
    request.fields['kota_kabupaten'] = kota;
    request.fields['kecamatan'] = kecamatan;
    request.fields['kelurahan'] = kelurahan;

    var profilPict = await http.MultipartFile.fromPath(
        'profil_pict', ProfilePicture.image!.path);
    request.files.add(profilPict);

    var facePictAsJson = json.encode(facePict);
    request.fields['face_pict'] = facePictAsJson;

    EasyLoading.show(
      status: 'Loading...',
      maskType: EasyLoadingMaskType.black,
    );
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      _dataResponse = json.decode(response.body);
      notifyListeners();
      EasyLoading.dismiss();
      if (_dataResponse['value'] == 1) {
        _success(_dataResponse['message']);
        print("uploaded");
      } else if (_dataResponse['value'] == 2) {
        _failed("Error", _dataResponse['message']);
      }
    } else {
      EasyLoading.dismiss();
      _failed(
          "Error " + response.statusCode.toString(), _dataResponse['message']);
    }
    // EasyLoading.dismiss();
  }

  ///Edit data karyawan
  Future<void> editData(
    String id,
    String nama,
    String email,
    String tempatLahir,
    dynamic tanggalLahir,
    String noHp,
    String jenisKelamin,
    String jabatan,
    String alamat,
    String provinsi,
    String kota,
    String kecamatan,
    String kelurahan,
  ) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(BaseUrl.karyawanAPI + id));
    request.fields['nama'] = nama;
    request.fields['email'] = email;
    request.fields['tempat_lahir'] = tempatLahir;
    request.fields['tanggal_lahir'] = tanggalLahir;
    request.fields['no_hp'] = noHp;
    request.fields['jenis_kelamin'] = jenisKelamin;
    request.fields['jabatan'] = jabatan;
    request.fields['alamat'] = alamat;
    request.fields['provinsi'] = provinsi;
    request.fields['kota_kabupaten'] = kota;
    request.fields['kecamatan'] = kecamatan;
    request.fields['kelurahan'] = kelurahan;

    var profilPict = await http.MultipartFile.fromPath(
        'profil_pict', ProfilePicture.image!.path);
    request.files.add(profilPict);

    EasyLoading.show(
      status: 'Loading...',
      maskType: EasyLoadingMaskType.black,
    );
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      _dataResponse = json.decode(response.body);
      notifyListeners();
      EasyLoading.dismiss();
      if (_dataResponse['value'] == 1) {
        _success(_dataResponse['message']);
        print("uploaded");
      } else if (_dataResponse['value'] == 2) {
        _failed("Error", _dataResponse['message']);
      }
    } else {
      EasyLoading.dismiss();
      _failed(
          "Error " + response.statusCode.toString(), _dataResponse['message']);
      print("Gagal");
    }
    EasyLoading.dismiss();
  }

  ///Get data karyawan
  Future<void> getKaryawan() async {
    var response = await http.get(Uri.parse(BaseUrl.karyawanAPI));

    _dataKaryawan = json.decode(response.body)['data'];
    notifyListeners();
  }

  ///get data gender
  Future<void> getGender() async {
    var hasilGetData = await http.get(Uri.parse(BaseUrl.genderAPI));
    _dataGender = json.decode(hasilGetData.body)['data'];
    notifyListeners();
  }

  ///get data jabatan
  Future<void> getJabatan() async {
    var hasilGetData = await http.get(Uri.parse(BaseUrl.jabatanAPI));
    _dataJabatan = json.decode(hasilGetData.body)['data'];
    notifyListeners();
  }

  ///Delete data karyawan
  Future<void> deleteData(String id) {
    return http.delete(Uri.parse(BaseUrl.karyawanAPI + id)).then(
      (response) {
        _dataResponse.removeWhere((key, value) => value.id_karyawan == id);
        notifyListeners();
        if (response.statusCode == 200) {
          _success(_dataResponse['message']);
          print(_dataResponse['message']);
        }
      },
    );
  }
}
