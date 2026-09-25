String? validerFormulaireEchantillon({
  required int nombreBouteilles,
  required String fournisseur,
  required List<String> referencesBouteilles,
}) {
  if (nombreBouteilles < 1) return 'Ajoutez au moins une bouteille.';
  if (fournisseur.trim().isEmpty) return 'Le fournisseur est obligatoire.';
  for (var i = 0; i < referencesBouteilles.length; i++) {
    if (referencesBouteilles[i].trim().isEmpty) {
      return 'La référence bouteille est obligatoire pour la bouteille ${i + 1}.';
    }
  }
  return null;
}
