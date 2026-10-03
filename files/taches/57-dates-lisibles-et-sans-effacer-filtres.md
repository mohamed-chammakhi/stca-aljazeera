# Tâche 57 — Dates lisibles dans toute l'application + plus de bouton « effacer les filtres »

Écrit le 03/10/2026 par Claude. Exécutant : GitHub Copilot. Claude vérifie et commite.
Concerne **tous les rôles** (collecteur, dégustateur, chef, laboratoire, direction).

## 1. Supprimer « effacer les filtres » partout

L'utilisatrice ne veut ce bouton nulle part. Fichiers trouvés (chercher aussi d'autres libellés :
« Effacer », « Réinitialiser », icône `Icons.clear_all` / `filter_alt_off` près des filtres) :
- `lib/3_degustateur/tableau_de_bord/widgets/home_activite_section.dart`
- `lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart`
- `lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart`
- `lib/core/utilisateurs/utilisateurs_page_body.dart`
- et tout autre écran de `lib/` (barre de filtres partagée `lib/core/widgets/search_date_filter_bar.dart`,
  filtres de statut, etc.).
Supprimer le bouton et son espace ; les filtres restent utilisables (re-toucher « Tous », effacer
le champ de recherche avec sa croix si elle existe déjà dans le champ texte — ça, on le garde).
(La tâche 56 fait déjà la page Utilisateurs de la direction : si c'est le même fichier, ne pas
s'en soucier deux fois.)

## 2. Formulaire « Modifier l'échantillon » (dégustateur et chef) — champ « Date d'arrivée »

Capture de l'utilisatrice : le champ affiche `2026-09-25T18:05:28.81524…`.
Fichiers : `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` (~169)
et `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` (~279) :
`_dateAjoutCtrl = TextEditingController(text: e?.dateAjout ?? _todayStr())`.

Deux erreurs :
1. le texte est la valeur ISO brute du serveur ;
2. le champ s'appelle « Date d'arrivée » mais contient `dateAjout` (= date d'**enregistrement**).

À faire :
- Lire ce que ce champ envoie au serveur à l'enregistrement. Le champ « Date d'arrivée » doit
  correspondre à `date_arrivee_echantillon` (date prévue d'arrivée de l'échantillon, cf. carte :
  « Arrivée prévue ») : le pré-remplir avec `e.dateArriveeEchantillon` (vide si absente), au
  format `JJ/MM/AAAA` ; à l'envoi, convertir en ISO comme le reste de l'application.
- Ne **jamais** envoyer `date_ajout` depuis ce formulaire (le serveur la fixe à la création).
- Comparer avec le formulaire du **collecteur**
  (`lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart`) et faire pareil
  s'il a le même défaut.

## 3. Audit des dates dans toute l'application

Règle d'affichage : jamais de texte ISO (`2026-09-25T18:05:28…`, `+01:00`, `Z`) à l'écran.
- Date seule : `JJ/MM/AAAA` → `DegDateUtils.formaterAffichage` (`lib/core/utils/date_utils.dart`).
- Date + heure : `JJ/MM/AAAA HH:MM` en heure locale → `DegDateUtils.formaterDateHeure` /
  `formaterDateHeureOuTiret`.
- Valeur vide → « — ».
À vérifier dans **toutes** les pages et fenêtres des 5 rôles : cartes, détails, formulaires
(champs pré-remplis à la modification : dates d'arrivée, de livraison du stock et sa fin, de
réception, d'analyse labo `_debutCtrl` / `_finCtrl` dans
`lib/4_laboratoire/echantillons_labo/widgets/dialogs/formulaire_analyse_labo_dialog.dart`,
dates de session), notifications (date affichée), messagerie (heure des messages), tableaux de
bord, bordereau, profils. Méthode : chercher les champs date des modèles (`date…`, `…At`,
`createdAt`, `heure`) et suivre chaque affichage et chaque `TextEditingController(text: …)`.
Pour chaque formulaire de modification : le champ pré-rempli est lisible, et ce qui repart au
serveur reste au bon format (vérifier le sérialiseur Django correspondant).

Lister dans le rapport chaque endroit corrigé (fichier + ce qui était affiché avant).

## Tests

- Test Dart pour le formulaire de modification (ou sa fonction de pré-remplissage) : un
  échantillon avec `dateArriveeEchantillon = '2026-09-25T18:05:28.815240+01:00'` donne
  `25/09/2026` dans le champ « Date d'arrivée ».
- Mettre à jour les tests touchés.

## Règles

Voir `files/taches/PROTOCOLE.md`. Interdit : `git commit`, `git push`, migration appliquée sur la
vraie base, ML Kit, fausses données. Même correction pour tous les rôles qui partagent un écran.
Encodage UTF-8 sans BOM, garder les fins de ligne. Lancer `flutter analyze` (zéro ligne
« error - »), `flutter test` (et les tests Django si un fichier serveur change) avant le rapport.
