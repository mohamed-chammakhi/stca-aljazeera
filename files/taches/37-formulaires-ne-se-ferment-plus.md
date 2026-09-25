# Tâche 37 — Les formulaires ne se ferment plus par accident

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Flutter uniquement. Aucun changement backend.

## Pourquoi

La propriétaire teste l'application sur son téléphone. Quand elle remplit un nouvel
échantillon et touche par erreur à côté de la fenêtre, la fenêtre se ferme et **tout ce
qu'elle a tapé est perdu**. Ça vient du comportement par défaut de Flutter :
`showDialog` a `barrierDismissible: true`, `showModalBottomSheet` a `isDismissible: true`
et `enableDrag: true`. Le bouton retour d'Android ferme aussi la fenêtre sans rien demander.

Elle veut : **un formulaire ne se ferme que quand on appuie sur Enregistrer (ou Ajouter,
Valider…) ou sur Annuler.**

## Partie A — Un seul outil partagé

Crée `lib/core/widgets/saisie_protegee.dart` avec :

1. `Future<bool> confirmerAbandonSaisie(BuildContext context)` : petite `AlertDialog`
   (elle-même `barrierDismissible: false`) :
   - titre : `Quitter sans enregistrer ?`
   - texte : `Ce que vous avez saisi sera perdu.`
   - boutons : `Continuer la saisie` (renvoie `false`) et `Quitter` (renvoie `true`,
     texte en rouge `Colors.red.shade700`).
2. Un widget `SaisieProtegee({required Widget child})` qui enveloppe `child` dans un
   `PopScope(canPop: false, onPopInvokedWithResult: ...)`. Quand on appuie sur le bouton
   retour d'Android : appelle `confirmerAbandonSaisie` ; si `true`, ferme avec
   `Navigator.of(context).pop()`.
   **Attention** : le bouton `Annuler` et le bouton d'enregistrement du formulaire ferment
   déjà avec `Navigator.pop(...)`. Avec `canPop: false`, un `Navigator.pop` direct reste
   possible (`PopScope` ne bloque que le retour système / `maybePop`). Vérifie que les
   boutons `Annuler`, `Enregistrer` et la croix de fermeture (s'il y en a une) ferment
   toujours **sans** demander de confirmation. Si un de ces boutons utilise `maybePop`,
   remplace-le par `pop`.

## Partie B — Les formulaires concernés

Pour **chaque** fenêtre de saisie ci-dessous :
- `showDialog` → ajoute `barrierDismissible: false` ;
- `showModalBottomSheet` → ajoute `isDismissible: false` et `enableDrag: false` ;
- enveloppe le contenu dans `SaisieProtegee`.

```
lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart        (ajout / modification d'échantillon)
lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart   (idem)
lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart (idem)
lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart  → _onScheduleArrivee (planifier l'arrivée)
lib/2_collecteur/mes_echantillons/widgets/dialogs/confirmer_achat_dialog.dart
lib/4_laboratoire/echantillons_labo/widgets/dialogs/formulaire_analyse_labo_dialog.dart (la feuille _FormulaireSheet)
lib/3_degustateur/sessions_degustation/widgets/dialogs/formulaire_session_dialog.dart (la feuille du formulaire de session, pas les petits sélecteurs d'heure)
lib/5_chef_degustateur/sessions_degustation/widgets/dialogs/formulaire_session_dialog.dart (idem)
lib/1_ceo/validation_achats/widgets/refus_dialog.dart   (RefusDecisionDialog, là où on tape le motif)
lib/1_ceo/analyse_organoleptique/widgets/approval_dialog.dart
lib/1_ceo/analyse_organoleptique/widgets/refusal_dialog.dart
lib/core/utilisateurs/utilisateurs_page_body.dart → la feuille de saisie vers la ligne 707 (vérifie que c'est bien un formulaire ; la feuille _showUserProfile vers la ligne 563 est une simple fiche, ne la touche pas)
ChangePasswordDialog (les 5 appels dans les pages de profil : profilcom.dart, profil_labo_page.dart, profil_page.dart, profil.dart, profil_ceo_page.dart)
```

Pour les `showDialog` / `showModalBottomSheet` des fichiers ci-dessus, le réglage se met à
l'endroit de l'appel (ex. dans `validation_achats_ceo_page.dart` pour `RefusDecisionDialog`,
dans `analyse_organoleptique_ceo_page.dart` pour `ApprovalDialog` / `RefusalDialog`).
Cherche avec `grep` où chaque fenêtre est ouverte.

**Pages plein écran de saisie** (ouvertes avec `MaterialPageRoute`) : ajoute seulement
`SaisieProtegee` autour du `Scaffold`, pour que le bouton retour d'Android et la flèche
retour de l'en-tête demandent confirmation :
```
lib/3_degustateur/evaluation_echantillons/formulaire_evaluation.dart  (FormulaireEvaluationPage)
lib/5_chef_degustateur/formulaire_evaluation.dart                    (FormulaireEvaluationPage)
```
Si la flèche retour de l'en-tête appelle `Navigator.pop` directement, fais-lui appeler
`confirmerAbandonSaisie` d'abord. Après un enregistrement réussi, la page doit se fermer
**sans** confirmation.

**Ne touche pas** : les filtres de date (`DateFilterSheet`), les fiches en lecture seule
(`shared_evaluation_form_sheet.dart`, `analyse_labo_sheet_adapter.dart`, `_showUserProfile`),
les petites confirmations Oui/Non, le sélecteur de classe (`carte_classification.dart`),
les sélecteurs d'heure. Elles doivent continuer à se fermer quand on touche à côté.

Si un fichier de la liste ne correspond pas (pas de champ de saisie, ouverture faite
ailleurs…), ne devine pas : écris-le sous `## QUESTION` et continue.

Ne change ni les textes existants, ni les couleurs, ni la mise en page.

## Partie C — Test

Ajoute `test/saisie_protegee_test.dart` :
- une fenêtre ouverte avec `barrierDismissible: false` + `SaisieProtegee` : taper en dehors
  (`tester.tapAt(const Offset(5, 5))`) ne la ferme pas ;
- retour système (`tester.binding.handlePopRoute()`) → la confirmation apparaît ;
  `Continuer la saisie` → la fenêtre est toujours là ; `Quitter` → elle est fermée ;
- un bouton qui fait `Navigator.pop(context)` ferme la fenêtre directement, sans confirmation.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera
`flutter analyze lib test` et `flutter test` (attendu : 0 erreur, 0 échec).

Dans ton rapport, liste chaque fenêtre modifiée avec une ligne :
« toucher à côté : bloqué oui/non — retour Android : confirmation oui/non ».

## RAPPORT

### Fait

- `lib/core/widgets/saisie_protegee.dart` — nouvel outil partagé : le retour Android demande confirmation avant d'abandonner une saisie, et les boutons explicites continuent à fermer directement.
- `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` — ajout/modification d'échantillon collecteur : toucher à côté : bloqué oui — retour Android : confirmation oui.
- `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` — ajout/modification d'échantillon dégustateur : toucher à côté : bloqué oui — retour Android : confirmation oui.
- `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` — ajout/modification d'échantillon chef : toucher à côté : bloqué oui — retour Android : confirmation oui.
- `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` — planification de l'arrivée d'un échantillon : toucher à côté : bloqué oui — retour Android : confirmation oui.
- `lib/2_collecteur/mes_echantillons/widgets/dialogs/confirmer_achat_dialog.dart` — confirmation/modification d'achat collecteur : toucher à côté : bloqué oui — retour Android : confirmation oui.
- `lib/4_laboratoire/echantillons_labo/widgets/dialogs/formulaire_analyse_labo_dialog.dart` — feuille de saisie/modification d'analyse labo : toucher à côté : bloqué oui — retour Android : confirmation oui. Le mode lecture seule reste libre.
- `lib/3_degustateur/sessions_degustation/widgets/dialogs/formulaire_session_dialog.dart` — formulaire de session dégustateur : toucher à côté : bloqué oui — retour Android : confirmation oui.
- `lib/5_chef_degustateur/sessions_degustation/widgets/dialogs/formulaire_session_dialog.dart` — formulaire de session chef : toucher à côté : bloqué oui — retour Android : confirmation oui.
- `lib/1_ceo/validation_achats/validation_achats_ceo_page.dart` et `lib/1_ceo/validation_achats/widgets/refus_dialog.dart` — refus avec motif/contre-proposition : toucher à côté : bloqué oui — retour Android : confirmation oui.
- `lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart`, `lib/1_ceo/analyse_organoleptique/widgets/approval_dialog.dart`, `lib/1_ceo/analyse_organoleptique/widgets/refusal_dialog.dart` — approbation/refus organoleptique : toucher à côté : bloqué oui — retour Android : confirmation oui.
- `lib/core/utilisateurs/utilisateurs_page_body.dart` — feuille de création utilisateur : toucher à côté : bloqué oui — retour Android : confirmation oui. La fiche `_showUserProfile` n'a pas été touchée.
- `lib/core/widgets/change_password_dialog.dart`, `lib/2_collecteur/profilcom.dart`, `lib/3_degustateur/profil/profil_page.dart`, `lib/4_laboratoire/profil_labo_page.dart`, `lib/5_chef_degustateur/profil.dart`, `lib/1_ceo/profil_ceo_page.dart` — changement de mot de passe sur les 5 profils : toucher à côté : bloqué oui — retour Android : confirmation oui.
- `lib/3_degustateur/evaluation_echantillons/formulaire_evaluation.dart` — page plein écran d'évaluation dégustateur : toucher à côté : non applicable — retour Android/flèche : confirmation oui.
- `lib/5_chef_degustateur/formulaire_evaluation.dart` — page plein écran d'évaluation chef : toucher à côté : non applicable — retour Android/flèche : confirmation oui.
- `test/saisie_protegee_test.dart` — test widget ajouté pour le tap extérieur, le retour système, `Continuer la saisie`, `Quitter`, et la fermeture directe par `Navigator.pop`.

### Vérifié

```bash
git diff --check
```

Sortie : exit code 0. Aucun whitespace error. Sortie brute : avertissements CRLF uniquement, par exemple `LF will be replaced by CRLF the next time Git touches it`.

```bash
(rg "barrierDismissible: false|isDismissible: false|enableDrag: false|SaisieProtegee|confirmerAbandonSaisie" lib test | Measure-Object).Count
```

Sortie brute : `46`.

```bash
(rg "maybePop" lib/1_ceo lib/2_collecteur lib/3_degustateur lib/4_laboratoire lib/5_chef_degustateur lib/core | Measure-Object).Count
```

Sortie brute : `0`.

```bash
(rg "showDialog<bool>\(|builder: \(_\) => const ChangePasswordDialog" lib/2_collecteur/profilcom.dart lib/4_laboratoire/profil_labo_page.dart lib/3_degustateur/profil/profil_page.dart lib/5_chef_degustateur/profil.dart lib/1_ceo/profil_ceo_page.dart | Measure-Object).Count
```

Sortie brute : `10` (5 appels `showDialog` et 5 builders `ChangePasswordDialog`).

Commandes tentées mais non concluantes :

```bash
dart format lib/core/widgets/saisie_protegee.dart ... test/saisie_protegee_test.dart
```

Sortie brute : `command timed out after 120035 milliseconds`.

```bash
dart format lib/core/widgets/saisie_protegee.dart lib/core/widgets/change_password_dialog.dart test/saisie_protegee_test.dart
```

Sortie brute : `command timed out after 60059 milliseconds`.

```bash
dart --disable-analytics format --output=none test/saisie_protegee_test.dart
```

Sortie brute : `command timed out after 20044 milliseconds`.

### Non fait

- `flutter analyze lib test` et `flutter test` non exécutés : la consigne de la tâche dit explicitement que le sandbox ne peut pas lancer Flutter et demande de ne pas essayer.
- `dart format` n'a pas pu être mené à terme : l'outil Dart ne rend pas la main, même sur un seul fichier de test.

### HORS PÉRIMÈTRE

- L'arbre de travail contenait déjà des modifications et fichiers non suivis hors tâche (`backend_new/`, `lib/core/api_client.dart`, `lib/main.dart`, `test/resultat_service_test.dart`, etc.). Je n'y ai pas touché pour cette correction.
