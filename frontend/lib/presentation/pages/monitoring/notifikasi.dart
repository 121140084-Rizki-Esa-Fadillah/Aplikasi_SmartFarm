import 'package:flutter/material.dart';
import '../../widget/navigation/navigasi_monitoring.dart';
import '../../widget/background_widget.dart';
import '../beranda/beranda.dart';
import 'riwayat_kualitas_air/riwayat_kualitas_air.dart';
import 'kontrol_pakan_aerator.dart';
import 'monitoirng_sensor/monitoring.dart';
import '../../widget/navigation/app_bar_widget.dart';
import '../../blocks/kolom_notifikasi.dart'; // Import NotifikasiWidget

class Notifikasi extends StatelessWidget {
  final String pondId;
  final String namePond;

  const Notifikasi({super.key, required this.pondId, required this.namePond});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBarWidget(
        title: "Notifikasi",
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

          // **Konten Utama**
          Positioned(
            top: screenHeight * 0.03,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenHeight * 0.10,
            child: Column(
              children: [
                Expanded(
                  child: KolomNotifikasi(pondId: pondId), // Dibungkus dengan Expanded agar sesuai dengan tata letak
                ),
              ],
            ),
          ),

          // **Navigasi Monitoring dalam Stack**
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavigasiMonitoring(
              selectedIndex: 2,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Monitoring(pondId: pondId, namePond: namePond)), // ✅ Kirim pondId
                  );
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RiwayatKualitasAir(pondId: pondId, namePond: namePond)), // ✅ Kirim pondId
                  );
                } else if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => KontrolPakanAerator(pondId: pondId, namePond: namePond)), // ✅ Tanpa const
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
