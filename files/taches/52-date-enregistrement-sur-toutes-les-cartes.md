# Tâche 52 — « Enregistré le » sur toutes les cartes d'échantillon, tous les rôles

Écrit le 03/10/2026 par Claude. Exécutant : GitHub Copilot. Claude vérifie et commite.

## Besoin de l'utilisatrice

Sur **chaque carte d'échantillon de chaque rôle** (collecteur, dégustateur, chef dégustateur,
laboratoire, direction), afficher la date et l'heure où l'échantillon a été **enregistré dans
l'application** (par le collecteur, le dégustateur ou le chef). Le but : distinguer
l'enregistrement dans l'application de l'arrivée réelle dans la société (« Reçu le »).

## Ce qu'il faut faire

1. La donnée existe déjà : champ serveur `date_ajout`, modèle Dart `Echantillon.dateAjout`
   (et équivalents dans les modèles de la direction / du chef). Aucun changement serveur.
2. **Même nom partout : « Enregistré le »**. Remplacer les libellés existants
   « Date ajout » / « Date d'ajout » par « Enregistré le » :
   - `lib/1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart` (~476)
   - `lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart` (~770)
   - `lib/1_ceo/widgets/sample_card_echantillon.dart` (~143, et vérifier ~429)
   - `lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart` (~741)
3. **Ajouter « Enregistré le »** là où il manque, au minimum :
   - `lib/core/widgets/gestion_echantillons/echantillon_card.dart` (carte partagée dégustateur +
     chef) : dans la liste de détails, juste **avant** « Reçu physiquement » (~ligne 404) ;
   - `lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart` ;
   - `lib/1_ceo/widgets/base_sample_card.dart` si elle affiche des détails ;
   - les cartes d'échantillon du laboratoire (`lib/4_laboratoire/`) et des pages direction
     `lib/1_ceo/achats_confirmes/`, `lib/1_ceo/validation_achats/`, `lib/1_ceo/echantillons/`.
   Chercher toutes les autres cartes qui montrent un échantillon (`grep -rn "DetailItem\|Reçu physiquement\|Arrivée prévue" lib`)
   et y mettre le champ aussi. Placer « Enregistré le » à côté des autres dates, avant « Reçu le ».
4. **Format** : jour/mois/année et heure, comme « Reçu le » (ex. `03/10/2026 09:41`).
   Réutiliser la même fonction de formatage que « Reçu le » dans chaque fichier
   (`_dateOuTiret` dans `echantillon_card.dart`) ; si la date est vide ou illisible : « — ».
   La valeur serveur est en ISO 8601 (UTC) : l'afficher en heure locale.
   Si plusieurs fichiers ont besoin du même format, créer une seule fonction partagée dans
   `lib/core/` plutôt que de la copier.
5. Ne rien changer d'autre (pas de renommage de « Reçu physiquement » ni « Reçu le »).

## Tests

- Ajouter `test/date_enregistrement_carte_test.dart` : affiche la carte partagée
  (`echantillon_card.dart`) avec un échantillon dont `dateAjout = '2026-10-03T08:41:00Z'` et
  vérifie que « Enregistré le » est présent avec une date au format `jj/mm/aaaa hh:mm`.
- Mettre à jour les tests existants qui cherchent « Date ajout » / « Date d'ajout ».

## Règles

Voir `files/taches/PROTOCOLE.md`. Interdit : `git commit`, `git push`, ML Kit.
Encodage UTF-8 sans BOM, garder les fins de ligne de chaque fichier.
Flutter est installé sur ce PC : lancer `flutter analyze` (zéro ligne « error - ») et
`flutter test` avant d'écrire le rapport.

## RAPPORT

### Fait

- `lib/core/utils/date_utils.dart` : ajoute le formatage partagé date + heure locale et la valeur « — » pour les dates vides ou illisibles.
- `lib/core/widgets/gestion_echantillons/echantillon_card.dart` : affiche « Enregistré le » avant les informations de réception.
- `lib/core/widgets/evaluation_echantillons/echantillon_card.dart` : affiche « Enregistré le » pour les cartes dégustateur et chef.
- `lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart` : affiche « Enregistré le » sur la carte collecteur.
- `lib/4_laboratoire/echantillons_labo/models/echantillon_labo.dart` : conserve `date_ajout` dans le modèle laboratoire.
- `lib/4_laboratoire/echantillons_labo/widgets/echantillon_labo_card.dart` : affiche « Enregistré le » sur la carte laboratoire.
- `lib/1_ceo/echantillons/services/echantillon_ceo_service.dart` : conserve la valeur ISO de `date_ajout` pour afficher l’heure.
- `lib/1_ceo/widgets/sample_card_echantillon.dart` : remplace « Date d'ajout » par « Enregistré le » avec le format partagé.
- `lib/1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart` : remplace le libellé par « Enregistré le ».
- `lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart` : remplace le libellé par « Enregistré le ».
- `lib/1_ceo/achats_confirmes/achats_confirmes_ceo_page.dart` : remplace « Date enregistrement » par « Enregistré le ».
- `lib/1_ceo/validation_achats/validation_achats_ceo_page.dart` : remplace « Date enregistrement » par « Enregistré le ».
- `lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart` : conserve l'ISO et affiche « Enregistré le ».
- `test/date_enregistrement_carte_test.dart` : vérifie le libellé et le format `jj/mm/aaaa hh:mm` sur la carte partagée.

### Vérifié

- Test ciblé : `test/date_enregistrement_carte_test.dart` — réussi.
- `flutter analyze lib test` — `52 issues found. (ran in 6.8s)`, dont zéro ligne `error -` ; les diagnostics restants sont des `info`/`warning` préexistants.
- `flutter test` — `00:53 +185: All tests passed!`.
- Aucune migration, modification serveur ou utilisation de ML Kit.

### Non fait

- Aucun test Django : aucun fichier backend n'a été modifié et la tâche ne le demandait pas.
- Aucun changement des libellés du formulaire collecteur « Date d'ajout », car ils ne sont pas des cartes d'échantillon.

### HORS PÉRIMÈTRE

- `files/taches/FILE-ATTENTE.md`, les sauvegardes/base/media backend et les fichiers générés de plateformes étaient déjà présents ou ont été signalés par les commandes Flutter ; ils n'ont pas été modifiés fonctionnellement.
- Le `git pull --rebase origin main` n'a pas pu être exécuté : Git a refusé à cause des modifications non indexées préexistantes.

FIN RAPPORT
