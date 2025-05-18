import 'package:flutter/material.dart';
import '../widget/pop_up/custom_dialog.dart';
import '../widget/pop_up/custom_dialog_button.dart';

class NotifikasiItem extends StatefulWidget {
  final bool initialValue;
  final void Function(bool) onToggle;

  const NotifikasiItem({
    super.key,
    required this.initialValue,
    required this.onToggle,
  });

  @override
  State<NotifikasiItem> createState() => NotifikasiItemState();
}

class NotifikasiItemState extends State<NotifikasiItem> {
  bool _expanded = false;
  bool _currentValue = false;


  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant NotifikasiItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _currentValue = widget.initialValue;
      });
    }
  }

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _handleToggle(bool newValue) {
    if (!newValue) {
      CustomDialogButton.show(
        context: context,
        title: "Matikan Notifikasi?",
        message: "Apakah Anda yakin ingin mematikan popup notifikasi?",
        confirmText: "Ya, Matikan",
        cancelText: "Batal",
        isWarning: true,
        onConfirm: () {
          setState(() {
            _currentValue = newValue;
          });
          widget.onToggle(newValue);
        },
      );
    } else {
      CustomDialog.show(
        context: context,
        isSuccess: true,
        message: "Notifikasi diaktifkan",
        onComplete: () {
          setState(() {
            _currentValue = newValue;
          });
          widget.onToggle(newValue); // Biarkan parent simpan ke SharedPreferences
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleExpand,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _expanded ? Colors.orange.withAlpha(16) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications, color: Colors.orange, size: 18),
                const SizedBox(width: 10),
                const Text(
                  "Notifikasi",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                const Spacer(),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.orange,
                  size: 24,
                ),
              ],
            ),
            if (_expanded) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 0.75,
                      child: Switch(
                        value: _currentValue,
                        onChanged: _handleToggle,
                        activeColor: Colors.blue,
                        inactiveTrackColor: Colors.grey.shade300,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    Text(
                      "status: ${_currentValue ? "On" : "Off"}",
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
