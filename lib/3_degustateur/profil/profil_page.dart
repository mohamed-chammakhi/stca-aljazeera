import 'package:flutter/material.dart';
import 'package:project3/core/services/profile_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/degustateur_nav_mixin.dart';
import '../tableau_de_bord/homepage_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../tableau_de_bord/widgets/app_drawer.dart';
import '../membres_panel/membres_panel_page.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with DegustateurNavMixin {
  // â”€â”€ Controllers â€” empty by default, filled by backend later â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _numeroController;

  // â”€â”€ Per-field editing booleans â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bool _editingNom = false;
  bool _editingPrenom = false;
  bool _editingEmail = false;
  bool _editingnumero = false;
  bool _profileLoading = false;
  bool _profileSaving = false;

  // â”€â”€ Displayed header values â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String _displayedFullName = '';

  // â”€â”€ FocusNodes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final FocusNode _nomFocus = FocusNode();
  final FocusNode _prenomFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _numeroFocus = FocusNode();

  // â”€â”€ initState â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  void initState() {
    super.initState();
    // TODO: populate from Django API: GET /api/utilisateurs/me/
    _nomController = TextEditingController(text: '');
    _prenomController = TextEditingController(text: '');
    _emailController = TextEditingController(text: '');
    _numeroController = TextEditingController(text: '');
    _loadProfile();
  }

  // â”€â”€ dispose â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€ Toggle edit/save â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _loadProfile() async {
    setState(() => _profileLoading = true);
    try {
      final profile = await profileService.currentProfile();
      if (!mounted) return;
      setState(() {
        _nomController.text = profile.nom;
        _prenomController.text = profile.prenom;
        _emailController.text = profile.email;
        _numeroController.text = profile.telephone ?? '';
        _displayedFullName = profile.nomComplet;
      });
    } catch (error) {
      if (!mounted) return;
      _showError(profileService.messageFor(error));
    } finally {
      if (mounted) setState(() => _profileLoading = false);
    }
  }

  Future<bool> _saveProfile(String successMessage) async {
    if (_profileSaving) return false;
    setState(() => _profileSaving = true);
    try {
      final profile = await profileService.updateCurrentProfile(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _numeroController.text.trim(),
      );
      if (!mounted) return false;
      setState(() {
        _nomController.text = profile.nom;
        _prenomController.text = profile.prenom;
        _emailController.text = profile.email;
        _numeroController.text = profile.telephone ?? '';
        _displayedFullName = profile.nomComplet;
      });
      _showSuccess(successMessage);
      return true;
    } catch (error) {
      if (!mounted) return false;
      _showError(profileService.messageFor(error));
      return false;
    } finally {
      if (mounted) setState(() => _profileSaving = false);
    }
  }

  void _focusField(String fieldKey) {
    FocusNode? focusNode;
    switch (fieldKey) {
      case 'prenom':
        focusNode = _prenomFocus;
        break;
      case 'nom':
        focusNode = _nomFocus;
        break;
      case 'email':
        focusNode = _emailFocus;
        break;
      case 'numero':
        focusNode = _numeroFocus;
        break;
    }
    if (focusNode != null) {
      Future.delayed(const Duration(milliseconds: 50), focusNode.requestFocus);
    }
  }

  Future<void> _toggleEdit(String fieldKey) async {
    if (_profileLoading || _profileSaving) return;
    var enteringEdit = false;
    var successMessage = '';

    setState(() {
      switch (fieldKey) {
        case 'prenom':
          _editingPrenom = !_editingPrenom;
          if (_editingPrenom) {
            enteringEdit = true;
          } else {
            _displayedFullName =
                '${_prenomController.text} ${_nomController.text}'.trim();
            successMessage = 'Prénom mis à jour';
          }
          break;

        case 'nom':
          _editingNom = !_editingNom;
          if (_editingNom) {
            enteringEdit = true;
          } else {
            _displayedFullName =
                '${_prenomController.text} ${_nomController.text}'.trim();
            successMessage = 'Nom mis à jour';
          }
          break;

        case 'email':
          _editingEmail = !_editingEmail;
          if (_editingEmail) {
            enteringEdit = true;
          } else {
            successMessage = 'Email mis à jour';
          }
          break;

        case 'numero':
          _editingnumero = !_editingnumero;
          if (_editingnumero) {
            enteringEdit = true;
          } else {
            successMessage = 'Numéro mis à jour';
          }
          break;
      }
    });

    if (enteringEdit) {
      _focusField(fieldKey);
      return;
    }

    final saved = await _saveProfile(successMessage);
    if (!saved && mounted) {
      setState(() {
        switch (fieldKey) {
          case 'prenom':
            _editingPrenom = true;
            break;
          case 'nom':
            _editingNom = true;
            break;
          case 'email':
            _editingEmail = true;
            break;
          case 'numero':
            _editingnumero = true;
            break;
        }
      });
      _focusField(fieldKey);
    }
  }

  // â”€â”€ Profile picture bottom sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
                color: kDark,
              ),
            ),
            const SizedBox(height: 20),
            _bottomSheetItem(
              icon: Icons.photo_library_outlined,
              label: 'Choisir depuis la galerie',
              onTap: () {
                Navigator.pop(context);
                _showSuccess('Galerie - disponible avec image_picker');
              },
            ),
            const SizedBox(height: 4),
            _bottomSheetItem(
              icon: Icons.camera_alt_outlined,
              label: 'Prendre une photo',
              onTap: () {
                Navigator.pop(context);
                _showSuccess('Caméra - disponible avec image_picker');
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

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppDrawer(
        onaccueil: () => goToPage(const HomePage()),
        onEvaluationEchantillons: () =>
            goToPage(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => goToPage(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => goToPage(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () =>
            goToPage(const SessionsDegustationPage()),
        onMembredupanel: () => goToPage(const MembresPanelPage()),
        onProfil: () => goToPage(const ProfilePage()),
        onDeconnexion: goToLogin,
      ),
      appBar: AppBar(
        backgroundColor: kHeaderBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Votre Profil',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kDark,
          ),
        ),
        iconTheme: const IconThemeData(color: kDark),
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
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kGreen.withValues(alpha: 0.2),
                    border: Border.all(color: kGreen, width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: const Icon(Icons.person, size: 60, color: kGreen),
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
                        color: kGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: kGreen.withValues(alpha: 0.4),
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

            if (_displayedFullName.isNotEmpty)
              Text(
                _displayedFullName,
                style: GoogleFonts.domine(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: kDark,
                ),
              ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kGreen.withValues(alpha: 0.08),
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

                  _buildField(
                    label: 'Prénom',
                    controller: _prenomController,
                    focusNode: _prenomFocus,
                    icon: Icons.person_outline,
                    isEditing: _editingPrenom,
                    fieldKey: 'prenom',
                    hint: 'Votre prénom',
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    label: 'Nom',
                    controller: _nomController,
                    focusNode: _nomFocus,
                    icon: Icons.person_outline,
                    isEditing: _editingNom,
                    fieldKey: 'nom',
                    hint: 'Votre nom',
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    label: 'Email',
                    controller: _emailController,
                    focusNode: _emailFocus,
                    icon: Icons.email_outlined,
                    isEditing: _editingEmail,
                    fieldKey: 'email',
                    hint: 'Votre email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  _buildField(
                    label: 'Numéro de Téléphone',
                    controller: _numeroController,
                    focusNode: _numeroFocus,
                    icon: Icons.phone_outlined,
                    isEditing: _editingnumero,
                    fieldKey: 'numero',
                    hint: 'Votre Numéro de Téléphone',
                    keyboardType: TextInputType.phone,
                  ),
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
                  foregroundColor: kGreen,
                  side: const BorderSide(color: kGreen, width: 1.5),
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
        _fieldLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          readOnly: !isEditing,
          style: TextStyle(
            color: kDark,
            fontSize: 15,
            fontWeight: isEditing ? FontWeight.w500 : FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: kGreen, size: 20),
            suffixIcon: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isEditing ? kGreen : kGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  isEditing ? Icons.check : Icons.edit,
                  color: isEditing ? Colors.white : kGreen,
                  size: 15,
                ),
              ),
              onPressed: _profileLoading || _profileSaving
                  ? null
                  : () {
                      _toggleEdit(fieldKey);
                    },
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
                  ? BorderSide(color: kGreen.withValues(alpha: 0.5), width: 1.5)
                  : BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kGreen, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.domine(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: kDark,
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kOlive,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _bottomSheetItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? kGreen;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: itemColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: itemColor),
      ),
      title: Text(label, style: TextStyle(color: itemColor)),
      onTap: onTap,
    );
  }

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
        backgroundColor: kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

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
              color: kDark,
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
                  labelStyle: const TextStyle(color: kOlive),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureCurrent
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: kOlive,
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
                    borderSide: const BorderSide(color: kGreen, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPwController,
                obscureText: obscureNew,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  labelStyle: const TextStyle(color: kOlive),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: kOlive,
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
                    borderSide: const BorderSide(color: kGreen, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPwController,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  labelStyle: const TextStyle(color: kOlive),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: kOlive,
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
                    borderSide: const BorderSide(color: kGreen, width: 2),
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
              style: ElevatedButton.styleFrom(backgroundColor: kGreen),
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
