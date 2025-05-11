import 'package:flutter/material.dart';
import '../../../blocks/kolom_riwayat.dart';
import '../../../widget/navigation/app_bar_widget.dart';
import '../../../widget/navigation/navigasi_monitoring.dart';
import '../../../widget/background_widget.dart';
import '../../beranda/beranda.dart';
import '../kontrol_pakan_aerator.dart';
import '../monitoirng_sensor/monitoring.dart';
import '../notifikasi.dart';

class RiwayatKualitasAir extends StatelessWidget {
  final String pondId;
  final String namePond; // ✅ Tambahkan namePond

  const RiwayatKualitasAir({super.key, required this.pondId, required this.namePond});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBarWidget(
        title: "Riwayat Kualitas Air",
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

          // **Konten Utama Riwayat Laporan tanpa scroll**
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.0225,
                left: screenWidth * 0.04,
                right: screenWidth * 0.04,
                bottom: screenHeight * 0.10, // Menyesuaikan batas bawah
              ),
              child: Column(
                children: [
                  Expanded(
                    child: KolomRiwayat(pondId: pondId, namePond: namePond,), // Pastikan tidak ada scrolling di dalamnya
                  ),
                ],
              ),
            ),
          ),

          // **Navigasi Monitoring dalam Stack**
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavigasiMonitoring(
              selectedIndex: 1,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Monitoring(pondId: pondId, namePond: namePond)),
                  );
                } else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Notifikasi(pondId: pondId, namePond: namePond)),
                  );
                } else if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => KontrolPakanAerator(pondId: pondId, namePond: namePond)),
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
