// ═════════════════════════════════════════════════════════════════════════════
// FILE : ceo/utilisateurs/utilisateurs_ceo_page.dart
// PURPOSE : CEO user management page — view all users, their roles,
//           contact info, status, and perform admin actions.
// DATA   : Reads from mockUtilisateurs (mock/mock_data_patch.dart).
//           When API is ready: replace the getter with a service call.
// STYLE  : Matches ProfilceoPage — same palette, fonts, and component style.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../main.dart';
import '../../widgets/ceo_drawer.dart';
import '../../echantillons/echantillons_ceo_page.dart';
import '../../achats_confirmes/achats_confirmes_ceo_page.dart';
import '../../analyse_laboratoire/analyse_laboratoire_ceo_page.dart';
import '../../analyse_organoleptique/analyse_organoleptique_ceo_page.dart';
import '../../profil_ceo_page.dart';
import '../../utilisateurs/models/mock_data_patch.dart'; // ← same import pattern as organo page

// ── Data model ────────────────────────────────────────────────────────────────
enum UserRole { ceo, laboratoire, degustateur, collecteur }

class AppUser {
  final String id;
  final String initials;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String dateDebut;
  final UserRole role;
  bool actif;

  AppUser({
    required this.id,
    required this.initials,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.dateDebut,
    required this.role,
    this.actif = true,
  });

  String get fullName => '$prenom $nom';

  String get roleLabel {
    switch (role) {
      case UserRole.ceo:
        return 'CEO';
      case UserRole.laboratoire:
        return 'Laboratoire';
      case UserRole.degustateur:
        return 'Dégustateur';
      case UserRole.collecteur:
        return 'Collecteur';
    }
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────
class UtilisateursCeoPage extends StatefulWidget {
  const UtilisateursCeoPage({super.key});

  @override
  State<UtilisateursCeoPage> createState() => _UtilisateursCeoPageState();
}

class _UtilisateursCeoPageState extends State<UtilisateursCeoPage> {
  // ── Brand colors — identical to ProfilceoPage ─────────────────────────────
  static const Color green = Color(0xFF38835A);
  static const Color oliveGreen = Color(0xFF6B8143);
  static const Color cream = Color(0xFFF9F6EF);
  static const Color darkText = Color(0xFF1A2E1F);

  // ── Role accent colors ─────────────────────────────────────────────────────
  static const _roleColors = {
    UserRole.ceo: (bg: Color(0xFFE1F5EE), fg: Color(0xFF0F6E56)),
    UserRole.laboratoire: (bg: Color(0xFFE6F1FB), fg: Color(0xFF185FA5)),
    UserRole.degustateur: (bg: Color(0xFFFAEEDA), fg: Color(0xFF854F0B)),
    UserRole.collecteur: (bg: Color(0xFFFBEAF0), fg: Color(0xFF993556)),
  };

  // ── Data — from mock_data_patch.dart, same pattern as organo page ──────────
  // To switch to real API: replace this getter with a FutureBuilder call.
  // Example: Future<List<AppUser>> _future = UserService.fetchAll();
  List<AppUser> get _utilisateurs => mockUtilisateurs;

  // ── Local UI state ─────────────────────────────────────────────────────────
  UserRole? _activeFilter; // null = show all
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Derived filtered list — same filter+search pattern as echantillons page
  List<AppUser> get _filtered {
    return _utilisateurs.where((u) {
      final matchRole = _activeFilter == null || u.role == _activeFilter;
      final q = _searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          u.fullName.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.roleLabel.toLowerCase().contains(q) ||
          u.telephone.contains(q);
      return matchRole && matchSearch;
    }).toList();
  }

  // ── Navigation helpers — identical to every other CEO page ────────────────
  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: cream,
      drawer: CeoDrawer(
        onEchantillons: () => _goTo(const EchantillonsCeoPage()),
        onAnalyseOrganoleptique: () =>
            _goTo(const AnalyseOrganoleptiqueCeoPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoireCeoPage()),
        onAchatsConfirmes: () => _goTo(const AchatsConfirmesCeoPage()),
        onTableauDeBord: () => Navigator.pop(context),
        onProfil: () => _goTo(const ProfilceoPage()),
        onutilisiateurs: () => Navigator.pop(context),
        onDeconnexion: () => _goTo(LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,
        title: Text(
          'Utilisateurs',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          // Live count badge — same style as analyse_organoleptique appbar
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${filtered.length} utilisateur${filtered.length > 1 ? "s" : ""}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: _buildSearchBar(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserSheet,
        backgroundColor: green,
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: Text(
          'Ajouter',
          style: GoogleFonts.domine(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _UserCard(
                      user: filtered[i],
                      green: green,
                      oliveGreen: oliveGreen,
                      darkText: darkText,
                      roleColors: _roleColors,
                      onToggleStatus: () => _confirmToggleStatus(filtered[i]),
                      onDelete: () => _confirmDelete(filtered[i]),
                      onViewProfile: () => _showUserProfile(filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Search bar — green header continuation, same as organo page ───────────
  Widget _buildSearchBar() {
    return Container(
      color: green,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: darkText.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v.trim()),
          style: const TextStyle(fontSize: 13, color: darkText),
          decoration: InputDecoration(
            hintText: 'Rechercher par nom, email, rôle…',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color.fromARGB(255, 150, 149, 149),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 17,
              color: Colors.grey.shade400,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(
                      Icons.close,
                      size: 17,
                      color: Colors.grey.shade400,
                    ),
                  )
                : null,
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 9,
            ),
          ),
        ),
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    final chips = [
      (label: 'Tous', role: null as UserRole?),
      (label: 'CEO', role: UserRole.ceo as UserRole?),
      (label: 'Laboratoire', role: UserRole.laboratoire as UserRole?),
      (label: 'Dégustateur', role: UserRole.degustateur as UserRole?),
      (label: 'Collecteur', role: UserRole.collecteur as UserRole?),
    ];
    return Container(
      height: 52,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final chip = chips[i];
          final isActive = _activeFilter == chip.role;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = chip.role),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? green : cream,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? green : Colors.grey.shade300,
                ),
              ),
              child: Text(
                chip.label,
                style: TextStyle(
                  color: isActive ? Colors.white : oliveGreen,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Aucun utilisateur trouvé',
            style: GoogleFonts.domine(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Toggle active / inactive ───────────────────────────────────────────────
  void _confirmToggleStatus(AppUser user) {
    final action = user.actif ? 'désactiver' : 'réactiver';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Confirmer',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        content: Text(
          'Voulez-vous $action le compte de ${user.fullName} ?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => user.actif = !user.actif);
              Navigator.pop(context);
              _showSuccess(
                user.actif
                    ? '${user.fullName} réactivé'
                    : '${user.fullName} désactivé',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: green),
            child: Text(
              user.actif ? 'Désactiver' : 'Réactiver',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delete ─────────────────────────────────────────────────────────────────
  void _confirmDelete(AppUser user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Supprimer l'utilisateur",
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.red.shade700,
          ),
        ),
        content: Text(
          'Cette action est irréversible. Voulez-vous supprimer '
          '${user.fullName} ?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Mutates mockUtilisateurs directly — same pattern used in
              // other pages. With real API: await UserService.delete(user.id)
              setState(
                () => mockUtilisateurs.removeWhere((u) => u.id == user.id),
              );
              Navigator.pop(context);
              _showSuccess('${user.fullName} supprimé');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile bottom sheet ───────────────────────────────────────────────────
  void _showUserProfile(AppUser user) {
    final colors = _roleColors[user.role]!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colors.bg,
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        color: colors.fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: GoogleFonts.domine(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.bg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.roleLabel,
                            style: TextStyle(
                              color: colors.fg,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user.actif
                          ? const Color(0xFFE1F5EE)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: user.actif
                              ? const Color(0xFF1D9E75)
                              : Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          user.actif ? 'Actif' : 'Inactif',
                          style: TextStyle(
                            fontSize: 11,
                            color: user.actif
                                ? const Color(0xFF0F6E56)
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 16),
              Text(
                'Informations',
                style: GoogleFonts.domine(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 12),
              _infoTile(Icons.email_outlined, 'Email', user.email),
              _infoTile(Icons.phone_outlined, 'Téléphone', user.telephone),
              _infoTile(
                Icons.calendar_today_outlined,
                'Date de début',
                user.dateDebut,
              ),
              _infoTile(Icons.badge_outlined, 'Rôle', user.roleLabel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: green),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: oliveGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(value, style: TextStyle(fontSize: 14, color: darkText)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Add user bottom sheet ──────────────────────────────────────────────────
  void _showAddUserSheet() {
    final nomCtrl = TextEditingController();
    final prenomCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    UserRole selectedRole = UserRole.degustateur;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Nouvel Utilisateur',
                style: GoogleFonts.domine(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Rôle',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: oliveGreen,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: UserRole.values.map((r) {
                  final colors = _roleColors[r]!;
                  final isSelected = selectedRole == r;
                  final label = AppUser(
                    id: '',
                    initials: '',
                    nom: '',
                    prenom: '',
                    email: '',
                    telephone: '',
                    dateDebut: '',
                    role: r,
                  ).roleLabel;
                  return GestureDetector(
                    onTap: () => setSheet(() => selectedRole = r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.fg : colors.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : colors.fg,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _addField(
                prenomCtrl,
                'Prénom',
                Icons.person_outline,
                TextInputType.name,
              ),
              const SizedBox(height: 12),
              _addField(
                nomCtrl,
                'Nom',
                Icons.person_outline,
                TextInputType.name,
              ),
              const SizedBox(height: 12),
              _addField(
                emailCtrl,
                'Email',
                Icons.email_outlined,
                TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _addField(
                telCtrl,
                'Téléphone',
                Icons.phone_outlined,
                TextInputType.phone,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (prenomCtrl.text.isEmpty ||
                        nomCtrl.text.isEmpty ||
                        emailCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Veuillez remplir tous les champs obligatoires',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    final initials = '${prenomCtrl.text[0]}${nomCtrl.text[0]}'
                        .toUpperCase();
                    final newUser = AppUser(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      initials: initials,
                      nom: nomCtrl.text.trim(),
                      prenom: prenomCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      telephone: telCtrl.text.trim(),
                      dateDebut: _todayFormatted(),
                      role: selectedRole,
                    );
                    // Mutates mock list directly — same pattern as delete above.
                    // With real API: await UserService.create(newUser)
                    setState(() => mockUtilisateurs.add(newUser));
                    Navigator.pop(context);
                    _showSuccess(
                      '${prenomCtrl.text} ${nomCtrl.text} ajouté — invitation envoyée',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Ajouter et envoyer l'invitation",
                    style: GoogleFonts.domine(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    TextInputType type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: oliveGreen,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: TextStyle(color: darkText, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: green, size: 18),
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
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
              borderSide: const BorderSide(color: green, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _todayFormatted() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
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
        backgroundColor: green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// WIDGET — _UserCard
// Mirrors the card style of _PanelBlock / sample cards in organo page.
// ═════════════════════════════════════════════════════════════════════════════
class _UserCard extends StatelessWidget {
  final AppUser user;
  final Color green;
  final Color oliveGreen;
  final Color darkText;
  final Map<UserRole, ({Color bg, Color fg})> roleColors;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;
  final VoidCallback onViewProfile;

  const _UserCard({
    required this.user,
    required this.green,
    required this.oliveGreen,
    required this.darkText,
    required this.roleColors,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final colors = roleColors[user.role]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: green.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colors.bg,
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      color: colors.fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.roleLabel,
                          style: TextStyle(
                            color: colors.fg,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge — same dot+label style as organo badges
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: user.actif
                        ? const Color(0xFFE1F5EE)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 3,
                        backgroundColor: user.actif
                            ? const Color(0xFF1D9E75)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.actif ? 'Actif' : 'Inactif',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: user.actif
                              ? const Color(0xFF0F6E56)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 8),

            // ── Info rows ─────────────────────────────────────────────
            _infoRow(Icons.email_outlined, user.email),
            const SizedBox(height: 4),
            _infoRow(Icons.phone_outlined, user.telephone),
            const SizedBox(height: 4),
            _infoRow(
              Icons.calendar_today_outlined,
              'Début : ${user.dateDebut}',
            ),

            const SizedBox(height: 10),

            // ── Action buttons ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    label: 'Voir profil',
                    color: green,
                    onTap: onViewProfile,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _actionBtn(
                    label: user.actif ? 'Désactiver' : 'Réactiver',
                    color: user.actif
                        ? Colors.orange.shade700
                        : const Color(0xFF38835A),
                    onTap: onToggleStatus,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF38835A).withOpacity(0.7)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
