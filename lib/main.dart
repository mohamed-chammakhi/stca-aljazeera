import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'degustateur/homepage/homepage_page.dart';

// ─────────────────────────────────────────────────────────────────────────────

// ENTRY POINT

// The first function Flutter calls when the app launches.

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  runApp(const MyApp());
}

// ─────────────────────────────────────────────────────────────────────────────

// ROOT WIDGET — MyApp

// Sets up the global app configuration: title, theme, and starting screen.

// StatelessWidget means this widget never changes after being built.

// ─────────────────────────────────────────────────────────────────────────────

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

      // Hides the red DEBUG banner in the top-right corner during development
      debugShowCheckedModeBanner: false,

      // Global theme applied across the entire app
      theme: ThemeData(
        primaryColor: const Color(0xFF38835A),

        scaffoldBackgroundColor: const Color(0xFFF9F6EF),
      ),

      // First screen shown when the app opens
      home: const LoginPage(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

// LOGIN PAGE — LoginPage

// StatefulWidget because it needs to change over time (e.g. show/hide password)

// ─────────────────────────────────────────────────────────────────────────────

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

// ─────────────────────────────────────────────────────────────────────────────

// STATE CLASS — _LoginPageState

// All the logic and UI for the login screen lives here.

// ─────────────────────────────────────────────────────────────────────────────

class _LoginPageState extends State<LoginPage> {
  // ── Controllers ───────────────────────────────────────────────────────────

  // TextEditingController lets us read what the user typed in a field.

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // ── Form Key ──────────────────────────────────────────────────────────────

  // Used to validate all form fields at once when the button is pressed.

  final _formKey = GlobalKey<FormState>();

  // ── Password Visibility ───────────────────────────────────────────────────

  // true = password is hidden (dots), false = password is visible

  bool _obscurePassword = true;

  // ── Brand Colors ──────────────────────────────────────────────────────────

  // All colors defined once here so they are easy to change in one place.

  static const Color green = Color(0xFF38835A); // main brand green

  static const Color red = Color(0xFFF83837); // used for error messages

  static const Color yellow = Color(0xFFF4C834); // decorative accent

  static const Color oliveGreen = Color(0xFF6B8143); // secondary green

  static const Color cream = Color(0xFFF9F6EF); // page background

  static const Color darkText = Color(0xFF1A2E1F); // main text color

  // ─────────────────────────────────────────────────────────────────────────

  // EMAIL VALIDATOR

  // Returns an error message if invalid, or null if valid.

  // ─────────────────────────────────────────────────────────────────────────

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email field is required';

    if (!value.contains('@')) return 'Please enter a valid email';

    return null; // null = valid, no error shown
  }

  // ─────────────────────────────────────────────────────────────────────────

  // PASSWORD VALIDATOR

  // Returns an error message if invalid, or null if valid.

  // ─────────────────────────────────────────────────────────────────────────

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password field is required';

    if (value.length < 6) return 'Please enter a valid password';

    // Must contain at least one number

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Please enter a valid password';
    }

    // Must contain at least one special character (not a letter or number)

    if (!value.contains(RegExp(r'[^a-zA-Z0-9]'))) {
      return 'Please enter a valid password';
    }

    return null; // null = valid, no error shown
  }

  // ─────────────────────────────────────────────────────────────────────────

  // LOGIN FUNCTION

  // Validates the form and shows a success message.

  // TODO: replace the SnackBar with your real API authentication call.

  // Example: AuthService.login(emailController.text, passwordController.text)

  // ─────────────────────────────────────────────────────────────────────────

  void _login() {
    if (_formKey.currentState!.validate()) {
      // ✅ Step 1 — unfocus keyboard first (removes keyboard snap)
      FocusScope.of(context).unfocus();

      // ✅ Step 2 — small delay lets the keyboard close smoothly
      //            before the transition starts
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeIn,
                    ),
                    child: child,
                  );
                },
          ),
        );
      });
    }
  }
  // ─────────────────────────────────────────────────────────────────────────

  // FORGOT PASSWORD FUNCTION

  // Called when the user taps "Forgotten password?"

  // TODO: replace with your real password reset screen or API call.

  // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordPage()))

  // ─────────────────────────────────────────────────────────────────────────

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Password reset link sent!',

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),

        backgroundColor: oliveGreen,

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        margin: const EdgeInsets.all(20),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  // BUILD METHOD

  // Draws the full login screen every time the state changes.

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // MediaQuery gives us the real screen dimensions of the device.

    // We use these to make the background fill the ENTIRE screen height.

    final double screenHeight = MediaQuery.of(context).size.height;

    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: cream,

      // Stack lets widgets sit on top of each other.

      // Layer 1 (bottom): full-screen background with decorative circles

      // Layer 2 (top): scrollable content (logo, title, form)
      body: Stack(
        children: [
          // ══════════════════════════════════════════════════════════════════

          // FULL SCREEN BACKGROUND LAYER

          // ──────────────────────────────────────────────────────────────────

          // This Container is explicitly set to screenHeight x screenWidth

          // so it always covers the ENTIRE phone screen including the bottom.

          // Without this, the background only covers the content area and

          // leaves the bottom of the screen bare.

          // ══════════════════════════════════════════════════════════════════
          SizedBox(
            width: screenWidth,

            height: screenHeight,

            child: Stack(
              children: [
                // ── Decorative Circle — Top Right ────────────────────────

                // Large semi-transparent green circle at the top-right corner.
                Positioned(
                  top: -60,

                  right: -60,

                  child: Container(
                    width: 220,

                    height: 220,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: green.withOpacity(0.12),
                    ),
                  ),
                ),

                // ── Decorative Circle — Bottom Left ──────────────────────

                // Large circle anchored to the BOTTOM LEFT of the full screen.

                // Because the parent SizedBox is screen-height tall, this

                // circle always reaches the very bottom of the phone.
                Positioned(
                  bottom: -80,

                  left: -50,

                  child: Container(
                    width: 280,

                    height: 280,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: oliveGreen.withOpacity(0.10),
                    ),
                  ),
                ),

                // ── Decorative Circle — Middle Left ──────────────────────

                // Small yellow accent circle positioned at 35% of screen height.
                Positioned(
                  top: screenHeight * 0.35,

                  left: -30,

                  child: Container(
                    width: 100,

                    height: 100,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: yellow.withOpacity(0.15),
                    ),
                  ),
                ),

                // ── Decorative Circle — Bottom Right ─────────────────────

                // Extra circle near the bottom-right for visual richness

                // at the lower part of the screen.
                Positioned(
                  bottom: screenHeight * 0.04,

                  right: -40,

                  child: Container(
                    width: 150,

                    height: 150,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: green.withOpacity(0.08),
                    ),
                  ),
                ),

                // ── Decorative Circle — Bottom Center ────────────────────

                // Small yellow circle near the bottom for extra depth.
                Positioned(
                  bottom: screenHeight * 0.10,

                  left: screenWidth * 0.35,

                  child: Container(
                    width: 60,

                    height: 60,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: yellow.withOpacity(0.10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════════════════════

          // END OF BACKGROUND LAYER

          // ══════════════════════════════════════════════════════════════════

          // ── Main Content Layer ────────────────────────────────────────────

          // SafeArea keeps content away from the notch and status bar.

          // SingleChildScrollView allows scrolling when the keyboard opens.
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),

              child: Column(
                // crossAxisAlignment.start keeps everything left-aligned

                // which also pushes the logo to the left side
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30),

                    child: Image.asset(
                      'assets/img/Aljazia_logo.png', // ← your logo file path

                      width: 140, // ← adjust logo width here

                      height: 140, // ← adjust logo height here

                      fit: BoxFit.contain, // keeps logo proportions intact
                    ),
                  ),
                  const SizedBox(height: 1), // spacing between logo and title
                  Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // keeps it centered nicely
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

                        SizedBox(height: 10), // space between texts

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "The Panel's Best Choice for Perfection",
                              textAlign: TextAlign.center, // important
                              style: GoogleFonts.alegreya(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: const Color.fromARGB(233, 22, 61, 39),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 55), // spacing between title and form
                  // ── Form Card ────────────────────────────────────────────
                  //the panel's choice for perfection
                  // White rounded card containing all input fields and button.

                  // boxShadow gives it a subtle floating effect.
                  Container(
                    padding: const EdgeInsets.all(26),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(24),

                      boxShadow: [
                        BoxShadow(
                          color: green.withOpacity(0.08),

                          blurRadius: 30,

                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    // Form groups all TextFormFields so they validate together
                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // ── Email Label ──
                          _fieldLabel('Email'),

                          const SizedBox(height: 8),

                          // ── Email Input Field ──

                          // keyboardType shows the email keyboard on mobile
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

                          // ── Password Label ──
                          _fieldLabel('Password'),

                          const SizedBox(height: 8),

                          // ── Password Input Field ──

                          // obscureText hides characters when _obscurePassword is true
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

                              // Eye icon on the right — toggles password visibility
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,

                                  color: oliveGreen,

                                  size: 20,
                                ),

                                // Flips _obscurePassword and rebuilds the UI
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Forgotten Password — CENTERED ─────────────────

                          // Center() makes this link sit in the middle of the card.

                          // To move to the RIGHT:

                          //   Align(alignment: Alignment.centerRight, child: TextButton(...))

                          // To move to the LEFT:

                          //   Remove Center() entirely.
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

                          // ── Log In Button ──────────────────────────────────

                          // Full width button that triggers _login() on press.

                          // double.infinity makes it stretch to the full card width.
                          SizedBox(
                            width: double.infinity,

                            height: 52,

                            child: ElevatedButton(
                              onPressed: _login,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  233,
                                  22,
                                  61,
                                  39,
                                ), // button color

                                foregroundColor: Colors.white, // text color

                                elevation: 0,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),

                              child: const Text(
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

                  const SizedBox(height: 30), // bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  // HELPER — _fieldLabel

  // Small styled label shown above each input field.

  // Usage: _fieldLabel('Email') or _fieldLabel('Password')

  // ─────────────────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────────────────

  // HELPER — _inputDecoration

  // Consistent styling applied to all input fields.

  // Parameters:

  //   hint   → placeholder text shown when field is empty

  //   icon   → icon on the left side of the field

  //   suffix → optional widget on the right (used for the eye icon)

  // ─────────────────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String hint,

    required IconData icon,

    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),

      // Left side icon inside the field
      prefixIcon: Icon(icon, color: green, size: 20),

      // Right side widget (eye toggle for password, null for email)
      suffixIcon: suffix,

      // Light background inside the field
      filled: true,

      fillColor: const Color(0xFFF7FAF8),

      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),

      // Default border
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: BorderSide(color: Colors.grey.shade200),
      ),

      // Border when the field is not focused
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: BorderSide(color: Colors.grey.shade200),
      ),

      // Border when the user is actively typing
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: green, width: 1.8),
      ),

      // Border shown when validation fails
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: red, width: 1.5),
      ),

      // Border when field is focused AND has a validation error
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(color: red, width: 1.8),
      ),

      // Style of the error text shown below the field
      errorStyle: const TextStyle(color: red, fontSize: 12),
    );
  }
}
