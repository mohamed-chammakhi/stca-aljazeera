import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '3_degustateur/tableau_de_bord/homepage_page.dart';
import '2_collecteur/mes_echantillons/mes_echantillons_page.dart';
import '1_ceo/tableau_de_bord/tableau_de_bord.dart';
import '4_laboratoire/echantillons_labo/echantillons_labo_page.dart';
import '5_chef_degustateur/tableau_de_bord/homepage_page.dart' as chef;
import 'core/api_client.dart';
import 'core/models/enums.dart';
import 'core/services/auth_service.dart';

// ENTRY POINT
void main() {
  runApp(const MyApp());
}

// ROOT WIDGET — sets up global config: title, theme, starting screen
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasting Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF38835A),
        scaffoldBackgroundColor: const Color(0xFFF9F6EF),
      ),
      home: const AuthGate(),
    );
  }
}

Widget _destinationForRole(RoleUtilisateur role) {
  return switch (role) {
    RoleUtilisateur.direction => const HomePageCeo(),
    RoleUtilisateur.collecteur => const MesEchantillonsPage(),
    RoleUtilisateur.degustateur => const HomePage(),
    RoleUtilisateur.laboratoire => const EchantillonsLaboPage(),
    RoleUtilisateur.chefDegustation => const chef.HomePage(),
  };
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final token = await apiClient.accessToken;
      if (token == null || token.isEmpty) {
        if (mounted) setState(() => _checkingSession = false);
        return;
      }

      final user = await authService.currentUser().timeout(
        const Duration(seconds: 8),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => _destinationForRole(user.role)),
      );
    } catch (_) {
      if (mounted) setState(() => _checkingSession = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkingSession) return const LoginPage();

    return const Scaffold(
      backgroundColor: Color(0xFFF9F6EF),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF38835A))),
    );
  }
}

// LOGIN PAGE — StatefulWidget because it manages password visibility + form state
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Brand colors
  static const Color green = Color(0xFF38835A);
  static const Color red = Color(0xFFF83837);
  static const Color yellow = Color(0xFFF4C834);
  static const Color oliveGreen = Color(0xFF6B8143);
  static const Color cream = Color(0xFFF9F6EF);
  static const Color darkText = Color(0xFF1A2E1F);

  // ── Validators ────────────────────────────────────────────────────────────
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Le champ email est obligatoire';
    if (!value.contains('@')) return 'Veuillez saisir un email valide';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le champ mot de passe est obligatoire';
    }
    if (value.length < 6) return 'Veuillez saisir un mot de passe valide';
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Veuillez saisir un mot de passe valide';
    }
    if (!value.contains(RegExp(r'[^a-zA-Z0-9]'))) {
      return 'Veuillez saisir un mot de passe valide';
    }
    return null;
  }

  // ── Navigation helper ─────────────────────────────────────────────────────
  void _goTo(Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: replace with real API call
      // 1. Authenticate — saves JWT tokens automatically
      final user = await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // 2. Use the returned profile role for navigation.
      final role = user.role;

      // 3. Navigate to the correct dashboard based on role.
      if (!mounted) return;
      final destination = _destinationForRole(role);

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeIn,
                ),
                child: child,
              ),
        ),
      );
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = switch (e.code) {
          'email_not_found' => "Aucun compte n'est associé à cet email.",
          'password_incorrect' => 'Mot de passe incorrect.',
          'account_inactive' => 'Ce compte est désactivé.',
          _ =>
            e.statusCode == 401
                ? 'Email ou mot de passe incorrect.'
                : 'Erreur serveur (${e.statusCode}). Réessayez.',
        };
      });
    } catch (_) {
      setState(() {
        _errorMessage =
            'Impossible de joindre le serveur. Vérifiez votre connexion.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Le backend ne propose pas encore de réinitialisation autonome.
  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Contactez votre administrateur pour réinitialiser votre mot de passe.',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: oliveGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: cream,
      body: Stack(
        children: [
          // ── Background decorative circles ──────────────────────────────
          SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  right: -60,
                  child: _circle(220, green.withValues(alpha: 0.12)),
                ),
                Positioned(
                  bottom: -80,
                  left: -50,
                  child: _circle(280, oliveGreen.withValues(alpha: 0.10)),
                ),
                Positioned(
                  top: screenHeight * 0.35,
                  left: -30,
                  child: _circle(100, yellow.withValues(alpha: 0.15)),
                ),
                Positioned(
                  bottom: screenHeight * 0.04,
                  right: -40,
                  child: _circle(150, green.withValues(alpha: 0.08)),
                ),
                Positioned(
                  bottom: screenHeight * 0.10,
                  left: screenWidth * 0.35,
                  child: _circle(60, yellow.withValues(alpha: 0.10)),
                ),
              ],
            ),
          ),

          // ── Main content ───────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Image.asset(
                      'assets/img/Aljazia_logo.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tasting Panel',
                          style: GoogleFonts.domine(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: const Color.fromARGB(233, 22, 61, 39),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "The Panel's Best Choice for Perfection",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.alegreya(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: const Color.fromARGB(233, 22, 61, 39),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 55),

                  // ── Form card ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: green.withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Email'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 15,
                            ),
                            decoration: _inputDecoration(
                              hint: 'you@example.com',
                              icon: Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _fieldLabel('Password'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 15,
                            ),
                            decoration: _inputDecoration(
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: oliveGreen,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: TextButton(
                              onPressed: _forgotPassword,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgotten password?',
                                style: TextStyle(
                                  color: oliveGreen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  233,
                                  22,
                                  61,
                                  39,
                                ),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Log In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── DEBUG buttons — remove before final delivery ──────
                  Text(
                    'DEBUG ACCESS',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade400,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      _debugBtn(
                        'Direction',
                        () => _goTo(const HomePageCeo()),
                      ),
                      _debugBtn('Dégustateur', () => _goTo(const HomePage())),
                      _debugBtn(
                        'Collecteur',
                        () => _goTo(const MesEchantillonsPage()),
                      ),

                      _debugBtn(
                        'Technicien labo',
                        () => _goTo(const EchantillonsLaboPage()),
                      ),
                      _debugBtn(
                        'Chef de Dégustation',
                        () => _goTo(const chef.HomePage()),
                      ),
                    ],
                  ),

                  // ── END DEBUG ─────────────────────────────────────────
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _debugBtn(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: oliveGreen,
        letterSpacing: 0.6,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: green, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF7FAF8),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
        borderSide: const BorderSide(color: green, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: red, width: 1.8),
      ),
      errorStyle: const TextStyle(color: red, fontSize: 12),
    );
  }
}
