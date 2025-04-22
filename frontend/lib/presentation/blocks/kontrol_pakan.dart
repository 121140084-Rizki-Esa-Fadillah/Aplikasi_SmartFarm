import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../color/color_constant.dart';
import '../../server/api_service.dart';
import '../widget/button/button_outlined.dart';
import '../widget/button/button_switch.dart';
import '../widget/input/input_schedule_time.dart';
import '../widget/input/input_value.dart';
import '../widget/pop_up/custom_dialog.dart';

class KontrolPakan extends StatefulWidget {
  final String pondId;
  const KontrolPakan({super.key, required this.pondId});

  @override
  _KontrolPakanState createState() => _KontrolPakanState();
}

class _KontrolPakanState extends State<KontrolPakan> {
  List<TimeOfDay?> _feedingSchedule = List.filled(4, null);
  bool? isFeedingOn;
  double feedAmount = 100.0;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => isLoading = true);

      final responses = await Future.wait([
        ApiService.getDeviceConfig(widget.pondId, "feeding_schedule/schedule"),
        ApiService.getDeviceConfig(widget.pondId, "feeding_schedule/status"),
        ApiService.getDeviceConfig(widget.pondId, "feeding_schedule/amount"),
      ]);

      // Process schedule
      final scheduleData = responses[0];
      if (scheduleData != null && scheduleData["data"] is List) {
        final times = (scheduleData["data"] as List).cast<String>();
        setState(() {
          _feedingSchedule = List.generate(4, (index) {
            if (index < times.length) {
              final parts = times[index].split(':');
              if (parts.length == 2) {
                return TimeOfDay(
                  hour: int.parse(parts[0]),
                  minute: int.parse(parts[1]),
                );
              }
            }
            return null;
          });
        });
      }

      // 2. Process Status
      final statusData = responses[1];
      print("📦 Raw statusData: $statusData");

      if (statusData != null && statusData["on"] != null) {
        final bool statusValue = statusData["on"] == true;

        print('✅ isFeedingOn set to: $statusValue');

        setState(() {
          isFeedingOn = statusValue;
        });
      } else {
        print("⚠️ statusData is null or missing 'on' key");
      }


      // Process amount
      final amountData = responses[2];
      if (amountData != null && amountData["data"] is num) {
        setState(() => feedAmount = amountData["data"].toDouble());
      }

    } catch (e) {
      print('Error loading config: $e');
      setState(() {
        isFeedingOn = false;
        feedAmount = 100.0;
        _feedingSchedule = List.filled(4, null);
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveData() async {
    setState(() => isSaving = true);

    try {
      final formattedSchedule = _feedingSchedule
          .where((time) => time != null)
          .map((time) =>
      "${time!.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}")
          .toList();

      await Future.wait([
        if (formattedSchedule.isNotEmpty)
          ApiService.updateDeviceConfig(
              widget.pondId,
              "feeding_schedule/schedule",
              formattedSchedule
          ),
        ApiService.updateDeviceConfig(
            widget.pondId,
            "feeding_schedule/amount",
            feedAmount.toInt()
        ),
        ApiService.updateDeviceConfig(
            widget.pondId,
            "feeding_schedule/status",
            {"on": isFeedingOn ?? false}
        ),
      ]);

      CustomDialog.show(
        context: context,
        isSuccess: true,
        message: "Konfigurasi berhasil disimpan",
      );
    } catch (e) {
      print("❌ Error saving config: $e");
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Gagal menyimpan konfigurasi: ${e.toString()}",
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            "Kontrol Pakan",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorConstant.primary,
            ),
          ),
          const SizedBox(height: 12),

          // On/Off Pakan (dibuat seperti Aerator)
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x80D9DCD6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  "On/Off Pakan : ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                ButtonSwitch(
                  value: isFeedingOn ?? false,
                  onChanged: (value) async {
                    setState(() => isFeedingOn = value);

                    try {
                      print("📩 PUT Request API: http://192.168.1.38:5000/api/konfigurasi/${widget.pondId}/feeding_schedule/status with data: {\"on\": $isFeedingOn}");
                      final statusUpdated = await ApiService.updateDeviceConfig(
                        widget.pondId,
                        "feeding_schedule/status",
                        {"on": isFeedingOn ?? false},
                      );
                      print("📥 Response (200): $statusUpdated");

                      // Logging saja, tanpa dialog
                      if (isFeedingOn == true) {
                        print("✅ Pakan berhasil diaktifkan");
                      } else {
                        print("⚠️ Pakan berhasil dinonaktifkan");
                      }

                    } catch (e) {
                      print("❌ Error saat memperbarui status pakan: $e");
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            "Penjadwalan pemberian dan jumlah pakan udang",
            style: TextStyle(
              fontSize: 14,
              color: ColorConstant.primary,
            ),
          ),
          const SizedBox(height: 12),

          // Main Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Jadwal
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x80D9DCD6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: InputScheduleTime(
                          label: 'Waktu ${index + 1}',
                          initialTime: _feedingSchedule[index] ??
                              const TimeOfDay(hour: 7, minute: 0),
                          onTimeSelected: (TimeOfDay? newTime) {
                            setState(() => _feedingSchedule[index] = newTime);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Kolom Jumlah Pakan & Simpan
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0x80D9DCD6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Jumlah Pakan",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InputValue(
                            initialValue: feedAmount,
                            minValue: 100,
                            maxValue: 500,
                            step: 100,
                            unit: "Gr",
                            onChanged: (value) =>
                                setState(() => feedAmount = value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ButtonOutlined(
                      text: "Simpan",
                      onPressed: _saveData,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}