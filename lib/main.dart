import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rolley_app/AppFlow/MainTabScreen.dart';
import 'package:rolley_app/AppFlow/SplashScreen.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message ---------->>>>> ${message.messageId}');
}

AndroidNotificationChannel channel;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      showBadge: true,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Platform.isAndroid ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.grey.shade400,
      systemNavigationBarDividerColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPref pref = SharedPref();

  String stockName = "";
  String channelId = "";
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  GlobalKey<NavigatorState> navState = GlobalKey<NavigatorState>();

  void iOSPermission() async {
    debugPrint("<<<<<-------------- User granted permission -------------->>>>>");
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    debugPrint("User granted permission -------------->>>>> ${settings.authorizationStatus}");
  }

  firebaseInit() async {
    await Firebase.initializeApp();

    if (Platform.isIOS) iOSPermission();
    _firebaseMessaging.getToken().then((value) => tokenReceived(value));
    _firebaseMessaging.getInitialMessage().then((RemoteMessage message) {
      if (message != null) {
        debugPrint("message -- main -- initState ---------->>>>> ${message.messageType}");
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: 'ic_notifications',
              enableLights: true,
              playSound: true,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published! - data ---------->>>>> ${message.data}');

      stockName = message.data['stock_name'];
      channelId = message.data['channel_id'];

      Navigator.push(
        navState.currentContext,
        MaterialPageRoute(
          builder: (context) => MainTab(),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    firebaseInit();
  }

  void tokenReceived(String pushToken) async {
    debugPrint("main push token ---------->>>>> $pushToken");
    await pref.saveString(pref.DeviceToken, pushToken);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROLLEY',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
