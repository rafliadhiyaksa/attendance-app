import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:presensi_app/models/model_karyawan.dart';
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

  int get jumlahKaryawan => _dataKaryawan.length;

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
    required String namaDepan,
    required String namaBelakang,
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
    request.fields['NAMA_DEPAN'] = namaDepan;
    request.fields['NAMA_BELAKANG'] = namaBelakang;
    request.fields['EMAIL'] = email;
    request.fields['TEMPAT_LAHIR'] = tempatLahir;
    request.fields['TGL_LAHIR'] = tanggalLahir;
    request.fields['ID_GENDER'] = idGender;
    request.fields['NO_HP'] = noHp;
    request.fields['ID_JABATAN'] = idJabatan.toString();
    request.fields['ALAMAT'] = alamat;
    request.fields['PROVINSI'] = provinsi;
    request.fields['KOTA_KAB'] = kota;
    request.fields['KECAMATAN'] = kecamatan;
    request.fields['KELURAHAN'] = kelurahan;

    var profilPict = await http.MultipartFile.fromPath(
        'PROFIL_IMG', ProfilePicture.image!.path);
    request.files.add(profilPict);

    var facePictAsJson = json.encode(facePict);
    request.fields['DATA_WAJAH'] = facePictAsJson;

    EasyLoading.show(
      status: 'Loading...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
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
        _failed("Error ${response.statusCode}", _dataResponse['message']);
        throw response.statusCode;
      }
    } catch (err) {
      EasyLoading.dismiss();
      throw err;
    }

    // EasyLoading.dismiss();
  }

  ///Edit data karyawan
  Future<void> editData(
    String id,
    String nama,
    String email,
    String noHp,
    String jabatan,
    String alamat,
    String provinsi,
    String kota,
    String kecamatan,
    String kelurahan,
  ) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(BaseUrl.karyawanAPI + id));
    request.fields['NAMA'] = nama;
    request.fields['EMAIL'] = email;
    request.fields['NO_HP'] = noHp;
    request.fields['ID_JABATAN'] = jabatan;
    request.fields['ALAMAT'] = alamat;
    request.fields['PROVINSI'] = provinsi;
    request.fields['KOTA_KAB'] = kota;
    request.fields['KECAMATAN'] = kecamatan;
    request.fields['KELURAHAN'] = kelurahan;

    var profilPict = await http.MultipartFile.fromPath(
        'PROFIL_IMG', ProfilePicture.image!.path);
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
    if (response.statusCode >= 200 && response.statusCode < 300) {
      List dataResponse = json.decode(response.body)['data'];
      dataResponse.forEach((element) {
        List dataWajah = jsonDecode(element['DATA_WAJAH']);
        int idKaryawan = jsonDecode(element['ID_KARYAWAN']);
        // print("data wajah = $dataWajah");
        var karyawan = ModelKaryawan(
          idKaryawan: idKaryawan,
          namaDepan: element['NAMA_DEPAN'],
          namaBelakang: element['NAMA_BELAKANG'],
          email: element['EMAIL'],
          tempatLahir: element['TEMPAT_LAHIR'],
          tglLahir: element['TGL_LAHIR'],
          gender: element['GENDER'],
          noHp: element['NO_HP'],
          jabatan: element['JABATAN'],
          alamat: element['ALAMAT'],
          provinsi: element['PROVINSI'],
          kota: element['KOTA_KAB'],
          kecamatan: element['KECAMATAN'],
          kelurahan: element['KELURAHAN'],
          profilImg: element['PROFIL_IMG'],
          dataWajah: dataWajah,
        );
        _dataKaryawan.add(karyawan);
      });
      notifyListeners();
    } else {
      _failed("Error ${response.statusCode}", "Connection Timeout");
    }
  }

  ///get data gender
  Future<void> getGender() async {
    try {
      var response = await http.get(Uri.parse(BaseUrl.genderAPI));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _dataGender = json.decode(response.body)['data'];
        notifyListeners();
      } else {
        _failed("Error ${response.statusCode}", "Not Found");
      }
    } catch (err) {
      _failed("Error", "Connection Timeout");
      throw err;
    }
  }

  ///get data jabatan
  Future<void> getJabatan() async {
    try {
      var response = await http.get(Uri.parse(BaseUrl.jabatanAPI));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _dataJabatan = json.decode(response.body)['data'];
        notifyListeners();
      } else {
        _failed("Error ${response.statusCode}", "Not Found");
      }
    } catch (err) {
      _failed("Error", "Connection Timeout");
      throw err;
    }
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

  void logout() {}
}
