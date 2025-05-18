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
  double? aeratorDelay;
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
      final aeratorData = await ApiService.getAerator(widget.pondId);
      setState(() {
        if (aeratorData != null) {
          if (aeratorData.containsKey('statusAerator') && aeratorData['statusAerator'] is bool) {
            isAeratorOn = aeratorData['statusAerator'];
          }
          if (aeratorData.containsKey('aeratorOnMinuteAfter') && aeratorData['aeratorOnMinuteAfter'] is num) {
            aeratorDelay = aeratorData['aeratorOnMinuteAfter'].toDouble();
          }
        }
      });
    } catch (e) {
      print("Error saat mengambil data aerator: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> _updateAeratorConfig() async {
    setState(() => isSaving = true);
    try {
      await ApiService.updateAerator(
        widget.pondId,
        {
          "aerator_delay": aeratorDelay?.toInt(),
        },
      );
      _showDialog(true, "Waktu delay aerator berhasil diperbarui");
    } catch (e) {
      print("Error saat memperbarui delay aerator: $e");
      _showDialog(false, "Terjadi kesalahan saat menyimpan delay aerator");
    }
    setState(() => isSaving = false);
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
                      });

                      try {
                        await ApiService.updateAerator(
                          widget.pondId,
                          {
                            "status": {"on": isAeratorOn},
                          },
                        );

                        CustomDialog.show(
                          context: context,
                          isSuccess: true,
                          message: isAeratorOn
                              ? "Aerator berhasil diaktifkan"
                              : "Aerator berhasil dinonaktifkan",
                        );
                      } catch (e) {
                        print("Error saat memperbarui aerator: $e");
                        CustomDialog.show(
                          context: context,
                          isSuccess: false,
                          message: "Gagal memperbarui status aerator",
                        );
                      }
                    }
                ),
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
                          initialValue:  aeratorDelay ?? 5,
                          minValue: 5,
                          maxValue: 60,
                          step: 5,
                          unit: "Menit",
                          onChanged: (value) {
                            setState(() {
                              aeratorDelay = value;
                              print("aeratorDelay changed to: $aeratorDelay");
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
