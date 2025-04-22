import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend_app/presentation/pages/autentikasi/splash_screen.dart';

// 🔹 Inisialisasi Firebase Messaging
FirebaseMessaging messaging = FirebaseMessaging.instance;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
String? fcmDeviceToken;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  String title = message.notification?.title ?? "";
  String body = message.notification?.body ?? "";

  if (title.isNotEmpty && body.isNotEmpty) {
    print("📩 Notifikasi diterima di background: $title - $body");
  } else {
    print("⚠️ Notifikasi kosong diabaikan.");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🔹 Setup Firebase Cloud Messaging
  await setupFirebaseMessaging();

  // 🔹 Setup Notifikasi Lokal
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
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}

// ✅ Setup Firebase Messaging (Cegah Notifikasi Kosong)
Future<void> setupFirebaseMessaging() async {
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    fcmDeviceToken = await messaging.getToken();
    print("🔑 Firebase Token: $fcmDeviceToken");

    if (fcmDeviceToken == null) {
      print("❌ Gagal mendapatkan device token");
    }

    // (Opsional) handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      fcmDeviceToken = newToken;
      print("🔁 Device token diperbarui: $fcmDeviceToken");
    });

  } else {
    print("❌ Izin notifikasi ditolak.");
  }

  // Listener notifikasi
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String? type = message.data['type'];
    String title = message.notification?.title ?? "";
    String body = message.notification?.body ?? "";

    if (title.isNotEmpty && body.isNotEmpty) {
      switch (type) {
        case 'feed_alert':
        case 'water_quality_alert':
        case 'threshold_update':
        case 'feed_schedule_update':
        case 'aerator_control_update':
          showLocalNotification(title, body);
          break;
        default:
          print("⚠️ Notifikasi dengan tipe tidak dikenali: $type");
      }
    } else {
      print("⚠️ Notifikasi kosong diabaikan.");
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}


// ✅ Setup Lokal Notifikasi
void setupLocalNotifications() {
  var androidSettings = const AndroidInitializationSettings('@drawable/logo_app');
  var initializationSettings = InitializationSettings(android: androidSettings);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // 🔹 Konfigurasi Channel Notifikasi untuk Android 13+
  var androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'General Notifications',
    description: 'Channel untuk notifikasi utama',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);
  print("🚨 Notification channel created: ${androidChannel.id}");

}


// ✅ Tampilkan Popup Notifikasi di Foreground (Cegah Notifikasi Kosong)
void showLocalNotification(String title, String body) {
  if (title.isEmpty || body.isEmpty) {
    print("⚠️ Notifikasi lokal kosong diabaikan.");
    return;
  }

  var androidDetails = const AndroidNotificationDetails(
    'high_importance_channel',
    'General Notifications',
    importance: Importance.high,
    priority: Priority.high,
  );

  var notificationDetails = NotificationDetails(android: androidDetails);
  print("🚨 Menampilkan popup notifikasi lokal");
  flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
}