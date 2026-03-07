import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/echantillon_gestion.dart';
import '../date_input_field.dart'; // ← new widget

const Color _green = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText = Color(0xFF1A2E1F);

void showFormulaireDialog(
  BuildContext context, {
  EchantillonGestion? echantillon,
  required int prochainNumero,
  required Function(EchantillonGestion) onSave,
}) {
  final isModification = echantillon != null;

  // ── Controllers ───────────────────────────────────────────────────────────
  final refCtrl = TextEditingController(
    text: isModification ? echantillon.ref : '',
  );
  final fournisseurCtrl = TextEditingController(
    text: isModification ? echantillon.fournisseur : '',
  );
  final varieteCtrl = TextEditingController(
    text: isModification ? echantillon.variete : '',
  );
  final origineCtrl = TextEditingController(
    text: isModification ? echantillon.origine : '',
  );
  final quantiteCtrl = TextEditingController(
    text: isModification ? echantillon.quantite : '',
  );

  // ── Date — default = today, user can change it ────────────────────────────
  final now = DateTime.now();
  final String dateDefaut =
      '${now.day.toString().padLeft(2, '0')}/'
      '${now.month.toString().padLeft(2, '0')}/'
      '${now.year}';

  final dateCtrl = TextEditingController(
    text: isModification ? echantillon.dateArrivee : dateDefaut,
  );

  // ── Statut — always read-only ─────────────────────────────────────────────
  final String statutActuel = isModification
      ? echantillon.statut
      : 'En attente';

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isModification ? Icons.edit_outlined : Icons.add_circle_outline,
                color: _green,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                isModification
                    ? "Modifier l'échantillon"
                    : 'Nouvel échantillon',
                style: GoogleFonts.domine(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _darkText,
                ),
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── ID AUTO-GÉNÉRÉ — ajout seulement ─────────────────────
                if (!isModification)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _green.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'ID : ${DateTime.now().year}/$prochainNumero',
                          style: GoogleFonts.domine(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _green,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Auto-généré',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── RÉFÉRENCE ─────────────────────────────────────────────
                _dialogField(
                  label: 'Référence',
                  controller: refCtrl,
                  icon: Icons.tag,
                  hint: 'Référence',
                ),
                const SizedBox(height: 12),

                // ── FOURNISSEUR ───────────────────────────────────────────
                _dialogField(
                  label: 'Fournisseur',
                  controller: fournisseurCtrl,
                  icon: Icons.store_outlined,
                  hint: 'Nom du fournisseur',
                ),
                const SizedBox(height: 12),

                // ── VARIÉTÉ ───────────────────────────────────────────────
                _dialogField(
                  label: "Variété d'olive",
                  controller: varieteCtrl,
                  icon: Icons.eco_outlined,
                  hint: 'Ex: Chemlali, Chetoui...',
                ),
                const SizedBox(height: 12),

                // ── ORIGINE — dropdown 24 gouvernorats ───────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Origine (Région)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _oliveGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: origineCtrl.text.isEmpty ? null : origineCtrl.text,
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: _green,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7FAF8),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
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
                          borderSide: const BorderSide(
                            color: _green,
                            width: 1.8,
                          ),
                        ),
                      ),
                      items:
                          const [
                                'Unknown',
                                'Ariana',
                                'Béja',
                                'Ben Arous',
                                'Bizerte',
                                'Gabès',
                                'Gafsa',
                                'Jendouba',
                                'Kairouan',
                                'Kasserine',
                                'Kébili',
                                'Kef',
                                'Mahdia',
                                'Manouba',
                                'Médenine',
                                'Monastir',
                                'Nabeul',
                                'Sfax',
                                'Sidi Bouzid',
                                'Siliana',
                                'Sousse',
                                'Tataouine',
                                'Tozeur',
                                'Tunis',
                                'Zaghouan',
                              ]
                              .map(
                                (r) =>
                                    DropdownMenuItem(value: r, child: Text(r)),
                              )
                              .toList(),
                      onChanged: (value) =>
                          setDialogState(() => origineCtrl.text = value ?? ''),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── QUANTITÉ — number only, kg added automatically ─────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quantité disponible',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _oliveGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: quantiteCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 14, color: _darkText),
                      decoration: InputDecoration(
                        hintText: 'Ex: 5000',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.scale_outlined,
                          color: _green,
                          size: 20,
                        ),
                        suffixText: 'kg',
                        suffixStyle: const TextStyle(
                          color: _green,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7FAF8),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
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
                          borderSide: const BorderSide(
                            color: _green,
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── DATE D'ARRIVÉE — handled entirely by DateInputField ────
                DateInputField(controller: dateCtrl),
                const SizedBox(height: 12),

                // ── STATUT — lecture seule dans les DEUX modes ────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statut',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _oliveGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flag_outlined,
                            color: _green,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            statutActuel,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _darkText,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── PHOTO ─────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: _green.withOpacity(0.6),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ajouter une photo (optionnel)',
                        style: TextStyle(
                          fontSize: 12,
                          color: _green.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── ACTIONS ──────────────────────────────────────────────────────
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (refCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Champ manquant'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);

                if (isModification) {
                  echantillon.ref = refCtrl.text;
                  echantillon.fournisseur = fournisseurCtrl.text;
                  echantillon.variete = varieteCtrl.text;
                  echantillon.origine = origineCtrl.text;
                  echantillon.quantite = quantiteCtrl.text;
                  echantillon.dateArrivee = dateCtrl.text;
                  echantillon.statut = statutActuel;
                  onSave(echantillon);
                } else {
                  onSave(
                    EchantillonGestion(
                      id: '${DateTime.now().year}/$prochainNumero',
                      ref: refCtrl.text,
                      fournisseur: fournisseurCtrl.text,
                      variete: varieteCtrl.text,
                      dateArrivee: dateCtrl.text,
                      origine: origineCtrl.text,
                      quantite: quantiteCtrl.text,
                      statut: 'En attente',
                    ),
                  );
                }
              },
              icon: Icon(isModification ? Icons.check : Icons.add, size: 16),
              label: Text(isModification ? 'Enregistrer' : 'Ajouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER — reusable text field
// ─────────────────────────────────────────────────────────────────────────────
Widget _dialogField({
  required String label,
  required TextEditingController controller,
  required IconData icon,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _oliveGreen,
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: _darkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(icon, color: _green, size: 20),
          filled: true,
          fillColor: const Color(0xFFF7FAF8),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
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
            borderSide: const BorderSide(color: _green, width: 1.8),
          ),
        ),
      ),
    ],
  );
}
