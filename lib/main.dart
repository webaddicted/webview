import 'package:webview/utils/common/firebase_utility.dart';
import 'package:webview/utils/constant/routers_const.dart';
import 'package:webview/utils/constant/routes.dart';
import 'package:webview/utils/constant/string_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  await initFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.put(AppController());
    return GetMaterialApp(
      title: StringConst.APP_NAME,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.rightToLeft,
     // initialBinding: InitialBinding(),
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity
      ),
      initialRoute: RoutersConst.initialRoute,
      getPages: routes(),
    );
  }
}