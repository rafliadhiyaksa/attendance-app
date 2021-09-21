import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:supercharged/supercharged.dart';
import 'package:provider/provider.dart';

import '../provider/alamat.dart';
import '../provider/karyawan.dart';
import '../service/face_recognition_service.dart';
import './face_registration.dart';
import '../widgets/build_dropdown.dart';
import '../widgets/build_profile_picture.dart';
import '../widgets/build_text_form_field.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  Color primary = '3546AB'.toColor();
  bool isInit = true;
  final _key = GlobalKey<FormState>();

  FaceRecognitionService _faceRecognitionService = FaceRecognitionService();
  ProfilePicture _profilePicture = ProfilePicture();

  final namaDepanController = TextEditingController();
  final namaBelakangController = TextEditingController();
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

  dynamic namaGender;
  dynamic namaJabatan;
  dynamic namaProvinsi;
  dynamic namaKota;
  dynamic namaKecamatan;
  dynamic namaKelurahan;

  @override
  void didChangeDependencies() {
    if (isInit) {
      Provider.of<Alamat>(context, listen: false).getProvinsi();
      Provider.of<Karyawan>(context, listen: false).getGender();
      Provider.of<Karyawan>(context, listen: false).getJabatan();
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    this._profilePicture.setValueImage(null);
    this._faceRecognitionService.setCurrFaceData([]);
    TextEditingController().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraDescription =
        ModalRoute.of(context)!.settings.arguments as CameraDescription;
    final karyawanProvider = Provider.of<Karyawan>(context, listen: false);
    final alamatProvider = Provider.of<Alamat>(context, listen: false);
    List currFaceData =
        Provider.of<FaceRecognitionService>(context).currFaceData;

    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        final value = await buildShowDialog(context);
        return value == true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: FaIcon(FontAwesomeIcons.arrowLeft),
            iconSize: 20,
            onPressed: () {
              buildShowDialog(context);
            },
          ),
        ),
        backgroundColor: primary,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40.0,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: buildText("Registrasi", 40, Colors.white)),
                Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: buildText("Data Diri Karyawan", 22, Colors.white)),
                SizedBox(
                  height: 30.0,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35))),
                  width: double.infinity,
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _key,
                    child: Column(
                      children: [
                        //PROFIL PICTURE
                        Container(child: _profilePicture),
                        SizedBox(height: 36.0),

                        //NAMA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: width * 0.40,
                              child: BuildTextFormField(
                                text: "Nama Depan",
                                controller: namaDepanController,
                                validator:
                                    RequiredValidator(errorText: "Required*"),
                              ),
                            ),
                            Container(
                              width: width * 0.40,
                              child: BuildTextFormField(
                                text: "Nama Belakang",
                                controller: namaBelakangController,
                                validator:
                                    RequiredValidator(errorText: "Required*"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.0),

                        //EMAIL
                        Container(
                            child: BuildTextFormField(
                          text: "Email",
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
                            validator:
                                RequiredValidator(errorText: "Required*"),
                            ontap: () async {
                              var date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1960),
                                lastDate: DateTime.now(),
                                initialDatePickerMode: DatePickerMode.year,
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                              );
                              dateController.text =
                                  date.toString().substring(0, 10);
                            },
                          ),
                        ),
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
                          child: Consumer<Karyawan>(
                            builder: (context, value, child) {
                              return BuildDropdown(
                                label: "Jenis Kelamin",
                                value: valueGender,
                                items: value.dataGender.map((e) {
                                  return DropdownMenuItem(
                                    child: Text(e['GENDER']),
                                    value: e['ID_GENDER'],
                                    onTap: () {
                                      namaGender = e['GENDER'];
                                    },
                                  );
                                }).toList(),
                                onchanged: (value) {
                                  setState(() {
                                    valueGender = value;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20.0),

                        //JABATAN
                        Container(
                          child: Consumer<Karyawan>(
                            builder: (context, value, child) {
                              return BuildDropdown(
                                label: "Jabatan",
                                value: valueJabatan,
                                items: value.dataJabatan.map((e) {
                                  return DropdownMenuItem(
                                    child: Text(e['JABATAN']),
                                    value: e['ID_JABATAN'],
                                    onTap: () {
                                      namaJabatan = e['JABATAN'];
                                    },
                                  );
                                }).toList(),
                                onchanged: (value) {
                                  setState(() {
                                    valueJabatan = value;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 32.0),

                        // ---------ALAMAT----------
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 3,
                                color: Colors.grey.shade400,
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
                            validator:
                                RequiredValidator(errorText: "Required*"),
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
                              width: MediaQuery.of(context).size.width * 0.67,
                              height: 65.0,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: primary,
                                    enableFeedback: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15))),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          FaceRegistration(cameraDescription),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Image(
                                      image:
                                          AssetImage('assets/icon/face-id.png'),
                                      width: 30,
                                    ),
                                    buildText(
                                        "Daftarkan Wajah", 18, Colors.white)
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              child: FaIcon(
                                FontAwesomeIcons.checkCircle,
                                color: (currFaceData.length == 0)
                                    ? Colors.grey
                                    : Colors.green,
                                size: MediaQuery.of(context).size.width * 0.13,
                              ),
                            )
                          ],
                        ),

                        SizedBox(
                          height: 50.0,
                        ),

                        /// tombol daftar
                        Container(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              primary: primary,
                            ),
                            onPressed: () {
                              if (_key.currentState!.validate() &&
                                  ProfilePicture.image != null &&
                                  currFaceData.length != 0) {
                                showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25))),
                                        title: buildText("Registrasi Akun", 20,
                                            Colors.black),
                                        content: buildText(
                                            "Apakah anda yakin ingin registrasi akun?",
                                            15,
                                            Colors.black),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: buildText(
                                                  "Tidak", 15, primary)),
                                          TextButton(
                                              onPressed: () {
                                                karyawanProvider.postData(
                                                  namaDepan:
                                                      namaDepanController.text,
                                                  namaBelakang:
                                                      namaBelakangController
                                                          .text,
                                                  email: emailController.text,
                                                  tempatLahir:
                                                      tempatLahirController
                                                          .text,
                                                  tanggalLahir:
                                                      dateController.text,
                                                  noHp: noHpController.text,
                                                  idGender: valueGender,
                                                  idJabatan: valueJabatan,
                                                  alamat: alamatController.text,
                                                  provinsi: namaProvinsi,
                                                  kota: namaKota,
                                                  kecamatan: namaKecamatan,
                                                  kelurahan: namaKelurahan,
                                                  facePict: currFaceData,
                                                );
                                                Navigator.of(context).pop();
                                              },
                                              child:
                                                  buildText("Ya", 15, primary)),
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
                            child: buildText("Daftar", 18, Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        extendBody: true,
      ),
    );
  }

  Future<dynamic> buildShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          title: buildText("Keluar Registrasi", 20, Colors.black),
          content:
              buildText("Apakah Anda Yakin Ingin Keluar?", 15, Colors.black),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
                child: buildText("Tidak", 15, primary)),
            TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                  Navigator.of(context).pop(true);
                },
                child: buildText("Ya", 15, primary))
          ],
        );
      },
    );
  }

  Text buildText(String text, double size, Color color) {
    return Text(
      text,
      style: TextStyle(
          color: color,
          fontSize: size,
          fontFamily: 'ProductSans',
          fontWeight: FontWeight.bold),
    );
  }
}
