String construireReferenceBouteille({
  required String fournisseur,
  required String numeroCiterne,
  required String quantite,
}) {
  final fournisseurNormalise = fournisseur.trim().replaceAll(
    RegExp(r'\s+'),
    '',
  );
  final citerneNormalisee = numeroCiterne.trim();
  final quantiteNormalisee = quantite.trim();

  if (fournisseurNormalise.isEmpty ||
      citerneNormalisee.isEmpty ||
      quantiteNormalisee.isEmpty) {
    return '';
  }

  return '${fournisseurNormalise}_${citerneNormalisee}_${quantiteNormalisee}T';
}

String actualiserReferenceBouteille({
  required String fournisseur,
  required String numeroCiterne,
  required String quantite,
}) => construireReferenceBouteille(
  fournisseur: fournisseur,
  numeroCiterne: numeroCiterne,
  quantite: quantite,
);
