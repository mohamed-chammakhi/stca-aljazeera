import 'package:flutter/material.dart';

import '../../services/messagerie_service.dart';

class MessagerieBadge extends StatefulWidget {
  const MessagerieBadge({super.key});

  @override
  State<MessagerieBadge> createState() => _MessagerieBadgeState();
}

class _MessagerieBadgeState extends State<MessagerieBadge> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final count = await MessagerieService.instance.fetchUnreadCount();
    if (!mounted) return;
    setState(() => _count = count);
  }

  @override
  Widget build(BuildContext context) {
    if (_count <= 0) return const SizedBox.shrink();
    final label = _count > 9 ? '9+' : '$_count';
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFC0392B),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
