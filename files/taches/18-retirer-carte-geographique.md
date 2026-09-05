# Tâche 18 — Retirer complètement la carte géographique

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Module concerné : `2_collecteur`, plus un point à vérifier côté `1_ceo`.

---

## Contexte

Le propriétaire ne veut plus de l'écran "Carte géographique" du collecteur. Il veut qu'il
disparaisse complètement — plus d'entrée dans le menu, plus d'écran, plus aucun moyen d'y
accéder.

**Important : `GeoService` (`lib/2_collecteur/carte_geo/services/geo_service.dart`) n'est
pas seulement utilisé par la carte.** C'est lui qui fournit la liste des gouvernorats et des
délégations aux menus déroulants "Gouvernorat" / "Délégation" du formulaire d'échantillon
(collecteur, dégustateur, chef dégustateur). **Ce fichier ne se supprime pas.**

Points d'accès à la carte trouvés :

| Fichier | Ce qu'il fait |
|---|---|
| `lib/2_collecteur/carte_geo/carte_geo_page.dart` | L'écran de la carte lui-même |
| `lib/2_collecteur/widgets/collecteur_drawer.dart` (~L94-98) | L'entrée de menu "Carte géographique" (`onCarte`) |
| `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` | Ouvre `CarteGeoPage` via `onCarte` du tiroir |
| `lib/2_collecteur/profilcom.dart` (~L223) | Un autre tiroir du collecteur, `onCarte` pointe déjà vers un `Placeholder()` — donc déjà mort, à nettoyer pareil |
| `lib/1_ceo/echantillons/widgets/collecteur_section.dart` (~L155-257) | Étiquette "Carte" et classe `CarteGeoPlaceholder` ("Connecter CarteGeoPage ici") — vérifie si ce widget est réellement instancié quelque part avant de le supprimer |

---

## CONSIGNE

1. **Supprime** `lib/2_collecteur/carte_geo/carte_geo_page.dart`.
2. **Retire l'entrée de menu** "Carte géographique" dans `CollecteurDrawer`
   (`collecteur_drawer.dart`) : le paramètre `onCarte`, le `_DrawerItem` correspondant, et
   son appel dans chaque endroit qui construit `CollecteurDrawer`
   (`mes_echantillons_page.dart`, `profilcom.dart`, et tout autre fichier que `grep` te
   montrerait).
3. **Côté CEO** (`1_ceo/echantillons/widgets/collecteur_section.dart`) : vérifie avec `grep`
   si `CarteGeoPlaceholder` est instanciée ailleurs dans le code. Si non, supprime la classe
   et l'étiquette "Carte" qui l'accompagne. Si oui, dis-le sous `## QUESTION` avant de
   toucher à quoi que ce soit — ne devine pas.
4. **Ne touche pas** à `GeoService` : `load()`, `gouvernorats`, `delegationsFor()` doivent
   continuer de marcher à l'identique pour les menus déroulants du formulaire. N'essaie pas
   de nettoyer les parties de `GeoService` qui ne servaient qu'à la carte (`zones`,
   `markVisited`, `DelegationZone`, etc.) dans cette tâche — laisse-les, même inutilisées.
   Si tu veux les signaler, mets-les sous `## HORS PÉRIMÈTRE`.
5. Vérifie avec `grep -rn "CarteGeoPage\|carte_geo" lib` qu'il ne reste plus aucune
   référence à l'écran supprimé (les références à `geo_service.dart` restent normales).

---

## Ce que tu ne fais pas

- Tu ne touches pas à `pubspec.yaml` (dépendances `flutter_map` / `latlong2`) : signale
  seulement sous `## HORS PÉRIMÈTRE` si tu penses qu'une dépendance devient inutile.
- Tu ne supprimes pas `geo_service.dart`.
- Tu ne touches à aucun autre module.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
grep -rn "CarteGeoPage" lib
```

Donne les sorties chiffrées réelles dans ton rapport, y compris le résultat brut du `grep`
(il doit ne rien renvoyer).

## QUESTION

La consigne demande de verifier si `CarteGeoPlaceholder` est instanciee ailleurs, puis de
s'arreter avant de toucher au code si c'est le cas. La verification trouve une instance
reelle cote CEO :

```bash
rg -n "CarteGeoPlaceholder" lib files
```

```text
files\taches\18-retirer-carte-geographique.md:28:| `lib/1_ceo/echantillons/widgets/collecteur_section.dart` (~L155-257) | Étiquette "Carte" et classe `CarteGeoPlaceholder` ("Connecter CarteGeoPage ici") — vérifie si ce widget est réellement instancié quelque part avant de le supprimer |
files\taches\18-retirer-carte-geographique.md:41:   si `CarteGeoPlaceholder` est instanciée ailleurs dans le code. Si non, supprime la classe
lib\1_ceo\echantillons\widgets\collecteur_section.dart:219:class CarteGeoPlaceholder extends StatelessWidget {
lib\1_ceo\echantillons\widgets\collecteur_section.dart:221:  const CarteGeoPlaceholder({super.key, required this.collecteurNom});
lib\1_ceo\echantillons\echantillons_ceo_page.dart:425:                                        builder: (_) => CarteGeoPlaceholder(
```

Question : faut-il aussi retirer l'acces CEO qui pousse `CarteGeoPlaceholder` depuis
`lib/1_ceo/echantillons/echantillons_ceo_page.dart`, ou la suppression doit-elle rester
strictement limitee a l'ecran carte du collecteur ?

---

### RÉPONSE À LA QUESTION

Oui, retire-la aussi. Le propriétaire a demandé que la carte géographique soit "retirée
complètement" — sans exception pour ce bouton. `CarteGeoPlaceholder` ne fait déjà rien de
réel (son propre texte dit "Connecter CarteGeoPage ici", c'est une ébauche jamais terminée),
donc le garder serait un bouton "Carte" qui ne mène nulle part d'utile, pire que pas de
bouton du tout.

Ce que tu fais :
- Retire l'étiquette "Carte" et son `onTap` qui construit `CarteGeoPlaceholder` dans
  `lib/1_ceo/echantillons/widgets/collecteur_section.dart` (~L155-163 pour l'étiquette,
  ~L217-257 pour la classe `CarteGeoPlaceholder` elle-même — supprime la classe aussi,
  vérifie d'abord avec `grep` qu'elle n'est utilisée nulle part ailleurs).
- Retire l'appel `builder: (_) => CarteGeoPlaceholder(...)` dans
  `lib/1_ceo/echantillons/echantillons_ceo_page.dart` (~L425) et ce qui l'entoure
  (le bouton/l'action qui déclenchait cette navigation côté CEO).
- Le reste de la consigne d'origine ne change pas : `GeoService` reste intact, `pubspec.yaml`
  ne bouge pas.

Reprends l'exécution normalement à partir d'ici.

## RAPPORT

### Fait

- `lib/2_collecteur/carte_geo/carte_geo_page.dart` supprimé : l'écran de carte géographique collecteur n'existe plus.
- `lib/2_collecteur/widgets/collecteur_drawer.dart` modifié : l'entrée de menu "Carte géographique" a disparu du tiroir collecteur.
- `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` modifié : la page "Mes échantillons" ne peut plus ouvrir la carte depuis le tiroir.
- `lib/2_collecteur/profilcom.dart` modifié : le tiroir du profil collecteur ne contient plus de callback mort vers une carte/placeholder.
- `lib/1_ceo/echantillons/widgets/collecteur_section.dart` modifié : le bouton "Carte" côté CEO et la classe `CarteGeoPlaceholder` ont été retirés.
- `lib/1_ceo/echantillons/echantillons_ceo_page.dart` modifié : la liste CEO ne pousse plus `CarteGeoPlaceholder`.

### Vérifié

```bash
flutter analyze lib test
```

Sortie réelle :

```text
command timed out after 900130 milliseconds
```

Résultat : non conclusif, la commande n'a produit ni compteur de diagnostics ni fin d'analyse après 15 minutes. Le processus `dart` laissé actif a été arrêté ensuite.

```bash
flutter test
```

Sortie réelle :

```text
command timed out after 900116 milliseconds
```

Résultat : non conclusif, la commande n'a produit ni compteur de tests ni sortie d'échec après 15 minutes. Le processus `dart` laissé actif a été arrêté ensuite.

```bash
grep -rn "CarteGeoPage\|carte_geo" lib
```

Sortie brute réelle :

```text
      0 [main] grep (22672) C:\Program Files\Git\usr\bin\grep.exe: *** fatal error - CreateFileMapping S-1-5-21-2378039868-576862018-1579538929-1001.1, Win32 error 5.  Terminating.
```

`grep` Git for Windows échoue avant la recherche. Vérification de secours exécutée avec `rg` :

```bash
rg -n "CarteGeoPage|carte_geo" lib
```

Sortie brute réelle :

```text
lib\3_degustateur\gestion_echantillons\widgets\dialogs\formulaire_dialog.dart:20:import '../../../../2_collecteur/carte_geo/services/geo_service.dart';
lib\2_collecteur\mes_echantillons\mes_echantillons_page.dart:25:import '../carte_geo/services/geo_service.dart';
lib\2_collecteur\carte_geo\services\geo_service.dart:2:// FILE : collecteur/carte_geo/services/geo_service.dart
lib\2_collecteur\mes_echantillons\widgets\dialogs\formulaire_dialog.dart:16:import '../../../../2_collecteur/carte_geo/services/geo_service.dart';
lib\5_chef_degustateur\gestion_echantillons\widgets\dialogs\formulaire_dialog.dart:17:import '../../../../2_collecteur/carte_geo/services/geo_service.dart';
```

Interprétation : aucune référence à `CarteGeoPage`; les références restantes à `carte_geo` pointent uniquement vers `geo_service.dart`, conservé volontairement.

```bash
grep -rn "CarteGeoPage" lib
```

Sortie brute réelle :

```text
      0 [main] grep (1456) C:\Program Files\Git\usr\bin\grep.exe: *** fatal error - CreateFileMapping S-1-5-21-2378039868-576862018-1579538929-1001.1, Win32 error 5.  Terminating.
```

Vérification de secours exécutée avec `rg` :

```bash
rg -n "CarteGeoPage" lib
```

Sortie brute réelle :

```text

```

Résultat : aucune occurrence.

Recherches complémentaires :

```bash
rg -n "CarteGeoPlaceholder|onCarte|onViewMap|Carte g[ée]ographique|label: 'Carte'" lib
```

Sortie brute réelle :

```text

```

Résultat : aucune occurrence.

```bash
dart format lib/1_ceo/echantillons/echantillons_ceo_page.dart lib/1_ceo/echantillons/widgets/collecteur_section.dart lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart lib/2_collecteur/profilcom.dart lib/2_collecteur/widgets/collecteur_drawer.dart
```

Sortie réelle du premier essai :

```text
command timed out after 120133 milliseconds
```

Sortie réelle du second essai :

```text
command timed out after 300109 milliseconds
```

Résultat : non conclusif, le formatteur n'a pas terminé. Les processus `dart` laissés actifs ont été arrêtés.

### Non fait

- Aucune modification demandée n'a été laissée de côté.
- Les validations `flutter analyze lib test`, `flutter test` et `dart format` n'ont pas pu être conclues à cause de timeouts sans sortie exploitable.

### HORS PÉRIMÈTRE

- `GeoService` contient encore des membres liés à l'ancienne carte (`zones`, `markVisited`, `DelegationZone`, etc.). Ils ont été laissés intacts comme demandé, parce que `GeoService` fournit toujours les gouvernorats/délégations aux formulaires.

### Complément — vérification par Claude

Un premier lancement de Codex sur cette reprise s'était réellement bloqué (0% de processeur
pendant 30 minutes, aucun fichier modifié) et a été arrêté puis relancé — le rapport
ci-dessus vient de cette seconde tentative, qui a bien édité le code. Une fois terminée,
Claude a exécuté lui-même les vérifications que l'outillage refusait à Codex :

```bash
dart format lib/1_ceo/echantillons/echantillons_ceo_page.dart lib/1_ceo/echantillons/widgets/collecteur_section.dart lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart lib/2_collecteur/profilcom.dart lib/2_collecteur/widgets/collecteur_drawer.dart
```
Sortie brute : `Formatted 5 files (5 changed) in 0.10 seconds.`

```bash
flutter analyze lib test
```
Sortie brute : `49 issues found. (ran in 6.6s)` — 0 erreur, **un diagnostic de moins que la
référence** (50) : le nettoyage a fait disparaître un avertissement pré-existant.

```bash
flutter test
```
Sortie brute : `103 tests`, **102 réussis**, 1 échec déjà connu
(`test/widget_test.dart: Counter increments smoke test`). Aucune régression.
- `pubspec.yaml` n'a pas été modifié. `latlong2` reste utilisé par `geo_service.dart`; l'utilité restante de `flutter_map` et `flutter_map_cancellable_tile_provider` peut être réévaluée dans une tâche séparée.
