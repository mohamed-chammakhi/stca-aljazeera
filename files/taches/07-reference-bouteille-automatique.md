# Tâche 07 — La référence bouteille s'écrit toute seule

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Source de la demande : `docs/retours-utilisation-et-questions.md`, point 2.9.

À faire **après** la tâche 06, qui modifie le même fichier.

---

## Contexte

Aujourd'hui le collecteur tape la référence de chaque bouteille à la main :
`formulaire_dialog.dart:1001-1007`, dans `_BouteilleCard`, un simple `TextField` sur
`row.refCtrl` avec le texte d'exemple `'Ex: CHEMLALI-C1'`. Aucun contrôle d'unicité.

C'est le seul champ obligatoire du formulaire (`_isValid`, L329-331 ; message d'erreur
L369-370).

Un fournisseur peut avoir beaucoup de citernes — le bordereau papier de l'entreprise en montre
jusqu'à neuf pour un seul fournisseur. Taper autant de références à la main est long et
provoque des fautes.

Les trois informations nécessaires sont **déjà saisies** :

| Information | Où elle est |
|---|---|
| Code ou nom du fournisseur | Au niveau du formulaire (champ fournisseur avec autocomplétion, `_verifierFournisseur()` L335-363) |
| Numéro de citerne | `row.numCiterneCtrl` — champ « N° citerne », `_BouteilleCard` L1031-1037 |
| Quantité en tonnes | `row.qteCtrl` — champ « Quantité estimée », L1045-1052, avec `suffixText: 'T'` |

---

## CONSIGNE

1. La référence bouteille se remplit automatiquement, au format :

   ```
   codeOuNomFournisseur_numeroCiterne_quantiteT
   ```

   Exemple : fournisseur `S.T`, citerne `C3`, quantité `30` donne `S.T_C3_30T`.

   Le nombre est bien le **tonnage de la citerne**, confirmé par le propriétaire — pas le
   volume de la petite bouteille.

2. Utilise le **code** du fournisseur s'il existe, sinon son nom. Remplace les espaces par
   rien ou par un tiret, de façon cohérente, et documente ton choix dans le rapport.

3. La référence se met à jour à chaque fois que l'un des trois champs change, **tant que
   l'utilisateur n'a pas modifié la référence lui-même**. S'il la corrige à la main, on ne
   l'écrase plus.

4. Le champ reste visible et modifiable. Il reste obligatoire — ne touche pas à `_isValid`.

5. En mode modification (`_save()` L398-420), la référence existante ne doit **pas** être
   réécrite automatiquement.

6. Si une citerne ou une quantité est vide, n'écris pas une référence à trous du type
   `S.T__30T`. Choisis un comportement propre (par exemple : ne rien proposer tant que les
   trois champs ne sont pas remplis) et explique-le dans ton rapport.

---

## Ce que tu ne fais pas

- Tu n'ajoutes **pas** de contrôle d'unicité sur la référence dans cette tâche. Cela toucherait
  la base de données — si tu penses que c'est nécessaire, écris-le sous `## HORS PÉRIMÈTRE`.
- Tu ne changes pas le format des numéros d'échantillon (`numero`, `'2026/0001'`, construit à
  `formulaire_dialog.dart:429-430`). C'est autre chose que la référence bouteille.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Ajoute un test qui vérifie que saisir fournisseur `S.T`, citerne `C3`, quantité `30` produit
bien `S.T_C3_30T`, et qu'une référence modifiée à la main n'est plus écrasée ensuite.

## QUESTION

Le rapport de la tâche 06 est présent, mais il indique que cette tâche n'est pas terminée : elle
attend une décision sur l'enregistrement simultané des remarques globale et par bouteille. La
tâche 07 dépend explicitement d'une tâche 06 terminée et relue. Faut-il reprendre la tâche 07
avant la résolution et la relecture de ce prérequis ?


### RÉPONSE À LA QUESTION

**Oui, mais dans l'ordre.** La tâche 06 vient d'être débloquée : sa question est répondue dans
son propre fichier, sous `### RÉPONSE À LA QUESTION`.

Fais donc la 06 d'abord, complètement, avec son rapport. La 07 vient ensuite.

Ton réflexe de t'arrêter était le bon. Ne pars pas d'un fichier qu'une autre tâche est en train
de réécrire.

## RAPPORT

### Fait

- Aucun code modifié : le prérequis obligatoire de la tâche 06 n'est pas terminé ni relu.

### Vérifié

- Vérifications Flutter non exécutées : aucune modification applicative n'est autorisée tant que
  le prérequis de la tâche 06 reste incomplet.

### Non fait

- La génération automatique de référence et son test ne sont pas réalisés, en attente de la
  finalisation et de la relecture de la tâche 06.

### HORS PÉRIMÈTRE

- Aucun problème hors périmètre corrigé ou modifié.

### Reprise

#### Fait

- `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` : lors d'une
  création, la référence visible se met maintenant à jour avec le code du fournisseur
  sélectionné (ou le nom saisi si aucun code n'est disponible), le numéro de citerne et le
  tonnage. Une correction manuelle n'est plus écrasée, et une référence existante reste intacte
  en mode modification.
- `lib/2_collecteur/mes_echantillons/widgets/dialogs/bouteille_row.dart` : chaque bouteille
  conserve le fait que sa référence a été corrigée manuellement, indépendamment des autres
  bouteilles.
- `lib/core/utils/reference_bouteille.dart` : le format produit est
  `fournisseur_citerne_quantiteT`. Les espaces du code ou du nom fournisseur sont supprimés
  (`Domaine Bel Air` devient `DomaineBelAir`) ; si l'une des trois informations manque, aucune
  référence n'est proposée et le champ reste vide plutôt que d'afficher une référence à trous.
- `test/reference_bouteille_test.dart` : quatre tests unitaires sans écran couvrent l'exemple
  `S.T_C3_30T`, la protection d'une correction manuelle, l'absence de proposition incomplète et
  la suppression des espaces du fournisseur.

#### Vérifié

- `dart format lib/core/utils/reference_bouteille.dart lib/2_collecteur/mes_echantillons/widgets/dialogs/bouteille_row.dart lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart test/reference_bouteille_test.dart`
  → code de sortie 0 ; `Formatted 4 files (2 changed) in 0.08 seconds.`
- Exécution directe, avec `dart.exe`, d'un script temporaire important la fonction pure et
  reproduisant les quatre assertions du test → code de sortie 0 ;
  `4 vérifications réussies`. Le script temporaire a ensuite été supprimé.
- `flutter test test/reference_bouteille_test.dart` → code de sortie 1 avant le démarrage des
  tests : `CreateFile failed 5 (Access is denied.)`, puis Flutter échoue à exécuter
  `git -c log.showSignature=false log HEAD -n 1 --pretty=format:%ad --date=iso` dans son SDK.
- `flutter analyze lib test` → code de sortie 1 avant toute analyse, avec la même erreur
  `CreateFile failed 5 (Access is denied.)` sur la commande Git du SDK Flutter.
- `flutter test` → code de sortie 1 avant le démarrage des tests, avec la même erreur
  `CreateFile failed 5 (Access is denied.)` sur la commande Git du SDK Flutter.
- Vérifications complémentaires tentées : `dart analyze lib test` (code de sortie 1, lancement
  de `analysis_server_aot.dart.snapshot` refusé par `Access is denied`) et
  `dart test test/reference_bouteille_test.dart` (code de sortie 1, lancement du hook natif
  `objective_c` refusé par `Access is denied`).

#### Non fait

- Les diagnostics globaux de `flutter analyze lib test` et le bilan de `flutter test` ne sont
  pas disponibles : dans cet environnement, Flutter s'arrête sur l'accès au dépôt Git de son
  SDK avant d'atteindre le code du projet. Aucun nombre de diagnostics ou de tests Flutter
  réussis n'est donc revendiqué.

#### HORS PÉRIMÈTRE

- Aucun contrôle d'unicité n'a été ajouté à la référence bouteille, conformément à la consigne ;
  aucune base de données, permission ou route n'a été modifiée.

---

## CONSIGNE DE REPRISE — le prérequis est levé

La tâche 06 est **terminée, relue et commitée** (`370ff0a`). Tu peux exécuter la tâche 07.

### Ce qui a changé dans le fichier depuis que cette tâche a été écrite

`formulaire_dialog.dart` a beaucoup bougé. Lis-le avant de coder, les numéros de ligne de la
consigne d'origine ne sont plus fiables. En résumé :

- Chaque `_BouteilleCard` a maintenant **son propre bouton photo** (Galerie / Appareil photo /
  Annuler) et **sa propre remarque** (`row.remarqueCtrl`).
- Le bouton photo global, la question « à quelle bouteille ? » et la remarque globale ont été
  supprimés.
- `BouteilleRow` porte désormais : `refCtrl`, `varieteCtrl`, `numCiterneCtrl`, `qteCtrl`,
  `remarqueCtrl`, `photoBytes`, `photoName`.

Les trois sources dont tu as besoin pour construire la référence sont inchangées : le
fournisseur au niveau du formulaire, `row.numCiterneCtrl` et `row.qteCtrl`.

### Sur les tests — lis ceci avant d'en écrire un

**N'écris pas de test de widget sur le formulaire du collecteur.** Trois tentatives ont échoué
pendant la tâche 06, et le fichier de test a fini par être supprimé. La raison est structurelle :
ces écrans vont chercher la liste des fournisseurs à l'ouverture et ne se stabilisent jamais
dans un test. C'est une décision prise, elle est notée dans `ETAT.md`.

**Ce que tu peux faire à la place :** si tu écris la construction de la référence sous forme de
**fonction pure** — trois textes en entrée, un texte en sortie — tu peux la tester directement,
sans monter aucun écran. C'est la bonne façon de faire ici, et c'est ce qu'on préfère.

Si tu juges que ce n'est pas possible proprement, n'écris pas de test et dis-le sous
« Non fait » avec ta raison. On vérifiera à l'écran. Ne perds pas de temps à forcer un test de
widget.

### Vérification

```bash
flutter analyze lib test
flutter test
```

Référence : **50 problèmes, 0 erreur** ; **97 tests réussis** et un seul échec,
`test/widget_test.dart`, connu et listé dans `PROTOCOLE.md`.

Si `flutter` refuse de s'exécuter chez toi, dis-le franchement comme tu l'as fait trois fois,
et ne revendique aucun chiffre. Écris ton compte rendu sous `### Reprise`.
