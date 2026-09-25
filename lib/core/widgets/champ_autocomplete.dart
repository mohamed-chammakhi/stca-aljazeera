// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/widgets/champ_autocomplete.dart
// PURPOSE : A text field that suggests values already in the system.
//
//           Rule for this project: autocomplete ASSISTS typing, it never
//           CONSTRAINS it. There is no closed dropdown here — the user can
//           always keep typing a value nobody has used before. Suggestions only
//           save keystrokes and keep spellings consistent.
//
//           Used for supplier and variety. The only genuinely closed field in
//           the app is the delegation, which comes from the official Tunisian
//           list already bundled with the app (GeoService).
// ═════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../services/resultat_service.dart';
import 'bandeau_demonstration.dart';

class ChampAutocomplete<T> extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;

  /// Returns what to propose for the text typed so far.
  final Future<Resultat<List<T>>> Function(String saisie) chercher;

  /// What the user reads in the list, and what lands in the field when picked.
  final String Function(T valeur) libelle;

  /// Optional second line — e.g. the supplier's region, to tell two similar
  /// names apart.
  final String? Function(T valeur)? sousTitre;

  /// Fired when a suggestion is picked, so the caller can keep the entity's ID.
  /// Not fired when the user types a value of their own.
  final void Function(T valeur)? onSelection;

  /// Fired whenever the text changes without picking a suggestion, so the caller
  /// knows the field no longer points at a known entity.
  final VoidCallback? onSaisieLibre;

  final bool enabled;

  const ChampAutocomplete({
    super.key,
    required this.controller,
    required this.label,
    required this.chercher,
    required this.libelle,
    this.hint,
    this.sousTitre,
    this.onSelection,
    this.onSaisieLibre,
    this.enabled = true,
  });

  @override
  State<ChampAutocomplete<T>> createState() => _ChampAutocompleteState<T>();
}

class _ChampAutocompleteState<T> extends State<ChampAutocomplete<T>> {
  final GlobalKey _blocKey = GlobalKey();
  final FocusNode _focus = FocusNode();
  List<T> _suggestions = const [];
  Timer? _debounce;
  bool _choixEnCours = false;
  bool _estDemonstration = false;
  Object? _erreur;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTexteChange);
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onTexteChange);
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focus.hasFocus && widget.enabled) {
      setState(() {});
      _debounce?.cancel();
      _rechercher();
      return;
    }

    setState(() => _suggestions = const []);
  }

  void _onTexteChange() {
    // Picking a suggestion writes into the controller too; without this the
    // list would immediately reopen under the value just chosen.
    if (_choixEnCours) return;
    widget.onSaisieLibre?.call();

    // One search per pause in typing, not one per keystroke.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), _rechercher);
  }

  Future<void> _rechercher() async {
    final saisie = widget.controller.text;
    try {
      final resultat = await widget.chercher(saisie);
      if (!mounted) return;
      setState(() {
        _suggestions = resultat.donnees;
        _estDemonstration = resultat.estDemonstration;
        _erreur = null;
      });
      if (_focus.hasFocus && _suggestions.isNotEmpty && widget.enabled) {
        _rendreVisible();
      }
    } catch (erreur) {
      if (!mounted) return;
      setState(() {
        _suggestions = const [];
        _erreur = erreur;
      });
    }
  }

  void _rendreVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final blocContext = _blocKey.currentContext;
      if (blocContext == null || Scrollable.maybeOf(blocContext) == null) {
        return;
      }

      Scrollable.ensureVisible(
        blocContext,
        alignment: 0.1,
        duration: const Duration(milliseconds: 200),
      );
    });
  }

  void _choisir(T valeur) {
    _choixEnCours = true;
    widget.controller.text = widget.libelle(valeur);
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.controller.text.length),
    );
    _choixEnCours = false;

    widget.onSelection?.call(valeur);
    setState(() => _suggestions = const []);
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final ouvert = _focus.hasFocus && _suggestions.isNotEmpty && widget.enabled;

    return KeyedSubtree(
      key: _blocKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: GoogleFonts.alegreya(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kOlive,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: widget.controller,
            focusNode: _focus,
            enabled: widget.enabled,
            style: const TextStyle(fontSize: 14, color: kDark),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xFFFAFAF7),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kGreen, width: 1.8),
              ),
            ),
          ),
          if (_estDemonstration) ...[
            const SizedBox(height: 4),
            BandeauDemonstration(onReessayer: _rechercher),
          ],
          if (_erreur != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Suggestions indisponibles.',
                    style: TextStyle(color: kRed, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: _rechercher,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ],
          // Inline rather than floating: the field lives inside a scrolling form,
          // and an overlay would drift away from it as the form scrolls.
          if (ouvert)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < _suggestions.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    _LigneSuggestion(
                      titre: widget.libelle(_suggestions[i]),
                      sousTitre: widget.sousTitre?.call(_suggestions[i]),
                      onTap: () => _choisir(_suggestions[i]),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LigneSuggestion extends StatelessWidget {
  final String titre;
  final String? sousTitre;
  final VoidCallback onTap;

  const _LigneSuggestion({
    required this.titre,
    required this.sousTitre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: GoogleFonts.alegreya(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kDark,
                    ),
                  ),
                  if (sousTitre != null && sousTitre!.isNotEmpty)
                    Text(
                      sousTitre!,
                      style: GoogleFonts.alegreya(
                        fontSize: 12,
                        color: const Color(0xFF6B8E7A),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.north_west, size: 14, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }
}
