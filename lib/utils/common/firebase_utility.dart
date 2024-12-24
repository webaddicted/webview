import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:webview/utils/common/global_utilities.dart';

initFirebase()async{
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  getFcmToken();
}
getFcmToken() async {
  String? token = "";
  try {
    token = await FirebaseMessaging.instance.getToken();
    printLog(msg: "Firebase Token : $token");
  } catch (error) {
    printLog(msg: "Firebase Token Error $error");
  }
  return token;
}
logFcmEvent(String eventName, Map<String, Object>? param){
  FirebaseAnalytics.instance.logEvent(
    name: 'event_name',
    parameters: param,
  );
}
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // if (kIsWeb) {
    //   return web;
    // }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // case TargetPlatform.iOS:
      //   return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // static const FirebaseOptions web = FirebaseOptions(
  //   apiKey: 'AIzaSyA-MkM1z8YGc_yJ4Z1r3LGsdfOtmknak',
  //   appId: '1:67977657210:web:e3da4fad4b11aa4473b4c3',
  //   messagingSenderId: '67977657210',
  //   projectId: 'movies4u0',
  //   authDomain: 'movies4u0.firebaseapp.com',
  //   databaseURL: 'https://movies4u0-default-rtdb.firebaseio.com',
  //   storageBucket: 'movies4u0.appspot.com',
  //   measurementId: 'G-C2QWDT793Q',
  // );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCcU4q24qhSDAmnQXiZZRkdNGFdxBy2UyE',
    appId: '1:492280411355:android:70dd74fcf168315d7208fe',
    messagingSenderId: '492280411355',
    projectId: 'jojo-executive',
    // databaseURL: 'https://ezeegoopartners-default-rtdb.firebaseio.com',
    // storageBucket: 'ezeegoopartners.appspot.com',
  );

  // static const FirebaseOptions ios = FirebaseOptions(
  //   apiKey: 'AIzaSyAa4RRBD1t2Kiiwqaedefgg6a7DIt_hM',
  //   appId: '1:67977657210:ios:c04bd17a952a9f9273b4c3',
  //   messagingSenderId: '67977657210',
  //   projectId: 'movies4u0',
  //   databaseURL: 'https://movies4u0-default-rtdb.firebaseio.com',
  //   storageBucket: 'movies4u0.appspot.com',
  //   iosBundleId: 'com.ezeego.ezeegopartner',
  // );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp();
  printLog(msg: 'A bg message just showed up :  ${message.messageId}');
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
    playSound: true);



