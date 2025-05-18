import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartSensor extends StatelessWidget {
  final List<Map<String, dynamic>> sensorData;

  const ChartSensor({super.key, required this.sensorData});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textScale = MediaQuery.of(context).textScaleFactor;

    if (sensorData.isEmpty) {
      return Center(
        child: Text(
          "No data available",
          style: TextStyle(fontSize: 16 * textScale),
        ),
      );
    }

    // Ambil nilai tertinggi & terendah dari sensor untuk set minY dan maxY
    final values = sensorData.map((e) => (e["value"] as num).toDouble()).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final yPadding = (maxValue - minValue) * 0.1; // beri jarak 10%

    return Padding(
      padding: EdgeInsets.only(right: screenWidth * 0.02),
      child: LineChart(
        LineChartData(
          minY: minValue - yPadding,
          maxY: maxValue + yPadding,
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: screenWidth * 0.08,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.005),
                    child: Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(fontSize: 10 * textScale),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: screenHeight * 0.03,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < sensorData.length) {
                    return Padding(
                      padding: EdgeInsets.only(right: screenWidth * 0.005),
                      child: Text(
                        sensorData[index]["time"],
                        style: TextStyle(fontSize: 10 * textScale),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.grey),
              bottom: BorderSide(color: Colors.grey),
              right: BorderSide(color: Colors.transparent),
              top: BorderSide(color: Colors.transparent),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: sensorData.asMap().entries.map((e) {
                return FlSpot(
                  e.key.toDouble(),
                  (e.value["value"] as num).toDouble(),
                );
              }).toList(),
              isCurved: true,
              curveSmoothness: 0.15,
              color: Colors.blue,
              barWidth: screenWidth * 0.007,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withAlpha(50),
              ),
              dotData: FlDotData(show: true), // Tampilkan titik
            ),
          ],
        ),
      ),
    );
  }
}
