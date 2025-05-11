import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_app/presentation/pages/autentikasi/login.dart';
import 'package:frontend_app/presentation/pages/beranda/beranda.dart';
import 'package:frontend_app/presentation/pages/beranda/beranda_user.dart';
import 'package:frontend_app/presentation/widget/background_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../monitoring/kontrol_pakan_aerator.dart';
import '../monitoring/monitoirng_sensor/monitoring.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleStartupLogic();
  }

  Future<void> _handleStartupLogic() async {
    await Future.delayed(const Duration(seconds: 3));

    // 🔍 Cek apakah dibuka dari notifikasi (terminated)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final role = prefs.getString('role');

      if (token != null && token.isNotEmpty && !JwtDecoder.isExpired(token)) {
        final data = initialMessage.data;
        final type = data['type'];
        final pondId = data['pondId'];
        final namePond = data['namePond'];

        switch (type) {
          case 'feed_alert':
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Beranda()));
            return;
          case 'water_quality_alert':
          case 'threshold_update':
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => Monitoring(pondId: pondId, namePond: namePond)));
            return;
          case 'feed_schedule_update':
          case 'aerator_control_update':
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => KontrolPakanAerator(pondId: pondId, namePond: namePond)));
            return;
        }
      }
    }

    // ✅ Jika tidak dari notifikasi, cek token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');

    if (token != null && token.isNotEmpty && !JwtDecoder.isExpired(token)) {
      if (role == "Admin") {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Beranda()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const BerandaUser()));
      }
    } else {
      await prefs.remove('token');
      await prefs.remove('role');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Login()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundWidget(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/Logo-App.png",
                  width: size.width * 0.6,
                ),
                const SizedBox(height: 10),
                Text(
                  "Sadewa Smartfarm",
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.07,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
