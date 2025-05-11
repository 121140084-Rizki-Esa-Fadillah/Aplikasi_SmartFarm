import 'package:flutter/material.dart';
import 'package:frontend_app/presentation/widget/pop_up/popup_menu_profile.dart'; // Import widget baru

class TileProfile extends StatefulWidget {
  final String username;
  final String role;

  const TileProfile({
    super.key,
    required this.username,
    required this.role,
  });

  @override
  _TileProfileState createState() => _TileProfileState();
}

class _TileProfileState extends State<TileProfile> {
  bool isPressed = false; // State untuk mendeteksi apakah tombol ditekan

  void _showProfileMenu(BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;

    if (box == null) {
      debugPrint("RenderBox tidak ditemukan!");
      return;
    }

    final buttonPosition = box.localToGlobal(Offset.zero);
    final buttonWidth = box.size.width;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return; // Pastikan widget masih aktif sebelum menampilkan popup

      showDialog(
        context: context,
        builder: (context) => PopupMenuProfile(
          leftPosition: buttonPosition.dx - 5,
          topPosition: buttonPosition.dy + box.size.height + 5,
          buttonWidth: buttonWidth,
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        _showProfileMenu(context);
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size.width * 0.45,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isPressed ? const Color(0xFF316B94) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/Logo-App.png',
                width: size.width * 0.1,
                height: size.width * 0.1,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.role,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
