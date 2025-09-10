import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../color/color_constant.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPress;

  const AppBarWidget({
    super.key,
    required this.title,
    required this.onBackPress,
  });

  @override
  _AppBarWidgetState createState() => _AppBarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _AppBarWidgetState extends State<AppBarWidget> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AppBar(
      backgroundColor: ColorConstant.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 0,
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  isPressed = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  isPressed = false;
                });
                widget.onBackPress();
              },
              onTapCancel: () {
                setState(() {
                  isPressed = false;
                });
              },
              child: Image.asset(
                'assets/icons/icon-back.png',
                width: size.width * 0.12,
                color: isPressed ? const Color(0xFF316B94) : null,
              ),
            ),
          ),
          SizedBox(width: size.width * 0.02),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: size.width * 0.06,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      toolbarHeight: 60, // Tinggi AppBar tetap 60
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }
}
