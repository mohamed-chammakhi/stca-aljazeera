import 'package:flutter/foundation.dart' show kReleaseMode;

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

/// Enveloppe un appel réseau et rend explicite le recours aux démonstrations.
///
/// En développement, une erreur renvoie les données de secours en le signalant.
/// En production, elle remonte jusqu'à l'écran : aucune donnée inventée ne doit
/// être présentée à un utilisateur réel.
Future<Resultat<T>> avecSecours<T>(
  Future<T> Function() appel,
  T Function() secours,
) async {
  try {
    return Resultat(await appel());
  } catch (e) {
    if (kReleaseMode) rethrow;
    return Resultat(
      secours(),
      estDemonstration: true,
      messageErreur: e.toString(),
    );
  }
}
