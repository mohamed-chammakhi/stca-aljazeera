# Tâche 44 — Messagerie : citer une bouteille (recherche serveur, 15 récentes, détails)

Lis `files/taches/PROTOCOLE.md` (dont « Même correction pour tous les rôles »), puis
`CLAUDE.md`. Backend + Flutter. Aucune migration. À faire **après la tâche 43** (le
fournisseur y gagne un lieu et le code fournisseur disparaît : utilise le nom + le lieu).

Fichier principal : `lib/core/widgets/messagerie/conversation_page.dart`
(`_chooseEchantillon`, `_EchantillonPicker`, `_EchantillonMessageRef`,
`_MessageEchantillonChip`). La messagerie est partagée par tous les rôles.

## Constaté par la propriétaire (sur téléphone)

1. La fenêtre « Référencer un échantillon » monte trop haut quand le clavier s'ouvre :
   elle touche la barre de l'heure et de la batterie. Cause : `SizedBox(height: 72 % de
   l'écran)` + `padding` du bas = `viewInsets.bottom`.
2. Les références bouteille ne s'affichent pas dans la liste : la ligne montre surtout
   le numéro `2026/0001`.
3. `_load()` télécharge **tous** les échantillons (`GET /api/echantillons/`) et filtre sur
   le téléphone. Avec des milliers d'échantillons, c'est trop lourd.

## Ce qu'elle veut

- Trouver une bouteille en tapant n'importe quel morceau : référence, fournisseur,
  variété, n° citerne, gouvernorat / délégation, numéro d'échantillon.
- Ne recevoir que les **15 bouteilles les plus récentes** qui correspondent (rien tapé =
  les 15 dernières).
- Voir assez de détails pour choisir la bonne quand plusieurs se ressemblent.

## A — Backend : recherche limitée

Sur la liste des échantillons (`backend_new/echantillons/views.py`), accepte deux
paramètres facultatifs, **sans changer** la réponse quand ils sont absents (les autres
écrans en dépendent) :
- `recherche=<texte>` : découpe en mots ; un échantillon correspond s'il contient **chaque
  mot** (insensible à la casse) dans au moins un de ces champs : `reference_bouteille`,
  `numero`, nom du fournisseur, `variete`, `num_citerne`, `gouvernorat`, `delegation`
  (échantillon et/ou fournisseur, selon la tâche 43) ;
- `limite=<n>` : au plus n résultats (max 50), triés du plus récent au plus ancien
  (`-date_ajout`).
Le filtrage par rôle de `get_queryset()` s'applique **avant** (un collecteur ne trouve que
ses échantillons, le labo que les reçus, etc.). Tests : recherche multi-mots, limite,
tri récent d'abord, isolation collecteur.

## B — Flutter : la fenêtre

1. **Hauteur** : la feuille ne dépasse jamais la zone sûre du haut. Utilise
   `useSafeArea: true` sur `showModalBottomSheet` et une hauteur
   `min(72 % de l'écran, hauteur disponible − clavier − marge)` ; la liste se réduit quand
   le clavier est ouvert, le champ de recherche reste visible.
2. **Chargement** : à l'ouverture, `recherche` vide + `limite=15`. À chaque frappe (pause
   de 300 ms), nouvel appel serveur avec le texte. Ignore une réponse qui arrive après une
   plus récente. Plus de filtrage local sur une liste complète.
3. **Ligne de résultat** (dans cet ordre) :
   - **référence bouteille** en gras (repli : numéro si la référence est vide) ;
   - fournisseur — lieu (`hami — Gabès (El Hamma)`, même libellé que la tâche 43) ;
   - `Citerne 4h · 120 T · Chemlali` (n'affiche que les valeurs présentes) ;
   - `2026/0012 · 24/09/2026 · <statut lisible>`.
4. Titre : `Citer une bouteille`. Indication du champ :
   `Référence, fournisseur, variété, citerne, lieu…`. Sous le champ, petite ligne grise :
   `Les 15 plus récentes. Ajoutez un mot pour affiner.`
5. Aucun résultat : `Aucune bouteille ne correspond.` (et si rien n'existe encore, le
   message « système tout neuf » de `empty_state.dart`).
6. **Pastille dans le message envoyé** (`_MessageEchantillonChip`) : référence bouteille en
   premier, puis fournisseur ; le numéro reste en petit. Vérifie que le serveur renvoie ce
   qu'il faut avec le message (champ `echantillon_reference_bouteille` etc.) ; ajoute le
   nom du fournisseur si absent.

## Tests

- Backend : cf. A.
- Flutter : la feuille avec clavier ouvert (grand `viewInsets`) ne dépasse pas la zone
  sûre ; une ligne affiche référence + fournisseur + citerne/quantité/variété ; la frappe
  déclenche un appel avec `recherche=` et `limite=15`.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera les tests Flutter et
Django.

## RAPPORT
