# Lab Technician Notifications Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a full notification system for the lab technician receiving urgent analysis requests, and add an urgent 🔔 button on the degustateur + chef dégustateur analyse_labo cards that triggers those notifications.

**Architecture:** New `4_laboratoire/notifications/` module (model + service + page) mirrors the CEO notification pattern exactly. The urgent button is added to both degustateur and chef `AnalyseCard` widgets as optional `onUrgentLabo`/`isUrgentLabo` params — the page holds `_urgentSent` state and shows the CEO-style confirmation dialog. Backend gets one new `ANALYSE_URGENTE` type.

**Tech Stack:** Flutter (StatefulWidget + setState), Dart, Django REST Framework (backend only — one line addition).

---

## File Map

| Action | Path |
|--------|------|
| Create | `lib/4_laboratoire/notifications/models/notification_labo.dart` |
| Create | `lib/4_laboratoire/notifications/services/notification_labo_service.dart` |
| Create | `lib/4_laboratoire/notifications/notifications_labo_page.dart` |
| Modify | `lib/3_degustateur/analyse_labo/widgets/analyse_card.dart` |
| Modify | `lib/3_degustateur/analyse_labo/services/analyse_labo_service.dart` |
| Modify | `lib/3_degustateur/analyse_labo/analyse_laboratoire_page.dart` |
| Modify | `lib/5_chef_degustateur/analyse_labo/widgets/analyse_card.dart` |
| Modify | `lib/5_chef_degustateur/analyse_labo/services/analyse_labo_chef_service.dart` |
| Modify | `lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart` |
| Modify | `lib/4_laboratoire/labo_drawer.dart` |
| Modify | `lib/4_laboratoire/echantillons_labo/echantillons_labo_page.dart` |
| Modify | `backend_new/notifications/models.py` |

---

## Task 1: Backend — Add ANALYSE_URGENTE notification type

**Files:**
- Modify: `backend_new/notifications/models.py`

- [ ] **Step 1: Add the new type to the Type enum**

In `backend_new/notifications/models.py`, inside `class Type(models.TextChoices):`, add after the last existing entry:

```python
ANALYSE_URGENTE = 'ANALYSE_URGENTE', 'Analyse urgente demandée'
```

The full enum block after the change:
```python
class Type(models.TextChoices):
    NOUVEL_ECHANTILLON   = 'NOUVEL_ECHANTILLON',   'Nouvel échantillon'
    ECHANTILLON_MODIFIE  = 'ECHANTILLON_MODIFIE',  'Échantillon modifié'
    ECHANTILLON_SUPPRIME = 'ECHANTILLON_SUPPRIME', 'Échantillon supprimé'
    ECHANTILLON_RECU     = 'ECHANTILLON_RECU',     'Échantillon reçu physiquement'
    PREMIERE_EVALUATION  = 'PREMIERE_EVALUATION',  'Première évaluation soumise'
    TOUTES_EVALUATIONS   = 'TOUTES_EVALUATIONS',   'Toutes les évaluations soumises'
    ANALYSE_SOUMISE      = 'ANALYSE_SOUMISE',      'Analyse laboratoire soumise'
    ACHAT_CONFIRME       = 'ACHAT_CONFIRME',       'Achat confirmé'
    ANALYSE_URGENTE      = 'ANALYSE_URGENTE',      'Analyse urgente demandée'
```

- [ ] **Step 2: Commit**

```bash
git add backend_new/notifications/models.py
git commit -m "feat: add ANALYSE_URGENTE notification type to backend model"
```

---

## Task 2: Lab Notification Model

**Files:**
- Create: `lib/4_laboratoire/notifications/models/notification_labo.dart`

- [ ] **Step 1: Create the model file**

```dart
class NotificationLabo {
  final String id;
  final String type;
  final String titre;
  final String message;
  final String? echantillonId;
  final String? echantillonReference;
  final String section;
  final bool isRead;
  final DateTime dateCreation;

  const NotificationLabo({
    required this.id,
    required this.type,
    required this.titre,
    required this.message,
    this.echantillonId,
    this.echantillonReference,
    required this.section,
    required this.isRead,
    required this.dateCreation,
  });

  factory NotificationLabo.fromJson(Map<String, dynamic> json) => NotificationLabo(
    id:                   json['id'] as String,
    type:                 json['type'] as String,
    titre:                json['titre'] as String,
    message:              json['message'] as String,
    echantillonId:        json['echantillon'] as String?,
    echantillonReference: json['echantillon_reference'] as String?,
    section:              json['section'] as String,
    isRead:               json['is_read'] as bool,
    dateCreation:         DateTime.parse(json['date_creation'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id':                    id,
    'type':                  type,
    'titre':                 titre,
    'message':               message,
    'echantillon':           echantillonId,
    'echantillon_reference': echantillonReference,
    'section':               section,
    'is_read':               isRead,
    'date_creation':         dateCreation.toIso8601String(),
  };

  NotificationLabo copyWith({bool? isRead}) => NotificationLabo(
    id:                   id,
    type:                 type,
    titre:                titre,
    message:              message,
    echantillonId:        echantillonId,
    echantillonReference: echantillonReference,
    section:              section,
    isRead:               isRead ?? this.isRead,
    dateCreation:         dateCreation,
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/4_laboratoire/notifications/models/notification_labo.dart
git commit -m "feat: add NotificationLabo model"
```

---

## Task 3: Lab Notification Service with Mock Data

**Files:**
- Create: `lib/4_laboratoire/notifications/services/notification_labo_service.dart`

- [ ] **Step 1: Create the service with rich mock scenarios**

The mock data must cover real usage: dégustateur and chef sending urgent requests for different samples, at different times (today / yesterday / earlier), some read and some unread.

```dart
import '../models/notification_labo.dart';

class NotificationLaboService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  Future<List<NotificationLabo>> fetchNotifications() async {
    // TODO: replace with: final data = await _api.get('/api/notifications/');
    // TODO: return (data['results'] as List).map((e) => NotificationLabo.fromJson(e)).toList();
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockNotifications(); // TODO: remove when backend is ready
  }

  Future<void> markAsRead(String id) async {
    // TODO: replace with: await _api.patch('/api/notifications/$id/', {'is_read': true});
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> markAllAsRead() async {
    // TODO: replace with: await _api.post('/api/notifications/read-all/', {});
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<int> fetchUnreadCount() async {
    // TODO: replace with: final data = await _api.get('/api/notifications/unread-count/');
    // TODO: return data['count'] as int;
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockNotifications().where((n) => !n.isRead).length;
  }

  // TODO: remove when backend is ready
  List<NotificationLabo> _mockNotifications() {
    final now = DateTime.now();
    return [
      // ── Aujourd'hui ────────────────────────────────────────────────────────
      NotificationLabo(
        id: 'notif-labo-1',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Lobna E. (dégustateur) a marqué l'échantillon ECH-2026-041 (Chemlali, Sfax) comme urgent. Veuillez prioriser son analyse chimique.",
        echantillonId: 'ech-041',
        echantillonReference: 'ECH-2026-041',
        section: 'ANALYSES',
        isRead: false,
        dateCreation: now.subtract(const Duration(minutes: 5)),
      ),
      NotificationLabo(
        id: 'notif-labo-2',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Karim B. (chef dégustateur) demande en urgence l'analyse de l'échantillon ECH-2026-039 (Chetoui, Béja). Une décision d'achat en dépend.",
        echantillonId: 'ech-039',
        echantillonReference: 'ECH-2026-039',
        section: 'ANALYSES',
        isRead: false,
        dateCreation: now.subtract(const Duration(hours: 2)),
      ),
      NotificationLabo(
        id: 'notif-labo-3',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Nayrouz F. (dégustateur) a signalé l'échantillon ECH-2026-037 (Zalmati, Monastir) comme prioritaire. L'évaluation organoleptique est déjà soumise et en attente du rapport chimique.",
        echantillonId: 'ech-037',
        echantillonReference: 'ECH-2026-037',
        section: 'ANALYSES',
        isRead: false,
        dateCreation: now.subtract(const Duration(hours: 4, minutes: 30)),
      ),
      // ── Hier ───────────────────────────────────────────────────────────────
      NotificationLabo(
        id: 'notif-labo-4',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Yosra S. (chef dégustateur) a demandé en urgence l'analyse de l'échantillon ECH-2026-035 (Arbequina, Nabeul, 95 L). Le fournisseur attend une réponse dans 48h.",
        echantillonId: 'ech-035',
        echantillonReference: 'ECH-2026-035',
        section: 'ANALYSES',
        isRead: true,
        dateCreation: now.subtract(const Duration(days: 1, hours: 1)),
      ),
      NotificationLabo(
        id: 'notif-labo-5',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Ahmed D. (dégustateur) a marqué ECH-2026-033 (Oueslati, Kairouan, 60 L) comme urgent. Les résultats de dégustation sont excellents — confirmation chimique attendue.",
        echantillonId: 'ech-033',
        echantillonReference: 'ECH-2026-033',
        section: 'ANALYSES',
        isRead: true,
        dateCreation: now.subtract(const Duration(days: 1, hours: 5)),
      ),
      // ── Plus tôt ───────────────────────────────────────────────────────────
      NotificationLabo(
        id: 'notif-labo-6',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Rania H. (chef dégustateur) demande la priorisation de l'analyse chimique pour ECH-2026-029 (Chemlali, Sfax Sud, 140 L). Potentiel Extra Vierge selon l'évaluation panel.",
        echantillonId: 'ech-029',
        echantillonReference: 'ECH-2026-029',
        section: 'ANALYSES',
        isRead: true,
        dateCreation: now.subtract(const Duration(days: 2, hours: 3)),
      ),
      NotificationLabo(
        id: 'notif-labo-7',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Sami K. (dégustateur) a signalé ECH-2026-025 (Chetoui, Bizerte) comme prioritaire suite à une évaluation organoleptique exceptionnelle. Panel unanime — analyse chimique requise d'urgence.",
        echantillonId: 'ech-025',
        echantillonReference: 'ECH-2026-025',
        section: 'ANALYSES',
        isRead: true,
        dateCreation: now.subtract(const Duration(days: 3, hours: 2)),
      ),
    ];
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/4_laboratoire/notifications/services/notification_labo_service.dart
git commit -m "feat: add NotificationLaboService with mock urgent analysis scenarios"
```

---

## Task 4: Lab Notification Page

**Files:**
- Create: `lib/4_laboratoire/notifications/notifications_labo_page.dart`

- [ ] **Step 1: Create the page**

This is a full-page notification list, mirrors `NotificationsCeoPage`. Uses `CeoNotificationCard` visual pattern but inline (no separate widget file needed). Groups by Aujourd'hui / Hier / Plus tôt.

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/notification_labo.dart';
import 'services/notification_labo_service.dart';
import '../../core/theme/app_colors.dart';

class NotificationsLaboPage extends StatefulWidget {
  const NotificationsLaboPage({super.key});

  @override
  State<NotificationsLaboPage> createState() => _NotificationsLaboPageState();
}

class _NotificationsLaboPageState extends State<NotificationsLaboPage> {
  final _service = NotificationLaboService();
  List<NotificationLabo> _all = [];
  bool _loading = true;
  String _filter = 'tous';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.fetchNotifications();
    if (mounted) setState(() { _all = data; _loading = false; });
  }

  List<NotificationLabo> get _filtered =>
      _filter == 'non_lus' ? _all.where((n) => !n.isRead).toList() : _all;

  int get _unreadCount => _all.where((n) => !n.isRead).length;

  Future<void> _markRead(NotificationLabo n) async {
    if (n.isRead) return;
    await _service.markAsRead(n.id);
    setState(() {
      final i = _all.indexWhere((x) => x.id == n.id);
      if (i != -1) _all[i] = n.copyWith(isRead: true);
    });
  }

  Future<void> _markAllRead() async {
    await _service.markAllAsRead();
    setState(() => _all = _all.map((n) => n.copyWith(isRead: true)).toList());
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
          style: GoogleFonts.domine(fontSize: 18, fontWeight: FontWeight.w700, color: kDark),
        ),
        iconTheme: const IconThemeData(color: kDark),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Tout marquer lu',
                style: TextStyle(fontSize: 12, color: kGreen, fontWeight: FontWeight.w600),
              ),
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
                  _FilterChip(
                    label: 'Tous',
                    active: _filter == 'tous',
                    onTap: () => setState(() => _filter = 'tous'),
                  ),
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
                    '${_filtered.length} notification${_filtered.length != 1 ? "s" : ""}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                  ),
                ]),
              ),
              Expanded(
                child: _filtered.isEmpty ? _buildEmpty() : _buildGroupedList(),
              ),
            ]),
    );
  }

  Widget _buildGroupedList() {
    final grouped = <String, List<NotificationLabo>>{};
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
              child: _LaboNotifCard(notification: n, onTap: () => _markRead(n)),
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

// ── Filter chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? kGreen : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? kGreen : const Color(0xFFE0E0E0),
          width: 1.2,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : const Color(0xFF757575),
        ),
      ),
    ),
  );
}

// ── Group header ──────────────────────────────────────────────────────────────
class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade400,
        letterSpacing: 0.5,
      ),
    ),
  );
}

// ── Notification card ─────────────────────────────────────────────────────────
class _LaboNotifCard extends StatelessWidget {
  final NotificationLabo notification;
  final VoidCallback onTap;
  const _LaboNotifCard({required this.notification, required this.onTap});

  static const _urgentColor = Color(0xFFC62828);
  static const _urgentBg    = Color(0xFFFFEBEE);

  @override
  Widget build(BuildContext context) {
    const color = _urgentColor;
    const bgCol = _urgentBg;
    const icon  = Icons.notification_important_outlined;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead
                ? Colors.grey.shade100
                : color.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (!notification.isRead)
              Container(width: 4, color: color),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  notification.isRead ? 14 : 10, 14, 14, 14,
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: bgCol,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(
                          child: Text(
                            notification.titre,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: kDark,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ]),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        if (notification.echantillonReference != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              notification.echantillonReference!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          _relativeTime(notification.dateCreation),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: Colors.grey.shade300,
                        ),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ),
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/4_laboratoire/notifications/notifications_labo_page.dart
git commit -m "feat: add NotificationsLaboPage with grouped notification list"
```

---

## Task 5: Update LaboDrawer — add Notifications entry

**Files:**
- Modify: `lib/4_laboratoire/labo_drawer.dart`

- [ ] **Step 1: Add `onNotifications` callback to constructor**

Change the constructor from:
```dart
class LaboDrawer extends StatelessWidget {
  final VoidCallback onEchantillons;
  final VoidCallback onProfil;
  final VoidCallback onDeconnexion;

  const LaboDrawer({
    super.key,
    required this.onEchantillons,
    required this.onProfil,
    required this.onDeconnexion,
  });
```

To:
```dart
class LaboDrawer extends StatelessWidget {
  final VoidCallback onEchantillons;
  final VoidCallback onNotifications;
  final VoidCallback onProfil;
  final VoidCallback onDeconnexion;

  const LaboDrawer({
    super.key,
    required this.onEchantillons,
    required this.onNotifications,
    required this.onProfil,
    required this.onDeconnexion,
  });
```

- [ ] **Step 2: Add Notifications nav item in the ListView**

In the `ListView` inside `Expanded`, add after the existing `_DrawerItem` for echantillons and before the first `Divider`:

```dart
_DrawerItem(
  icon: Icons.notifications_outlined,
  label: 'Notifications',
  onTap: onNotifications,
),
```

The full `Expanded` child `ListView` becomes:
```dart
Expanded(
  child: ListView(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    children: [
      _SectionLabel('Analyses'),
      _DrawerItem(
        icon: Icons.science_outlined,
        label: 'Échantillons à analyser',
        onTap: onEchantillons,
      ),
      _DrawerItem(
        icon: Icons.notifications_outlined,
        label: 'Notifications',
        onTap: onNotifications,
      ),
      const SizedBox(height: 4),
      Divider(color: kOlive.withOpacity(0.15), height: 1),
      const SizedBox(height: 4),
      _SectionLabel('Compte'),
      _DrawerItem(
        icon: Icons.person_outline,
        label: 'Mon Profil',
        onTap: onProfil,
      ),
    ],
  ),
),
```

- [ ] **Step 3: Commit**

```bash
git add lib/4_laboratoire/labo_drawer.dart
git commit -m "feat: add Notifications entry to LaboDrawer"
```

---

## Task 6: Wire notifications into EchantillonsLaboPage

**Files:**
- Modify: `lib/4_laboratoire/echantillons_labo/echantillons_labo_page.dart`

- [ ] **Step 1: Add import**

At the top of the file, add:
```dart
import '../notifications/notifications_labo_page.dart';
```

- [ ] **Step 2: Add notification bell to AppBar actions**

In the `appBar:` block, add `actions:` after `iconTheme`:

```dart
actions: [
  IconButton(
    icon: const Icon(Icons.notifications_outlined, size: 22),
    color: kDark,
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsLaboPage()),
    ),
  ),
],
```

- [ ] **Step 3: Wire `onNotifications` in the LaboDrawer call**

Change the existing `LaboDrawer(...)` call from:
```dart
drawer: LaboDrawer(
  onEchantillons: () => goToPage(const EchantillonsLaboPage()),
  onProfil: () => goToPage(const ProfilLaboPage()),
  onDeconnexion: () => goToPage(LoginPage()),
),
```

To:
```dart
drawer: LaboDrawer(
  onEchantillons: () => goToPage(const EchantillonsLaboPage()),
  onNotifications: () => goToPage(const NotificationsLaboPage()),
  onProfil: () => goToPage(const ProfilLaboPage()),
  onDeconnexion: () => goToPage(LoginPage()),
),
```

- [ ] **Step 4: Commit**

```bash
git add lib/4_laboratoire/echantillons_labo/echantillons_labo_page.dart
git commit -m "feat: wire notifications page into lab module (appbar bell + drawer)"
```

---

## Task 7: Add urgent button to Dégustateur AnalyseCard

**Files:**
- Modify: `lib/3_degustateur/analyse_labo/widgets/analyse_card.dart`

- [ ] **Step 1: Add `onUrgentLabo` and `isUrgentLabo` params to `AnalyseCard`**

Change the widget class from:
```dart
class AnalyseCard extends StatefulWidget {
  final AnalyseLabo analyse;

  const AnalyseCard({super.key, required this.analyse});
```

To:
```dart
class AnalyseCard extends StatefulWidget {
  final AnalyseLabo analyse;
  final VoidCallback? onUrgentLabo;
  final bool isUrgentLabo;

  const AnalyseCard({
    super.key,
    required this.analyse,
    this.onUrgentLabo,
    this.isUrgentLabo = false,
  });
```

- [ ] **Step 2: Add the 🔔 button in row 2 of the card header**

In `_AnalyseCardState.build()`, locate the `Row` that starts with `Icon(Icons.tag, ...)` (the second row inside the card header `Column`). It currently ends with `const Spacer()`. Replace the entire row with:

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Icon(Icons.tag, size: 11, color: Colors.grey.shade400),
    const SizedBox(width: 4),
    Text(
      a.id,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade500,
      ),
    ),
    const Spacer(),
    if (widget.onUrgentLabo != null)
      GestureDetector(
        onTap: widget.onUrgentLabo,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.isUrgentLabo
                ? const Color(0xFFC62828).withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isUrgentLabo
                  ? const Color(0xFFC62828).withValues(alpha: 0.40)
                  : Colors.grey.shade300,
              width: widget.isUrgentLabo ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isUrgentLabo
                    ? Icons.notifications_active
                    : Icons.notifications_outlined,
                size: 13,
                color: widget.isUrgentLabo
                    ? const Color(0xFFC62828)
                    : Colors.grey.shade400,
              ),
              if (widget.isUrgentLabo) ...[
                const SizedBox(width: 3),
                const Text(
                  'Urgent',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC62828),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
  ],
),
```

- [ ] **Step 3: Commit**

```bash
git add lib/3_degustateur/analyse_labo/widgets/analyse_card.dart
git commit -m "feat: add urgent lab notification button to degustateur AnalyseCard"
```

---

## Task 8: Add sendUrgentAnalyseLabo to Dégustateur AnalyseLaboService

**Files:**
- Modify: `lib/3_degustateur/analyse_labo/services/analyse_labo_service.dart`

- [ ] **Step 1: Add the method**

After the existing `fetchAnalyses()` method, add:

```dart
Future<void> sendUrgentAnalyseLabo(
  String echantillonId,
  String echantillonReference,
) async {
  // TODO: replace with: await _api.post('/api/notifications/urgent-labo/', {
  //   'echantillon_id': echantillonId,
  //   'echantillon_reference': echantillonReference,
  // });
  await Future.delayed(const Duration(milliseconds: 200));
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/3_degustateur/analyse_labo/services/analyse_labo_service.dart
git commit -m "feat: add sendUrgentAnalyseLabo to degustateur service"
```

---

## Task 9: Wire urgent button in Dégustateur AnalyseLaboratoirePage

**Files:**
- Modify: `lib/3_degustateur/analyse_labo/analyse_laboratoire_page.dart`

- [ ] **Step 1: Add `_urgentSent` state set**

In `_AnalyseLaboratoirePageState`, add after the existing state fields:

```dart
final Set<String> _urgentSent = {};
```

- [ ] **Step 2: Add `_confirmSendUrgent` method**

Add this method to `_AnalyseLaboratoirePageState` (before `dispose()`):

```dart
Future<void> _confirmSendUrgent(AnalyseLabo a) async {
  if (_urgentSent.contains(a.id)) return;

  await showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEBEE),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notification_important_outlined,
                  color: Color(0xFFC62828),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analyse urgente',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kDark,
                        ),
                      ),
                      Text(
                        a.echantillonNom,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E4A4A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Text(
              'Notifier le technicien laboratoire pour prioriser l\'analyse chimique de ${a.echantillonNom} en urgence ?',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A4A4A),
                height: 1.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6EF),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _service.sendUrgentAnalyseLabo(
                        a.echantillonId,
                        a.echantillonNom,
                      );
                      setState(() => _urgentSent.add(a.id));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Technicien notifié — analyse urgente pour ${a.echantillonNom}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: const Color(0xFFC62828),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(20),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Notifier',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 3: Wire the button in the `ListView.builder`**

Find the `AnalyseCard(analyse: a)` call in the `itemBuilder`. Replace it with:

```dart
AnalyseCard(
  analyse: a,
  onUrgentLabo: () => _confirmSendUrgent(a),
  isUrgentLabo: _urgentSent.contains(a.id),
),
```

- [ ] **Step 4: Add missing import for kDark**

Ensure `kDark` is available. The file already imports `'../../../core/theme/app_colors.dart'` which exports `kDark`. No additional import needed.

- [ ] **Step 5: Commit**

```bash
git add lib/3_degustateur/analyse_labo/analyse_laboratoire_page.dart
git commit -m "feat: wire urgent lab button in degustateur analyse page"
```

---

## Task 10: Add urgent button to Chef Dégustateur AnalyseCard

**Files:**
- Modify: `lib/5_chef_degustateur/analyse_labo/widgets/analyse_card.dart`

- [ ] **Step 1: Add `onUrgentLabo` and `isUrgentLabo` params**

Change the widget class from:
```dart
class AnalyseCard extends StatefulWidget {
  final AnalyseLabo analyse;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;

  const AnalyseCard({
    super.key,
    required this.analyse,
    this.onModifier,
    this.onSupprimer,
  });
```

To:
```dart
class AnalyseCard extends StatefulWidget {
  final AnalyseLabo analyse;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;
  final VoidCallback? onUrgentLabo;
  final bool isUrgentLabo;

  const AnalyseCard({
    super.key,
    required this.analyse,
    this.onModifier,
    this.onSupprimer,
    this.onUrgentLabo,
    this.isUrgentLabo = false,
  });
```

- [ ] **Step 2: Add the 🔔 button in row 2 of the card header**

In `_AnalyseCardState.build()`, find the second `Row` inside the card header (the one with `Icon(Icons.tag, ...)` and `const Spacer()`). Replace its full content with:

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Icon(Icons.tag, size: 11, color: Colors.grey.shade400),
    const SizedBox(width: 4),
    Text(
      a.id,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade500,
      ),
    ),
    const SizedBox(width: 10),
    const Spacer(),
    if (_expanded &&
        (widget.onModifier != null || widget.onSupprimer != null)) ...[
      if (widget.onModifier != null)
        Tooltip(
          message: 'Modifier',
          child: _SmallIconBtn(
            icon: Icons.edit_outlined,
            color: _olive,
            onTap: widget.onModifier!,
          ),
        ),
      if (widget.onModifier != null) const SizedBox(width: 2),
      if (widget.onSupprimer != null)
        Tooltip(
          message: 'Supprimer',
          child: _SmallIconBtn(
            icon: Icons.delete_outline,
            color: Colors.red.shade300,
            onTap: widget.onSupprimer!,
          ),
        ),
      const SizedBox(width: 6),
    ],
    if (widget.onUrgentLabo != null)
      GestureDetector(
        onTap: widget.onUrgentLabo,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.isUrgentLabo
                ? const Color(0xFFC62828).withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isUrgentLabo
                  ? const Color(0xFFC62828).withValues(alpha: 0.40)
                  : Colors.grey.shade300,
              width: widget.isUrgentLabo ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isUrgentLabo
                    ? Icons.notifications_active
                    : Icons.notifications_outlined,
                size: 13,
                color: widget.isUrgentLabo
                    ? const Color(0xFFC62828)
                    : Colors.grey.shade400,
              ),
              if (widget.isUrgentLabo) ...[
                const SizedBox(width: 3),
                const Text(
                  'Urgent',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC62828),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
  ],
),
```

- [ ] **Step 3: Commit**

```bash
git add lib/5_chef_degustateur/analyse_labo/widgets/analyse_card.dart
git commit -m "feat: add urgent lab notification button to chef AnalyseCard"
```

---

## Task 11: Add sendUrgentAnalyseLabo to Chef AnalyseLaboChefService

**Files:**
- Modify: `lib/5_chef_degustateur/analyse_labo/services/analyse_labo_chef_service.dart`

- [ ] **Step 1: Add the method after `deleteAnalyse`**

```dart
Future<void> sendUrgentAnalyseLabo(
  String echantillonId,
  String echantillonReference,
) async {
  // TODO: replace with: await _api.post('/api/notifications/urgent-labo/', {
  //   'echantillon_id': echantillonId,
  //   'echantillon_reference': echantillonReference,
  // });
  await Future.delayed(const Duration(milliseconds: 200));
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/5_chef_degustateur/analyse_labo/services/analyse_labo_chef_service.dart
git commit -m "feat: add sendUrgentAnalyseLabo to chef service"
```

---

## Task 12: Wire urgent button in Chef AnalyseLaboratoirePage

**Files:**
- Modify: `lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart`

- [ ] **Step 1: Add `_urgentSent` state set**

In `_AnalyseLaboratoirePageState`, add after existing state fields:

```dart
final Set<String> _urgentSent = {};
```

- [ ] **Step 2: Add `_confirmSendUrgent` method**

Add the exact same method as Task 9 Step 2, but referencing `_service` which is `AnalyseLaboChefService`. The dialog body text references `a.echantillonNom`. The method is identical:

```dart
Future<void> _confirmSendUrgent(AnalyseLabo a) async {
  if (_urgentSent.contains(a.id)) return;

  await showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEBEE),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notification_important_outlined,
                  color: Color(0xFFC62828),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analyse urgente',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kDark,
                        ),
                      ),
                      Text(
                        a.echantillonNom,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E4A4A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Text(
              'Notifier le technicien laboratoire pour prioriser l\'analyse chimique de ${a.echantillonNom} en urgence ?',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A4A4A),
                height: 1.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6EF),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _service.sendUrgentAnalyseLabo(
                        a.echantillonId,
                        a.echantillonNom,
                      );
                      setState(() => _urgentSent.add(a.id));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Technicien notifié — analyse urgente pour ${a.echantillonNom}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: const Color(0xFFC62828),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(20),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Notifier',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 3: Wire the button in the `ListView.builder`**

Find the `AnalyseCard(...)` call in the chef page's `itemBuilder`. It currently passes `onModifier` and `onSupprimer`. Add the two new params:

```dart
AnalyseCard(
  analyse: a,
  onModifier: /* existing value */,
  onSupprimer: /* existing value */,
  onUrgentLabo: () => _confirmSendUrgent(a),
  isUrgentLabo: _urgentSent.contains(a.id),
),
```

> Note: Read the actual `itemBuilder` to find the existing `onModifier`/`onSupprimer` values and preserve them exactly. Only add the two new params.

- [ ] **Step 4: Add `kDark` import if needed**

The chef page already imports `'../../../core/theme/app_colors.dart'`. No additional import needed.

- [ ] **Step 5: Commit**

```bash
git add lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart
git commit -m "feat: wire urgent lab button in chef analyse page"
```

---

## Verification

- [ ] Run `flutter analyze` — expect zero errors
- [ ] Launch app, log in as **Dégustateur** → Analyse de laboratoire → tap 🔔 on any card → confirm dialog appears → tap Notifier → button shows "🔔 Urgent" + snackbar fires
- [ ] Launch app, log in as **Chef Dégustateur** → Analyse de laboratoire → same flow works
- [ ] Launch app, log in as **Technicien Labo** → tap bell icon in AppBar OR open drawer → Notifications → grouped list shows 7 scenarios (3 unread today, 2 read yesterday, 2 read earlier) → tap any card → marks as read → "Tout marquer lu" clears all badges → filter "Non lus" shows only unread
