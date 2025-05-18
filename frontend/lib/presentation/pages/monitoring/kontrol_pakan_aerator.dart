import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../blocks/kontrol_aerator.dart';
import '../../blocks/kontrol_pakan.dart';
import '../../widget/navigation/app_bar_widget.dart';
import '../../widget/navigation/navigasi_monitoring.dart';
import '../../widget/background_widget.dart';
import '../beranda/beranda_admin.dart';
import '../beranda/beranda_user.dart';
import 'riwayat_kualitas_air/riwayat_kualitas_air.dart';
import 'monitoirng_sensor/monitoring.dart';
import 'notifikasi.dart';

class KontrolPakanAerator extends StatelessWidget {
  final String pondId;
  final String namePond;

  const KontrolPakanAerator({super.key, required this.pondId, required this.namePond});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: "Kontrol Pakan & Aerator",
        onBackPress: () async {
          final prefs = await SharedPreferences.getInstance();
          final role = prefs.getString('role');

          if (role == "Admin") {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const BerandaAdmin()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const BerandaUser()),
            );
          }
        },
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundWidget(),

          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KontrolPakan(pondId: pondId),
                    const SizedBox(height: 20),
                    KontrolAerator(pondId: pondId),
                  ],
                ),
              ),
            ),
          ),

          // **Navigasi Monitoring dalam Stack**
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavigasiMonitoring(
              selectedIndex: 3, // Pastikan index sesuai halaman
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Monitoring(pondId: pondId, namePond: namePond)), // ✅ Kirim pondId ke Monitoring
                  );
                }
                else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RiwayatKualitasAir(pondId: pondId, namePond: namePond)), // ✅ Kirim pondId ke Riwayat
                  );
                }
                else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Notifikasi(pondId: pondId, namePond: namePond)), // ✅ Kirim pondId ke Notifikasi
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
