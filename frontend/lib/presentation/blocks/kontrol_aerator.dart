import 'package:flutter/material.dart';
import '../../../color/color_constant.dart';
import '../../server/api_service.dart';
import '../widget/button/button_outlined.dart';
import '../widget/button/button_switch.dart';
import '../widget/input/input_value.dart';
import '../widget/pop_up/custom_dialog.dart';

class KontrolAerator extends StatefulWidget {
  final String pondId;
  const KontrolAerator({super.key, required this.pondId});

  @override
  _KontrolAeratorState createState() => _KontrolAeratorState();
}

class _KontrolAeratorState extends State<KontrolAerator> {
  bool isAeratorOn = false;
  double? aeratorDelay; // Ubah jadi nullable
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchAeratorConfig();
  }

  Future<void> _fetchAeratorConfig() async {
    setState(() => isLoading = true);

    try {
      print("📩 GET Request API: http://192.168.1.38:5000/api/konfigurasi/${widget.pondId}/aerator/status");
      final statusData = await ApiService.getDeviceConfig(widget.pondId, "aerator/status");
      print("📥 Response (200): $statusData");

      print("📩 GET Request API: http://192.168.1.38:5000/api/konfigurasi/${widget.pondId}/aerator/aerator_delay");
      final delayData = await ApiService.getDeviceConfig(widget.pondId, "aerator/aerator_delay");
      print("📥 Response (200): $delayData");

      setState(() {
        // Cek apakah statusData memiliki format yang benar
        if (statusData != null && statusData['data'] != null && statusData['data']['on'] is bool) {
          isAeratorOn = statusData['data']['on'];
          print("✅ isAeratorOn set to: $isAeratorOn");
        } else if (statusData != null && statusData['on'] is bool) {
          // Handle format case without 'data'
          isAeratorOn = statusData['on'];
          print("✅ isAeratorOn set to: $isAeratorOn");
        } else {
          print("⚠️ Invalid status data format");
        }

        // Cek apakah delayData memiliki format yang benar
        if (delayData != null && delayData['data'] is num) {
          aeratorDelay = delayData['data'].toDouble();
          print("✅ aeratorDelay set to: $aeratorDelay");
        } else if (delayData != null && delayData['data'] is num) {
          aeratorDelay = delayData['data'].toDouble();
          print("✅ aeratorDelay set to: $aeratorDelay");
        } else {
          print("⚠️ Invalid delay data format");
        }
      });
    } catch (e) {
      print("❌ Error saat mengambil data aerator: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _updateAeratorConfig() async {
    setState(() => isSaving = true);

    try {
      // Log untuk status aerator
      print("📩 PUT Request API: http://192.168.1.38:5000/api/konfigurasi/${widget.pondId}/aerator/status with data: {\"on\": $isAeratorOn}");
      final statusUpdated = await ApiService.updateDeviceConfig(
        widget.pondId,
        "aerator/status",
        {"on": isAeratorOn},
      );
      print("📥 Response (200): $statusUpdated");

      // Log untuk delay aerator
      print("📩 PUT Request API: http://192.168.1.38:5000/api/konfigurasi/${widget.pondId}/aerator/aerator_delay with data: {\"delay\": $aeratorDelay}");
      final delayUpdated = await ApiService.updateDeviceConfig(
        widget.pondId,
        "aerator/aerator_delay",
        aeratorDelay!.toInt(),
      );
      print("📥 Response (200): $delayUpdated");

      CustomDialog.show(
        context: context,
        isSuccess: statusUpdated && delayUpdated,
        message: statusUpdated && delayUpdated
            ? "Konfigurasi aerator berhasil disimpan"
            : "Gagal menyimpan konfigurasi aerator",
      );
    } catch (e) {
      print("❌ Error saat memperbarui aerator: $e");
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Terjadi kesalahan saat menyimpan data",
      );
    }

    setState(() => isSaving = false);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x80D9DCD6),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kontrol Aerator",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorConstant.primary,
            ),
          ),
          const SizedBox(height: 12),

          // Switch Aerator
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0x80D9DCD6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Text(
                  "On/Off Aerator : ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                ButtonSwitch(
                  value: isAeratorOn,
                  onChanged: (value) async {
                    setState(() {
                      isAeratorOn = value;
                      print("✅ isAeratorOn changed to: $isAeratorOn");
                    });

                    try {
                      print("📩 PUT Request API: http://192.168.1.38:5000/api/konfigurasi/${widget.pondId}/aerator/status with data: {\"on\": $isAeratorOn}");
                      final statusUpdated = await ApiService.updateDeviceConfig(
                        widget.pondId,
                        "aerator/status",
                        {"on": isAeratorOn},
                      );
                      print("📥 Response (200): $statusUpdated");

                      // Log info tanpa menampilkan dialog
                      if (isAeratorOn) {
                        print("✅ Aerator berhasil diaktifkan");
                      } else {
                        print("⚠️ Aerator berhasil dinonaktifkan");
                      }

                    } catch (e) {
                      print("❌ Error saat memperbarui aerator: $e");
                    }
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 8),

          Text(
            "Pengaturan waktu interval pengoperasian aerator setelah pemberian pakan.",
            style: TextStyle(
              fontSize: 14,
              color: ColorConstant.primary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0x80D9DCD6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Waktu :",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (aeratorDelay != null)
                        InputValue(
                          initialValue: aeratorDelay!,
                          minValue: 5,
                          maxValue: 60,
                          step: 5,
                          unit: "Menit",
                          onChanged: (value) {
                            setState(() {
                              aeratorDelay = value;
                              print("✅ aeratorDelay changed to: $aeratorDelay");
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ButtonOutlined(
                text: "Simpan",
                onPressed: _updateAeratorConfig,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
