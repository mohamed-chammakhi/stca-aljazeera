// ═════════════════════════════════════════════════════════════════════════════
// FILE : 6_responsable_financier/profil_rf_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/rf_drawer.dart';
import 'achats_confirmes/achats_confirmes_rf_page.dart';
import 'factures/factures_page.dart';
import '../main.dart';

class ProfilRfPage extends StatefulWidget {
  const ProfilRfPage({super.key});

  @override
  State<ProfilRfPage> createState() => _ProfilRfPageState();
}

class _ProfilRfPageState extends State<ProfilRfPage> {
  static const Color green      = Color(0xFF38835A);
  static const Color oliveGreen = Color(0xFF6B8143);
  static const Color headerBg   = Color.fromARGB(255, 220, 233, 226);
  static const Color darkText   = Color(0xFF1A2E1F);

  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _numeroController;

  bool _editingNom    = false;
  bool _editingPrenom = false;
  bool _editingEmail  = false;
  bool _editingNumero = false;

  String _displayedFullName = '';

  final FocusNode _nomFocus    = FocusNode();
  final FocusNode _prenomFocus = FocusNode();
  final FocusNode _emailFocus  = FocusNode();
  final FocusNode _numeroFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nomController    = TextEditingController(text: '');
    _prenomController = TextEditingController(text: '');
    _emailController  = TextEditingController(text: '');
    _numeroController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _numeroController.dispose();
    _nomFocus.dispose();
    _prenomFocus.dispose();
    _emailFocus.dispose();
    _numeroFocus.dispose();
    super.dispose();
  }

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _goToLogin() {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  void _toggleEdit(String fieldKey) {
    setState(() {
      switch (fieldKey) {
        case 'prenom':
          _editingPrenom = !_editingPrenom;
          if (_editingPrenom) {
            Future.delayed(const Duration(milliseconds: 50), () => _prenomFocus.requestFocus());
          } else {
            _displayedFullName = '${_prenomController.text} ${_nomController.text}'.trim();
            _showSuccess('Prénom mis à jour');
          }
          break;
        case 'nom':
          _editingNom = !_editingNom;
          if (_editingNom) {
            Future.delayed(const Duration(milliseconds: 50), () => _nomFocus.requestFocus());
          } else {
            _displayedFullName = '${_prenomController.text} ${_nomController.text}'.trim();
            _showSuccess('Nom mis à jour');
          }
          break;
        case 'email':
          _editingEmail = !_editingEmail;
          if (_editingEmail) {
            Future.delayed(const Duration(milliseconds: 50), () => _emailFocus.requestFocus());
          } else {
            _showSuccess('Email mis à jour');
          }
          break;
        case 'numero':
          _editingNumero = !_editingNumero;
          if (_editingNumero) {
            Future.delayed(const Duration(milliseconds: 50), () => _numeroFocus.requestFocus());
          } else {
            _showSuccess('Numéro mis à jour');
          }
          break;
      }
    });
  }

  void _onChangeProfilePicture() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Text(
              'Changer la photo de profil',
              style: GoogleFonts.domine(fontSize: 18, fontWeight: FontWeight.w700, color: darkText),
            ),
            const SizedBox(height: 20),
            _bottomSheetItem(icon: Icons.photo_library_outlined, label: 'Choisir depuis la galerie',
                onTap: () { Navigator.pop(context); _showSuccess('Galerie'); }),
            const SizedBox(height: 4),
            _bottomSheetItem(icon: Icons.camera_alt_outlined, label: 'Prendre une photo',
                onTap: () { Navigator.pop(context); _showSuccess('Caméra'); }),
            const SizedBox(height: 4),
            _bottomSheetItem(icon: Icons.delete_outline, label: 'Supprimer la photo',
                color: Colors.red.shade400,
                onTap: () { Navigator.pop(context); _showSuccess('Photo supprimée'); }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: RfDrawer(
        onAchatsConfirmes: () => _goTo(const AchatsConfirmesRfPage()),
        onFactures: () => _goTo(const FacturesPage()),
        onProfil: () => Navigator.pop(context),
        onDeconnexion: _goToLogin,
      ),
      appBar: AppBar(
        backgroundColor: headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Votre Profil',
          style: GoogleFonts.domine(fontSize: 18, fontWeight: FontWeight.w700, color: darkText),
        ),
        iconTheme: const IconThemeData(color: darkText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: green.withValues(alpha: 0.2),
                    border: Border.all(color: green, width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: const Icon(Icons.person, size: 60, color: green),
                  ),
                ),
                Positioned(
                  bottom: 2, right: 2,
                  child: GestureDetector(
                    onTap: _onChangeProfilePicture,
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: green, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(color: green.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_displayedFullName.isNotEmpty)
              Text(
                _displayedFullName,
                style: GoogleFonts.domine(fontSize: 24, fontWeight: FontWeight.w700, color: darkText),
              ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: green.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Informations Personnelles'),
                  const SizedBox(height: 20),
                  _buildField(label: 'Prénom', controller: _prenomController, focusNode: _prenomFocus,
                      icon: Icons.person_outline, isEditing: _editingPrenom, fieldKey: 'prenom',
                      hint: 'Votre prénom', keyboardType: TextInputType.name),
                  const SizedBox(height: 16),
                  _buildField(label: 'Nom', controller: _nomController, focusNode: _nomFocus,
                      icon: Icons.person_outline, isEditing: _editingNom, fieldKey: 'nom',
                      hint: 'Votre nom', keyboardType: TextInputType.name),
                  const SizedBox(height: 16),
                  _buildField(label: 'Email', controller: _emailController, focusNode: _emailFocus,
                      icon: Icons.email_outlined, isEditing: _editingEmail, fieldKey: 'email',
                      hint: 'Votre email', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildField(label: 'Numéro de téléphone', controller: _numeroController, focusNode: _numeroFocus,
                      icon: Icons.phone_outlined, isEditing: _editingNumero, fieldKey: 'numero',
                      hint: 'Votre numéro', keyboardType: TextInputType.phone),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showChangePasswordDialog,
                icon: const Icon(Icons.lock_outline, size: 18),
                label: const Text('Changer le mot de passe'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required bool isEditing,
    required String fieldKey,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: oliveGreen, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          readOnly: !isEditing,
          style: TextStyle(color: darkText, fontSize: 15,
              fontWeight: isEditing ? FontWeight.w500 : FontWeight.w400),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: green, size: 20),
            suffixIcon: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isEditing ? green : green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(isEditing ? Icons.check : Icons.edit,
                    color: isEditing ? Colors.white : green, size: 15),
              ),
              onPressed: () => _toggleEdit(fieldKey),
            ),
            filled: true,
            fillColor: isEditing ? Colors.white : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: isEditing
                    ? BorderSide(color: green.withValues(alpha: 0.5), width: 1.5)
                    : BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: green, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style: GoogleFonts.domine(fontSize: 18, fontWeight: FontWeight.w700, color: darkText));

  Widget _bottomSheetItem({required IconData icon, required String label,
      required VoidCallback onTap, Color? color}) {
    final c = color ?? green;
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: c)),
      title: Text(label, style: TextStyle(color: c)),
      onTap: onTap,
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(20),
    ));
  }

  void _showChangePasswordDialog() {
    final currentCtrl  = TextEditingController();
    final newCtrl      = TextEditingController();
    final confirmCtrl  = TextEditingController();
    bool hideCurrent   = true;
    bool hideNew       = true;
    bool hideConfirm   = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDS) => AlertDialog(
          title: Text('Changer le mot de passe',
              style: GoogleFonts.domine(fontSize: 18, fontWeight: FontWeight.w700, color: darkText)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            _pwField(ctrl: currentCtrl, label: 'Mot de passe actuel',
                hide: hideCurrent, onToggle: () => setDS(() => hideCurrent = !hideCurrent)),
            const SizedBox(height: 16),
            _pwField(ctrl: newCtrl, label: 'Nouveau mot de passe',
                hide: hideNew, onToggle: () => setDS(() => hideNew = !hideNew)),
            const SizedBox(height: 16),
            _pwField(ctrl: confirmCtrl, label: 'Confirmer le mot de passe',
                hide: hideConfirm, onToggle: () => setDS(() => hideConfirm = !hideConfirm)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                if (newCtrl.text.isEmpty || confirmCtrl.text.isEmpty) return;
                if (newCtrl.text == confirmCtrl.text) {
                  Navigator.pop(context);
                  _showSuccess('Mot de passe changé');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Les mots de passe ne correspondent pas'), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: green),
              child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pwField({required TextEditingController ctrl, required String label,
      required bool hide, required VoidCallback onToggle}) {
    return TextField(
      controller: ctrl,
      obscureText: hide,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: oliveGreen),
        suffixIcon: IconButton(
          icon: Icon(hide ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: oliveGreen, size: 20),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: green, width: 2)),
      ),
    );
  }
}
