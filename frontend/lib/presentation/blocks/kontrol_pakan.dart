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
    _fetchFeederConfig();
  }

  Future<void> _fetchFeederConfig() async {
    try {
      setState(() => isLoading = true);
      final feedingScheduleData = await ApiService.getFeeding(widget.pondId);
      final statusData = feedingScheduleData["feedStatus"];
      final amountData = feedingScheduleData["amountFeeder"];
      final scheduleTimes = [
        feedingScheduleData["schedule_1"],
        feedingScheduleData["schedule_2"],
        feedingScheduleData["schedule_3"],
        feedingScheduleData["schedule_4"],
      ];
      setState(() {
        _feedingSchedule = scheduleTimes.map((timeStr) {
          if (timeStr != null && timeStr is String) {
            final parts = timeStr.split(':');
            if (parts.length == 2) {
              return TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );
            }
          }
          return null;
        }).toList();
      });

      if (statusData != null && statusData["on"] != null) {
        setState(() {
          isFeedingOn = statusData["on"];
        });
      }
      if (amountData != null) {
        setState(() {
          feedAmount = amountData.toDouble();
        });
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

  Future<void> _updateFeederConfig() async {
    setState(() => isSaving = true);
    try {
      final formattedSchedule = _feedingSchedule.map((time) {
        return time != null
            ? "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}"
            : null;
      }).toList();
      final Map<String, dynamic> payload = {
        "amount": feedAmount.toInt(),
        "schedule": formattedSchedule,
      };
      await ApiService.updateFeeding(widget.pondId, payload);
      _showDialog(true, "Konfigurasi berhasil disimpan");
    } catch (e) {
      print("Error saving config: $e");
      _showDialog(false, "Gagal menyimpan konfigurasi: ${e.toString()}");
    } finally {
      setState(() => isSaving = false);
    }
  }

  void _showDialog(bool isSuccess, String message, {VoidCallback? onComplete}) {
    CustomDialog.show(
      context: context,
      isSuccess: isSuccess,
      message: message,
      onComplete: onComplete,
    );
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

          // On/Off Pakan
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
                      await ApiService.updateFeeding(
                        widget.pondId,
                        {
                          "status": {"on": isFeedingOn ?? false}
                        },
                      );

                      CustomDialog.show(
                        context: context,
                        isSuccess: true,
                        message: isFeedingOn == true
                            ? "Pakan berhasil diaktifkan"
                            : "Pakan berhasil dinonaktifkan",
                      );
                    } catch (e) {
                      print("Error saat memperbarui status pakan: $e");
                      CustomDialog.show(
                        context: context,
                        isSuccess: false,
                        message: "Gagal mengubah status pakan",
                      );
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
                        padding: const EdgeInsets.only(left: 4),
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
                      onPressed: _updateFeederConfig,
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
