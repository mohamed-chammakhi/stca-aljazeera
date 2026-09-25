// ═════════════════════════════════════════════════════════════════════════════
// FILE    : 1_ceo/validation_achats/widgets/refus_dialog.dart
// PURPOSE : Refus scindé — la direction refuse un PRIX, pas forcément un STOCK.
//
// Un refus veut le plus souvent dire « le prix ne me va pas », pas « je ne veux
// pas de ce stock ». L'ancienne fenêtre ne proposait que le refus définitif :
// un désaccord commercial tuait un lot encore intéressant, sans retour possible.
//
// La carte garde ses deux boutons, Confirmer et Refuser. Le choix entre les deux
// natures de refus se fait ici, ce qui oblige la direction à trancher
// explicitement au lieu de refuser par réflexe.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project3/core/theme/app_colors.dart';
import 'package:project3/core/widgets/saisie_protegee.dart';

import '../../../2_collecteur/mes_echantillons/widgets/dialogs/date_livraison_section.dart'
    show DateLivraisonSection, ModePlanificationUI;

const Color _rouge = Color(0xFFB71C1C);
const Color _rougeClair = Color(0xFFFFEBEE);
const Color _orange = Color(0xFFD07B2F);
const Color _creme = Color(0xFFFEF3E8);
const Color _bordure = Color(0xFFE2E6E3);
const Color _gris = Color(0xFF6B7A70);

/// Ce que la direction a décidé dans la fenêtre de refus.
class DecisionRefus {
  /// Vrai = le stock sort du parcours d'achat. Faux = contre-proposition.
  final bool definitif;
  final String raison;

  // Renseignés uniquement quand [definitif] est faux.
  final String? contrePrix;
  final String? contrePrixMax;
  final String? quantiteCibleT;
  final String? dateLivraison;
  final String? dateLivraisonFin;

  const DecisionRefus({
    required this.definitif,
    required this.raison,
    this.contrePrix,
    this.contrePrixMax,
    this.quantiteCibleT,
    this.dateLivraison,
    this.dateLivraisonFin,
  });

  /// Prix affiché dans le récapitulatif — ferme ou intervalle.
  String get prixLisible {
    if (contrePrix == null) return '—';
    if (contrePrixMax == null || contrePrixMax!.isEmpty) {
      return '$contrePrix TND/L';
    }
    return '$contrePrix – $contrePrixMax TND/L';
  }
}

/// Fenêtre de refus. Pop `DecisionRefus` si la direction valide, `null` sinon.
class RefusDecisionDialog extends StatefulWidget {
  final String referenceBouteille;

  /// Nombre de tours déjà effectués, rappelé dans la confirmation pour que la
  /// direction voie qu'un dossier s'enlise avant d'envoyer le tour suivant.
  final int nbRenegociations;

  final String? quantiteActuelle;

  const RefusDecisionDialog({
    super.key,
    required this.referenceBouteille,
    this.nbRenegociations = 0,
    this.quantiteActuelle,
  });

  @override
  State<RefusDecisionDialog> createState() => _RefusDecisionDialogState();
}

class _RefusDecisionDialogState extends State<RefusDecisionDialog> {
  bool _definitif = false;

  final _prixMinCtrl = TextEditingController();
  final _prixMaxCtrl = TextEditingController();
  final _quantiteCtrl = TextEditingController();
  final _raisonCtrl = TextEditingController();

  ModePlanificationUI _dateMode = ModePlanificationUI.dateExacte;
  DateTime? _dateExacte;
  DateTime? _periodeDebut;
  DateTime? _periodeFin;

  String? _erreur;

  @override
  void initState() {
    super.initState();
    _quantiteCtrl.text = widget.quantiteActuelle ?? '';
  }

  @override
  void dispose() {
    _prixMinCtrl.dispose();
    _prixMaxCtrl.dispose();
    _quantiteCtrl.dispose();
    _raisonCtrl.dispose();
    super.dispose();
  }

  String? _iso(DateTime? d) => d?.toIso8601String();

  /// Contrôles faits ici plutôt qu'au retour : la direction corrige sur place,
  /// sans perdre ce qu'elle a déjà saisi.
  String? _valider() {
    if (_raisonCtrl.text.trim().isEmpty) {
      return 'La raison est obligatoire — le collecteur doit comprendre la décision.';
    }
    if (_definitif) return null;

    final min = double.tryParse(_prixMinCtrl.text.trim().replaceAll(',', '.'));
    if (min == null) return 'Indiquez un contre-prix.';

    final brutMax = _prixMaxCtrl.text.trim();
    if (brutMax.isNotEmpty) {
      final max = double.tryParse(brutMax.replaceAll(',', '.'));
      if (max == null) return 'Le prix haut n\'est pas un nombre valide.';
      if (max < min) return 'Le prix haut doit être supérieur au prix bas.';
    }
    return null;
  }

  void _soumettre() {
    final probleme = _valider();
    if (probleme != null) {
      setState(() => _erreur = probleme);
      return;
    }

    final exacte = _dateMode == ModePlanificationUI.dateExacte;
    Navigator.pop(
      context,
      DecisionRefus(
        definitif: _definitif,
        raison: _raisonCtrl.text.trim(),
        contrePrix: _definitif ? null : _prixMinCtrl.text.trim(),
        contrePrixMax: _definitif ? null : _prixMaxCtrl.text.trim(),
        quantiteCibleT: _definitif ? null : _quantiteCtrl.text.trim(),
        dateLivraison:
            _definitif ? null : _iso(exacte ? _dateExacte : _periodeDebut),
        dateLivraisonFin: _definitif || exacte ? null : _iso(_periodeFin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SaisieProtegee(
      child: AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Refuser',
            style: GoogleFonts.domine(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kDark,
            ),
          ),
          Text(
            widget.referenceBouteille,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B8E7A)),
          ),
        ],
      ),
      content: SizedBox(
        // Prend la largeur que la fenetre veut bien donner : sur telephone
        // elle est bien plus etroite que sur tablette.
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Les deux choix restent cote a cote en haut de la fenetre.
              // Poser les champs de la renegociation entre les deux poussait
              // « Refus definitif » sous la ligne de flottaison : il fallait
              // parcourir toute l'option 1 pour decouvrir l'option 2.
              _optionRenegocier(),
              const SizedBox(height: 8),
              _optionDefinitif(),
              const SizedBox(height: 14),
              _definitif ? _avertissementDefinitif() : _champsRenegociation(),
              const SizedBox(height: 14),
              _libelle('Raison'),
              const SizedBox(height: 6),
              _champTexte(
                _raisonCtrl,
                'Expliquer la décision au collecteur…',
                lignes: 2,
              ),
              if (_erreur != null) ...[
                const SizedBox(height: 10),
                _bandeauErreur(_erreur!),
              ],
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B8E7A))),
        ),
        ElevatedButton(
          onPressed: _soumettre,
          style: ElevatedButton.styleFrom(
            backgroundColor: _definitif ? _rouge : _orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Valider'),
        ),
      ],
      ),
    );
  }

  // ── Les deux choix ────────────────────────────────────────────────────────
  Widget _optionRenegocier() => _carteOption(
        actif: !_definitif,
        couleur: _orange,
        titre: 'Renvoyer en négociation',
        soustitre: 'Le prix ne convient pas, mais le stock reste intéressant.',
        onTap: () => setState(() {
          _definitif = false;
          _erreur = null;
        }),
      );

  Widget _optionDefinitif() => _carteOption(
        actif: _definitif,
        couleur: _rouge,
        titre: 'Refus définitif',
        soustitre: 'Ce stock ne vous intéresse pas.',
        onTap: () => setState(() {
          _definitif = true;
          _erreur = null;
        }),
      );

  // ── Le corps de l'option retenue ──────────────────────────────────────────
  Widget _champsRenegociation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _libelle('Intervalle de prix'),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _champNombre(_prixMinCtrl, 'ex : 7.00', 'TND/L')),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 9),
              child: Text('à', style: TextStyle(fontSize: 12.5, color: _gris)),
            ),
            Expanded(child: _champNombre(_prixMaxCtrl, 'facultatif', 'TND/L')),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Laissez le second champ vide pour proposer un prix ferme.',
          style: TextStyle(fontSize: 11, color: _gris, height: 1.35),
        ),
        const SizedBox(height: 13),
        _libelle('Quantité souhaitée'),
        const SizedBox(height: 6),
        _champNombre(_quantiteCtrl, 'ex : 28', 'T'),
        const SizedBox(height: 13),
        _libelle('Date de livraison souhaitée'),
        const SizedBox(height: 8),
        DateLivraisonSection(
          // Le composant affiche sinon sa propre étiquette, qui parle de
          // l'échantillon alors qu'il s'agit ici du stock.
          showLabel: false,
          mode: _dateMode,
          onModeChanged: (m) => setState(() => _dateMode = m),
          dateExacte: _dateExacte,
          periodeDebut: _periodeDebut,
          periodeFin: _periodeFin,
          onDateExacteChanged: (d) => setState(() => _dateExacte = d),
          onPeriodeDebutChanged: (d) => setState(() => _periodeDebut = d),
          onPeriodeFinChanged: (d) => setState(() => _periodeFin = d),
        ),
      ],
    );
  }

  Widget _avertissementDefinitif() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: _rougeClair,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _rouge.withValues(alpha: 0.22)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 15, color: _rouge),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'Le refus est définitif — l\'échantillon sort du parcours '
              'd\'achat et rien ne permet de revenir en arrière.',
              style: TextStyle(
                fontSize: 11.5,
                color: _rouge,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Fragments ─────────────────────────────────────────────────────────────
  /// Une option de refus — bouton radio, titre, sous-titre.
  /// Les champs correspondants sont affichés sous les deux options, pas dedans.
  Widget _carteOption({
    required bool actif,
    required Color couleur,
    required String titre,
    required String soustitre,
    required VoidCallback onTap,
  }) {
    final entete = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            actif ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            size: 17,
            color: actif ? couleur : const Color(0xFFC3CBC6),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: GoogleFonts.domine(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: actif ? couleur : kDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                soustitre,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: _gris,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: actif ? couleur : _bordure,
            width: actif ? 1.5 : 1.2,
          ),
          color: actif ? couleur.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [entete],
        ),
      ),
    );
  }

  Widget _libelle(String texte) => Text(
        texte,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5D6B62),
          letterSpacing: 0.2,
        ),
      );

  Widget _champNombre(
    TextEditingController ctrl,
    String exemple,
    String unite,
  ) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 13.5, color: kDark),
      decoration: _deco(exemple).copyWith(
        suffixText: unite,
        suffixStyle: const TextStyle(
          fontSize: 11.5,
          color: Color(0xFF9C9B9B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _champTexte(
    TextEditingController ctrl,
    String exemple, {
    int lignes = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: lignes,
      style: const TextStyle(fontSize: 13, color: kDark),
      decoration: _deco(exemple),
    );
  }

  InputDecoration _deco(String exemple) => InputDecoration(
        hintText: exemple,
        hintStyle: const TextStyle(color: Color(0xFFB9C0BB), fontSize: 12.5),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _bordure, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _bordure, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(
            color: _definitif ? _rouge : _orange,
            width: 1.4,
          ),
        ),
      );

  Widget _bandeauErreur(String message) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: _rougeClair,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _rouge.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, size: 15, color: _rouge),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: _rouge,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// CONFIRMATION — deuxième étape, différente selon la nature du refus
//
// Une confirmation qui demande seulement « êtes-vous sûr ? » apprend au lecteur
// à cliquer sans lire. Chacune rappelle donc ce qui est réellement engagé.
// ═════════════════════════════════════════════════════════════════════════════
class ConfirmerRefusDialog extends StatelessWidget {
  final String referenceBouteille;
  final DecisionRefus decision;

  /// Tours déjà effectués. Le tour annoncé est celui-ci plus un.
  final int nbRenegociations;

  const ConfirmerRefusDialog({
    super.key,
    required this.referenceBouteille,
    required this.decision,
    this.nbRenegociations = 0,
  });

  @override
  Widget build(BuildContext context) {
    final definitif = decision.definitif;
    final couleur = definitif ? _rouge : _orange;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: definitif ? _rougeClair : _creme,
              shape: BoxShape.circle,
            ),
            child: Icon(
              definitif ? Icons.warning_amber_rounded : Icons.replay,
              size: 17,
              color: couleur,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  definitif ? 'Refus définitif ?' : 'Renvoyer en négociation ?',
                  style: GoogleFonts.domine(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kDark,
                  ),
                ),
                Text(
                  referenceBouteille,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B8E7A)),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: definitif ? _corpsDefinitif() : _corpsRenegociation(),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Retour', style: TextStyle(color: Color(0xFF6B8E7A))),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: couleur,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Le bouton dit ce qu'il fait, pas « Confirmer ».
          child: Text(definitif ? 'Refuser définitivement' : 'Envoyer'),
        ),
      ],
    );
  }

  List<Widget> _corpsRenegociation() => [
        _recap([
          ('Prix proposé', decision.prixLisible),
          if ((decision.quantiteCibleT ?? '').isNotEmpty)
            ('Quantité', '${decision.quantiteCibleT} T'),
          ('Tour de négociation', '${nbRenegociations + 1}ᵉ'),
        ]),
        const SizedBox(height: 12),
        const Text(
          'Le collecteur sera notifié et pourra répondre. '
          'L\'échantillon reste en négociation.',
          style: TextStyle(fontSize: 12.5, color: _gris, height: 1.5),
        ),
      ];

  List<Widget> _corpsDefinitif() => [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: _rougeClair,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _rouge.withValues(alpha: 0.22)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, size: 15, color: _rouge),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Cette action est irréversible. L\'échantillon sortira du '
                  'parcours d\'achat et ne pourra plus être renégocié.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _rouge,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _recap([('Raison', decision.raison)]),
      ];

  Widget _recap(List<(String, String)> lignes) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F6EF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            for (final (etiquette, valeur) in lignes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      etiquette,
                      style: const TextStyle(fontSize: 12.5, color: _gris),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        valeur,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: kDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}
