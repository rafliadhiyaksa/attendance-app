import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:presensi_app/service/face_recognition_service.dart';
import 'package:presensi_app/view/face_registration.dart';
import 'package:presensi_app/view/login_page.dart';

import 'package:supercharged/supercharged.dart';
import 'package:form_field_validator/form_field_validator.dart';

import 'package:presensi_app/widgets/build_dropdown.dart';
import 'package:presensi_app/widgets/build_profile_picture.dart';
import 'package:presensi_app/widgets/build_text_form_field.dart';

import 'package:provider/provider.dart';
import 'package:presensi_app/provider/alamat.dart';
import 'package:presensi_app/provider/karyawan.dart';

class FormRegistration extends StatefulWidget {
  FormRegistration({Key? key}) : super(key: key);

  @override
  _FormRegistrationState createState() => _FormRegistrationState();
}

class _FormRegistrationState extends State<FormRegistration> {
  final Color primary = '3546AB'.toColor();

  final _key = GlobalKey<FormState>();

  FaceRecognitionService _faceRecognitionService = FaceRecognitionService();
  ProfilePicture _profilePicture = ProfilePicture();

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final tempatLahirController = TextEditingController();
  final dateController = TextEditingController();
  final noHpController = TextEditingController();
  final alamatController = TextEditingController();

  dynamic valueProvinsi;
  dynamic valueKota;
  dynamic valueKecamatan;
  dynamic valueKelurahan;
  dynamic valueGender;
  dynamic valueJabatan;

  dynamic namaProvinsi;
  dynamic namaKota;
  dynamic namaKecamatan;
  dynamic namaKelurahan;

  @override
  void dispose() {
    this._profilePicture.setValueImage(null);
    this._faceRecognitionService.setPredictedData(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final karyawanProvider = Provider.of<Karyawan>(context, listen: false);
    final alamatProvider = Provider.of<Alamat>(context, listen: false);
    List? predictedData = _faceRecognitionService.predictedData;
    print("REbuild");
    return Form(
      key: _key,
      child: Column(
        children: [
          //PROFIL PICTURE
          Container(child: _profilePicture),
          SizedBox(height: 36.0),

          //NAMA LENGKAP
          Container(
              child: BuildTextFormField(
            text: "Nama Lengkap",
            controller: namaController,
            validator: RequiredValidator(errorText: "Required*"),
          )),
          SizedBox(height: 20.0),

          //EMAIL ID
          Container(
              child: BuildTextFormField(
            text: "Email ID",
            type: TextInputType.emailAddress,
            controller: emailController,
            validator: MultiValidator([
              RequiredValidator(errorText: "Required*"),
              EmailValidator(errorText: "Not a valid Email"),
            ]),
          )),
          SizedBox(height: 20.0),

          //TEMPAT LAHIR
          Container(
              child: BuildTextFormField(
            text: "Tempat Lahir",
            controller: tempatLahirController,
            validator: RequiredValidator(errorText: "Required*"),
          )),
          SizedBox(height: 20.0),

          //TANGGAL LAHIR
          Container(
              child: BuildTextFormField(
            text: "Tanggal Lahir",
            suffixicon: Icon(Icons.date_range_rounded),
            readOnly: true,
            controller: dateController,
            validator: RequiredValidator(errorText: "Required*"),
            ontap: () async {
              var date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1960),
                lastDate: DateTime.now(),
              );
              dateController.text = date.toString().substring(0, 10);
            },
          )),
          SizedBox(height: 20.0),

          //NOMOR HANDPHONE
          Container(
              child: BuildTextFormField(
            text: "No. Handphone",
            type: TextInputType.phone,
            controller: noHpController,
            validator: RequiredValidator(errorText: "Required*"),
          )),
          SizedBox(height: 20.0),

          //JENIS KELAMIN
          Container(
            child: BuildDropdown(
              label: "Jenis Kelamin",
              value: valueGender,
              items: <String>[
                'Laki-laki',
                'Perempuan',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onchanged: (value) {
                setState(() {
                  valueGender = value;
                });
              },
            ),
          ),
          SizedBox(height: 20.0),

          //JABATAN
          Container(
            child: BuildDropdown(
              label: "Jabatan",
              value: valueJabatan,
              items: <String>[
                'Software Developer',
                'IT Support',
                'Database Administrator',
                'Project Manager',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onchanged: (value) {
                setState(() {
                  valueJabatan = value;
                });
              },
            ),
          ),
          SizedBox(height: 32.0),

          // ---------ALAMAT----------
          Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 2,
                  color: Colors.grey,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  "Alamat",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),

          // ALAMAT
          Container(
            child: BuildTextFormField(
              text: "Alamat",
              type: TextInputType.multiline,
              controller: alamatController,
              maxlines: null,
              maxlength: 150,
              minlines: 3,
              validator: RequiredValidator(errorText: "Required*"),
            ),
          ),
          SizedBox(height: 20.0),

          // PROVINSI
          Container(
            child: Consumer<Alamat>(
              builder: (context, value, child) {
                return BuildDropdown(
                  label: "Provinsi",
                  value: valueProvinsi,
                  items: value.dataProvinsi.map((e) {
                    return DropdownMenuItem(
                      child: Text(e['nama']),
                      value: e['id'],
                      onTap: () {
                        namaProvinsi = e['nama'];
                      },
                    );
                  }).toList(),
                  onchanged: (value) {
                    setState(() {
                      valueProvinsi = value;
                      valueKota = null;
                      valueKecamatan = null;
                      valueKelurahan = null;
                    });
                    alamatProvider.getKota(value);
                  },
                );
              },
            ),
          ),
          SizedBox(height: 20.0),

          // KABUPATEN / KOTA
          Container(child: Consumer<Alamat>(
            builder: (context, value, child) {
              return BuildDropdown(
                label: "Kota / Kabupaten",
                value: valueKota,
                items: value.dataKota.map((e) {
                  return DropdownMenuItem(
                    child: Text(e['nama']),
                    value: e['id'],
                    onTap: () {
                      namaKota = e['nama'];
                    },
                  );
                }).toList(),
                onchanged: (value) {
                  setState(() {
                    valueKota = value;
                    valueKecamatan = null;
                    valueKelurahan = null;
                  });
                  alamatProvider.getKecamatan(value);
                },
              );
            },
          )),
          SizedBox(height: 20.0),

          //KECAMATAN
          Container(child: Consumer<Alamat>(
            builder: (context, value, child) {
              return BuildDropdown(
                label: "Kecamatan",
                value: valueKecamatan,
                items: value.dataKecamatan.map((e) {
                  return DropdownMenuItem(
                    child: Text(e['nama']),
                    value: e['id'],
                    onTap: () {
                      namaKecamatan = e['nama'];
                    },
                  );
                }).toList(),
                onchanged: (value) {
                  setState(() {
                    valueKecamatan = value;
                    valueKelurahan = null;
                  });
                  alamatProvider.getKelurahan(value);
                },
              );
            },
          )),
          SizedBox(height: 20.0),

          ///INPUT KELURAHAN
          Container(child: Consumer<Alamat>(
            builder: (context, value, child) {
              return BuildDropdown(
                label: "Kelurahan",
                value: valueKelurahan,
                items: value.dataKelurahan.map((e) {
                  return DropdownMenuItem(
                    child: Text(e['nama']),
                    value: e['id'],
                    onTap: () {
                      namaKelurahan = e['nama'];
                    },
                  );
                }).toList(),
                onchanged: (value) {
                  setState(() {
                    valueKelurahan = value;
                  });
                },
              );
            },
          )),
          SizedBox(height: 30.0),

          //Face Registration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 65.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      onPrimary: primary,
                      enableFeedback: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17))),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => FaceRegistration(
                          cameraDescription: Login.cameraDescription!,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image(
                        image: AssetImage('assets/icon/face-id.png'),
                        width: 35,
                      ),
                      buildText("Daftarkan Wajah", 20, Colors.white)
                    ],
                  ),
                ),
              ),
              Container(
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: (predictedData == null) ? Colors.grey : Colors.green,
                  size: MediaQuery.of(context).size.width * 0.11,
                ),
              )
            ],
          ),

          SizedBox(
            height: 50.0,
          ),

          //TOMBOL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 55.0,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      enableFeedback: true,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: primary, width: 3.0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      karyawanProvider.getData();
                      print(predictedData);
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return AlertDialog(
                              title: buildText(
                                  "Keluar Registrasi", 20, Colors.black),
                              content: buildText(
                                  "Apakah Anda Yakin Ingin Keluar Registrasi?",
                                  15,
                                  Colors.black),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: buildText("Tidak", 15, primary)),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: buildText("Ya", 15, primary)),
                              ],
                            );
                          });
                    },
                    child: buildText("Batal", 20, primary)),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 55.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    onPrimary: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    if (_key.currentState!.validate() &&
                        ProfilePicture.image != null &&
                        _faceRecognitionService.predictedData != null) {
                      print("validated");
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: buildText(
                                  "Registrasi Akun", 20, Colors.black),
                              content: buildText(
                                  "Apakah anda yakin ingin registrasi akun?",
                                  15,
                                  Colors.black),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: buildText("Tidak", 15, primary)),
                                TextButton(
                                    onPressed: () {
                                      karyawanProvider.postData(
                                        namaController.text,
                                        emailController.text,
                                        tempatLahirController.text,
                                        dateController.text,
                                        noHpController.text,
                                        valueGender,
                                        valueJabatan,
                                        alamatController.text,
                                        namaProvinsi,
                                        namaKota,
                                        namaKecamatan,
                                        namaKelurahan,
                                        predictedData!,
                                      );
                                      Navigator.of(context).pop();
                                    },
                                    child: buildText("Ya", 15, primary)),
                              ],
                            );
                          });
                    } else if (!_key.currentState!.validate()) {
                      AlertController.show(
                        'Error',
                        'Semua Field Harus Terisi',
                        TypeAlert.error,
                      );
                    } else if (ProfilePicture.image == null) {
                      AlertController.show(
                        'Warning',
                        'Harus Menyertakan Foto Profil',
                        TypeAlert.error,
                      );
                    } else {
                      AlertController.show(
                        'Warning',
                        'Harus Mendaftarkan Wajah',
                        TypeAlert.error,
                      );
                    }
                  },
                  child: buildText("Daftar", 20, Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Text buildText(String text, double size, Color color) {
    return Text(
      text,
      style: TextStyle(
          color: color,
          fontFamily: "ProductSans",
          fontSize: size,
          fontWeight: FontWeight.w700),
    );
  }
}

class ChangeForm with ChangeNotifier {}
