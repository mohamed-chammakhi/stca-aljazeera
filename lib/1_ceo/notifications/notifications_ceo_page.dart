import 'package:flutter/material.dart';
import 'package:project3/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/bandeau_demonstration.dart';
import 'models/notification_ceo.dart';
import 'services/notification_ceo_service.dart';
import 'widgets/notification_header.dart';
import 'widgets/notification_card.dart';

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
  bool _estDemonstration = false;
  Object? _erreurChargement;
  String _filter = 'tous';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final resultat = await widget.service.fetchNotifications();
      if (!mounted) return;
      setState(() {
        _all = resultat.donnees;
        _estDemonstration = resultat.estDemonstration;
        _erreurChargement = null;
        _loading = false;
      });
    } catch (erreur) {
      if (!mounted) return;
      setState(() {
        _erreurChargement = erreur;
        _loading = false;
      });
    }
  }

  List<NotificationCeo> get _filtered =>
      _filter == 'non_lus' ? _all.where((n) => !n.isRead).toList() : _all;

  int get _unreadCount => _all.where((n) => !n.isRead).length;

  Future<bool> _markRead(NotificationCeo n) async {
    if (n.isRead) return true;
    try {
      await widget.service.markAsRead(n.id);
      if (!mounted) return false;
      setState(() {
        final i = _all.indexWhere((x) => x.id == n.id);
        if (i != -1) _all[i] = n.copyWith(isRead: true);
      });
      return true;
    } catch (_) {
      if (mounted) _signalerErreur();
      return false;
    }
  }

  Future<void> _markAllRead() async {
    try {
      await widget.service.markAllAsRead();
      if (!mounted) return;
      setState(() => _all = _all.map((n) => n.copyWith(isRead: true)).toList());
    } catch (_) {
      if (mounted) _signalerErreur();
    }
  }

  Future<void> _onTap(NotificationCeo n) async {
    if (!await _markRead(n) || !mounted) return;
    widget.onNavigate(n);
    Navigator.pop(context);
  }

  void _signalerErreur() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('La notification n’a pas pu être mise à jour.')),
    );
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
        title: Text(
          'Notifications',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kDark,
          ),
        ),
        iconTheme: const IconThemeData(color: kDark),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Tout marquer lu',
                style: TextStyle(
                  fontSize: 12,
                  color: kGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kGreen))
          : VueResultatService(
              estDemonstration: _estDemonstration,
              erreur: _erreurChargement,
              onReessayer: _load,
              child: Column(
                children: [
                  Container(
                    color: kHeaderBg,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                    child: Row(
                      children: [
                        NotifFilterChip(
                          label: 'Tous',
                          active: _filter == 'tous',
                          onTap: () => setState(() => _filter = 'tous'),
                        ),
                        const SizedBox(width: 8),
                        NotifFilterChip(
                          label: _unreadCount > 0
                              ? 'Non lus ($_unreadCount)'
                              : 'Non lus',
                          active: _filter == 'non_lus',
                          onTap: () => setState(() => _filter = 'non_lus'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                  Container(
                    color: kBg,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          size: 13,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_filtered.length} notification${_filtered.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _filtered.isEmpty
                        ? _buildEmpty()
                        : _buildGroupedList(),
                  ),
                ],
              ),
            ),
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
            NotifGroupHeader(group),
            const SizedBox(height: 8),
            ...grouped[group]!.map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CeoNotificationCard(
                  notification: n,
                  onTap: () => _onTap(n),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
      ],
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.notifications_off_outlined,
          size: 52,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 12),
        Text(
          'Aucune notification',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tout est à jour.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        ),
      ],
    ),
  );
}
