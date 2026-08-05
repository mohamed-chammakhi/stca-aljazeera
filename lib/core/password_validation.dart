String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Le champ mot de passe est obligatoire';
  }
  if (value.length < 6 ||
      !value.contains(RegExp(r'[0-9]')) ||
      !value.contains(RegExp(r'[^a-zA-Z0-9]'))) {
    return 'Le mot de passe doit contenir au moins 6 caractères, un chiffre et un caractère spécial.';
  }
  return null;
}
