/// Ce qu'un service renvoie : la donnée et son origine.
class Resultat<T> {
  final T donnees;
  final bool estDemonstration;
  final String? messageErreur;

  const Resultat(
    this.donnees, {
    this.estDemonstration = false,
    this.messageErreur,
  });
}

/// Enveloppe un appel réseau.
///
/// Une erreur remonte toujours jusqu'à l'écran, en développement comme en
/// production : aucune donnée inventée ne doit être présentée à l'utilisateur.
/// `secours` n'est plus appelé ; il reste dans la signature pour ne pas
/// toucher aux 22 appels existants.
Future<Resultat<T>> avecSecours<T>(
  Future<T> Function() appel,
  T Function() secours,
) async {
  return Resultat(await appel());
}
