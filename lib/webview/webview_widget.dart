import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:webview/utils/common/global_utilities.dart';
import 'package:webview/utils/constant/assets_constant.dart';
import 'package:webview/utils/constant/string_const.dart';
import 'package:webview/webview/drag_gesture_pull_to_refresh.dart';
import 'package:webview/webview/webview_constant.dart';
import 'package:webview/webview/webview_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

ScreenshotController screenshotController = ScreenshotController();

class WebViewScreen extends StatefulWidget {
  final String initialUrl;

  const WebViewScreen({
    super.key,
    required this.initialUrl,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with WidgetsBindingObserver {
  late WebViewController _controller;
  late DragGesturePullToRefresh dragGesturePullToRefresh; // Here
  WebViewHandler webViewHandler = WebViewHandler();
  final webViewLoaderPercentage = 0.obs;

  @override
  void initState() {
    super.initState();
    dragGesturePullToRefresh = DragGesturePullToRefresh();
    getController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // on portrait / landscape or other change, recalculate height
    dragGesturePullToRefresh.setHeight(MediaQuery.of(context).size.height);
  }

  @override
  Widget build(context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (isPop) async {
          final canGoBack = await _controller.canGoBack() ?? false;
          printLog(msg: "canGoBack $canGoBack");
          if (canGoBack) {
            _controller.goBack();
          } else {
            onWillPop();
          }
        },
        child: SafeArea(
            child:
                Scaffold(resizeToAvoidBottomInset: false, body: getWebView())));
  }

  Widget getWebView() {
    return Scaffold(
      body: Stack(children: [
        Center(child: getLoader()),
        RefreshIndicator(onRefresh: () {
          if (!webViewHandler.disableRefresh) {
            return dragGesturePullToRefresh.refresh();
          } else {
            return dragGesturePullToRefresh.finished();
          }
        }, child: Builder(builder: (context) {
          dragGesturePullToRefresh.setContext(context); // Here
          return Screenshot(
              controller: screenshotController,
              child: WebViewWidget(
                  controller: _controller,
                  gestureRecognizers: {
                    Factory(() => dragGesturePullToRefresh)
                  }));
        })),
        Center(child: getNoInternetStatus()),

        // ElevatedButton(
        //     style: ButtonStyle(
        //         foregroundColor:
        //         MaterialStateProperty.all<Color>(Colors.white),
        //         backgroundColor:
        //         MaterialStateProperty.all<Color>(Colors.red),
        //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        //             RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(35.0),
        //                 side: const BorderSide(color: Colors.red)))),
        //     onPressed: () async {
        //       // List<Permission> statuses = [
        //       //   Permission.location,
        //       //   Permission.camera
        //       // ];
        //       // PermissionHandler.requestMultiplePermission(statuses, (isPermissionGranted){});
        //      var funName = "{\"funName\":\"screenShotAndShare\",\"params\":{\"msg\":\"919024061407\"}}";
        //       webViewHandler.bridgeHandler(funName);
        //      //    var snackBar = const SnackBar(
        //      //        content: Text(StringConst.noInternetConnection));
        //      //    ScaffoldMessenger.of(context).showSnackBar(snackBar);
        //      //  screenshotController.capture();
        //       ///Capture and save to a file
        //
        //     },
        //     child: const Text("Retry",
        //         style:
        //         TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))
      ]),
    );
  }

  void getController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    _controller = WebViewController();
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(onProgress: (int progress) async {
          printLog(msg: 'WebView is loading (progress : $progress%)');
          if (await checkInternetConnection()) {
            webViewLoaderPercentage.value = progress;
          }
        }, onPageStarted: (String url) {
          printLog(msg: 'Page started loading: $url');
          dragGesturePullToRefresh.started();
        }, onPageFinished: (String url) async {
          printLog(msg: 'Page finished loading: $url');
          dragGesturePullToRefresh.finished();
          if ((await checkInternetConnection()) == false) {
            webViewLoaderPercentage.value = -1;
          }
        }, onWebResourceError: (WebResourceError error) async {
          dragGesturePullToRefresh.finished();
          if ((await checkInternetConnection()) == false) {
            webViewLoaderPercentage.value = -1;
          }
        }),
      )
      ..addJavaScriptChannel(
        WebViewConstant.WEBVIEW_APP_NAME,
        onMessageReceived: (JavaScriptMessage message) {
          printLog(msg: 'JavaScriptMessage Bridge Call : ${message.message}');
          webViewHandler.bridgeHandler(message.message);
        },
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
    webViewHandler.controller = _controller;
    dragGesturePullToRefresh.setController(_controller).setContext(context);
    WidgetsBinding.instance.addObserver(this);
  }

  getNoInternetStatus() {
    return Obx(() {
      var value = webViewLoaderPercentage.value;
      if (value == -1) {
        return Container(
            color: Colors.white,
            width: double.infinity,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(AssetsConst.noInternetConnection,
                  width: 250.0, height: 100.0),
              const SizedBox(height: 10),
              const Text(
                StringConst.noInternetConnection,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor:
                      WidgetStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.red),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35.0),
                              side: const BorderSide(color: Colors.red)))),
                  onPressed: () async {
                    bool check = await checkInternetConnection();
                    if (check) {
                      webViewLoaderPercentage.value = 0;
                      dragGesturePullToRefresh.refresh();
                    } else {
                      var snackBar = const SnackBar(
                          content: Text(StringConst.noInternetConnection));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: const Text("Retry",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))
            ]));
      } else {
        return Container();
      }
    });
  }

  getLoader() {
    return Obx(() {
      var value = webViewLoaderPercentage.value;
      if (value >= 0 && value < 60) {
        return Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(
                          // value: double.parse("${value/100}"),
                          color: Colors.orange,
                          strokeWidth: 4)),
                  Text("loading...",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17.0))
                ]));
      } else {
        return Container();
      }
    });
  }
}
