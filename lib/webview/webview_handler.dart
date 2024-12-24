import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview/utils/common/firebase_utility.dart';
import 'package:webview/utils/common/global_utilities.dart';
import 'package:webview/utils/common/permission_handler.dart';
import 'package:webview/webview/webview_constant.dart';
import 'package:webview/webview/webview_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:webview_flutter/webview_flutter.dart';

class WebViewHandler {
  WebViewController? controller;
  var isShowBridgeResponse = false;
  var disableRefresh = false;
  Future<void> bridgeHandler(String message) async {
    printLog(msg: "channel message : $message");
    var request = jsonDecode(message);
    String funName = request[WebViewConstant.funName];
    if (funName == WebViewConstant.screenShotAndShare) {
      var msg = "";
      screenshotController.capture().then((img) async {
        if(request.containsKey(WebViewConstant.params)) {
          var params = request[WebViewConstant.params];

          if (params.containsKey("msg")) {
            msg = params["msg"] ?? "";
          }
        }
        final shareResult = await Share.shareXFiles(
          text: msg,
            [
              XFile.fromData(
                  img!,
                  name: 'flutter_logo.png',
                  mimeType: 'image/png',
              )
            ]
        );
        // printLog(msg: "screenshotController $image $shareResult");
      });
    }else if (funName == "refreshPage") {
      var params = request[WebViewConstant.params];
      disableRefresh = params["disableRefresh"];
    }else if (funName == WebViewConstant.showBridgeResult) {
      var params = request[WebViewConstant.params];
      isShowBridgeResponse = params["isShowBridgeResponse"]?? false;
    }else if (funName == WebViewConstant.fetchLocation) {
      getLocation();
    } else if (funName == WebViewConstant.openWebPage) {
      var params = request[WebViewConstant.params];
      openBrowser(params["url"]);
    } else if (funName == WebViewConstant.cameraGallery) {
      imagePickerDialog(
          pickImg: (File filePath, String baseData64, String imageType) {
            var jsonResponse = {"base64": 'data:image/jpeg;base64,$baseData64'};
            returnResult(
                webViewBridgeCallback(WebViewConstant.cameraGallery, jsonResponse));
          });
    } else if (funName == WebViewConstant.camera) {
      getImage(
          imageType: ImageSource.camera,
          clickImageType: "Camera",
          pickImg: (File filePath, String baseData64, String imageType) {
            var jsonResponse = {"base64": 'data:image/jpeg;base64,$baseData64'};
            returnResult(
                webViewBridgeCallback(WebViewConstant.camera, jsonResponse));
          });
    } else if (funName == WebViewConstant.getPdf) {
      pickFile((File filePath, String baseData64) {
        var jsonResponse = {
          "base64": 'data:application/pdf;base64,$baseData64'
        };
        returnResult(
            webViewBridgeCallback(WebViewConstant.getPdf, jsonResponse));
      });
    } else if (funName == WebViewConstant.shareMsg) {
      var params = request[WebViewConstant.params];
      var msg = params["msg"];
      await Share.share(msg);
    }else if(funName.contains(WebViewConstant.reqPermission)){
      var params = request[WebViewConstant.params];
      var permissionType = params["permissionType"]?? "";
      getPermission(permissionType);
    }else if(funName ==WebViewConstant.getDeviceInfo){
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.buildNumber;
      String udid = await FlutterUdid.udid;
      var jsonResponse = {"version": version, "platform":defaultTargetPlatform.toString(),"deviceId":udid};

      returnResult(
          webViewBridgeCallback(WebViewConstant.getDeviceInfo, jsonResponse));
    }else if (funName.contains(WebViewConstant.openUrl)) {
      var params = request[WebViewConstant.params];
      var url = params["url"]?? "";
      UrlLauncher.launch(url);
    } else if (funName == WebViewConstant.fetchFcmToken) {
      var token = await getFcmToken();
      var jsonResponse = {"fcmToken": token};
      returnResult(
          webViewBridgeCallback(WebViewConstant.fetchFcmToken, jsonResponse));
    }else if (funName == "openDialer") {
      var params = request["params"];
      String mobileNumber = params["mobileNumber"];
      openDialer(mobileNumber);
    }

  }

  getLocation() async {
    String currentLat = "";
    String currentLong = "";
    Position position;
    try {
      Map<String, dynamic> jsonData;
      PermissionHandler.requestPermissionForMsg("location")
          .then((isPermissionGranted) async => {
                if (isPermissionGranted)
                  {
                    position =
                        await GeolocatorPlatform.instance.getCurrentPosition(),
                    currentLat = position.latitude.toString(),
                    currentLong = position.longitude.toString(),
                    jsonData = {
                      "latitude": currentLat,
                      "longitude": currentLong
                    },
                    returnResult(webViewBridgeCallback(
                        WebViewConstant.fetchLocation, jsonData)),
                  }
                else
                  {
                    returnResult(webViewBridgeCallback(WebViewConstant.fetchLocation,
                        {"errorCode": "404", "error": true, "errorMsg": ""}))
                  }
              });
    } catch (ex) {
      printLog(msg: "getLocation $ex");
      returnResult(webViewBridgeCallback(WebViewConstant.fetchLocation,
          {"errorCode": "404", "error": true, "errorMsg": ""}));
    }
  }

  Future<void> setDeviceId() async {
    final info = await DeviceInfoPlugin().androidInfo;
    String deviceId = info.id;
    printLog(msg: "Device ID : $deviceId");
    returnResult(deviceId);
  }

  openDialer(String number) async {
    String url = "tel:$number";
    if (await UrlLauncher.canLaunch(url)) {
      await UrlLauncher.launch(url);
    } else {
      await UrlLauncher.launch(url);
    }
  }
  openBrowser(String url) async {
    if (!await UrlLauncher.launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
  getPermission(String permissionType) async {
    try {
      Map<String, dynamic> jsonData;
      PermissionHandler.requestPermissionForMsg(permissionType)
          .then((isPermissionGranted) async => {
        jsonData = {"status": isPermissionGranted},
        returnResult(webViewBridgeCallback(
            WebViewConstant.reqPermission, jsonData)),
      });
    } catch (ex) {
      printLog(msg: "getLocation $ex");
      printLog(msg: "getLocation $ex");
      returnResult(webViewBridgeCallback(WebViewConstant.reqPermission,
          {"errorCode": "404", "error": true, "errorMsg": "$ex"}));
    }
  }
 webViewBridgeCallback(String funName, Map<dynamic, dynamic> jsonResponse)=>jsonEncode({
    "funName": funName,
    "params": jsonResponse});

  void returnResult(result) {
    var script = 'document.getElementById("${WebViewConstant.WEBVIEW_APP_NAME}").innerHTML=${jsonEncode(result)};';
    printLog(msg: "WebViewResponse script : $script");
    controller?.runJavaScript(script);
    if (isShowBridgeResponse) {
      var snackBar = SnackBar(
          content: Text(script.toString()));
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
    }
  }
}
