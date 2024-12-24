import 'package:webview/utils/common/global_utilities.dart';
import 'package:webview/utils/common/widget_helper.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler{

  static requestPermission(Permission permission, Function isPermissionGranted)async {
   PermissionStatus permissionStatus = await permission.status;
   if (permissionStatus != PermissionStatus.granted) {
      permissionStatus = await Permission.location.request();
    }
   if(permissionStatus == PermissionStatus.granted){
     isPermissionGranted(true);
   }else if (permissionStatus == PermissionStatus.denied || permissionStatus == PermissionStatus.permanentlyDenied) {
     showPermissionSettingDialog(message: "$permissionSettingMsg\n$permission",isDismissible: false,isPermissionGranted);
   }else{
     isPermissionGranted(false);
   }
  }

  // List<Permission> statuses = [
  //   Permission.location,
  //   Permission.camera,
  //   Permission.sms,
  //   Permission.storage,
  // ];
  static requestMultiplePermission(List<Permission> multiPermission, Function isPermissionGranted)async {
    for (var element in multiPermission) {
      var status = await element.status;
      printLog(msg: " requestMultiplePermission : $element $status.");
      if (status.isDenied || status.isPermanentlyDenied) {
        await multiPermission.request();
      }
    }
    String deniedPermission= "";
    for (var element in multiPermission) {
      var status = await element.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        deniedPermission = "$deniedPermission\n$element";
      }
    }
    if(deniedPermission.isNotEmpty){
      showPermissionSettingDialog(message: "$permissionSettingMsg\n$deniedPermission",isDismissible: false,(isOpenSetting){
        isPermissionGranted(false);
      });
    }else{
      isPermissionGranted(true);
    }

    // PermissionStatus permissionStatus = await permission.status;
    // if (permissionStatus != PermissionStatus.granted) {
    //   permissionStatus = await Permission.location.request();
    // }
    // if(permissionStatus == PermissionStatus.granted){
    //   isPermissionGranted(true);
    // }else if (permissionStatus == PermissionStatus.denied || permissionStatus == PermissionStatus.permanentlyDenied) {
    //   showCustomDialog(isPermissionGranted);
    // }else{
    //   isPermissionGranted(false);
    // }
  }


  static Future<bool> requestPermissionForMsg(String message)async {
    late PermissionStatus permission;
    late PermissionStatus permissionStatus;
    if(message =="location") {
      permission = await Permission.location.status;
      if (permission != PermissionStatus.granted) {
        permissionStatus = await Permission.location.request();
      }
    }else if(message =="contacts") {
      permission = await Permission.contacts.status;
      if (permission != PermissionStatus.granted) {
        permissionStatus = await Permission.contacts.request();
      }
    }else if(message =="camera") {
      permission = await Permission.camera.status;
      if (permission != PermissionStatus.granted) {
        permissionStatus = await Permission.camera.request();
      }
    }else if(message =="storage") {
      permission = await Permission.storage.status;
      if (permission != PermissionStatus.granted) {
        permissionStatus = await Permission.storage.request();
      }
    }else if(message =="notification") {
      permission = await Permission.notification.status;
      if (permission != PermissionStatus.granted) {
        permissionStatus = await Permission.notification.request();
      }
    }else if(message =="mediaLibrary") {
      permission = await Permission.mediaLibrary.status;
      if (permission != PermissionStatus.granted ) {
        permissionStatus = await Permission.mediaLibrary.request();
      }
    }else  {
      permission = await Permission.mediaLibrary.status;
      if (permission != PermissionStatus.granted) {
        permissionStatus = await Permission.mediaLibrary.request();
      }
    }
    if(permission == PermissionStatus.granted || permissionStatus == PermissionStatus.granted){
      return true;
    }else if (permissionStatus == PermissionStatus.denied) {
      return false;
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
      return false;
    }else{
      return false;
    }
  }


}


