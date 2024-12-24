
import 'package:webview/utils/constant/routers_const.dart';
import 'package:webview/view/splash_page.dart';
import 'package:get/route_manager.dart';

routes() => [
  GetPage(name: RoutersConst.initialRoute, page: () => const SplashPage()),

];