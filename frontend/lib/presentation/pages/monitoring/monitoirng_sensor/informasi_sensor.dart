import 'package:flutter/material.dart';
import '../../../widget/background_widget.dart';
import '../../../widget/navigation/app_bar_widget.dart';
import '../../../widget/navigation/navigasi_monitoring.dart';
import '../../../blocks/kolom_informasi_sensor.dart'; // Import SensorInfoWidget
import '../riwayat_kualitas_air/riwayat_kualitas_air.dart';
import '../kontrol_pakan_aerator.dart';
import '../notifikasi.dart';

class InformasiSensor extends StatelessWidget {
  final String sensorType;
  final String pondId;
  final String namePond;

  const InformasiSensor({super.key, required this.sensorType, required this.pondId, required this.namePond});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // 🔹 Data Sensor berdasarkan jenisnya
    final sensorData = getSensorData(sensorType);

    return Scaffold(
      appBar: AppBarWidget(
        title: "Informasi Sensor",
        onBackPress: () {
          Navigator.pop(context);
        },
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundWidget(),

          // **Konten Utama dalam SingleChildScrollView**
          Positioned(
            top: screenHeight * 0.0,
            left: screenWidth * 0.06,
            right: screenWidth * 0.06,
            bottom: screenHeight * 0.10,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  KolomInformasiSensor(
                    sensorTitle: sensorData["title"] ?? "Sensor Tidak Diketahui",
                    imagePath: sensorData["image"] ?? "assets/images/default-sensor.jpg",
                    description: sensorData["description"] ?? "Informasi sensor tidak tersedia.",
                    specifications: List<String>.from(sensorData["specifications"] ?? []),
                    optimalRange: sensorData["optimalRange"] ?? "Tidak ada data rentang optimal.",
                    rangeTitle: sensorData["rangeTitle"] ?? "Rentang Optimal",
                  ),
                  const SizedBox(height: 20),
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

  // 🔹 Fungsi untuk mendapatkan data sensor berdasarkan sensorType
  Map<String, dynamic> getSensorData(String sensorType) {
    Map<String, Map<String, dynamic>> sensorInfo = {
      "temperature": {
        "title": "Sensor Suhu",
        "image": "assets/images/Sensor-Suhu.jpg",
        "description":
        "DS18B20 adalah sensor berbentuk probe yang dirancang untuk mengukur suhu dalam air. Sensor ini memiliki fitur tahan air (waterproof), sehingga sangat ideal untuk digunakan dalam pemantauan suhu air secara akurat.",
        "specifications": <String>[
          "Tegangan Operasi: 3 - 5.5VDC",
          "Jenis Sensor: Dallas DS18B20",
          "Jenis Output: Digital",
          "Rentang Suhu: -55°C hingga +125°C"
        ],
        "optimalRange": "Udang tumbuh optimal pada suhu air antara 28°C hingga 32°C dan memiliki toleransi antara 26°C hingga 35°C.",
        "rangeTitle": "Rentang Suhu Optimal",
      },
      "ph": {
        "title": "Sensor pH",
        "image": "assets/images/Sensor-pH.jpg",
        "description":
        "Sensor pH digunakan untuk mengukur tingkat keasaman atau kebasaan dalam air. pH air sangat penting dalam budidaya perikanan untuk memastikan lingkungan yang sehat bagi organisme akuatik.",
        "specifications": <String>[
          "Tegangan Operasi: 5VDC",
          "Rentang pH: 0 - 14",
          "Jenis Output: Analog",
          "Akurasi: ±0.1 pH"
        ],
        "optimalRange": "Udang membutuhkan pH antara 7.5 hingga 8.5 untuk pertumbuhan yang optimal.",
        "rangeTitle": "Rentang pH Optimal",
      },
      "salinity": {
        "title": "Sensor Salinitas",
        "image": "assets/images/Sensor-Salinitas.png",
        "description":
        "Sensor salinitas digunakan untuk mengukur kadar garam dalam air. Salinitas yang stabil sangat penting untuk budidaya udang dan ikan laut.",
        "specifications": <String>[
          "Tegangan Operasi: 3.3V - 5VDC",
          "Rentang Salinitas: 0 - 40 ppt",
          "Jenis Output: Analog",
          "Akurasi: ±1% dari rentang pengukuran"
        ],
        "optimalRange": "Udang vannamei tumbuh optimal pada salinitas antara 15 - 25 ppt.",
        "rangeTitle": "Rentang Salinitas Optimal",
      },
      "turbidity": {
        "title": "Sensor Kekeruhan",
        "image": "assets/images/Sensor-Turbidity.jpg",
        "description":
        "Sensor kekeruhan digunakan untuk mengukur tingkat kejernihan air dengan mendeteksi jumlah partikel tersuspensi di dalamnya.",
        "specifications": <String>[
          "Tegangan Operasi: 5VDC",
          "Rentang Kekeruhan: 0 - 1000 NTU",
          "Jenis Output: Analog",
          "Akurasi: ±2% dari rentang pengukuran"
        ],
        "optimalRange": "Tingkat kekeruhan air yang aman untuk budidaya udang berkisar antara 30 - 80 NTU.",
        "rangeTitle": "Rentang Kekeruhan Optimal",
      },
    };

    return sensorInfo[sensorType] ?? {
      "title": "Sensor Tidak Diketahui",
      "image": "assets/images/default-sensor.jpg",
      "description": "Sensor ini belum terdaftar dalam sistem.",
      "specifications": <String>[],
      "optimalRange": "",
      "rangeTitle": "",
    };
  }
}
