# Tâche 33 — Les deux petits défauts connus

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Flutter uniquement. Aucun changement backend, aucune migration.

État de départ, vérifié par Claude le 24/09/2026 :
- `flutter analyze lib test` → 55 diagnostics, 0 erreur, 0 avertissement ;
- `flutter test` → 108 réussis, 1 échec (`test/widget_test.dart`) ;
- Django (`backend_new`) → 190 tests, 0 échec.

---

## Partie A — Supprimer `test/widget_test.dart`

C'est le test modèle livré par Flutter (« Counter increments smoke test »). Il teste un
compteur `+` qui n'existe pas dans cette application. Il échoue depuis toujours et cache
les vrais échecs dans la sortie de `flutter test`.

**Consigne :** supprime le fichier `test/widget_test.dart`. Ne le remplace par rien.
Ne touche pas à `lib/main.dart`.

Cette suppression est explicitement demandée : la règle « aucune suppression sans preuve »
du protocole ne s'applique pas ici. Vérifie seulement avec `grep` qu'aucun autre fichier de
`test/` ne l'importe.

---

## Partie B — Débordement sur la carte d'échantillon du collecteur

Pendant la tâche 05, tu avais signalé un débordement d'affichage dans
`lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart`, ligne
517 à l'époque. Le fichier a changé depuis. À l'époque, la ligne 517 était le `Row` de
l'en-tête de `_NegociationSection` (texte « Détails de la négociation » /
« Détails de la commande » + `Spacer` + flèche). Aujourd'hui ce `Row` est vers la ligne 536.
Le débordement apparaissait avec les **cartes de démonstration**, sur un écran de 360 px.

`EchantillonComCard` ne dépend que de son modèle (pas de service, pas d'appel réseau) :
elle se teste seule.

### Consigne

1. **D'abord reproduire, ensuite corriger.** Crée `test/carte_collecteur_debordement_test.dart`.
   Prends modèle sur `test/carte_echantillon_test.dart` pour fixer la taille d'écran
   (360×780, `devicePixelRatio = 1.0`, `addTearDown(tester.view.reset)`) — n'invente pas
   une autre façon.
2. Dans ce test, rends `EchantillonComCard` dans un `ListView` avec le même padding que la
   vraie page, pour chaque échantillon des données de démonstration du collecteur (cherche
   où elles sont définies avec `grep`). Pour chacun : rends la carte, puis déplie toutes les
   sections qui se déplient (détails, négociation/commande), puis `pumpAndSettle`.
   Un débordement fait échouer le test tout seul.
3. Lance le test **avant** toute correction et note le résultat dans ton rapport :
   - **si le test échoue** : note le message exact (quel widget, combien de pixels), puis
     corrige **uniquement** le widget qui déborde, avec le minimum : `Expanded` / `Flexible`
     autour du texte, et `softWrap` ou `maxLines` + `TextOverflow.ellipsis` si besoin.
     Ne change ni les couleurs, ni les tailles de police, ni les textes affichés ;
   - **si le test passe sans correction** : le défaut a déjà disparu. Ne modifie pas la
     carte. Garde le test (il protège contre un retour du défaut) et dis-le dans ton rapport.
4. Si le débordement vient d'un autre fichier que la carte, ne le corrige pas : écris-le
   sous `## QUESTION` et arrête-toi.

---

## Vérification attendue

```bash
flutter analyze lib test
flutter test
```

Résultat attendu : 0 erreur, **0 test en échec** (le seul échec connu vient d'être supprimé).
Pas besoin de relancer Django : aucun fichier backend n'est touché.

## RAPPORT

### Fait

- `test/widget_test.dart` supprimé : le test modèle Flutter du compteur inexistant ne masquera plus les vrais échecs de la suite de tests.
- `test/carte_collecteur_debordement_test.dart` créé : la carte collecteur est rendue sur un écran 360×780, dans un `ListView` avec le padding réel de la page, pour chaque échantillon de démonstration, puis ses sections repliables sont ouvertes.
- `files/taches/33-deux-petits-defauts-connus.md` modifié : ajout du présent rapport d’exécution.

### Vérifié

Recherche d’import de `test/widget_test.dart` avant suppression :

```bash
rg -n "widget_test" test
```

Sortie brute : aucune ligne, code de sortie 1.

Test ciblé de reproduction, avant toute correction de la carte :

```bash
flutter test test/carte_collecteur_debordement_test.dart
```

Sortie brute :

```text
command timed out after 120028 milliseconds
```

Relance du même test avec délai plus long :

```bash
flutter test test/carte_collecteur_debordement_test.dart
```

Sortie brute :

```text
command timed out after 300039 milliseconds
```

Diagnostic Flutter :

```bash
$env:FLUTTER_ALREADY_LOCKED='true'; & 'C:\Users\takwa\Documents\flutter\bin\cache\dart-sdk\bin\dart.exe' --packages='C:\Users\takwa\Documents\flutter\packages\flutter_tools\.dart_tool\package_config.json' 'C:\Users\takwa\Documents\flutter\bin\cache\flutter_tools.snapshot' --version
```

Sortie brute :

```text
CreateFile failed 5 (Access is denied.
)
CreateFile failed 5 (Access is denied.
)
CreateFile failed 5 (Access is denied.
)
CreateFile failed 5 (Access is denied.
)
CreateFile failed 5 (Access is denied.
)
CreateFile failed 5 (Access is denied.
)
Flutter failed to run "git -c log.showSignature=false log HEAD -n 1 --pretty=format:%ad --date=iso". The flutter tool cannot access the file or directory.
Please ensure that the SDK and/or project is installed in a location that has read/write permissions for the current user.
```

Formatage du nouveau test :

```bash
& 'C:\Users\takwa\Documents\flutter\bin\cache\dart-sdk\bin\dart.exe' format test/carte_collecteur_debordement_test.dart
```

Sortie brute :

```text
Formatted test/carte_collecteur_debordement_test.dart
Formatted 1 file (1 changed) in 0.00 seconds.
```

Vérifications attendues :

```bash
flutter analyze lib test
```

Sortie brute :

```text
command timed out after 120039 milliseconds
```

```bash
flutter test
```

Sortie brute :

```text
command timed out after 120038 milliseconds
```

Django non lancé : la consigne indique que ce n’est pas nécessaire pour cette tâche Flutter uniquement.

### Non fait

- Aucune correction appliquée à `lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart` : le protocole de la tâche demandait de corriger seulement après reproduction d’un échec Flutter. Dans ce sandbox, `flutter test` et `flutter analyze` ne terminent pas, et le diagnostic direct montre un refus d’accès du Flutter SDK hors workspace.
- Le résultat attendu “0 test en échec” n’a pas pu être prouvé pour la même raison.

### HORS PÉRIMÈTRE

- Le SDK Flutter situé dans `C:\Users\takwa\Documents\flutter` n’est pas pleinement accessible depuis l’environnement sandboxé actuel (`CreateFile failed 5`, accès refusé). Aucun fichier du SDK n’a été modifié.

### RÉPONSE À LA QUESTION

Claude a lancé `flutter test test/carte_collecteur_debordement_test.dart` hors sandbox
(ton sandbox ne peut pas lancer Flutter, ce n'est pas ta faute).

1. Ton test avait une erreur : après dépliage, la référence de la bouteille apparaît
   **deux fois** (en-tête + détail), donc `findsOneWidget` échouait. Claude l'a corrigé
   (`findsWidgets`, et la vérification de `numero` retirée). **Ne retouche pas le test.**
2. Une fois le test corrigé, le débordement est **reproduit** (4 cartes sur 7) :

   ```text
   A RenderFlex overflowed by 49 pixels on the right.
   Row:file:///.../lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart:536:20
   ```

   C'est bien le `Row` de l'en-tête de `_NegociationSection`.

**Consigne de reprise :** applique le point 3 de la partie B, cas « si le test échoue ».
Corrige uniquement ce `Row` (ligne 536), avec le minimum : le texte `_label` dans un
`Expanded`, et retire le `Spacer` qui devient inutile. Si 49 px ne s'expliquent pas par ce
seul texte (le `Row` est peut-être posé dans un parent trop étroit), cherche la vraie cause
dans **ce même fichier** et corrige-la, sans changer couleurs, tailles de police ni textes.
N'essaie pas de lancer Flutter : Claude le relancera. Ajoute une section `### Reprise` à ton
rapport.

### Reprise

#### Fait

- `lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart` modifié : l'en-tête de la section négociation/commande ne déborde plus sur écran étroit, le libellé occupe l'espace disponible avant la flèche.
- `files/taches/33-deux-petits-defauts-connus.md` modifié : ajout du présent compte rendu de reprise.

#### Vérifié

Formatage du fichier modifié :

```bash
& 'C:\Users\takwa\Documents\flutter\bin\cache\dart-sdk\bin\dart.exe' format lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart
```

Sortie brute :

```text
Formatted lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart
Formatted 1 file (1 changed) in 0.07 seconds.
```

Vérification whitespace du diff :

```bash
git diff --check -- lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart files/taches/33-deux-petits-defauts-connus.md
```

Sortie brute : aucune ligne, code de sortie 0.

Flutter non relancé : la consigne de reprise indique explicitement "N'essaie pas de lancer Flutter : Claude le relancera."

#### Non fait

- `flutter analyze lib test` et `flutter test` non relancés, conformément à la consigne de reprise.
- Le test `test/carte_collecteur_debordement_test.dart` n'a pas été retouché, conformément à la réponse de Claude.

#### HORS PÉRIMÈTRE

- Aucun nouveau problème hors périmètre constaté pendant la reprise.
