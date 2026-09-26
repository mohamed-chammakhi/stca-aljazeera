import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api_client.dart';
import '../auth/mot_de_passe_oublie_page.dart';
import '../password_validation.dart';
import '../services/profile_service.dart';
import 'saisie_protegee.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({
    super.key,
    required this.accentColor,
    required this.labelColor,
    required this.titleColor,
    this.service,
  });

  final Color accentColor;
  final Color labelColor;
  final Color titleColor;
  final ProfileService? service;

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _accountEmail;

  ProfileService get _service => widget.service ?? profileService;

  @override
  void initState() {
    super.initState();
    _loadAccountEmail();
  }

  Future<void> _loadAccountEmail() async {
    try {
      final profile = await _service.currentProfile();
      if (mounted) setState(() => _accountEmail = profile.email);
    } catch (_) {}
  }

  Future<void> _openForgotPassword() async {
    final navigator = Navigator.of(context);
    navigator.pop();
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => MotDePasseOubliePage(initialEmail: _accountEmail),
      ),
    );
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  InputDecoration _decoration({
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: widget.labelColor),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: widget.labelColor,
          size: 20,
        ),
        onPressed: onToggle,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: widget.accentColor, width: 2),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final passwordErrors = passwordValidationRulesNotMet(_newController.text);
    if (passwordErrors.isNotEmpty) {
      await _showErrorDialog(
        title: 'Mot de passe trop faible',
        message: passwordErrors.map((rule) => '- $rule').join('\n'),
      );
      return;
    }

    if (_newController.text != _confirmController.text) {
      await _showErrorDialog(
        title: 'Les mots de passe ne correspondent pas',
        message: 'La confirmation doit être identique au nouveau mot de passe.',
      );
      return;
    }

    if (_newController.text == _currentController.text) {
      await _showErrorDialog(
        title: 'Mot de passe trop faible',
        message: "- Le nouveau mot de passe doit être différent de l'ancien.",
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _service.changerMotDePasse(
        ancien: _currentController.text,
        nouveau: _newController.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final message = _service.messageFor(error);
      final oldPasswordIncorrect =
          error is ApiException && error.code == 'password_incorrect';
      await _showErrorDialog(
        title: oldPasswordIncorrect
            ? 'Ancien mot de passe incorrect'
            : 'Changement refusé',
        message: oldPasswordIncorrect
            ? 'Le mot de passe actuel saisi est incorrect.'
            : message,
      );
    }
  }

  Future<void> _showErrorDialog({
    required String title,
    required String message,
  }) async {
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

  @override
  Widget build(BuildContext context) {
    return SaisieProtegee(
      child: AlertDialog(
        title: Text(
          'Changer le mot de passe',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: widget.titleColor,
          ),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _currentController,
                  obscureText: _obscureCurrent,
                  decoration: _decoration(
                    label: 'Mot de passe actuel',
                    obscure: _obscureCurrent,
                    onToggle: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Le mot de passe actuel est obligatoire'
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    key: const Key('change-password-forgot'),
                    onPressed: _openForgotPassword,
                    child: const Text('Mot de passe oublié ?'),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newController,
                  obscureText: _obscureNew,
                  decoration: _decoration(
                    label: 'Nouveau mot de passe',
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  validator: (_) => null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  decoration: _decoration(
                    label: 'Confirmer le mot de passe',
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (_) => null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            key: const Key('change-password-submit'),
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.accentColor,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Enregistrer',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}
