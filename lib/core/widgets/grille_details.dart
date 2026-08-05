// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/widgets/grille_details.dart
// PURPOSE : Grille étiquette / valeur des panneaux de détails, pour tous les rôles.
//
// Pourquoi ce fichier existe :
//   Chaque rôle avait sa propre copie privée de `_DetailItem` — dix au total —
//   posées dans un `Wrap` avec un `spacing` choisi à la main (20, 60, puis 90).
//   `Wrap` place les éléments à la suite, pas en colonnes : la largeur d'une
//   cellule dépend de son contenu, donc la deuxième colonne ne commence pas au
//   même endroit d'une ligne à l'autre, et une valeur longue déborde sur sa
//   voisine au lieu de revenir à la ligne.
//
//   `GrilleDetails` impose à chaque cellule une largeur exacte — la moitié de
//   l'espace disponible, gouttière déduite. Les colonnes tombent donc toujours
//   au même endroit, et le texte trop long passe à la ligne dans sa cellule
//   sans jamais toucher la colonne d'à côté.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Largeur minimale d'une cellule. En dessous, la grille retire une colonne
/// plutôt que de hacher chaque valeur en quatre lignes.
///
/// Le repli se calcule sur la largeur d'une **cellule**, pas sur celle du
/// panneau : un seuil posé sur le total se déclenche à tort dès que le panneau
/// est imbriqué dans plusieurs marges. Sur un écran de 360 dp, un panneau de
/// détails ne dispose que d'environ 284 dp une fois les marges de la liste, de
/// la carte et du panneau déduites — ce qui laisse deux cellules de 134 dp,
/// largement suffisant.
const double _largeurMiniCellule = 110.0;

const Color _couleurEtiquette = Color(0xFF9C9B9B);
const Color _couleurValeur = Color(0xFF1A2E1F);

/// Une paire étiquette / valeur affichée dans une [GrilleDetails].
class DetailItem extends StatelessWidget {
  final String label;
  final String value;

  /// Couleur de la valeur, quand elle porte un sens (statut, alerte).
  /// Par défaut, le vert foncé de la charte.
  final Color? couleurValeur;

  const DetailItem(this.label, this.value, {super.key, this.couleurValeur});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _couleurEtiquette,
            letterSpacing: 0.3,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          // Pas d'ellipse : une valeur longue passe à la ligne dans sa cellule.
          // C'est ce qui garantit qu'elle n'empiète jamais sur la colonne
          // voisine, au prix d'une ligne de plus.
          softWrap: true,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: couleurValeur ?? _couleurValeur,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

/// Grille à colonnes de largeur fixe pour les paires étiquette / valeur.
///
/// Les cellules d'une même ligne sont alignées en haut : une valeur sur deux
/// lignes fait grandir la ligne sans décaler sa voisine.
class GrilleDetails extends StatelessWidget {
  /// Les cellules. Presque toujours des [DetailItem], mais la grille accepte
  /// n'importe quel widget : quelques cellules portent une pastille ou une
  /// icône en plus de la paire étiquette / valeur. C'est la géométrie des
  /// colonnes qui compte ici, pas le contenu.
  final List<Widget> items;

  /// Nombre de colonnes sur écran large. Ramené à 1 sur écran étroit.
  final int colonnes;

  /// Espace horizontal entre deux colonnes.
  final double gouttiere;

  /// Espace vertical entre deux lignes.
  final double interligne;

  const GrilleDetails({
    super.key,
    required this.items,
    this.colonnes = 2,
    this.gouttiere = 16,
    this.interligne = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, contraintes) {
        final largeur = contraintes.maxWidth;

        // On retire des colonnes tant que les cellules seraient trop étroites.
        var nb = colonnes;
        while (nb > 1 &&
            (largeur - gouttiere * (nb - 1)) / nb < _largeurMiniCellule) {
          nb--;
        }
        final largeurCellule = (largeur - gouttiere * (nb - 1)) / nb;

        final lignes = <Widget>[];
        for (var debut = 0; debut < items.length; debut += nb) {
          if (lignes.isNotEmpty) lignes.add(SizedBox(height: interligne));
          lignes.add(_ligne(debut, nb, largeurCellule));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: lignes,
        );
      },
    );
  }

  Widget _ligne(int debut, int nb, double largeurCellule) {
    final cellules = <Widget>[];
    for (var col = 0; col < nb; col++) {
      if (col > 0) cellules.add(SizedBox(width: gouttiere));
      final index = debut + col;
      cellules.add(
        SizedBox(
          width: largeurCellule,
          // Une ligne incomplète garde ses cellules vides : la colonne de
          // gauche reste alignée avec celles du dessus.
          child: index < items.length ? items[index] : const SizedBox.shrink(),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cellules,
    );
  }
}
