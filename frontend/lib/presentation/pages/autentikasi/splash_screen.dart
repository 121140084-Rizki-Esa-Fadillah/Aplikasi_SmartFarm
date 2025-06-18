import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_app/presentation/pages/autentikasi/login.dart';
import 'package:frontend_app/presentation/pages/beranda/beranda_admin.dart';
import 'package:frontend_app/presentation/pages/beranda/beranda_user.dart';
import 'package:frontend_app/presentation/widget/background_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../monitoring/notifikasi.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _splashScreenLogic();
  }

  Future<void> _splashScreenLogic() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    bool isLoggedIn = token != null && token.isNotEmpty && !JwtDecoder.isExpired(token);

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (isLoggedIn) {
        _navigateToNotifikasi(initialMessage.data);
      } else {
        await prefs.remove('pending_notification');
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Login()));
      }
      return;
    }

    final pendingPayload = prefs.getString('pending_notification');
    if (pendingPayload != null) {
      if (isLoggedIn) {
        final data = jsonDecode(pendingPayload);
        await prefs.remove('pending_notification');
        _navigateToNotifikasi(data);
      } else {
        await prefs.remove('pending_notification');
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Login()));
      }
      return;
    }

    if (isLoggedIn) {
      if (role == "Admin") {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const BerandaAdmin()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const BerandaUser()));
      }
    } else {
      await prefs.remove('token');
      await prefs.remove('role');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Login()));
    }
  }


  void _navigateToNotifikasi(Map<String, dynamic> data) {
    final pondId = data['pondId'];
    final namePond = data['namePond'];

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => Notifikasi(pondId: pondId, namePond: namePond)),
    );
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
