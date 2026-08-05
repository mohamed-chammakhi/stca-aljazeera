// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/widgets/marqueur_renegocie.dart
// PURPOSE : Marqueur « ↺ Renégocié ×N » sur la carte d'un échantillon.
//
// Pourquoi un marqueur et pas un statut : l'échantillon renvoyé en négociation
// reste « En négociation ». Créer un état supplémentaire obligerait à reprendre
// tous les filtres et toute la logique de statut. Le marqueur dit ce qui est
// arrivé au dossier en chemin, pas où il en est.
//
// Il se distingue du chip de statut par la FORME, pas seulement par la couleur :
// une pastille contournée, là où un statut est une pastille pleine. Sans ça, on
// recréerait visuellement l'état qu'on a justement refusé de créer.
//
// Partagé par la direction et le collecteur — c'est le collecteur qui doit agir
// dessus, le lui cacher n'aurait aucun sens.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Orange de la famille « négociation », repris du design system.
/// Volontairement pas rouge : le rouge est la couleur du refus, et il ferait
/// lire « refusé » un échantillon qui est toujours vivant.
const Color _orange = Color(0xFFD07B2F);
const Color _creme = Color(0xFFFEF3E8);

/// À partir de ce nombre de tours, le marqueur passe en pastille pleine.
///
/// Le nombre de renégociations n'est pas plafonné : l'application ne refuse
/// jamais un échantillon d'elle-même. Ce compteur est donc le seul signal qu'un
/// dossier s'enlise, et il doit finir par se voir en balayant une liste.
const int _seuilAlerte = 3;

class MarqueurRenegocie extends StatelessWidget {
  final int nombre;

  const MarqueurRenegocie({super.key, required this.nombre});

  @override
  Widget build(BuildContext context) {
    if (nombre <= 0) return const SizedBox.shrink();

    final appuye = nombre >= _seuilAlerte;
    final couleurTexte = appuye ? Colors.white : _orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: appuye ? _orange : _creme,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _orange, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.replay, size: 13, color: couleurTexte),
          const SizedBox(width: 4),
          Text(
            'Renégocié ×$nombre',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: couleurTexte,
            ),
          ),
        ],
      ),
    );
  }
}
