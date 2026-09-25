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

String fournisseurPourReferenceBouteille({
  required String texteChampFournisseur,
}) => texteChampFournisseur;

class DecisionReferenceBouteille {
  final String ancienneReference;
  final String nouvelleReference;

  const DecisionReferenceBouteille({
    required this.ancienneReference,
    required this.nouvelleReference,
  });
}

DecisionReferenceBouteille? referenceRecalculeeAConfirmer({
  required bool estModification,
  required String ancienneReference,
  required String referenceActuelle,
  required String fournisseur,
  required String numeroCiterne,
  required String quantite,
}) {
  if (!estModification) return null;

  final ancienne = ancienneReference.trim();
  final actuelle = referenceActuelle.trim();
  final automatique = construireReferenceBouteille(
    fournisseur: fournisseur,
    numeroCiterne: numeroCiterne,
    quantite: quantite,
  );

  if (actuelle.isEmpty || automatique.isEmpty) return null;
  if (actuelle == ancienne) return null;
  if (actuelle != automatique) return null;

  return DecisionReferenceBouteille(
    ancienneReference: ancienne,
    nouvelleReference: actuelle,
  );
}
