// ─────────────────────────────────────────────────────────────────────────────
// FILE : sessions_degustation/widgets/session_card.dart
// PURPOSE : One session card — left accent bar for status, chevron expand,
//           detail panel with all session info + edit/delete actions.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/session_degustation.dart';

const Color _dark = Color(0xFF1A2E1F);
const Color _olive = Color(0xFF6B8143);
const Color _green = Color(0xFF38835A);

Color _statusColor(StatutSession s) {
  switch (s) {
    case StatutSession.planifiee:
      return const Color(0xFFD07B2F);
    case StatutSession.enCours:
      return const Color(0xFF3A6EA5);
    case StatutSession.terminee:
      return const Color(0xFF38835A);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class SessionCard extends StatefulWidget {
  final SessionDegustation session;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;

  const SessionCard({
    super.key,
    required this.session,
    this.onModifier,
    this.onSupprimer,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  bool _expanded          = false;
  bool _presenceConfirmed = false;
  bool _showPresenceMsg   = false;
  Timer? _msgTimer;

  @override
  void dispose() {
    _msgTimer?.cancel();
    super.dispose();
  }

  void _togglePresence() {
    _msgTimer?.cancel();
    if (_presenceConfirmed) {
      setState(() {
        _presenceConfirmed = false;
        _showPresenceMsg   = false;
      });
    } else {
      setState(() {
        _presenceConfirmed = true;
        _showPresenceMsg   = true;
      });
      _msgTimer = Timer(const Duration(seconds: 6), () {
        if (mounted) setState(() => _showPresenceMsg = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final accent = _statusColor(s.statut);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header (always visible) ─────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent bar (status indicator)
                  Container(width: 4, color: accent),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: title + participant pill + chevron
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  s.titre,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _dark,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // ── Confirmation message (inline, collapses when hidden) ──
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                child: _showPresenceMsg
                                    ? Container(
                                        margin: const EdgeInsets.only(right: 6),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _green,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check,
                                              size: 10,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Présence confirmée',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              // ── Tick toggle button ───────────────────────
                              GestureDetector(
                                onTap: _togglePresence,
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 220),
                                    switchInCurve: Curves.easeOutBack,
                                    transitionBuilder: (child, anim) =>
                                        ScaleTransition(
                                          scale: anim,
                                          child: child,
                                        ),
                                    child: Icon(
                                      _presenceConfirmed
                                          ? Icons.check_circle
                                          : Icons.check_circle_outline,
                                      key: ValueKey(_presenceConfirmed),
                                      size: 20,
                                      color: _presenceConfirmed
                                          ? _green
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: _expanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 2),

                          // Row 2: session ID + action icons (expanded only)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                s.id,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const Spacer(),
                              if (_expanded &&
                                  (widget.onModifier != null ||
                                      widget.onSupprimer != null)) ...[
                                if (widget.onModifier != null)
                                  Tooltip(
                                    message: 'Modifier',
                                    child: _SmallIconBtn(
                                      icon: Icons.edit_outlined,
                                      color: _olive,
                                      onTap: widget.onModifier!,
                                    ),
                                  ),
                                if (widget.onModifier != null)
                                  const SizedBox(width: 2),
                                if (widget.onSupprimer != null)
                                  Tooltip(
                                    message: 'Supprimer',
                                    child: _SmallIconBtn(
                                      icon: Icons.delete_outline,
                                      color: Colors.red.shade300,
                                      onTap: widget.onSupprimer!,
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable detail panel ─────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _DetailPanel(s: s, accentColor: accent),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL ICON BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _SmallIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: Icon(icon, size: 18, color: color),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL PANEL — all session attributes
// ─────────────────────────────────────────────────────────────────────────────
class _DetailPanel extends StatelessWidget {
  final SessionDegustation s;
  final Color accentColor;

  const _DetailPanel({required this.s, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final noms = (s.participantNoms != null && s.participantNoms!.isNotEmpty)
        ? s.participantNoms!.join(', ')
        : '${s.nbParticipants} participant(s)';

    return Column(
      children: [
        Divider(color: Colors.grey.shade100, height: 1),
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Attribute grid ────────────────────────────────────────
              Wrap(
                spacing: 100,
                runSpacing: 10,
                children: [
                  _DetailItem('Date', s.date),
                  _DetailItem('Heure', s.heure),
                  _DetailItem('Lieu', s.lieu),
                  _DetailItem(
                    'Échantillons',
                    '${s.nbEchantillons} échantillon${s.nbEchantillons > 1 ? "s" : ""}',
                  ),
                  _DetailItem('Participants', noms),
                  _DetailItem('Organisé par', s.createdBy),
                ],
              ),

              // ── Notes (optional) ──────────────────────────────────────
              if (s.notes != null && s.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes_outlined,
                        size: 13,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          s.notes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL ITEM
// ─────────────────────────────────────────────────────────────────────────────
class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFFAAAAAA),
          letterSpacing: 0.3,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _dark,
        ),
      ),
    ],
  );
}
