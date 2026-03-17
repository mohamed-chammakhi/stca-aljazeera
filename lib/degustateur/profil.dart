import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage/homepage_page.dart';
//import 'degustateur/homepage/homepage_page.dart';
import '../degustateur/evaluation_echantillons/evaluation_echantillons_page.dart';
//import '../../../profil.dart';
import '../degustateur/homepage/widgets/app_drawer.dart';
import '../degustateur/membres_panel/membres_panel_page.dart';
import '../../../main.dart';
import '../degustateur/gestion_echantillons/gestion_echantillons_page.dart';
import '../degustateur/sessions_degustation/sessions_degustation_page.dart';
import 'analyse_labo/analyse_laboratoire_page.dart';

/*/
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Votre Profil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF38835A),
        scaffoldBackgroundColor: const Color(0xFFF9F6EF),
      ),
      home: const ProfilePage(),
    );
  }
}
*/
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _goTo(Widget page) {
    Navigator.pop(context); // close drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // Closes drawer then replaces the whole stack — no back button to homepage
  void _goToLogin() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color green = Color(0xFF38835A);
  static const Color oliveGreen = Color(0xFF6B8143);
  static const Color cream = Color(0xFFF9F6EF);
  static const Color darkText = Color(0xFF1A2E1F);

  // ── Controllers — empty by default, filled by backend later ──────────────
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _numeroController;
  late TextEditingController _roleController;

  // ── Per-field editing booleans ────────────────────────────────────────────
  bool _editingNom = false;
  bool _editingPrenom = false;
  bool _editingEmail = false;
  bool _editingnumero = false;
  bool _editingRole = false;

  // ── Displayed header values ───────────────────────────────────────────────
  // Empty by default — will be filled when user saves or data loads from API
  String _displayedFullName = '';
  String _displayedRole = '';

  // ── FocusNodes ────────────────────────────────────────────────────────────
  final FocusNode _nomFocus = FocusNode();
  final FocusNode _prenomFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _numeroFocus = FocusNode();

  final FocusNode _roleFocus = FocusNode();

  // ── initState ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // ✅ Empty controllers — no default values
    // Later: populate from Spring Boot API response
    // Example: GET /api/user/profile → _nomController.text = response.nom
    _nomController = TextEditingController(text: '');
    _prenomController = TextEditingController(text: '');
    _emailController = TextEditingController(text: '');
    _numeroController = TextEditingController(text: '');

    _roleController = TextEditingController(text: '');
  }

  // ── dispose ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _numeroController.dispose();
    _roleController.dispose();
    _nomFocus.dispose();
    _prenomFocus.dispose();
    _emailFocus.dispose();
    _numeroFocus.dispose();
    _roleFocus.dispose();
    super.dispose();
  }

  // ── Toggle edit/save ─────────────────────────────────────────────────────
  void _toggleEdit(String fieldKey) {
    setState(() {
      switch (fieldKey) {
        case 'prenom':
          _editingPrenom = !_editingPrenom;
          if (_editingPrenom) {
            Future.delayed(
              const Duration(milliseconds: 50),
              () => _prenomFocus.requestFocus(),
            );
          } else {
            _displayedFullName =
                '${_prenomController.text} ${_nomController.text}'.trim();
            _showSuccess('Prénom mis à jour');
          }
          break;

        case 'nom':
          _editingNom = !_editingNom;
          if (_editingNom) {
            Future.delayed(
              const Duration(milliseconds: 50),
              () => _nomFocus.requestFocus(),
            );
          } else {
            _displayedFullName =
                '${_prenomController.text} ${_nomController.text}'.trim();
            _showSuccess('Nom mis à jour');
          }
          break;

        case 'email':
          _editingEmail = !_editingEmail;
          if (_editingEmail) {
            Future.delayed(
              const Duration(milliseconds: 50),
              () => _emailFocus.requestFocus(),
            );
          } else {
            _showSuccess('Email mis à jour');
          }
          break;
        case 'numero':
          _editingnumero = !_editingnumero;
          if (_editingnumero) {
            Future.delayed(
              const Duration(milliseconds: 50),
              () => _numeroFocus.requestFocus(),
            );
          } else {
            _showSuccess('numero mis à jour');
          }
          break;

        case 'role':
          _editingRole = !_editingRole;
          if (_editingRole) {
            Future.delayed(
              const Duration(milliseconds: 50),
              () => _roleFocus.requestFocus(),
            );
          } else {
            _displayedRole = _roleController.text;
            _showSuccess('Rôle mis à jour');
          }
          break;
      }
    });
  }

  // ── Profile picture bottom sheet ──────────────────────────────────────────
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
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Changer la photo de profil',
              style: GoogleFonts.domine(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            const SizedBox(height: 20),
            _bottomSheetItem(
              icon: Icons.photo_library_outlined,
              label: 'Choisir depuis la galerie',
              onTap: () {
                Navigator.pop(context);
                _showSuccess('Galerie — disponible avec image_picker');
              },
            ),
            const SizedBox(height: 4),
            _bottomSheetItem(
              icon: Icons.camera_alt_outlined,
              label: 'Prendre une photo',
              onTap: () {
                Navigator.pop(context);
                _showSuccess('Caméra — disponible avec image_picker');
              },
            ),
            const SizedBox(height: 4),
            _bottomSheetItem(
              icon: Icons.delete_outline,
              label: 'Supprimer la photo',
              color: Colors.red.shade400,
              onTap: () {
                Navigator.pop(context);
                _showSuccess('Photo supprimée');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      drawer: AppDrawer(
        onaccueil: () => _goTo(const HomePage()),

        // OLD : EvaluationEchantillonsPage from EvaluationEchantillonsPage.dart
        // NEW : will be EvaluationEchantillonsPage from
        //       evaluation_echantillons/evaluation_echantillons_page.dart
        // TODO : replace with _goTo(const EvaluationEchantillonsPage())
        onEvaluationEchantillons: () =>
            _goTo(const EvaluationEchantillonsPage()),

        // OLD : GestionEchantillonsPage from GestionEchantillon.dart
        // NEW : GestionEchantillonsPage from
        //       gestion_echantillons/gestion_echantillons_page.dart ✅ done
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),

        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),

        // OLD : ProfilePage from profil.dart (same level)
        // NEW : ProfilePage from ../profil.dart (one level up) ✅ done
        onMembredupanel: () => _goTo(const MembresPanelPage()),
        onProfil: () => _goTo(const ProfilePage()),

        onAPropos: () => Navigator.pop(context),
        onDeconnexion: _goToLogin,
      ),
      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,

        // ✅ Back arrow — navigates to HomePage in homepage.dart
        title: Text(
          'Votre Profil',
          style: GoogleFonts.domine(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ══════════════════════════════════════════════════════════════
            // AVATAR + pen icon
            // ══════════════════════════════════════════════════════════════
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: green.withOpacity(0.2),
                    border: Border.all(color: green, width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: const Icon(Icons.person, size: 60, color: green),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: _onChangeProfilePicture,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: green.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Full name — shows after user saves prenom + nom ──
            if (_displayedFullName.isNotEmpty)
              Text(
                _displayedFullName,
                style: GoogleFonts.domine(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),

            // ── Role — shows after user saves role ──
            if (_displayedRole.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _displayedRole,
                style: GoogleFonts.alegreya(
                  fontSize: 16,
                  color: oliveGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            const SizedBox(height: 30),

            // ══════════════════════════════════════════════════════════════
            // INFO CARD
            // ══════════════════════════════════════════════════════════════
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: green.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Informations Personnelles'),
                  const SizedBox(height: 20),

                  // ── Prénom ──
                  _buildField(
                    label: 'Prénom',
                    controller: _prenomController,
                    focusNode: _prenomFocus,
                    icon: Icons.person_outline,
                    isEditing: _editingPrenom,
                    fieldKey: 'prenom',
                    hint: 'Votre prénom', // ✅ hint instead of default value
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),

                  // ── Nom ──
                  _buildField(
                    label: 'Nom',
                    controller: _nomController,
                    focusNode: _nomFocus,
                    icon: Icons.person_outline,
                    isEditing: _editingNom,
                    fieldKey: 'nom',
                    hint: 'Votre nom', // ✅ hint instead of default value
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),

                  // ── Email ──
                  _buildField(
                    label: 'Email',
                    controller: _emailController,
                    focusNode: _emailFocus,
                    icon: Icons.email_outlined,
                    isEditing: _editingEmail,
                    fieldKey: 'email',
                    hint: 'Votre email', // ✅ hint instead of default value
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  // ── Email ──
                  _buildField(
                    label: 'Numéro de Téléphone',
                    controller: _numeroController,
                    focusNode: _numeroFocus,
                    icon: Icons.phone_outlined,
                    isEditing: _editingnumero,
                    fieldKey: 'numero',
                    hint:
                        'Votre Numéro de Téléphone', // ✅ hint instead of default value
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 20),

                  _sectionTitle('Informations Professionnelles'),
                  const SizedBox(height: 20),

                  // ── Rôle ──
                  _buildField(
                    label: 'Rôle',
                    controller: _roleController,
                    focusNode: _roleFocus,
                    icon: Icons.badge_outlined,
                    isEditing: _editingRole,
                    fieldKey: 'role',
                    hint: 'Votre rôle', // ✅ hint instead of default value
                  ),
                  const SizedBox(height: 16),

                  // ── Date — always locked, assigned by system ──
                  _buildLockedField(
                    label: "Date de début d'activité",
                    value: '01/01/2024',
                    icon: Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ── Change password ──
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER — _buildField
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required bool isEditing,
    required String fieldKey,
    required String hint, // ✅ hint is now required
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          readOnly: !isEditing,
          style: TextStyle(
            color: darkText,
            fontSize: 15,
            fontWeight: isEditing ? FontWeight.w500 : FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint, // ✅ shows hint when field is empty
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: green, size: 20),
            suffixIcon: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isEditing ? green : green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  isEditing ? Icons.check : Icons.edit,
                  color: isEditing ? Colors.white : green,
                  size: 15,
                ),
              ),
              onPressed: () => _toggleEdit(fieldKey),
            ),
            filled: true,
            fillColor: isEditing ? Colors.white : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: isEditing
                  ? BorderSide(color: green.withOpacity(0.5), width: 1.5)
                  : BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: green, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER — _buildLockedField
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLockedField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          controller: TextEditingController(text: value),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
            suffixIcon: Icon(
              Icons.lock_outline,
              color: Colors.grey.shade400,
              size: 18,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER — _sectionTitle
  // ─────────────────────────────────────────────────────────────────────────
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.domine(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: darkText,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER — _fieldLabel
  // ─────────────────────────────────────────────────────────────────────────
  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: oliveGreen,
        letterSpacing: 0.5,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER — _bottomSheetItem
  // ─────────────────────────────────────────────────────────────────────────
  Widget _bottomSheetItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? green;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: itemColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: itemColor),
      ),
      title: Text(label, style: TextStyle(color: itemColor)),
      onTap: onTap,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER — _showSuccess
  // ─────────────────────────────────────────────────────────────────────────
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER — _showChangePasswordDialog
  // ─────────────────────────────────────────────────────────────────────────
  void _showChangePasswordDialog() {
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Changer le mot de passe',
            style: GoogleFonts.domine(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPwController,
                obscureText: obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Mot de passe actuel',
                  labelStyle: const TextStyle(color: oliveGreen),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureCurrent
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: oliveGreen,
                      size: 20,
                    ),
                    onPressed: () =>
                        setDialogState(() => obscureCurrent = !obscureCurrent),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: green, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPwController,
                obscureText: obscureNew,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  labelStyle: const TextStyle(color: oliveGreen),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: oliveGreen,
                      size: 20,
                    ),
                    onPressed: () =>
                        setDialogState(() => obscureNew = !obscureNew),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: green, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPwController,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  labelStyle: const TextStyle(color: oliveGreen),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: oliveGreen,
                      size: 20,
                    ),
                    onPressed: () =>
                        setDialogState(() => obscureConfirm = !obscureConfirm),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: green, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPwController.text.isEmpty ||
                    confirmPwController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (newPwController.text == confirmPwController.text) {
                  Navigator.pop(context);
                  _showSuccess('Mot de passe changé avec succès');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Les mots de passe ne correspondent pas'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: green),
              child: const Text(
                'Enregistrer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
