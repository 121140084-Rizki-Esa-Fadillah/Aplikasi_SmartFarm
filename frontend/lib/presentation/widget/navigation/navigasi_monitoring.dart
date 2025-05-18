import 'package:flutter/material.dart';
import '../../../color/color_constant.dart';

class NavigasiMonitoring extends StatefulWidget {
  final Function(int) onTap;
  final int selectedIndex;

  const NavigasiMonitoring({
    super.key,
    required this.onTap,
    required this.selectedIndex,
  });

  @override
  _NavigasiMonitoringState createState() => _NavigasiMonitoringState();
}

class _NavigasiMonitoringState extends State<NavigasiMonitoring> {
  @override
  Widget build(BuildContext context) {
    double iconSize = MediaQuery.of(context).size.width * 0.08;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(5),
        topRight: Radius.circular(5),
      ),
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            _buildNavItem(
              index: 0,
              iconPath: "assets/icons/icon-monitoring.png",
              iconSize: iconSize,
              label: "Monitoring",
            ),
            _buildNavItem(
              index: 1,
              iconPath: "assets/icons/icon-history.png",
              iconSize: iconSize,
              label: "Riwayat",
            ),
            _buildNavItem(
              index: 2,
              iconPath: "assets/icons/icon-notification.png",
              iconSize: iconSize,
              label: "Notifikasi",
            ),
            _buildNavItem(
              index: 3,
              iconPath: "assets/icons/icon-control.png",
              iconSize: iconSize,
              label: "Kontrol",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String iconPath,
    required double iconSize,
    required String label,
  }) {
    bool isSelected = widget.selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          decoration: BoxDecoration(
            color: isSelected
                ? ColorConstant.primary.withAlpha(75)
                : const Color(0xFFD9DCD6).withAlpha(64),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
                color: Colors.white,
              ),
              const SizedBox(height: 2),
              FittedBox(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
