import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview/utils/common/global_utilities.dart';
import 'package:permission_handler/permission_handler.dart';
//var message= "If you deny this permission, basic features of your device may no longer function as intended";
var permissionSettingMsg =
"This app may not work correctly without the requested permissions.\nOpen the app settings screen to modify app permissions";

showPermissionSettingDialog(Function isOpenSetting,
    {String title = "Permission Required",
    String message = "",
    String okBtn = "Go to Settings",
    String cancelBtn = "Dismiss",
    bool isDismissible = false}) async {
  showDialog<bool>(
      context: Get.context!,
      barrierDismissible: isDismissible,
      builder: (_) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: getTxtBlackColor(
              msg: title, fontSize: 18, fontWeight: FontWeight.bold),
          content: getTxtBlackColor(msg: message, fontSize: 17),
          actions: <Widget>[
            TextButton(
                child: getTxtBlackColor(msg: okBtn, fontSize: 17),
                onPressed: () {
                  Get.back();
                  openAppSettings();
                  isOpenSetting(false);
                }),
            TextButton(
                child: getTxtBlackColor(msg: cancelBtn, fontSize: 17),
                onPressed: () {
                  Get.back();
                  isOpenSetting(false);
                }),
          ],
        );
      });
}
showCustomDialog(Function isGranted,
    {required String title,
      required String message,
      String okBtn = "ok",
      String cancelBtn = "Cancel",
      bool isDismissible = false}) async {
  showDialog<bool>(
      context: Get.context!,
      barrierDismissible: isDismissible,
      builder: (_) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: getTxtBlackColor(
              msg: title, fontSize: 18, fontWeight: FontWeight.bold),
          content: getTxtBlackColor(msg: message, fontSize: 17),
          actions: <Widget>[
            TextButton(
                child: getTxtBlackColor(msg: okBtn, fontSize: 17),
                onPressed: () {
                  isGranted(true);
                }),
            TextButton(
                child: getTxtBlackColor(msg: cancelBtn, fontSize: 17),
                onPressed: () {
                  Get.back();
                  isGranted(false);
                }),
          ],
        );
      });
}