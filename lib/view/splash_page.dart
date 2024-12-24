import 'package:flutter/material.dart';
import 'package:webview/utils/common/global_utilities.dart';
import 'package:webview/utils/constant/assets_constant.dart';
import 'package:webview/utils/constant/color_const.dart';
import 'package:webview/utils/constant/string_const.dart';
import 'package:webview/webview/webview_widget.dart';
import 'package:get/get.dart';
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _splashContainer(),
    );
  }

  Widget _splashContainer() {
    delay(
        durationSec: 5,
        click: () {
          Navigator.pushReplacement(
            Get.context!,
            MaterialPageRoute(
                builder: (context) =>
                    const WebViewScreen(initialUrl: StringConst.webUrl)),
          );
        });
    return InkWell(
        onTap: () {},
        child: Container(
            color: ColorConst.WHITE_COLOR,
            height: double.infinity,
            width: double.infinity,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Image.asset(AssetsConst.appLogo, width: 250, height: 250)
                ])));
  }
}
