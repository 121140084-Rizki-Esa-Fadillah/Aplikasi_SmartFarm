import 'package:flutter/material.dart';
import '../../../widget/background_widget.dart';
import '../../../blocks/kolom_pengaturan_sensor.dart';
import '../../../widget/navigation/app_bar_widget.dart';
import '../../../widget/navigation/navigasi_monitoring.dart';
import '../riwayat_kualitas_air/riwayat_kualitas_air.dart';
import '../kontrol_pakan_aerator.dart';
import '../notifikasi.dart';

class PengaturanSensor extends StatelessWidget {
  final String pondId;
  final String namePond;
  final String sensorName;
  final String currentValue;

  const PengaturanSensor({
    super.key,
    required this.pondId,
    required this.sensorName,
    required this.currentValue,
    required this.namePond,
  });

  // 🔹 Fungsi untuk menentukan sensorType berdasarkan sensorName
  String getSensorType(String sensorName) {
    switch (sensorName.toLowerCase()) { // Ubah input ke huruf kecil untuk memudahkan perbandingan
      case "sensor suhu":
        return "temperature"; // Sesuai dengan Firebase
      case "sensor ph":
        return "ph"; // Perhatikan huruf besar "pH"
      case "sensor salinitas":
        return "salinity"; // Sesuai dengan Firebase
      case "sensor kekeruhan":
        return "turbidity"; // Sesuai dengan Firebase
      default:
        return ""; // Jika tidak cocok, kembalikan string kosong
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: "Pengaturan",
        onBackPress: () => Navigator.pop(context),
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundWidget(),

          // **Widget untuk Menampilkan dan Mengedit Parameter Sensor**
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
            child: KolomPengaturanSensor(
              pondId: pondId,
              sensorName: sensorName,
              sensorType: getSensorType(sensorName),
              namePond: namePond, //
            ),
          ),

          // **Navigasi Monitoring dalam Stack**
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavigasiMonitoring(
              selectedIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RiwayatKualitasAir(pondId: pondId, namePond: namePond)),
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
