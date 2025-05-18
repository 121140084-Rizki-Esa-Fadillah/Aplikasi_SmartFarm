import 'package:flutter/material.dart';
import '../../../color/color_constant.dart';

class NavigasiBeranda extends StatefulWidget {
  final Function(int) onTap;
  final int selectedIndex;

  const NavigasiBeranda({
    super.key,
    required this.onTap,
    required this.selectedIndex,
  });

  @override
  _NavigasiBerandaState createState() => _NavigasiBerandaState();
}

class _NavigasiBerandaState extends State<NavigasiBeranda> {
  @override
  Widget build(BuildContext context) {
    double iconSize = MediaQuery.of(context).size.width * 0.08;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(5),
        topRight: Radius.circular(5),
      ),
      child: Container(
        height: 60, // Tinggi navigasi tetap 60
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            _buildNavItem(
              index: 0,
              iconPath: "assets/icons/icon-beranda.png",
              iconSize: iconSize,
              label: "Beranda",
            ),
            _buildNavItem(
              index: 1,
              iconPath: "assets/icons/icon-manajemen-user.png",
              iconSize: iconSize,
              label: "Manajemen User",
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
