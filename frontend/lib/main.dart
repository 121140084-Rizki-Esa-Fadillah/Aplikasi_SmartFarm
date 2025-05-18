import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend_app/presentation/pages/autentikasi/splash_screen.dart';
import 'package:frontend_app/presentation/pages/monitoring/notifikasi.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
String? fcmDeviceToken;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await setupFirebaseMessaging(subscribe: false);

  setupLocalNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}

// Setup Firebase Messaging
Future<void> setupFirebaseMessaging({required bool subscribe}) async {
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    fcmDeviceToken = await messaging.getToken();
    print("Firebase Token: $fcmDeviceToken");

    if (subscribe) {
      await messaging.subscribeToTopic('global_notifications');
      print("Subscribed to global_notifications");
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      fcmDeviceToken = newToken;
      print("Device token diperbarui: $fcmDeviceToken");
    });

    // Notifikasi saat app aktif
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("FCM diterima (foreground): ${message.notification?.title}, ${message.notification?.body}, ${message.data}");

      String? type = message.data['type'];
      String title = message.notification?.title ?? "";
      String body = message.notification?.body ?? "";

      if (title.isNotEmpty && body.isNotEmpty) {
        Map<String, dynamic> payload = {
          'type': type,
          'pondId': message.data['pondId'],
          'namePond': message.data['namePond'],
        };

        showLocalNotification(title, body, data: payload);
      }
    });

    // Notifikasi dibuka dari background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Dibuka dari notifikasi (background): ${message.data}");
      handleNotificationClick(jsonEncode(message.data));
    });
  } else {
    print("Izin notifikasi ditolak.");
  }
}

// Notifikasi lokal (manual)
void setupLocalNotifications() {
  var androidSettings = const AndroidInitializationSettings('ic_notification');
  var initializationSettings = InitializationSettings(android: androidSettings);

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        // Simpan sementara untuk SplashScreen saat cold start
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_notification', response.payload!);

        handleNotificationClick(response.payload!);
        print("Klik notifikasi: ${response.payload}");
      }
    },
  );


  var androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'General Notifications',
    description: 'Channel untuk notifikasi utama',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

  print("Notification channel created: ${androidChannel.id}");
}

// Tampilkan notifikasi lokal manual
void showLocalNotification(String title, String body, {Map<String, dynamic>? data}) {
  if (title.isEmpty || body.isEmpty) return;

  var androidDetails = const AndroidNotificationDetails(
    'high_importance_channel',
    'General Notifications',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'ic_notification',
  );

  flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    NotificationDetails(android: androidDetails),
    payload: data != null ? jsonEncode(data) : null,
  );
}

// Navigasi berdasarkan tipe notifikasi
void handleNotificationClick(String payload) {
  final data = jsonDecode(payload);
  final type = data['type'];
  final pondId = data['pondId'];
  final namePond = data['namePond'];

  print("Navigasi berdasarkan tipe: $type");

  MyApp.navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => Notifikasi(pondId: pondId, namePond: namePond)),
  );
}
