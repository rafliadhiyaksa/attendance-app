import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:presensi_app/provider/api.dart';
import 'package:presensi_app/widgets/build_profile_picture.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';

class Karyawan with ChangeNotifier {
  Map<String, dynamic> _dataKaryawan = {};
  Map<String, dynamic> get dataKaryawan => _dataKaryawan;

  void _success() {
    AlertController.show(
      "Success",
      "Registration Success",
      TypeAlert.success,
    );
  }

  void _failed(statusCode) {
    AlertController.show(
      statusCode,
      "Registration Failed",
      TypeAlert.error,
    );
  }

  Future registerData(
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
    List facePict,
  ) async {
    var request = http.MultipartRequest('POST', BaseUrl.register);
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

    var facePictAsJson = json.encode(facePict);
    request.fields['face_pict'] = facePictAsJson;

    EasyLoading.show(
      status: 'Loading...',
      maskType: EasyLoadingMaskType.black,
    );
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      _dataKaryawan = json.decode(response.body);
      notifyListeners();
      EasyLoading.dismiss();
      _success();
      print("uploaded");
    } else {
      EasyLoading.dismiss();
      _failed(response.statusCode.toString());
      print("Gagal");
    }
  }

  // Karyawan findById(idKaryawan) {
  //   return _dataKaryawan.keys
  //       .firstWhere((id) => id.id_karyawan == idKaryawan);
  // }

  Future getData() async {
    var hasilGetData = await http.get(BaseUrl.login);
    _dataKaryawan = json.decode(hasilGetData.body);

    notifyListeners();
  }
}
