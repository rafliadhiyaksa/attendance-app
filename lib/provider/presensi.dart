import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';

import 'package:presensi_app/provider/api.dart';

class Presensi with ChangeNotifier {
  static final Presensi _presensi = Presensi._internal();
  factory Presensi() {
    return _presensi;
  }
  Presensi._internal();

  List<dynamic> _dataPresensi = [];
  List<dynamic> get dataPresensi => this._dataPresensi;

  Map<String, dynamic> _dataResponse = {};
  Map<String, dynamic> get dataResponse => _dataResponse;

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

  ///presensi masuk
  Future<void> presensiMasuk({required int idKaryawan}) async {
    Uri url = Uri.parse(BaseUrl.presensiAPI);
    final dateFormat = DateFormat('yyyy-MM-dd');
    final jamFormat = DateFormat('hh:mm:ss');

    final datetimeNow = dateFormat.format(DateTime.now());
    final timeNow = jamFormat.format(DateTime.now());

    return http
        .post(
      url,
      body: json.encode(
        {
          "ID_KARYAWAN": idKaryawan,
          "TGL_PRESENSI": datetimeNow,
          "JAM_MASUK": timeNow,
          "JAM_PULANG": "-",
        },
      ),
    )
        .then((response) {
      if (response.statusCode == 200) {
        _dataResponse = json.decode(response.body);
        notifyListeners();
        if (_dataResponse['value'] == 1) {
          _success(_dataResponse['message']);
          print("presensi berhasil");
        } else if (_dataResponse['value'] == 2) {
          _failed("Error", _dataResponse['message']);
        }
      } else {
        _failed("Error " + response.statusCode.toString(),
            _dataResponse['message']);
      }
    });
  }

  ///presensi pulang
  Future<void> presensiPulang(int id) {
    final jamFormat = DateFormat('hh:mm:ss');
    final timeNow = jamFormat.format(DateTime.now());

    Uri url = Uri.parse(BaseUrl.presensiAPI + id.toString());
    return http
        .post(
      url,
      body: json.encode(
        {"JAM_PULANG": timeNow},
      ),
    )
        .then((response) {
      if (response.statusCode == 200) {
        _dataResponse = json.decode(response.body);
        notifyListeners();
        _success(_dataResponse['message']);
      } else {
        _failed("Error " + response.statusCode.toString(),
            _dataResponse['message']);
      }
    });
  }

  Future<void> getPresensi(String idKaryawan) async {
    var response = await http.get(Uri.parse(BaseUrl.presensiAPI + idKaryawan));

    _dataPresensi = json.decode(response.body)['data'];
    notifyListeners();
  }
}
