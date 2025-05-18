import 'package:flutter/material.dart';
import '../../color/color_constant.dart';
import '../../server/api_service.dart';
import '../widget/button/button_outlined.dart';
import '../widget/input/input_treshold.dart';
import '../widget/button/button_text.dart';
import '../pages/monitoring/monitoirng_sensor/informasi_sensor.dart';
import '../widget/pop_up/custom_dialog.dart';

class KolomPengaturanSensor extends StatefulWidget {
  final String pondId;
  final String sensorName;
  final String namePond;
  final String sensorType;

  const KolomPengaturanSensor({
    super.key,
    required this.pondId,
    required this.sensorName,
    required this.sensorType,
    required this.namePond,
  });

  @override
  _KolomPengaturanSensorState createState() => _KolomPengaturanSensorState();
}

class _KolomPengaturanSensorState extends State<KolomPengaturanSensor> {
  double? highestValue;
  double? lowestValue;
  double? tempHighValue;
  double? tempLowValue;
  double? currentSensorValue;

  @override
  void initState() {
    super.initState();
    fetchSensorConfig();
  }

  Future<void> fetchSensorConfig() async {
    String sensorType = widget.sensorType.toLowerCase();
    try {
      final thresholds = await ApiService.getThresholds(widget.pondId);
      final sensorValueData = await ApiService.getMonitoringData(widget.pondId);
      final highKey = '${sensorType}High';
      final lowKey = '${sensorType}Low';
      final highest = thresholds?[highKey];
      final lowest = thresholds?[lowKey];

      setState(() {
        highestValue = highest?.toDouble();
        lowestValue = lowest?.toDouble();
        tempHighValue = highestValue;
        tempLowValue = lowestValue;

        final type = widget.sensorType.toLowerCase();
        currentSensorValue = (sensorValueData[type])?.toDouble();
      });
    } catch (e) {
      print("Error fetching threshold: $e");
    }
  }

  Future<void> saveThresholdValues() async {
    if (tempHighValue == null || tempLowValue == null) return;
    if (tempLowValue! >= tempHighValue!) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Batas bawah harus lebih kecil dari batas atas.",
      );
      return;
    }
    try {
      final sensorType = widget.sensorType.toLowerCase();
      final highValueFormatted = tempHighValue?.toStringAsFixed(1);
      final lowValueFormatted = tempLowValue?.toStringAsFixed(1);
      await ApiService.updateThresholds(widget.pondId, {
        sensorType: {
          "high": double.parse(highValueFormatted!),
          "low": double.parse(lowValueFormatted!),
        }
      });
      setState(() {
        highestValue = tempHighValue;
        lowestValue = tempLowValue;
      });
      CustomDialog.show(
        context: context,
        isSuccess: true,
        message: "Batasan sensor ${getReadableSensorName(widget.sensorType)} berhasil diperbarui.",
      );
    } catch (e) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Gagal menyimpan data: ${e.toString()}",
      );
    }
  }



  String getReadableSensorName(String sensorType) {
    switch (sensorType.toLowerCase()) {
      case 'temperature':
        return 'Suhu';
      case 'salinity':
        return 'Salinitas';
      case 'turbidity':
        return 'Kekeruhan';
      case 'ph':
        return 'pH';
      default:
        return sensorType;
    }
  }

  String formatNumber(double? number) {
    if (number == null) return "--";
    return number % 1 == 0 ? number.toInt().toString() : number.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String unit = "°C";
    String label = "Suhu";
    double minValue = -50, maxValue = 100, step = 1;

    switch (widget.sensorType.toLowerCase()) {
      case "ph":
        unit = "pH";
        label = "pH";
        minValue = 0;
        maxValue = 14;
        step = 0.01;
        break;
      case "salinity":
        unit = "PPT";
        label = "Salinitas";
        minValue = 0;
        maxValue = 100;
        step = 1;
        break;
      case "turbidity":
        unit = "NTU";
        label = "Kekeruhan";
        minValue = 0;
        maxValue = 1000;
        step = 1;
        break;
    }

    return Container(
      width: screenWidth * 0.9,
      height: screenHeight * 0.7,
      padding: EdgeInsets.only(
        left: screenWidth * 0.05,
        right: screenWidth * 0.05,
        bottom: screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        color: const Color(0x80D9DCD6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          _buildHeader(screenWidth),
          SizedBox(height: screenHeight * 0.03),

          // Data Sensor
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSensorData("$label \nSaat Ini", formatNumber(currentSensorValue), unit, screenWidth),
              _buildSensorData("$label \nTertinggi", formatNumber(highestValue), unit, screenWidth),
              _buildSensorData("$label \nTerendah", formatNumber(lowestValue), unit, screenWidth),
            ],
          ),

          SizedBox(height: screenHeight * 0.05),

          if (tempHighValue != null && tempLowValue != null) ...[
            _buildSettingBox("Tertinggi", tempHighValue!, minValue, maxValue, unit, screenWidth, screenHeight, (value) {
              setState(() {
                tempHighValue = value;
              });
            }),
            SizedBox(height: screenHeight * 0.01),
            _buildSettingBox("Terendah", tempLowValue!, minValue, maxValue, unit, screenWidth, screenHeight, (value) {
              setState(() {
                tempLowValue = value;
              });
            }),
          ] else

            SizedBox(height: screenHeight * 0.02),
          _buildSaveButton(),

          SizedBox(height: screenHeight * 0.015),
          Divider(
            color: Colors.white,
            thickness: 1,
          ),

          _buildInfoButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Container(
      height: 50,
      width: screenWidth * 0.5,
      decoration: BoxDecoration(
        color: const Color(0xFFD9DCD6),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.sensorName,
        style: TextStyle(
          fontSize: screenWidth * 0.055,
          fontWeight: FontWeight.bold,
          color: ColorConstant.primary,
        ),
      ),
    );
  }

  Widget _buildSensorData(String label, String value, String unit, double screenWidth) {
    return Column(
      children: [
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 12),
        Text("$value $unit", style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: ColorConstant.primary)),
      ],
    );
  }

  Widget _buildSettingBox(
      String type,
      double value,
      double minValue,
      double maxValue,
      String unit,
      double screenWidth,
      double screenHeight,
      Function(double) onChanged,
      ) {
    double step = 1.0;

    switch (widget.sensorType.toLowerCase()) {
      case "ph":
        step = 0.1;
        break;
      case "salinity":
      case "turbidity":
      case "temperature":
        step = 1;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${getReadableSensorName(widget.sensorType)} $type",
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Atur batasan $type",
                    style: TextStyle(
                      fontSize: screenWidth * 0.036,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Nilai Rekomendasi : ${_getFixedRecommendation(type)} $unit",
                    style: TextStyle(
                      fontSize: screenWidth * 0.036,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10, height: 10),
            // Input Kanan
            InputTresholds(
              initialValue: value,
              minValue: minValue,
              maxValue: maxValue,
              step: step,
              onChanged: onChanged,
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.03),
      ],
    );
  }


  String _getFixedRecommendation(String batasan) {
    String sensor = widget.sensorType.toLowerCase();

    Map<String, Map<String, String>> recommendations = {
      "ph": {
        "Tertinggi": "8.5",
        "Terendah": "7.5",
      },
      "salinity": {
        "Tertinggi": "25",
        "Terendah": "15",
      },
      "turbidity": {
        "Tertinggi": "40",
        "Terendah": "15",
      },
      "temperature": {
        "Tertinggi": "32",
        "Terendah": "28",
      },
    };

    final sensorRecommendations = recommendations[sensor];
    if (sensorRecommendations == null) {
      return '--';
    }

    return sensorRecommendations[batasan] ?? '--';
  }

  Widget _buildSaveButton() {
    return ButtonOutlined(
      text: "Simpan",
      onPressed: saveThresholdValues,
      isFullWidth: true,
      borderColor: ColorConstant.primary,
      textColor: ColorConstant.primary,
    );
  }

  Widget _buildInfoButton(BuildContext context) {
    return ButtonText(
      text: "Informasi Perangkat Sensor >>",
      icon: Icons.info,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InformasiSensor(
              sensorType: widget.sensorType,
              pondId: widget.pondId,
              namePond: widget.namePond,
            ),
          ),
        );
      },
    );
  }
}
