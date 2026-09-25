List<String> passwordValidationRulesNotMet(String? value) {
  final rules = <String>[];
  if (value == null || value.isEmpty) {
    rules.add('Le champ mot de passe est obligatoire.');
    return rules;
  }
  if (value.length < 6) {
    rules.add('Au moins 6 caractères.');
  }
  if (!value.contains(RegExp(r'[0-9]'))) {
    rules.add('Au moins un chiffre.');
  }
  if (!value.contains(RegExp(r'[^a-zA-Z0-9]'))) {
    rules.add('Au moins un caractère spécial.');
  }
  return rules;
}

String? validatePassword(String? value) {
  final rules = passwordValidationRulesNotMet(value);
  if (rules.isEmpty) return null;
  if (value == null || value.isEmpty) {
    return 'Le champ mot de passe est obligatoire';
  }
  return 'Le mot de passe doit contenir au moins 6 caractères, un chiffre et un caractère spécial.';
}
