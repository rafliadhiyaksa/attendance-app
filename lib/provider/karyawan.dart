import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'package:presensi_app/service/face_recognition_service.dart';
import 'package:presensi_app/widgets/build_profile_picture.dart';
import 'package:presensi_app/models/model_karyawan.dart';
import 'package:presensi_app/provider/api.dart';

class Karyawan with ChangeNotifier {
  static final Karyawan _karyawan = Karyawan._internal();
  factory Karyawan() {
    return _karyawan;
  }
  Karyawan._internal();

  ModelKaryawan _dataKaryawan = ModelKaryawan();
  ModelKaryawan get dataKaryawan => _dataKaryawan;

  Map<String, dynamic> _dataResponse = {};
  Map<String, dynamic> get dataResponse => _dataResponse;

  List<dynamic> _dataWajah = [];
  List<dynamic> get dataWajah => _dataWajah;

  List<dynamic> _dataGender = [];
  List<dynamic> get dataGender => _dataGender;

  List<dynamic> _dataJabatan = [];
  List<dynamic> get dataJabatan => _dataJabatan;

  int get jumlahDataWajah => _dataWajah.length;

  ModelKaryawan _tempDataKaryawan = ModelKaryawan();
  File? img;

  Future<void> saveDataToPref() async {
    _dataKaryawan = _tempDataKaryawan;

    final sharedPref = await SharedPreferences.getInstance();

    final sharedPrefAuth = json.encode({
      'idKaryawan': _tempDataKaryawan.idKaryawan.toString(),
      'namaDepan': _tempDataKaryawan.namaDepan,
      'namaBelakang': _tempDataKaryawan.namaBelakang,
      'email': _tempDataKaryawan.email,
      'tempatLahir': _tempDataKaryawan.tempatLahir,
      'tglLahir': _tempDataKaryawan.tglLahir,
      'gender': _tempDataKaryawan.gender,
      'noHp': _tempDataKaryawan.noHp,
      'jabatan': _tempDataKaryawan.jabatan,
      'alamat': _tempDataKaryawan.alamat,
      'provinsi': _tempDataKaryawan.provinsi,
      'kota': _tempDataKaryawan.kota,
      'kecamatan': _tempDataKaryawan.kecamatan,
      'kelurahan': _tempDataKaryawan.kelurahan,
      // 'profilImg': _tempDataKaryawan.profilImg,
      'profilImg': _tempDataKaryawan.profilImg,
      'dataWajah': _tempDataKaryawan.dataWajah.toString(),
    });
    sharedPref.setString('authData', sharedPrefAuth);
    // String? currImg = await sharedPref.getStringList('imageData');
    notifyListeners();
  }

  bool get isAuth => dataKaryawan.idKaryawan != null ? true : false;

  Future<void> urlToFile(String imageName) async {
    print("BUILD 1");
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath/' + imageName);
    http.Response response =
        await http.get(Uri.parse(BaseUrl.uploadAPI + imageName));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      Uint8List uint8List = response.bodyBytes;
      var buffer = uint8List.buffer;
      ByteData byteData = ByteData.view(buffer);
      file = await file.writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      img = file;
    } else {
      _failed("Error", "Connection Timeout");
    }
  }

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

  /// Auth data wajah
  Future<void> getDataWajah() async {
    var response =
        await http.get(Uri.parse(BaseUrl.karyawanAPI + "data_wajah"));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      List dataResponse = json.decode(response.body)['data'];
      dataResponse.forEach((element) {
        int idKaryawan = jsonDecode(element['ID_KARYAWAN']);
        List dataWajah = jsonDecode(element['DATA_WAJAH']);
        var wajah = ModelKaryawan(
          idKaryawan: idKaryawan,
          dataWajah: dataWajah,
        );
        _dataWajah.add(wajah);
      });
      notifyListeners();
    } else {
      _failed("Error ${response.statusCode}", "Connection Timeout");
    }
  }

  ///Get data karyawan
  Future<void> getKaryawan(idKaryawan) async {
    var response = await http
        .get(Uri.parse(BaseUrl.karyawanAPI + "$idKaryawan"))
        .catchError((err) async {
      print("ERROR = $err");
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      List dataResponse = json.decode(response.body)['data'];
      dataResponse.forEach((element) {
        List dataWajah = jsonDecode(element['DATA_WAJAH']);
        int idKaryawan = jsonDecode(element['ID_KARYAWAN']);
        // print("BUILD 1");
        _tempDataKaryawan = ModelKaryawan(
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
          // profilImg: img,
          dataWajah: dataWajah,
        );
      });

      notifyListeners();
    } else {
      _failed("Error ${response.statusCode}", "Connection Timeout");
    }
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

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _dataResponse = json.decode(response.body);
        notifyListeners();
        if (_dataResponse['value'] == 1) {
          _success(_dataResponse['message']);
          print("uploaded");
        } else if (_dataResponse['value'] == 2) {
          _failed("Error", _dataResponse['message']);
        }
      } else {
        _failed("Error ${response.statusCode}", _dataResponse['message']);
        throw response.statusCode;
      }
    } catch (err) {
      throw err;
    }
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

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      _dataResponse = json.decode(response.body);
      notifyListeners();
      if (_dataResponse['value'] == 1) {
        _success(_dataResponse['message']);
        print("uploaded");
      } else if (_dataResponse['value'] == 2) {
        _failed("Error", _dataResponse['message']);
      }
    } else {
      _failed(
          "Error " + response.statusCode.toString(), _dataResponse['message']);
      print("Gagal");
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

  Future<void> logout() async {
    FaceRecognitionService _faceRecognitionService = FaceRecognitionService();
    final pref = await SharedPreferences.getInstance();
    pref.clear();

    _faceRecognitionService.setPredictedData([]);
    _dataKaryawan = ModelKaryawan();

    notifyListeners();
  }

  Future<bool> autoLogin() async {
    final pref = await SharedPreferences.getInstance();

    if (!pref.containsKey('authData')) {
      return false;
    }

    final myData = json.decode(pref.getString('authData').toString())
        as Map<String, dynamic>;
    _dataKaryawan = ModelKaryawan(
      idKaryawan: int.parse(myData['idKaryawan']),
      namaDepan: myData['namaDepan'],
      namaBelakang: myData['namaBelakang'],
      email: myData['email'],
      tempatLahir: myData['tempatLahir'],
      tglLahir: myData['tglLahir'],
      gender: myData['gender'],
      noHp: myData['noHp'],
      jabatan: myData['jabatan'],
      alamat: myData['alamat'],
      provinsi: myData['provinsi'],
      kota: myData['kota'],
      kecamatan: myData['kecamatan'],
      kelurahan: myData['kelurahan'],
      profilImg: myData['profilImg'],
      dataWajah: json.decode(myData['dataWajah']),
    );
    notifyListeners();
    return true;
  }

  void setDataWajah(value) {
    _dataWajah = value;
  }
}
