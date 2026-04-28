import 'package:flutter/material.dart';
import 'package:project3/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/notification_ceo.dart';
import 'services/notification_ceo_service.dart';


class NotificationsCeoPage extends StatefulWidget {
  final NotificationCeoService service;
  final void Function(NotificationCeo) onNavigate;

  const NotificationsCeoPage({
    super.key,
    required this.service,
    required this.onNavigate,
  });

  @override
  State<NotificationsCeoPage> createState() => _NotificationsCeoPageState();
}

class _NotificationsCeoPageState extends State<NotificationsCeoPage> {
  List<NotificationCeo> _all = [];
  bool _loading = true;
  String _filter = 'tous';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.service.fetchNotifications();
    if (mounted) setState(() { _all = data; _loading = false; });
  }

  List<NotificationCeo> get _filtered =>
      _filter == 'non_lus' ? _all.where((n) => !n.isRead).toList() : _all;

  int get _unreadCount => _all.where((n) => !n.isRead).length;

  Future<void> _markRead(NotificationCeo n) async {
    if (n.isRead) return;
    await widget.service.markAsRead(n.id);
    setState(() {
      final i = _all.indexWhere((x) => x.id == n.id);
      if (i != -1) _all[i] = n.copyWith(isRead: true);
    });
  }

  Future<void> _markAllRead() async {
    await widget.service.markAllAsRead();
    setState(() => _all = _all.map((n) => n.copyWith(isRead: true)).toList());
  }

  void _onTap(NotificationCeo n) {
    _markRead(n);
    widget.onNavigate(n);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kHeaderBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text('Notifications',
            style: GoogleFonts.domine(fontSize: 18, fontWeight: FontWeight.w700, color: kDark)),
        iconTheme: const IconThemeData(color: kDark),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text('Tout marquer lu',
                  style: TextStyle(fontSize: 12, color: kGreen, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kGreen))
          : Column(children: [
              Container(
                color: kHeaderBg,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: Row(children: [
                  _FilterChip(label: 'Tous', active: _filter == 'tous',
                      onTap: () => setState(() => _filter = 'tous')),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: _unreadCount > 0 ? 'Non lus ($_unreadCount)' : 'Non lus',
                    active: _filter == 'non_lus',
                    onTap: () => setState(() => _filter = 'non_lus'),
                  ),
                ]),
              ),
              Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
              Container(
                color: kBg,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Row(children: [
                  Icon(Icons.notifications_outlined, size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(
                    '${_filtered.length} notification${_filtered.length != 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                  ),
                ]),
              ),
              Expanded(child: _filtered.isEmpty ? _buildEmpty() : _buildGroupedList()),
            ]),
    );
  }

  Widget _buildGroupedList() {
    final grouped = <String, List<NotificationCeo>>{};
    final now = DateTime.now();
    for (final n in _filtered) {
      final diff = now.difference(n.dateCreation);
      final String group;
      if (diff.inDays == 0) {
        group = "Aujourd'hui";
      } else if (diff.inDays == 1) {
        group = 'Hier';
      } else {
        group = 'Plus tôt';
      }
      grouped.putIfAbsent(group, () => []).add(n);
    }

    final order = ["Aujourd'hui", 'Hier', 'Plus tôt'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        for (final group in order)
          if (grouped.containsKey(group)) ...[
            _GroupHeader(group),
            const SizedBox(height: 8),
            ...grouped[group]!.map((n) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _NotificationCard(notification: n, onTap: () => _onTap(n)),
            )),
            const SizedBox(height: 4),
          ],
      ],
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.notifications_off_outlined, size: 52, color: Colors.grey.shade300),
      const SizedBox(height: 12),
      Text('Aucune notification',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text('Tout est à jour.', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
    ]),
  );
}

// ── Group header ──────────────────────────────────────────────────────────────
class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 2),
    child: Text(label,
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: Colors.grey.shade500, letterSpacing: 0.5,
        )),
  );
}

// ── Filter chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? kGreen : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: active
              ? [BoxShadow(color: kGreen.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.grey.shade600,
            )),
      ),
    );
  }
}

// ── Notification card ─────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationCeo notification;
  final VoidCallback onTap;
  const _NotificationCard({required this.notification, required this.onTap});

  static const _typeConfig = {
    'NOUVEL_ECHANTILLON':   (Icons.science_outlined,      Color(0xFF3A6EA5), Color(0xFFE8F1FB)),
    'ECHANTILLON_MODIFIE':  (Icons.edit_outlined,         Color(0xFFD07B2F), Color(0xFFFEF3E8)),
    'ECHANTILLON_SUPPRIME': (Icons.delete_outline,        Color(0xFFB71C1C), Color(0xFFFFEBEE)),
    'ECHANTILLON_RECU':     (Icons.check_circle_outline,  Color(0xFF38835A), Color(0xFFE6F4ED)),
    'PREMIERE_EVALUATION':  (Icons.star_border_outlined,  Color(0xFF7B1FA2), Color(0xFFF3E5F5)),
    'TOUTES_EVALUATIONS':   (Icons.group_outlined,        Color(0xFF38835A), Color(0xFFE6F4ED)),
    'ANALYSE_SOUMISE':      (Icons.biotech_outlined,      Color(0xFF0277BD), Color(0xFFE1F5FE)),
    'ACHAT_CONFIRME':       (Icons.handshake_outlined,    Color(0xFF38835A), Color(0xFFE6F4ED)),
  };

  @override
  Widget build(BuildContext context) {
    final cfg   = _typeConfig[notification.type];
    final icon  = cfg?.$1 ?? Icons.notifications_outlined;
    final color = cfg?.$2 ?? kGreen;
    final bgCol = cfg?.$3 ?? const Color(0xFFE6F4ED);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead ? Colors.grey.shade100 : color.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Left accent bar — visible only for unread, no height: infinity needed
            if (!notification.isRead)
              Container(width: 4, color: color),
            // Card content
            Expanded(child: Padding(
              padding: EdgeInsets.fromLTRB(notification.isRead ? 14 : 10, 14, 14, 14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: bgCol, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(notification.titre,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                          color: kDark,
                        ))),
                    if (!notification.isRead)
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                  ]),
                  const SizedBox(height: 4),
                  Text(notification.message,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
                  const SizedBox(height: 6),
                  Row(children: [
                    if (notification.echantillonReference != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(notification.echantillonReference!,
                            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(_relativeTime(notification.dateCreation),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.grey.shade300),
                  ]),
                ])),
              ]),
            )),
          ]),
        ),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} jours';
  }
}

