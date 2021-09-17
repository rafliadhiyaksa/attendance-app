import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:presensi_app/models/model_karyawan.dart';
import 'package:presensi_app/provider/alamat.dart';
import 'package:presensi_app/provider/karyawan.dart';
import 'package:presensi_app/widgets/build_dropdown.dart';
import 'package:presensi_app/widgets/build_profile_picture.dart';
import 'package:presensi_app/widgets/build_text_form_field.dart';
import 'package:provider/provider.dart';
import 'package:supercharged/supercharged.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

ProfilePicture _profilePicture = ProfilePicture();

class _ProfilePageState extends State<ProfilePage> {
  @override
  void didChangeDependencies() {
    // _profilePicture.setValueImage(
    //     Provider.of<Karyawan>(context, listen: false).dataKaryawan.profilImg);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _profilePicture.setValueImage(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataKaryawan =
        Provider.of<Karyawan>(context, listen: false).dataKaryawan;
    final id = dataKaryawan.idKaryawan;
    double height = MediaQuery.of(context).size.height;

    final Color primary = '3546AB'.toColor();

    final emailController =
        TextEditingController(text: id == null ? "" : dataKaryawan.email!);
    final tempatLahirController =
        TextEditingController(text: id == null ? "" : dataKaryawan.tempatLahir);
    final dateController =
        TextEditingController(text: id == null ? "" : dataKaryawan.tglLahir);
    final noHpController =
        TextEditingController(text: id == null ? "" : dataKaryawan.noHp);
    final genderController =
        TextEditingController(text: id == null ? "" : dataKaryawan.gender);
    final alamatController =
        TextEditingController(text: id == null ? "" : dataKaryawan.alamat);

    dynamic valueProvinsi = id == null ? "" : dataKaryawan.provinsi!;
    dynamic valueKota = id == null ? "" : dataKaryawan.kota!;
    dynamic valueKecamatan = id == null ? "" : dataKaryawan.kecamatan!;
    dynamic valueKelurahan = id == null ? "" : dataKaryawan.kelurahan!;

    dynamic namaProvinsi;
    dynamic namaKota;
    dynamic namaKecamatan;
    dynamic namaKelurahan;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.arrowLeft),
          iconSize: 20,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: buildText("Personal Data", 20, Colors.white),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.signOutAlt),
            iconSize: 20,
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    title: buildText("Logout", 20, Colors.black),
                    content: buildText(
                        "Apakah Anda Yakin Ingin Keluar ?", 15, Colors.black),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: buildText("Tidak", 15, primary)),
                      TextButton(
                          onPressed: () {
                            Provider.of<Karyawan>(context, listen: false)
                                .logout();
                            Navigator.pushNamedAndRemoveUntil(
                                context, 'login', (route) => false);
                          },
                          child: buildText("Ya", 15, primary))
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      backgroundColor: primary,
      body: SingleChildScrollView(
        child: Container(
          color: primary,
          child: Column(
            children: [
              SizedBox(
                height: height * 0.18,
              ),
              Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: 'F8F8F8'.toColor(),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        top: 80, right: 32, left: 32, bottom: 32),
                    child: Column(
                      children: [
                        buildText(
                            id == null
                                ? ""
                                : "${dataKaryawan.namaDepan!} ${dataKaryawan.namaBelakang!}",
                            20,
                            Colors.black),
                        SizedBox(height: 5.0),

                        buildText(id == null ? "" : dataKaryawan.jabatan!, 15,
                            Colors.grey.shade700),
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
                          readOnly: true,
                        )),
                        SizedBox(height: 20.0),

                        //TEMPAT LAHIR
                        Container(
                          child: BuildTextFormField(
                            text: "Tempat Lahir",
                            controller: tempatLahirController,
                            validator:
                                RequiredValidator(errorText: "Required*"),
                            readOnly: true,
                          ),
                        ),
                        SizedBox(height: 20.0),

                        //TANGGAL LAHIR
                        Container(
                          child: BuildTextFormField(
                            text: "Tanggal Lahir",
                            suffixicon: Icon(
                              Icons.date_range_rounded,
                              color: primary,
                            ),
                            readOnly: true,
                            controller: dateController,
                            validator:
                                RequiredValidator(errorText: "Required*"),
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

                        //NOMOR HANDPHONE
                        Container(
                          child: BuildTextFormField(
                            text: "Jenis Kelamin",
                            readOnly: true,
                            type: TextInputType.phone,
                            controller: genderController,
                            validator:
                                RequiredValidator(errorText: "Required*"),
                          ),
                        ),
                        SizedBox(height: 20.0),

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
                                // onchanged: (value) {
                                //   setState(() {
                                //     valueProvinsi = value;
                                //     valueKota = null;
                                //     valueKecamatan = null;
                                //     valueKelurahan = null;
                                //   });
                                //   alamatProvider.getKota(value);
                                // },
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
                              // onchanged: (value) {
                              //   setState(() {
                              //     valueKota = value;
                              //     valueKecamatan = null;
                              //     valueKelurahan = null;
                              //   });
                              //   alamatProvider.getKecamatan(value);
                              // },
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
                              // onchanged: (value) {
                              //   setState(() {
                              //     valueKecamatan = value;
                              //     valueKelurahan = null;
                              //   });
                              //   alamatProvider.getKelurahan(value);
                              // },
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
                              // onchanged: (value) {
                              //   setState(() {
                              //     valueKelurahan = value;
                              //   });
                              // },
                            );
                          },
                        )),
                        SizedBox(height: 30.0),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -80,
                    child: ProfilePicture(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
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
