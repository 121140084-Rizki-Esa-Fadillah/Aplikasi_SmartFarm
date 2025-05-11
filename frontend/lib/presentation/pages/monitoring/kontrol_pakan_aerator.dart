import 'package:flutter/material.dart';
import '../../blocks/kontrol_aerator.dart';
import '../../blocks/kontrol_pakan.dart';
import '../../widget/navigation/app_bar_widget.dart';
import '../../widget/navigation/navigasi_monitoring.dart';
import '../../widget/background_widget.dart';
import '../beranda/beranda.dart';
import 'riwayat_kualitas_air/riwayat_kualitas_air.dart';
import 'monitoirng_sensor/monitoring.dart';
import 'notifikasi.dart';

class KontrolPakanAerator extends StatelessWidget {
  final String pondId;
  final String namePond;

  const KontrolPakanAerator({super.key, required this.pondId, required this.namePond}); // ✅ Pastikan pondId bersifat required

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: "Kontrol Pakan & Aerator",
        onBackPress: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const Beranda()),
          );
        },
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundWidget(),

          // **Konten Utama dengan ScrollView agar tidak tertutup navigasi**
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 60.0), // Hindari overlap dengan navigasi
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KontrolPakan(pondId: pondId), // ✅ Pastikan pondId dikirim
                    const SizedBox(height: 20),
                    KontrolAerator(pondId: pondId), // ✅ Pastikan pondId dikirim
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
