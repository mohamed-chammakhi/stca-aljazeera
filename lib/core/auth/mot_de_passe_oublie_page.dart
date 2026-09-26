import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../password_validation.dart';
import '../services/mot_de_passe_oublie_service.dart';

class MotDePasseOubliePage extends StatefulWidget {
  final MotDePasseOublieService? service;
  final String? initialEmail;

  const MotDePasseOubliePage({super.key, this.service, this.initialEmail});

  @override
  State<MotDePasseOubliePage> createState() => _MotDePasseOubliePageState();
}

class _MotDePasseOubliePageState extends State<MotDePasseOubliePage> {
  static const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
  static const Color _green = Color(0xFF38835A);
  static const Color _dark = Color(0xFF1A2E1F);
  static const Color _red = Color(0xFFF83837);

  final _emailKey = GlobalKey<FormState>();
  final _codeKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  int _step = 0;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  String? _jeton;

  MotDePasseOublieService get _service =>
      widget.service ?? motDePasseOublieService;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail ?? '';
  }

  Future<void> _envoyerCode() async {
    if (!_emailKey.currentState!.validate()) return;
    await _run(
      action: () async {
        await _service.envoyerCode(_emailController.text.trim());
        setState(() => _step = 1);
      },
    );
  }

  Future<void> _renvoyerCode() async {
    await _run(
      action: () async {
        await _service.envoyerCode(_emailController.text.trim());
        _codeController.clear();
      },
    );
  }

  Future<void> _verifierCode() async {
    if (!_codeKey.currentState!.validate()) return;
    await _run(
      action: () async {
        final jeton = await _service.verifierCode(
          email: _emailController.text.trim(),
          code: _codeController.text.trim(),
        );
        setState(() {
          _jeton = jeton;
          _step = 2;
        });
      },
    );
  }

  Future<void> _enregistrer() async {
    if (!_passwordKey.currentState!.validate()) return;
    final passwordIssues = passwordValidationRulesNotMet(
      _passwordController.text,
    );
    if (passwordIssues.isNotEmpty) {
      await _showError('Mot de passe trop faible', passwordIssues.join('\n'));
      return;
    }
    if (_passwordController.text != _confirmationController.text) {
      await _showError(
        'Les mots de passe ne correspondent pas',
        'La confirmation doit être identique au nouveau mot de passe.',
      );
      return;
    }
    final jeton = _jeton;
    if (jeton == null) return;

    await _run(
      action: () async {
        await _service.enregistrerNouveauMotDePasse(
          jeton: jeton,
          nouveauMotDePasse: _passwordController.text,
        );
        if (mounted) Navigator.pop(context, true);
      },
    );
  }

  Future<void> _run({required Future<void> Function() action}) async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await action();
    } catch (error) {
      await _showError('Erreur', _service.messageFor(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showError(String title, String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le champ email est obligatoire';
    }
    if (!value.contains('@')) return 'Veuillez saisir un email valide';
    return null;
  }

  String? _validateCode(String? value) {
    if (value == null || value.length != 6) {
      return 'Le code doit contenir 6 chiffres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Mot de passe oublié',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        iconTheme: const IconThemeData(color: _dark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _stepHeader(),
              const SizedBox(height: 24),
              if (_step == 0) _emailStep(),
              if (_step == 1) _codeStep(),
              if (_step == 2) _passwordStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepHeader() {
    final labels = ['Email', 'Code', 'Nouveau mot de passe'];
    return Row(
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: index <= _step ? _green : const Color(0xFFE3E8E5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (index < labels.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _emailStep() {
    return Form(
      key: _emailKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fieldLabel('Email du compte'),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('forgot-password-email'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            decoration: _inputDecoration(
              hint: 'email@stca.tn',
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 24),
          _primaryButton(
            key: const Key('forgot-password-send'),
            label: 'Envoyer le code',
            onPressed: _envoyerCode,
          ),
        ],
      ),
    );
  }

  Widget _codeStep() {
    return Form(
      key: _codeKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fieldLabel('Code reçu par email'),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('forgot-password-code'),
            controller: _codeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: _validateCode,
            decoration: _inputDecoration(
              hint: '000000',
              icon: Icons.pin_outlined,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            key: const Key('forgot-password-resend'),
            onPressed: _loading ? null : _renvoyerCode,
            child: const Text('Renvoyer un code'),
          ),
          const SizedBox(height: 12),
          _primaryButton(
            key: const Key('forgot-password-verify'),
            label: 'Vérifier',
            onPressed: _verifierCode,
          ),
        ],
      ),
    );
  }

  Widget _passwordStep() {
    return Form(
      key: _passwordKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fieldLabel('Nouveau mot de passe'),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('forgot-password-new-password'),
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: validatePassword,
            decoration: _inputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline,
              suffix: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _fieldLabel('Confirmer le mot de passe'),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('forgot-password-confirmation'),
            controller: _confirmationController,
            obscureText: _obscureConfirmation,
            decoration: _inputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline,
              suffix: IconButton(
                onPressed: () => setState(
                  () => _obscureConfirmation = !_obscureConfirmation,
                ),
                icon: Icon(
                  _obscureConfirmation
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _primaryButton(
            key: const Key('forgot-password-save'),
            label: 'Enregistrer',
            onPressed: _enregistrer,
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required Key key,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        key: key,
        onPressed: _loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _dark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _green,
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
      prefixIcon: Icon(icon, color: _green, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF7FAF8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E5E2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E5E2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _green, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _red, width: 1.5),
      ),
    );
  }
}
