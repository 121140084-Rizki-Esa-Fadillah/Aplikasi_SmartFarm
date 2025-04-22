import 'package:flutter/material.dart';
import '../../color/color_constant.dart';

class KolomInformasiSensor extends StatelessWidget {
  final String sensorTitle;
  final String imagePath;
  final String description;
  final List<String> specifications;
  final String optimalRange;
  final String rangeTitle;

  const KolomInformasiSensor({
    super.key,
    required this.sensorTitle,
    required this.imagePath,
    required this.description,
    required this.specifications,
    required this.optimalRange,
    required this.rangeTitle,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Lebar layar
    double screenHeight = MediaQuery.of(context).size.height; // Tinggi layar

    return Container(
      width: screenWidth * 0.9, // 90% dari lebar layar
      padding: EdgeInsets.only(
        left: screenWidth * 0.05,  // 5% dari lebar layar
        right: screenWidth * 0.05, // 5% dari lebar layar
        bottom: screenHeight * 0.02, // 2% dari tinggi layar
      ),
      decoration: BoxDecoration(
        color: const Color(0x80D9DCD6),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(75),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Semua teks tetap kiri (start)
        children: [
          // Header Sensor (Di tengah)
          Align(
            alignment: Alignment.center, // Pastikan header di tengah layar
            child: Container(
              height: screenHeight * 0.06, // 6% dari tinggi layar
              width: screenWidth * 0.6, // 60% dari lebar layar
              decoration: BoxDecoration(
                color: const Color(0xFFD9DCD6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                sensorTitle,
                style: TextStyle(
                  fontSize: screenWidth * 0.055, // Font responsif
                  fontWeight: FontWeight.bold,
                  color: ColorConstant.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02), // Jarak dinamis

          // Gambar Sensor (Di tengah)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: screenWidth * 0.5, // 50% dari lebar layar
                height: screenHeight * 0.2, // 20% dari tinggi layar
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // Deskripsi (Tetap Start)
          _buildSectionTitle("Deskripsi", screenWidth),
          Text(
            description,
            style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.white),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: screenHeight * 0.015),

          // Spesifikasi (Tetap Start)
          _buildSectionTitle("Spesifikasi", screenWidth),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: specifications.map((spec) => Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.02, bottom: screenHeight * 0.005),
              child: Text(
                "• $spec",
                style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.white),
              ),
            )).toList(),
          ),
          SizedBox(height: screenHeight * 0.015),

          // Rentang Suhu Optimal (Tetap Start)
          _buildSectionTitle(rangeTitle, screenWidth),
          Text(
            optimalRange,
            style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.white),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // Widget untuk judul bagian (subheading) dengan ukuran responsif
  Widget _buildSectionTitle(String title, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.045, // Font responsif
          fontWeight: FontWeight.bold,
          color: ColorConstant.primary,
        ),
      ),
    );
  }
}
