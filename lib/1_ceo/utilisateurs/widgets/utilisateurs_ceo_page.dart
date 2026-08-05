// ═════════════════════════════════════════════════════════════════════════════
// FILE : ceo/utilisateurs/utilisateurs_ceo_page.dart
// PURPOSE : CEO user management page — view all users, their roles,
//           contact info, status, and perform admin actions.
// DATA   : Reads from the Django API, with mockUtilisateurs kept as fallback.
// STYLE  : Matches ProfilceoPage — same palette, fonts, and component style.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:project3/core/theme/app_colors.dart';
import '../../widgets/ceo_nav_mixin.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../main.dart';
import '../../widgets/ceo_drawer.dart';
import '../../echantillons/echantillons_ceo_page.dart';
import '../../achats_confirmes/achats_confirmes_ceo_page.dart';
import '../../validation_achats/validation_achats_ceo_page.dart';
import '../../analyse_laboratoire/analyse_laboratoire_ceo_page.dart';
import '../../analyse_organoleptique/analyse_organoleptique_ceo_page.dart';
import '../../profil_ceo_page.dart';
import '../../utilisateurs/models/mock_data_patch.dart';
import '../../utilisateurs/services/utilisateurs_ceo_service.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/models/enums.dart';
import 'user_card.dart';
import 'user_created_dialog.dart';

// ── Local aliases — keep page code unchanged while using core types ────────────
typedef UserRole = RoleUtilisateur;
typedef AppUser = UserProfile;

// ── Page ──────────────────────────────────────────────────────────────────────
class UtilisateursCeoPage extends StatefulWidget {
  const UtilisateursCeoPage({super.key});

  @override
  State<UtilisateursCeoPage> createState() => _UtilisateursCeoPageState();
}

class _UtilisateursCeoPageState extends State<UtilisateursCeoPage>
    with CeoNavMixin {
  // ── Role accent colors ─────────────────────────────────────────────────────
  // CEO → blue, Laboratoire → orange, Dégustateur → kGreen, Collecteur → pink
  static const _roleColors = {
    UserRole.direction: (bg: Color(0xFFE6F1FB), fg: Color(0xFF185FA5)),
    UserRole.laboratoire: (bg: Color(0xFFFAEEDA), fg: Color(0xFF854F0B)),
    UserRole.degustateur: (bg: Color(0xFFE1F5EE), fg: Color(0xFF0F6E56)),
    UserRole.collecteur: (bg: Color(0xFFFBEAF0), fg: Color(0xFF993556)),
    UserRole.chefDegustation: (bg: Color(0xFFF3EBF9), fg: Color(0xFF6A3D9A)),
  };

  // ── Data ──────────────────────────────────────────────────────────────────
  List<AppUser> _utilisateurs = List<AppUser>.from(mockUtilisateurs);
  bool _isLoading = false;
  bool _isMutating = false;
  bool _usesMockData = true;

  // ── Local UI state ─────────────────────────────────────────────────────────
  UserRole? _activeFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Derived filtered list ──────────────────────────────────────────────────
  List<AppUser> get _filtered {
    return _utilisateurs.where((u) {
      final matchRole = _activeFilter == null || u.role == _activeFilter;
      final q = _searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          u.nomComplet.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.role.label.toLowerCase().contains(q) ||
          (u.telephone?.contains(q) ?? false);
      return matchRole && matchSearch;
    }).toList();
  }

  // ── Navigation helpers ────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await utilisateursCeoService.fetchUsers();
      if (!mounted) return;
      setState(() {
        _utilisateurs = users;
        _usesMockData = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _utilisateurs = List<AppUser>.from(mockUtilisateurs);
        _usesMockData = true;
      });
      _showError(utilisateursCeoService.messageFor(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: kBg,
      drawer: CeoDrawer(
        onEchantillons: () => goToPage(const EchantillonsCeoPage()),
        onAnalyseOrganoleptique: () =>
            goToPage(const AnalyseOrganoleptiqueCeoPage()),
        onAnalyseLaboratoire: () => goToPage(const AnalyseLaboratoireCeoPage()),
        onValidationAchats: () => goToPage(const ValidationAchatsCeoPage()),
        onAchatsConfirmes: () => goToPage(const AchatsConfirmesCeoPage()),
        onTableauDeBord: () => Navigator.pop(context),
        onProfil: () => goToPage(const ProfilceoPage()),
        onutilisiateurs: () => Navigator.pop(context),
        onDeconnexion: () => goToPage(LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: kHeaderBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 52,
        title: Text(
          'Utilisateurs',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kDark,
          ),
        ),
        iconTheme: const IconThemeData(color: kDark),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _showAddUserSheet,
        backgroundColor: const Color.fromARGB(255, 197, 206, 201),
        elevation: 2,
        icon: const Icon(Icons.person_add_outlined, color: kDark),
        label: Text(
          'Ajouter',
          style: GoogleFonts.domine(color: kDark, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // ── Unified header zone ──────────────────────────────────────
          Container(
            color: kHeaderBg,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  style: const TextStyle(fontSize: 14, color: kDark),
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom, email, rôle…',
                    hintStyle: const TextStyle(
                      color: Color(0xFF6B8E7A),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF6B8E7A),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 17,
                              color: Color(0xFF6B8E7A),
                            ),
                            onPressed: () => setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            }),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 11,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kGreen, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                SizedBox(height: 34, child: _buildFilterChips()),
              ],
            ),
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => UserCard(
                      user: filtered[i],
                      green: kGreen,
                      darkText: kDark,
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

  // ── Filter chips ──────────────────────────────────────────────────────────
  // Inactive = gray (like current "Tous" inactive).
  // Active   = role-colored kBg + colored text (like current inactive role chips).
  Widget _buildFilterChips() {
    // (label, role, activeBg, activeFg)
    const chips = [
      (
        label: 'Tous',
        role: null as UserRole?,
        activeBg: Color(0xFF757575),
        activeFg: Colors.white,
      ),
      (
        label: 'CEO',
        role: UserRole.direction as UserRole?,
        activeBg: Color(0xFFE6F1FB),
        activeFg: Color(0xFF185FA5),
      ),
      (
        label: 'Laboratoire',
        role: UserRole.laboratoire as UserRole?,
        activeBg: Color(0xFFFAEEDA),
        activeFg: Color(0xFF854F0B),
      ),
      (
        label: 'Dégustateur',
        role: UserRole.degustateur as UserRole?,
        activeBg: Color(0xFFE1F5EE),
        activeFg: Color(0xFF0F6E56),
      ),
      (
        label: 'Collecteur',
        role: UserRole.collecteur as UserRole?,
        activeBg: Color(0xFFFBEAF0),
        activeFg: Color(0xFF993556),
      ),
      (
        label: 'Chef Dégustation',
        role: UserRole.chefDegustation as UserRole?,
        activeBg: Color(0xFFF3EBF9),
        activeFg: Color(0xFF6A3D9A),
      ),
    ];

    const Color inactiveBg = Color(0xFFF0F0F0);
    const Color inactiveFg = Color(0xFF757575);

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: chips.length,
      separatorBuilder: (_, _) => const SizedBox(width: 7),
      itemBuilder: (_, i) {
        final chip = chips[i];
        final isActive = _activeFilter == chip.role;
        final kBg = isActive ? chip.activeBg : inactiveBg;
        final fg = isActive ? chip.activeFg : inactiveFg;

        return GestureDetector(
          onTap: () => setState(() => _activeFilter = chip.role),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive
                    ? chip.activeFg.withValues(alpha: 0.4)
                    : const Color(0xFFE0E0E0),
                width: 1.2,
              ),
            ),
            child: Text(
              chip.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        );
      },
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
    final action = user.isActive ? 'désactiver' : 'réactiver';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Confirmer',
          style: GoogleFonts.domine(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: kDark,
          ),
        ),
        content: Text(
          'Voulez-vous $action le compte de ${user.nomComplet} ?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _isMutating
                ? null
                : () async {
                    Navigator.pop(context);
                    await _toggleUserStatus(user);
                  },
            style: ElevatedButton.styleFrom(backgroundColor: kGreen),
            child: Text(
              user.isActive ? 'Désactiver' : 'Réactiver',
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
          '${user.nomComplet} ?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _isMutating
                ? null
                : () async {
                    Navigator.pop(context);
                    await _deleteUser(user);
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

  Future<void> _toggleUserStatus(AppUser user) async {
    if (_isMutating) return;
    if (_usesMockData) {
      final updated = UserProfile(
        id: user.id,
        email: user.email,
        role: user.role,
        nom: user.nom,
        prenom: user.prenom,
        telephone: user.telephone,
        dateCreation: user.dateCreation,
        isActive: !user.isActive,
      );
      setState(() {
        final idx = _utilisateurs.indexWhere((u) => u.id == user.id);
        if (idx != -1) _utilisateurs[idx] = updated;
      });
      _showSuccess(
        updated.isActive
            ? '${updated.nomComplet} réactivé'
            : '${updated.nomComplet} désactivé',
      );
      return;
    }

    setState(() => _isMutating = true);
    try {
      final updated = await utilisateursCeoService.toggleActive(user.id);
      if (!mounted) return;
      setState(() {
        final idx = _utilisateurs.indexWhere((u) => u.id == user.id);
        if (idx != -1) _utilisateurs[idx] = updated;
      });
      _showSuccess(
        updated.isActive
            ? '${updated.nomComplet} réactivé'
            : '${updated.nomComplet} désactivé',
      );
    } catch (error) {
      if (!mounted) return;
      _showError(utilisateursCeoService.messageFor(error));
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    if (_isMutating) return;
    if (_usesMockData) {
      setState(() => _utilisateurs.removeWhere((u) => u.id == user.id));
      _showSuccess('${user.nomComplet} supprimé');
      return;
    }

    setState(() => _isMutating = true);
    try {
      await utilisateursCeoService.deleteUser(user.id);
      if (!mounted) return;
      setState(() => _utilisateurs.removeWhere((u) => u.id == user.id));
      _showSuccess('${user.nomComplet} supprimé');
    } catch (error) {
      if (!mounted) return;
      _showError(utilisateursCeoService.messageFor(error));
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
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
                      user.initiales,
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
                          user.nomComplet,
                          style: GoogleFonts.domine(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: kDark,
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
                            user.role.label,
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
                  color: kDark,
                ),
              ),
              const SizedBox(height: 12),
              _infoTile(Icons.email_outlined, 'Email', user.email),
              _infoTile(
                Icons.phone_outlined,
                'Téléphone',
                user.telephone ?? '—',
              ),
              _infoTile(
                Icons.calendar_today_outlined,
                'Date de début',
                user.dateCreation,
              ),
              _infoTile(Icons.badge_outlined, 'Rôle', user.role.label),
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
          Icon(icon, size: 18, color: kGreen),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: kOlive,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(value, style: TextStyle(fontSize: 14, color: kDark)),
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
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle + close ────────────────────────────────
              Row(
                children: [
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 17,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Single card: title + role picker ──────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_add_outlined,
                            color: kDark,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Nouvel Utilisateur',
                          style: GoogleFonts.domine(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(color: Colors.grey.shade100, height: 1),
                    const SizedBox(height: 14),

                    // Role label
                    const Text(
                      'Rôle',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kOlive,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Role chips — one row
                    Row(
                      children: UserRole.values.asMap().entries.map((entry) {
                        final i = entry.key;
                        final r = entry.value;
                        final roleC = _roleColors[r]!;
                        final isSelected = selectedRole == r;
                        final label = r.label;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: i < UserRole.values.length - 1 ? 6 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () => setSheet(() => selectedRole = r),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? roleC.bg
                                      : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? roleC.fg.withValues(alpha: 0.35)
                                        : const Color(0xFFE8E8E8),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? roleC.fg
                                          : const Color(0xFF9E9E9E),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Form fields ────────────────────────────────────────
              _addField(
                prenomCtrl,
                'Prénom',
                Icons.person_outline,
                TextInputType.name,
              ),
              const SizedBox(height: 14),
              _addField(
                nomCtrl,
                'Nom',
                Icons.person_outline,
                TextInputType.name,
              ),
              const SizedBox(height: 14),
              _addField(
                emailCtrl,
                'Email',
                Icons.email_outlined,
                TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _addField(
                telCtrl,
                'Téléphone',
                Icons.phone_outlined,
                TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // ── Action buttons ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: GoogleFonts.domine(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
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
                              setSheet(() => isSaving = true);
                              if (_usesMockData) {
                                final newUser = UserProfile(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  email: emailCtrl.text.trim(),
                                  role: selectedRole,
                                  nom: nomCtrl.text.trim(),
                                  prenom: prenomCtrl.text.trim(),
                                  telephone: telCtrl.text.trim(),
                                  dateCreation: _todayFormatted(),
                                );
                                setState(() => _utilisateurs.add(newUser));
                                if (ctx.mounted) Navigator.pop(ctx);
                                _showUserCreatedDialog(
                                  newUser.prenom,
                                  newUser.nom,
                                  newUser.email,
                                );
                                return;
                              }

                              try {
                                final newUser = await utilisateursCeoService
                                    .createUser(
                                      prenom: prenomCtrl.text.trim(),
                                      nom: nomCtrl.text.trim(),
                                      email: emailCtrl.text.trim(),
                                      role: selectedRole,
                                      telephone: telCtrl.text.trim(),
                                    );
                                if (!mounted) return;
                                setState(() => _utilisateurs.add(newUser));
                                if (ctx.mounted) Navigator.pop(ctx);
                                _showUserCreatedDialog(
                                  newUser.prenom,
                                  newUser.nom,
                                  newUser.email,
                                );
                              } catch (error) {
                                if (!mounted) return;
                                _showError(
                                  utilisateursCeoService.messageFor(error),
                                );
                              } finally {
                                if (ctx.mounted) {
                                  setSheet(() => isSaving = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          197,
                          206,
                          201,
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Enregistrer',
                        style: GoogleFonts.domine(
                          color: kDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
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
            color: kOlive,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: TextStyle(color: kDark, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: kGreen, size: 18),
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
              borderSide: const BorderSide(color: kGreen, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── User-created success dialog (auto-closes after 4 s) ───────────────────
  void _showUserCreatedDialog(String prenom, String nom, String email) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => UserCreatedDialog(prenom: prenom, nom: nom, email: email),
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
}
