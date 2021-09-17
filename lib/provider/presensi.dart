import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:presensi_app/models/model_presensi.dart';
import 'package:presensi_app/models/model_setting.dart';

import 'package:presensi_app/provider/api.dart';

class Presensi with ChangeNotifier {
  static final Presensi _presensi = Presensi._internal();
  factory Presensi() {
    return _presensi;
  }
  Presensi._internal();

  //menyimpan semua data presensi dari database sesuai dengan id_karyawan
  List<dynamic> _dataPresensi = [];
  List<dynamic> get dataPresensi => this._dataPresensi;

  //menyimpan semua data respon dari database
  Map<String, dynamic> _dataResponse = {};
  Map<String, dynamic> get dataResponse => this._dataResponse;

  //menyimpan data setting presensi
  List<dynamic> _dataSetting = [];
  List<dynamic> get dataSetting => _dataSetting;

  int get jumlahPresensi => _dataPresensi.length;
  int get jumlahSetting => _dataSetting.length;

  // alert gagal
  void _failed(String title, String message) {
    AlertController.show(
      title,
      message,
      TypeAlert.error,
    );
  }

  int? idKaryawan;
  void id(id) {
    idKaryawan = id;
  }

  /// melakukan presensi masuk
  Future<void> presensiMasuk() async {
    final now = DateFormat('HH:mm:ss').format(DateTime.now());
    print(now);

    Uri url = Uri.parse(BaseUrl.presensiAPI);
    try {
      http.Response response = await http.post(
        url,
        body: {"ID_KARYAWAN": idKaryawan.toString(), "JAM_MASUK": now},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _dataResponse = json.decode(response.body);
        if (_dataResponse['value'] == 1) {
          List dataPresensi = dataResponse['data'];
          dataPresensi.forEach((element) {
            int idPresensi = jsonDecode(element['ID_PRESENSI']);
            int idKaryawan = jsonDecode(element['ID_KARYAWAN']);

            var presensi = ModelPresensi(
              idPresensi: idPresensi,
              idKaryawan: idKaryawan,
              tanggal: element['TGL_PRESENSI'],
              jamMasuk: element['JAM_MASUK'],
              jamPulang: element['JAM_PULANG'],
            );

            _dataPresensi.add(presensi);
          });
        }
        notifyListeners();
      } else {
        _failed("Error ${response.statusCode}", "Connection Failed");
      }
    } catch (e) {
      throw e;
    }
  }

  /// melakukan presensi pulang
  Future<void> presensiPulang(int id) async {
    final now = DateFormat('HH:mm:ss').format(DateTime.now());

    Uri url = Uri.parse(BaseUrl.presensiAPI + "$id");

    try {
      http.Response response = await http.post(url, body: {"JAM_PULANG": now});
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(response.statusCode);
        _dataResponse = json.decode(response.body);

        if (_dataResponse['value'] == 1) {
          List dataPresensi = dataResponse['data'];
          dataPresensi.forEach((element) {
            int idPresensi = jsonDecode(element['ID_PRESENSI']);
            int idKaryawan = jsonDecode(element['ID_KARYAWAN']);

            var presensi = ModelPresensi(
              idPresensi: idPresensi,
              idKaryawan: idKaryawan,
              tanggal: element['TGL_PRESENSI'],
              jamMasuk: element['JAM_MASUK'],
              jamPulang: element['JAM_PULANG'],
            );
            int index = _dataPresensi.indexWhere(
                (element) => element.idPresensi == presensi.idPresensi);
            _dataPresensi[index] = presensi;
          });
          notifyListeners();
          // _success(dataResponse['message']);
        }
        // else if (dataResponse['value'] == 2) {
        //   _warning("Warning", dataResponse['message']);
        // } else {
        //   _warning("Warning", dataResponse['message']);
        // }
      } else {
        _failed("Error ${response.statusCode}", "Connection Failed");
      }
    } catch (e) {
      throw e;
    }
  }

  /// get data presensi sesuai id karyawan
  Future getPresensi() async {
    var response = await http
        .get(Uri.parse(BaseUrl.presensiAPI + "id_karyawan=$idKaryawan"));

    List dataResponse = json.decode(response.body)['data'];
    _dataPresensi = [];
    dataResponse.forEach((element) {
      int idPresensi = jsonDecode(element['ID_PRESENSI']);
      int idKaryawan = jsonDecode(element['ID_KARYAWAN']);

      var presensi = ModelPresensi(
        idPresensi: idPresensi,
        idKaryawan: idKaryawan,
        tanggal: element['TGL_PRESENSI'],
        jamMasuk: element['JAM_MASUK'],
        jamPulang: element['JAM_PULANG'],
      );
      if (_dataPresensi
          .every((element) => presensi.idPresensi != element.idPresensi)) {
        _dataPresensi.add(presensi);
      }
    });
    notifyListeners();
  }

  Future<void> getSetting() async {
    var response = await http.get(Uri.parse(BaseUrl.settingAPI));

    List dataResponse = json.decode(response.body)['data'];
    dataResponse.forEach((element) {
      int idSetting = int.parse(element['ID_SETTING']);

      var setting = ModelSetting(
        idSetting: idSetting,
        namaApp: element['NAMA_APP'],
        mulaiPresensi: element['MULAI_PRESENSI'],
        batasPresensi: element['BATAS_PRESENSI'],
        presensiPulang: element['PRESENSI_PULANG'],
      );
      if (_dataSetting
          .every((element) => element.idSetting != setting.idSetting)) {
        _dataSetting.add(setting);
      }
    });
    notifyListeners();
  }
}
