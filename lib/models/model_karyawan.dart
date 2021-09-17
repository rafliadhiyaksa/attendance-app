import 'dart:io';

class ModelKaryawan {
  int? idKaryawan;
  String? namaDepan,
      namaBelakang,
      email,
      tempatLahir,
      tglLahir,
      gender,
      noHp,
      jabatan,
      alamat,
      provinsi,
      kota,
      kecamatan,
      kelurahan,
      profilImg;
  List? dataWajah;

  ModelKaryawan(
      {this.idKaryawan,
      this.namaDepan,
      this.namaBelakang,
      this.email,
      this.tempatLahir,
      this.tglLahir,
      this.gender,
      this.noHp,
      this.jabatan,
      this.alamat,
      this.provinsi,
      this.kota,
      this.kecamatan,
      this.kelurahan,
      this.profilImg,
      this.dataWajah});
}
