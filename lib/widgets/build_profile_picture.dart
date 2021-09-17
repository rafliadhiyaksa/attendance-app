import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presensi_app/provider/api.dart';
import 'package:presensi_app/provider/karyawan.dart';
import 'package:provider/provider.dart';
import 'package:supercharged/supercharged.dart';

class ProfilePicture extends StatefulWidget {
  static dynamic _image;
  static dynamic get image => _image;

  ProfilePicture();

  void setValueImage(value) {
    ProfilePicture._image = value;
  }

  @override
  _ProfilePictureState createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  Color primary = '3546AB'.toColor();
  final crop = ImageCropper();
  final picker = ImagePicker();
  String? imgUrl;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Karyawan>(context, listen: false).dataKaryawan;
    return CircleAvatar(
      radius: 75,
      backgroundColor: Colors.grey,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 72,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: ProfilePicture.image != null
                  ? FileImage(ProfilePicture.image!)
                  : NetworkImage(
                          BaseUrl.uploadAPI + provider.profilImg.toString())
                      as ImageProvider,
              child: ProfilePicture.image == null && provider.profilImg == null
                  ? FaIcon(
                      FontAwesomeIcons.userAlt,
                      size: 25,
                    )
                  : null,
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  blurRadius: 1,
                  color: Colors.grey.shade500,
                )
              ], borderRadius: BorderRadius.all(Radius.circular(30))),
              child: GestureDetector(
                onTap: () {
                  _showPickOptionsDialog(context);
                },
                child: CircleAvatar(
                  radius: 23,
                  child: FaIcon(
                    FontAwesomeIcons.camera,
                    size: 20,
                    color: primary,
                  ),
                  backgroundColor: 'E8E8E8'.toColor(),
                ),
              ),
            ),
          )
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

  _loadPicker(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      File pickedImage = File(pickedFile.path);
      _cropImage(pickedImage);
    }
    Navigator.pop(context);
  }

  _cropImage(File pickedFile) async {
    final cropped = await ImageCropper.cropImage(
        androidUiSettings: AndroidUiSettings(
          toolbarColor: primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: primary,
        ),
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
        ]);
    if (cropped != null) {
      setState(() {
        ProfilePicture._image = cropped;
      });
    }
  }

  void _showPickOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        title: buildText("Pilih Opsi", 20, Colors.black),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: buildText(
                "Gallery",
                15,
                Colors.black,
              ),
              leading: Icon(
                Icons.photo_camera_back_rounded,
                color: Colors.black,
              ),
              onTap: () {
                _loadPicker(ImageSource.gallery);
              },
            ),
            ListTile(
              title: buildText("Camera", 15, Colors.black),
              leading: Icon(
                Icons.camera,
                color: Colors.black,
              ),
              onTap: () {
                _loadPicker(ImageSource.camera);
              },
            )
          ],
        ),
      ),
    );
  }
}
