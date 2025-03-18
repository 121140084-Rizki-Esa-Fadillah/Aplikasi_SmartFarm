import 'package:flutter/material.dart';
import 'package:frontend_app/presentation/pages/monitoring/monitoirng_sensor/monitoring.dart';
import 'package:frontend_app/presentation/widget/button/button_outlined.dart';
import 'package:frontend_app/presentation/widget/pop_up/popup_menu_kolam.dart';

class TileKolam extends StatefulWidget {
  final String pondId;
  final String pondName;
  final String status;
  final String date;
  final Map<String, dynamic> pondData;
  final Function(Map<String, dynamic>) onEdit;
  final VoidCallback onDelete;
  final bool showMenu;

  const TileKolam({
    super.key,
    required this.pondId,
    required this.pondName,
    required this.status,
    required this.date,
    required this.pondData,
    required this.onEdit,
    required this.onDelete,
    this.showMenu = true,
  });

  @override
  State<TileKolam> createState() => _TileKolamState();
}

class _TileKolamState extends State<TileKolam> {
  final GlobalKey _menuKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _showMenu() {
    final RenderBox renderBox = _menuKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeMenu,
                behavior: HitTestBehavior.translucent,
              ),
            ),
            Positioned(
              left: offset.dx - 100,
              top: offset.dy + renderBox.size.height + 5,
              child: Material(
                color: Colors.transparent,
                child: PopupMenuKolam(
                  onEdit: () {
                    _removeMenu();
                    widget.onEdit(widget.pondData);
                  },
                  onDelete: () {
                    _removeMenu();
                    widget.onDelete();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.pondName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  key: _menuKey,
                  onTap: _showMenu,
                  child: const Icon(Icons.more_vert, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 2),

            Text(
              widget.status,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 1),

            Text(
              widget.date,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 2),

            Center(
              child: ButtonOutlined(
                text: "Monitoring",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Monitoring(pondId: widget.pondId, namePond: widget.pondName, ), // ✅ Tambahkan pondId
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
