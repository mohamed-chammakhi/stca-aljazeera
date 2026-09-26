import 'package:flutter/material.dart';

import '../api_client.dart';
import '../password_validation.dart';
import '../services/profile_service.dart';

class ChangementMotDePasseObligatoirePage extends StatefulWidget {
  final String ancienMotDePasse;
  final Widget destination;

  const ChangementMotDePasseObligatoirePage({
    super.key,
    required this.ancienMotDePasse,
    required this.destination,
  });

  @override
  State<ChangementMotDePasseObligatoirePage> createState() =>
      _ChangementMotDePasseObligatoirePageState();
}

class _ChangementMotDePasseObligatoirePageState
    extends State<ChangementMotDePasseObligatoirePage> {
  final _formKey = GlobalKey<FormState>();
  final _nouveauCtrl = TextEditingController();
  final _confirmationCtrl = TextEditingController();
  final _service = ProfileService();
  bool _chargement = false;
  String? _erreur;

  @override
  void dispose() {
    _nouveauCtrl.dispose();
    _confirmationCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      await _service.changerMotDePasse(
        ancien: widget.ancienMotDePasse,
        nouveau: _nouveauCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => widget.destination),
        (_) => false,
      );
    } on ApiException catch (error) {
      setState(() => _erreur = error.message);
    } catch (_) {
      setState(() => _erreur = 'Impossible de changer le mot de passe.');
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F6EF),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Changer le mot de passe',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A2E1F),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nouveauCtrl,
                          obscureText: true,
                          validator: validatePassword,
                          decoration: const InputDecoration(
                            labelText: 'Nouveau mot de passe',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmationCtrl,
                          obscureText: true,
                          validator: (value) {
                            if (value != _nouveauCtrl.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        if (_erreur != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _erreur!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _chargement ? null : _enregistrer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38835A),
                            foregroundColor: Colors.white,
                          ),
                          child: _chargement
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Enregistrer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
