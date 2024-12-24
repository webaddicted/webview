import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:webview/utils/common/widget_helper.dart';
import 'package:webview/utils/constant/color_const.dart';
import 'package:webview/utils/constant/string_const.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:url_launcher/url_launcher.dart';
//  {START PAGE NAVIGATION}
void navigationPush(BuildContext context, StatefulWidget route) {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return route;
    },
  ));
}

void navigationRemoveAllPush(BuildContext context, StatefulWidget route) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) => route,
    ),
    (route) => false,
  );
}

void navigationPop(BuildContext context, StatefulWidget route) {
  Navigator.pop(context, MaterialPageRoute(builder: (context) {
    return route;
  }));
}

void navigationStateLessPush(BuildContext context, StatelessWidget route) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return route;
  }));
}

void navigationStateLessPop(BuildContext context, StatelessWidget route) {
  Navigator.pop(context, MaterialPageRoute(builder: (context) {
    return route;
  }));
}

Future<void> requestCameraPermission(Function isGranted1) async {
  Map<Permission, PermissionStatus> statues = await [
    Permission.camera,
    Permission.storage,
    Permission.photos
  ].request();
  PermissionStatus? statusCamera = statues[Permission.camera];
  PermissionStatus? statusStorage = statues[Permission.storage];
  PermissionStatus? statusPhotos = statues[Permission.photos];

  if (statusCamera == PermissionStatus.granted &&
      statusStorage == PermissionStatus.granted &&
      statusPhotos == PermissionStatus.granted) {
    isGranted1(true);
    print('Permission Granted');
  }
  bool isPermanentlyDenied =
      statusCamera == PermissionStatus.permanentlyDenied ||
          statusStorage == PermissionStatus.permanentlyDenied ||
          statusPhotos == PermissionStatus.permanentlyDenied;
  if (isPermanentlyDenied) {
    // _showSettingsDialog(context);
  }
}

imagePickerDialog({Function? pickImg}) {
  Widget dialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title:
          getTxtBlackColor(msg: 'Select Option', fontWeight: FontWeight.bold),
      content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
      GestureDetector(
        onTap: () async {
          Get.back();
          // var image = await ImagePicker.pickImage(source: ImageSource.camera);
          getImage(imageType:ImageSource.camera, pickImg:pickImg, clickImageType:"Camera");
          // getImageFromCamera(context, 0, selectedfile);
        },
        child: Container(
            padding: const EdgeInsets.all(15),
            child: getTxtBlackColor(msg: 'Take Photo')),
      ),
      const Divider(
        color: Colors.grey,
        height: 1,
      ),
      GestureDetector(
          onTap: () {
            Get.back();
            getImage(imageType:ImageSource.gallery, pickImg:pickImg, clickImageType:"Gallery");
            // var image = await ImagePicker.pickImage(source: ImageSource.gallery);
            // getImageFromCamera(context, 1, selectedfile);
          },
          child: Container(
              padding: const EdgeInsets.all(15),
              child: getTxtBlackColor(msg: 'Choose From Gallery'))),
              ],
            ));
  Get.dialog(dialog);
}

void getImageOpen({Function? pickImg}) async {
  var imageType = ImageSource.camera;
  var image;
  try {
    try {
      print("click1122:");
      image = await ImagePicker.platform.pickImage(
          source: imageType, preferredCameraDevice: CameraDevice.rear);
    } catch (Excep) {
      print("ExcepImage: $Excep");
    }
    File filePath = File(image.path);
    print("before : ${filePath.length}");
    final result = await FlutterImageCompress.compressWithFile(
      filePath.absolute.path,
      minWidth: 700,
      minHeight: 500,
      quality: 25,
      // rotate: 180,
    );
    print(filePath.lengthSync());
    // print("After : ${result.length}");
    final imageEncoded = base64.encode(result!);
    // print("Test : $imageEncoded");
    // final bytes = filePath.readAsBytesSync();
    // var base64Image = 'data:image/jpeg;base64,' + base64Encode(bytes);
    // print('object base64Image $base64Image');
    pickImg!(filePath, imageEncoded);
    // base64Image = Io.File(filePath.path).readAsBytesSync();
  } catch (error) {
    print("error11111: $error");
  }
}

void getImage({imageType, String clickImageType = "", Function? pickImg}) async {
  String type = clickImageType;

  try {
    var image = await ImagePicker().pickImage(source: imageType, preferredCameraDevice: CameraDevice.rear);
    File filePath = File(image?.path ?? "");
    // print("before : ${filePath.length}");
    final result = await FlutterImageCompress.compressWithFile(
      filePath.absolute.path,
      minWidth: 700,
      minHeight: 500,
      quality: 30,
      // rotate: 180,
    );
    print(filePath.lengthSync());
    // print("After : ${result.length}");
    // final imageEncoded = base64.encode(result);

    String imageEncoded = base64.encode(result!);
    print("Test : ${imageEncoded.toString()}");
    // final bytes = filePath.readAsBytesSync();
    // var base64Image = 'data:image/jpeg;base64,' + base64Encode(bytes);
    // print('object base64Image $base64Image');
    pickImg!(filePath, imageEncoded.toString(), type);
    // base64Image = Io.File(filePath.path).readAsBytesSync();
  } catch (error) {
    print("error11111: $error");
  }
}

Text getTxtBlackColor(
    {String msg = "",
    double? fontSize,
    FontWeight? fontWeight,
    int? maxLines,
    TextAlign? textAlign}) {
  return Text(
    msg,
    textAlign: textAlign,
    maxLines: maxLines,
    style: _getFontStyle(
        txtColor: ColorConst.BLACK_COLOR,
        fontSize: fontSize,
        fontWeight: fontWeight),
  );
}

TextStyle _getFontStyle(
    {Color txtColor = ColorConst.COLOR,
    double? fontSize,
    FontWeight? fontWeight,
    String? fontFamily,
    TextDecoration? txtDecoration}) {
  return TextStyle(
      color: txtColor,
      fontSize: fontSize ?? 14,
      decoration: txtDecoration ?? TextDecoration.none,
      // fontFamily: fontFamily == null ? AssetsConst.ZILLASLAB_FONT : fontFamily,
      fontWeight: fontWeight ?? FontWeight.normal);
}

/*
 void getFirbaseConfig() async {
  FirebaseRemoteConfig firebaseRemoteConfig = await FirebaseRemoteConfig.instance;
  await firebaseRemoteConfig.activate();
  await firebaseRemoteConfig.fetchAndActivate();
  var fcmVersionCode = firebaseRemoteConfig.getInt('versionCode');
  print('Welcome  ${fcmVersionCode}  ${packageInfo.buildNumber}  ');
  print('Welcome ${firebaseRemoteConfig.getAll()}');
  if (fcmVersionCode > int.parse(packageInfo.buildNumber)) {
    showCustomDialog(
        "A new version of ${StringConst.APP_NAME} is available.\nWould you like to update it now?",
        (bool isGranted) async {
      if (isGranted) {
        _launchURL(ApiConstant.PLAYSTORE_URL);
      } else {
        Get.back();
      }
    }, title: "Update App?", okBtn: "Update Now");
  }
}
*/

/*
 void getIosFirbaseConfig() async {
  FirebaseRemoteConfig firebaseRemoteConfig = await FirebaseRemoteConfig.instance;
  await firebaseRemoteConfig.activate();
  await firebaseRemoteConfig.fetchAndActivate();
  var fcmVersionCode = firebaseRemoteConfig.getInt('iosVersionCode');

  print('WelcomeIos  ${fcmVersionCode}  ${packageInfo.buildNumber}');
  print('WelcomeIosnew ${firebaseRemoteConfig.getAll()}');
  if (fcmVersionCode > int.parse(packageInfo.buildNumber)) {
    showCustomDialog(
        "A new version of ${StringConst.APP_NAME} is available.\nWould you like to update it now?",
            (bool isGranted) async {
          if (isGranted) {
            _launchURL(ApiConstant.APPSTORE_URL);
          } else {
            Get.back();
          }
        }, title: "Update App?", okBtn: "Update Now");
  }
}
*/

void _launchURL(String mobile) async => await canLaunch(mobile)
    ? await launch(mobile)
    : throw 'Could not launch $mobile';

Future<bool> checkInternetConnection() async {
  bool result = await InternetConnection().hasInternetAccess;;
  return result;
}

enum ApiStatus { loading, success, error }
final logger = Logger();
printLog(
    {String tag = "",
      required dynamic msg,
      ApiStatus status = ApiStatus.success}) {
  if (kDebugMode) {
    print("$tag : $msg");
    if (status == ApiStatus.error) {
      logger.e("$tag : $msg");
    } else {
      logger.d("$tag : $msg");
    }
  }
}
onWillPop() async {
  showCustomDialog(
    title: StringConst.warning,
      message: "Are you sure you want to exit this app?", okBtn: "Exit", cancelBtn: "Cancel",(bool isGranted) async {
    if (isGranted) {
      SystemNavigator.pop();
    } else {
      Get.back();
    }
  });
}
void pickFile(Function fileImg) async {
  try {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      File file = File(result.files.single.path!);
      final bytes = File(file.path).readAsBytesSync();
      String file64 = base64Encode(bytes);
      fileImg(file, file64);
    }
  } catch (error) {
    printLog(msg: "error11111: $error");
  }
}

shareData(String msg, {String subject = ""}) async {
  await Share.share(msg, subject: subject);
}

Future<void> openMap(double latitude, double longitude) async {
  String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  if (await canLaunchUrl(Uri.parse(googleUrl))) {
    await launchUrl(Uri.parse(googleUrl));
  } else {
    throw 'Could not open the map.';
  }
}

delay({int durationSec = 1,required Function click}) {
  int sec = (durationSec * 1000);
  Future.delayed(Duration(milliseconds: sec), () {
    click();
  });
}