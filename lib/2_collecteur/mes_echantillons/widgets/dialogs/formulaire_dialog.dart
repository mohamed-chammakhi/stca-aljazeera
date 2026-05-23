// ─────────────────────────────────────────────────────────────────────────────
// FILE : 2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/echantillon_collecteur.dart';
import '../../services/bottle_label_ocr_service.dart';
import '../../../../core/models/enums.dart';
import '../../../../2_collecteur/carte_geo/services/geo_service.dart';
import 'bouteille_row.dart';
import 'date_livraison_section.dart';
import 'formulaire_sections.dart';
import 'formulaire_decorations.dart';

// Save callback. Carries the optional bottle photo so the page can persist
// it with the new sample (offline OCR already ran on it in the dialog).
typedef SaveSamplesCb =
    void Function(
      List<EchantillonCollecteur> samples, {
      List<int>? photoBytes,
      String? photoName,
    });

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────
void showFormulaireDialog(
  BuildContext context, {
  EchantillonCollecteur? echantillon,
  required int prochainNumero,
  required SaveSamplesCb onSaveMultiple,
}) {
  showDialog(
    context: context,
    builder: (_) => _FormulaireDialog(
      echantillon: echantillon,
      prochainNumero: prochainNumero,
      onSaveMultiple: onSaveMultiple,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STATEFUL DIALOG WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _FormulaireDialog extends StatefulWidget {
  final EchantillonCollecteur? echantillon;
  final int prochainNumero;
  final SaveSamplesCb onSaveMultiple;

  const _FormulaireDialog({
    required this.echantillon,
    required this.prochainNumero,
    required this.onSaveMultiple,
  });

  @override
  State<_FormulaireDialog> createState() => _FormulaireDialogState();
}

class _FormulaireDialogState extends State<_FormulaireDialog> {
  final GeoService _geo = GeoService.instance;
  bool _geoLoaded = false;

  // ── Shared controllers ───────────────────────────────────────────────────
  late final TextEditingController _codeFournisseurCtrl;
  late final TextEditingController _collecteurCtrl;
  late final TextEditingController _remarquesCtrl;

  // ── Date de livraison ────────────────────────────────────────────────────
  ModePlanificationUI _livMode = ModePlanificationUI.dateExacte;
  DateTime? _livExacte;
  DateTime? _livDebut;
  DateTime? _livFin;

  // ── Location ─────────────────────────────────────────────────────────────
  String? _gouvernorat;
  String? _delegation;

  // ── Per-bouteille rows ────────────────────────────────────────────────────
  final List<BouteilleRow> _bouteilles = [];

  // ── Bottle photo + offline OCR ────────────────────────────────────────────
  final BottleLabelOcrService _ocrService = BottleLabelOcrService();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _photoBytes;
  String? _photoName;
  bool _ocrLoading = false;
  String? _ocrError;
  Map<String, dynamic> _ocrConfidence = {};
  // Supplier name as read by OCR — sent to the backend as `fournisseur_nom`
  // separately from `code_fournisseur` so the server never mistakes a
  // handwritten name for a supplier code.
  String? _fournisseurNomFromOcr;

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 2000,
        imageQuality: 90,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _photoName = file.name;
        _ocrLoading = true;
        _ocrError = null;
      });
      try {
        final res = await _ocrService.readLabel(file.path);
        if (mounted) _applyOcr(res);
      } catch (_) {
        if (mounted) {
          setState(
            () => _ocrError =
                'Lecture automatique indisponible — saisie manuelle.',
          );
        }
      } finally {
        if (mounted) setState(() => _ocrLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _ocrLoading = false);
    }
  }

  // Only pre-fill EMPTY fields — OCR never overwrites what the collector typed.
  void _applyOcr(Map<String, dynamic> res) {
    final fournisseur = res['fournisseur_nom'] as String?;
    final reference = res['reference'] as String?;
    final variete = res['variete'] as String?;
    final scellage = res['scellage'] as String?;
    final quantite = res['quantite'] as String?;
    if (fournisseur != null && fournisseur.isNotEmpty) {
      // Stash the OCR-read name so the save call can send it explicitly as
      // `fournisseur_nom` (never as the code). The visible field is still
      // pre-filled so the collector sees the prefill.
      _fournisseurNomFromOcr = fournisseur;
      if (_codeFournisseurCtrl.text.trim().isEmpty) {
        _codeFournisseurCtrl.text = fournisseur;
      }
    }
    if (_bouteilles.isNotEmpty) {
      final b = _bouteilles.first;
      if (reference != null &&
          reference.isNotEmpty &&
          b.refCtrl.text.trim().isEmpty) {
        b.refCtrl.text = reference;
      }
      if (variete != null &&
          variete.isNotEmpty &&
          b.varieteCtrl.text.trim().isEmpty) {
        b.varieteCtrl.text = variete;
      }
      if (scellage != null &&
          scellage.isNotEmpty &&
          b.scellageCtrl.text.trim().isEmpty) {
        b.scellageCtrl.text = scellage;
      }
      if (quantite != null &&
          quantite.isNotEmpty &&
          b.qteCtrl.text.trim().isEmpty) {
        b.qteCtrl.text = quantite;
      }
    }
    setState(() {
      _ocrConfidence =
          (res['_confidence'] as Map?)?.cast<String, dynamic>() ?? {};
    });
  }

  void _removePhoto() => setState(() {
    _photoBytes = null;
    _photoName = null;
    _ocrError = null;
    _ocrConfidence = {};
  });

  void _choosePhotoSource() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: kGreen),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: kGreen),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoZone() {
    // ── Loading: OCR reading in progress ────────────────────────────────
    if (_ocrLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: kGreen.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kGreen.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(kGreen),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Lecture en cours…',
              style: TextStyle(
                fontSize: 13,
                color: kGreen.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // ── Empty: no photo yet ─────────────────────────────────────────────
    if (_photoBytes == null) {
      return InkWell(
        onTap: _choosePhotoSource,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            color: kGreen.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kGreen.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: kGreen.withValues(alpha: 0.55),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Ajouter une photo',
                style: TextStyle(
                  fontSize: 12,
                  color: kGreen.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Filled: photo chosen, OCR applied ───────────────────────────────
    final lowConf = _ocrConfidence.values.whereType<num>().any(
      (v) => v > 0 && v < 0.5,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            _photoBytes!,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                _photoName ?? 'photo.jpg',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
            TextButton.icon(
              onPressed: _choosePhotoSource,
              icon: const Icon(Icons.refresh, size: 16, color: kGreen),
              label: const Text(
                'Relancer',
                style: TextStyle(fontSize: 12, color: kGreen),
              ),
            ),
            TextButton.icon(
              onPressed: _removePhoto,
              icon: Icon(
                Icons.delete_outline,
                size: 16,
                color: Colors.red.shade400,
              ),
              label: Text(
                'Retirer',
                style: TextStyle(fontSize: 12, color: Colors.red.shade400),
              ),
            ),
          ],
        ),
        if (_ocrError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _ocrError!,
              style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
            ),
          )
        else
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: (lowConf ? Colors.orange : kGreen).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  lowConf
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  size: 14,
                  color: lowConf ? Colors.orange.shade800 : kGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lowConf
                        ? 'Champs pré-remplis — lecture incertaine, vérifiez bien.'
                        : 'Champs pré-remplis automatiquement — vérifiez puis confirmez.',
                    style: TextStyle(
                      fontSize: 11,
                      color: lowConf ? Colors.orange.shade900 : kGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool get _isModification => widget.echantillon != null;
  int get _bottleCount => _bouteilles.length;

  @override
  void initState() {
    super.initState();
    final e = widget.echantillon;

    _codeFournisseurCtrl = TextEditingController(
      text: e?.codeFournisseur ?? '',
    );
    _collecteurCtrl = TextEditingController(text: e?.collecteurNom ?? '');
    _remarquesCtrl = TextEditingController(text: e?.remarques ?? '');

    _gouvernorat = (e?.gouvernorat != null && e!.gouvernorat.isNotEmpty)
        ? e.gouvernorat
        : null;
    _delegation = e?.delegation;

    // Pre-fill date de livraison — dateArriveeEchantillon is already DateTime?
    _livExacte = e?.dateArriveeEchantillon;

    _bouteilles.add(
      e != null
          ? BouteilleRow.fromSample(
              referenceBouteille: e.referenceBouteille,
              variete: e.variete ?? '',
              scellage: e.scellage ?? '',
              qte: e.quantiteEstimee ?? '',
            )
          : BouteilleRow.empty(),
    );

    _geo.load().then((_) {
      if (mounted) setState(() => _geoLoaded = true);
    });
  }

  @override
  void dispose() {
    _codeFournisseurCtrl.dispose();
    _collecteurCtrl.dispose();
    _remarquesCtrl.dispose();
    for (final b in _bouteilles) {
      b.dispose();
    }
    super.dispose();
  }

  DateTime? get _livDate =>
      _livMode == ModePlanificationUI.dateExacte ? _livExacte : _livDebut;

  void _addRow() => setState(() => _bouteilles.add(BouteilleRow.empty()));
  void _removeRow(int i) {
    setState(() {
      _bouteilles[i].dispose();
      _bouteilles.removeAt(i);
    });
  }

  bool get _isValid =>
      _bouteilles.isNotEmpty &&
      _bouteilles.every((b) => b.refCtrl.text.trim().isNotEmpty);

  void _save() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'La référence est obligatoire pour chaque bouteille',
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    Navigator.pop(context);

    final gouvernorat = _gouvernorat ?? '';
    final collecteur = _collecteurCtrl.text.trim().isEmpty
        ? null
        : _collecteurCtrl.text.trim();
    final codeFournisseur = _codeFournisseurCtrl.text.trim().isEmpty
        ? null
        : _codeFournisseurCtrl.text.trim();

    if (_isModification) {
      final e = widget.echantillon!;
      final b = _bouteilles.first;
      e.referenceBouteille = b.refCtrl.text.trim();
      e.variete = b.varieteCtrl.text.trim().isEmpty
          ? null
          : b.varieteCtrl.text.trim();
      e.scellage = b.scellageCtrl.text.trim().isEmpty
          ? null
          : b.scellageCtrl.text.trim();
      e.quantiteEstimee = b.qteCtrl.text.trim().isEmpty
          ? null
          : b.qteCtrl.text.trim();
      e.gouvernorat = gouvernorat;
      e.delegation = _delegation;
      e.remarques = _remarquesCtrl.text.trim().isEmpty
          ? null
          : _remarquesCtrl.text.trim();
      e.dateArriveeEchantillon = _livDate;
      widget.onSaveMultiple([e]); // modification: photo unchanged here
    } else {
      final now = DateTime.now();
      final samples = _bouteilles.asMap().entries.map((entry) {
        final idx = entry.key;
        final b = entry.value;
        final numero = widget.prochainNumero + idx;
        return EchantillonCollecteur(
          id: 'new-${now.millisecondsSinceEpoch}-$idx',
          numero:
              '${now.year}/${(widget.prochainNumero + idx).toString().padLeft(4, '0')}',
          codeFournisseur: codeFournisseur ?? '',
          fournisseurNom: _fournisseurNomFromOcr,
          collecteurId: 'collecteur-placeholder',
          collecteurNom: collecteur ?? '',
          referenceBouteille: b.refCtrl.text.trim(),
          variete: b.varieteCtrl.text.trim().isEmpty
              ? null
              : b.varieteCtrl.text.trim(),
          scellage: b.scellageCtrl.text.trim().isEmpty
              ? null
              : b.scellageCtrl.text.trim(),
          gouvernorat: gouvernorat,
          delegation: _delegation,
          remarques: _remarquesCtrl.text.trim().isEmpty
              ? null
              : _remarquesCtrl.text.trim(),
          quantiteEstimee: b.qteCtrl.text.trim().isEmpty
              ? null
              : b.qteCtrl.text.trim(),
          dateAjout: DateTime.now(),
          dateArriveeEchantillon: _livDate,
          achatConfirme: false,
          statut: StatutCollecteur.receptionne,
        );
      }).toList();
      widget.onSaveMultiple(
        samples,
        photoBytes: _photoBytes,
        photoName: _photoName,
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFFE9F4EE),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    _isModification
                        ? Icons.edit_outlined
                        : Icons.add_circle_outline,
                    color: kDarkText,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isModification
                          ? "Modifier l'échantillon"
                          : 'Nouvel échantillon',
                      style: GoogleFonts.domine(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: kDarkText,
                      ),
                    ),
                  ),
                  if (!_isModification)
                    _IdBadge(
                      prochainNumero: widget.prochainNumero,
                      bottleCount: _bottleCount,
                    ),
                ],
              ),
            ),

            // ── Scrollable body ───────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fournisseur & collecteur
                    _FormField(
                      label: 'Nom / Code fournisseur',
                      controller: _codeFournisseurCtrl,
                      hint: 'Ex: Domaine Bel-Air',
                    ),

                    const SizedBox(height: 12),

                    // Localisation
                    _DropdownField(
                      label: 'Gouvernorat',
                      value: _gouvernorat,
                      items: _geoLoaded
                          ? _geo.gouvernorats.toSet().toList()
                          : [],
                      hint: _geoLoaded
                          ? 'Sélectionner un gouvernorat'
                          : 'Chargement…',
                      onChanged: (v) => setState(() {
                        _gouvernorat = v;
                        _delegation = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    _DropdownField(
                      label: 'Délégation',
                      value: _delegation,
                      items: (_geoLoaded && _gouvernorat != null)
                          ? _geo.delegationsFor(_gouvernorat!).toSet().toList()
                          : [],
                      hint: _gouvernorat == null
                          ? "Choisir un gouvernorat d'abord"
                          : 'Sélectionner une délégation',
                      onChanged: _gouvernorat == null
                          ? null
                          : (v) => setState(() => _delegation = v),
                    ),
                    const SizedBox(height: 12),

                    // Bouteilles
                    _BouteillesSection(
                      bouteilles: _bouteilles,
                      isModification: _isModification,
                      onAddRow: _addRow,
                      onRemoveRow: _removeRow,
                    ),
                    const SizedBox(height: 12),

                    // ── Date de livraison (always visible) ────────────────
                    DateLivraisonSection(
                      mode: _livMode,
                      onModeChanged: (m) => setState(() => _livMode = m),
                      dateExacte: _livExacte,
                      periodeDebut: _livDebut,
                      periodeFin: _livFin,
                      onDateExacteChanged: (dt) =>
                          setState(() => _livExacte = dt),
                      onPeriodeDebutChanged: (dt) =>
                          setState(() => _livDebut = dt),
                      onPeriodeFinChanged: (dt) => setState(() => _livFin = dt),
                    ),
                    const SizedBox(height: 12),

                    // Statut (read-only)
                    _ReadOnlyField(
                      label: 'Statut',
                      icon: Icons.flag_outlined,
                      value: _isModification
                          ? widget.echantillon!.statut.label
                          : 'Réceptionné',
                    ),
                    const SizedBox(height: 16),

                    // Photo de la bouteille + lecture automatique (OCR hors-ligne)
                    Row(
                      children: [
                        _FieldLabel(label: 'Photo de la bouteille'),
                        const SizedBox(width: 6),
                        Text(
                          'lecture automatique',
                          style: TextStyle(
                            fontSize: 11,
                            color: kGreen.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildPhotoZone(),
                    const SizedBox(height: 12),

                    // Remarques
                    Row(
                      children: [
                        const Text(
                          'Remarques',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kOlive,
                          ),
                        ),
                        Text(
                          ' (optionnel)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _remarquesCtrl,
                      maxLines: 3,
                      minLines: 2,
                      style: const TextStyle(fontSize: 14, color: kDarkText),
                      decoration: InputDecoration(
                        hintText: 'Notes, observations particulières...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: kFieldFill,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: kGreen,
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Action buttons ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6EF),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
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
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: Icon(
                        _isModification ? Icons.check : Icons.add,
                        size: 16,
                      ),
                      label: Text(
                        _isModification
                            ? 'Enregistrer'
                            : _bottleCount > 1
                            ? 'Ajouter $_bottleCount échantillons'
                            : 'Ajouter',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          197,
                          206,
                          201,
                        ),
                        foregroundColor: kDarkText,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// ID BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _IdBadge extends StatelessWidget {
  final int prochainNumero;
  final int bottleCount;

  const _IdBadge({required this.prochainNumero, required this.bottleCount});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final from = prochainNumero.toString().padLeft(4, '0');
    final to = (prochainNumero + bottleCount - 1).toString().padLeft(4, '0');
    final label = bottleCount > 1 ? '$year/$from → $to' : '$year/$from';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 46, 31).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: kDarkText,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOUTEILLES SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _BouteillesSection extends StatelessWidget {
  final List<BouteilleRow> bouteilles;
  final bool isModification;
  final VoidCallback onAddRow;
  final ValueChanged<int> onRemoveRow;

  const _BouteillesSection({
    required this.bouteilles,
    required this.isModification,
    required this.onAddRow,
    required this.onRemoveRow,
  });

  @override
  Widget build(BuildContext context) {
    final count = bouteilles.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Bouteilles *',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kOlive,
              ),
            ),
            const Spacer(),
            if (!isModification)
              GestureDetector(
                onTap: onAddRow,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: kGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kGreen.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 14, color: kGreen),
                      SizedBox(width: 4),
                      Text(
                        'Ajouter une bouteille',
                        style: TextStyle(
                          fontSize: 12,
                          color: kGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (!isModification && count > 1) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kGreen.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kGreen.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: kGreen.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$count bouteilles → $count échantillons séparés seront créés',
                    style: TextStyle(
                      fontSize: 11,
                      color: kGreen.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        ...List.generate(
          count,
          (i) => _BouteilleCard(
            row: bouteilles[i],
            index: i,
            showRemove: !isModification && count > 1,
            onRemove: () => onRemoveRow(i),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOUTEILLE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _BouteilleCard extends StatelessWidget {
  final BouteilleRow row;
  final int index;
  final bool showRemove;
  final VoidCallback onRemove;

  const _BouteilleCard({
    required this.row,
    required this.index,
    required this.showRemove,
    required this.onRemove,
  });

  InputDecoration _fieldDec(String hint, {String? suffixText}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        suffixText: suffixText,
        suffixStyle: const TextStyle(
          color: kOlive,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kGreen, width: 1.8),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Bouteille ${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: kGreen,
                  ),
                ),
              ),
              const Spacer(),
              if (showRemove)
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 15,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          _InlineLabel(label: 'Référence bouteille', required: true),
          const SizedBox(height: 5),
          TextField(
            controller: row.refCtrl,
            style: const TextStyle(fontSize: 13, color: kDarkText),
            decoration: _fieldDec('Ex: CHEMLALI-C1'),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InlineLabel(label: "Variété d'olive"),
                    const SizedBox(height: 5),
                    TextField(
                      controller: row.varieteCtrl,
                      style: const TextStyle(fontSize: 13, color: kDarkText),
                      decoration: _fieldDec('Ex: Chemlali'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InlineLabel(label: 'Scellage'),
                    const SizedBox(height: 5),
                    TextField(
                      controller: row.scellageCtrl,
                      style: const TextStyle(fontSize: 13, color: kDarkText),
                      decoration: _fieldDec('Ex: Z1'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _InlineLabel(label: 'Quantité estimée'),
          const SizedBox(height: 5),
          TextField(
            controller: row.qteCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 13, color: kDarkText),
            decoration: _fieldDec('Ex: 5000', suffixText: 'T'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INLINE LABEL
// ─────────────────────────────────────────────────────────────────────────────
class _InlineLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _InlineLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
      if (required)
        const Text(' *', style: TextStyle(fontSize: 11, color: Colors.red)),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FIELD LABEL
// ─────────────────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: kOlive,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FORM FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  InputDecoration _dec() => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
    filled: true,
    fillColor: kFieldFill,
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kGreen, width: 1.8),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kOlive,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14, color: kDarkText),
          decoration: _dec(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DROPDOWN FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String hint;
  final ValueChanged<String?>? onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = items.isEmpty && onChanged != null;
    final isDisabled = onChanged == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kOlive,
          ),
        ),
        const SizedBox(height: 6),
        if (isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            decoration: BoxDecoration(
              color: kFieldFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      kGreen.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  hint,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
              ],
            ),
          )
        else
          Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: IgnorePointer(
              ignoring: isDisabled,
              child: DropdownButtonFormField<String>(
                initialValue: (value != null && items.contains(value))
                    ? value
                    : null,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kFieldFill,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kGreen, width: 1.8),
                  ),
                ),
                hint: Text(
                  hint,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
                items: items
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// READ-ONLY FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _ReadOnlyField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;

  const _ReadOnlyField({
    required this.label,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: kOlive,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: kFieldFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: kGreen, size: 20),
            const SizedBox(width: 12),
            Text(value, style: const TextStyle(fontSize: 14, color: kDarkText)),
            const Spacer(),
            Icon(Icons.lock_outline, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    ],
  );
}
