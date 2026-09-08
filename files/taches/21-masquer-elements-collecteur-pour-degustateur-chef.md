# Tâche 21 — Retirer (pas juste cacher) les éléments propres au collecteur quand
# `MesEchantillonsPage` est ouverte par le dégustateur ou le chef dégustateur

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Modules concernés : `2_collecteur` (la page réutilisée), `3_degustateur`, `5_chef_degustateur`
(les points d'entrée ajoutés en tâche 20).

---

## Contexte

La tâche 20 a donné au dégustateur et au chef dégustateur un accès à
`lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart`, réutilisée telle quelle depuis
leurs tiroirs. Cette page embarque plusieurs éléments qui n'ont de sens que pour le
collecteur :

- Le tiroir `CollecteurDrawer` (~L632), avec son lien "Profil" qui ouvre
  `ProfileCollecteurPage` (~L635).
- La cloche de notifications et son badge, liés à `NotificationCollecteurService`
  (`_notifService`, ~L40, `_unreadNotifCount`, ~L53, boutons ~L657-700).
- Les actions "Confirmer l'achat" et "Planifier la livraison" sur chaque carte
  (`onConfirmerAchat` ~L1025, `onPlanifierLivraison` ~L1028) — refusées côté serveur pour ces
  deux rôles, mais aujourd'hui affichées quand même selon le statut de l'échantillon.

Le propriétaire ne veut pas que ces éléments soient simplement masqués visuellement
(opacité, `Visibility`, etc.) — il veut qu'ils **ne soient pas construits du tout** pour le
dégustateur et le chef, par précaution : un widget encore présent mais caché peut encore
déclencher ses appels et casser quelque chose. Un widget jamais construit ne peut rien casser.

Ce que la page n'a **pas** à perdre pour ces deux rôles : le bouton "Ajouter" (FAB), et les
actions "Modifier"/"Supprimer" sur les cartes (déjà correctement gérées par la tâche 20). Le
but de la tâche 20 était justement de leur donner ces trois actions.

---

## CONSIGNE

### 1. Rendre `MesEchantillonsPage` injectable, sans rien changer pour le collecteur

Ajoute deux paramètres optionnels au constructeur de `MesEchantillonsPage`
(`lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart`) :

```dart
final Widget? drawerPersonnalise;
final bool afficherExtrasCollecteur; // défaut : true
```

- `drawer: widget.drawerPersonnalise ?? CollecteurDrawer(...)` à la place de la construction
  actuelle (~L632). Si `drawerPersonnalise` n'est pas fourni, **rien ne change** pour le
  collecteur.
- Enveloppe le bloc de la cloche de notifications (les `IconButton` liés à `_unreadNotifCount`
  et `_notifService`, ~L657-700) dans `if (widget.afficherExtrasCollecteur) ...[ ... ]`, pour
  qu'il ne soit tout simplement pas construit quand c'est `false`. Si `_notifService` /
  `_unreadNotifCount` ne servent plus à rien d'autre dans ce cas, ne les charge pas non plus
  (`_loadUnreadCount()` peut rester inconditionnel si c'est plus simple, tant que rien ne
  s'affiche — à toi de juger le plus propre, dis ton choix dans le rapport).
- `onConfirmerAchat` et `onPlanifierLivraison` (~L1025-1029) : `null` directement quand
  `!widget.afficherExtrasCollecteur`, sans même évaluer `e.canConfirm`/`e.canPlanifier` :

```dart
onConfirmerAchat: (widget.afficherExtrasCollecteur && e.canConfirm)
    ? () => _onConfirmerAchat(e)
    : null,
onPlanifierLivraison: (widget.afficherExtrasCollecteur && e.canPlanifier)
    ? () => _onPlanifierLivraison(e)
    : null,
```

Le comportement par défaut (`afficherExtrasCollecteur: true`, `drawerPersonnalise: null`)
doit reproduire exactement l'écran actuel du collecteur — vérifie-le en relisant le diff, pas
seulement en le supposant.

### 2. Dégustateur et chef dégustateur passent leur propre tiroir

Dans `lib/3_degustateur/tableau_de_bord/widgets/app_drawer.dart` et
`lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart`, à l'endroit où
`MesEchantillonsPage` est ouverte (ajouté en tâche 20), passe :

```dart
MesEchantillonsPage(
  afficherExtrasCollecteur: false,
  drawerPersonnalise: AppDrawer(/* les mêmes callbacks que là où AppDrawer est
      normalement construit pour ce rôle — regarde comment sa page d'accueil
      (homepage_page.dart) le fait déjà et reproduis le même câblage */),
)
```

Regarde comment chaque `homepage_page.dart` (dégustateur, chef) construit déjà son propre
`AppDrawer` pour connaître la liste exacte des callbacks à fournir et la navigation attendue.

### 3. Vérifie qu'il n'y a pas d'import circulaire

`2_collecteur/mes_echantillons/mes_echantillons_page.dart` ne doit importer ni
`3_degustateur/...` ni `5_chef_degustateur/...` : c'est justement pour éviter ça que le tiroir
est injecté depuis l'extérieur plutôt qu'importé directement dans cette page.

---

## Ce que tu ne fais pas

- Tu ne touches pas au bouton "Ajouter" (FAB) : il reste identique pour les trois rôles.
- Tu ne touches pas aux actions "Modifier"/"Supprimer" : déjà correctement gérées par la
  tâche 20, ne change rien à cette logique.
- Tu ne changes rien au comportement du collecteur lui-même.
- Tu ne touches pas aux permissions serveur (déjà réglées en tâche 20).

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport.

## RAPPORT

*Rapport rédigé par Claude : le processus Codex qui a écrit le code ci-dessous s'est bloqué
avant de pouvoir lancer ses vérifications (même symptôme que sur plusieurs tâches ce soir —
0% d'activité après un temps normal de travail). Le code, lui, était complet et correct :
Claude l'a relu et vérifié lui-même plutôt que de relancer Codex sur un travail déjà fait.*

### Fait

- `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` : `MesEchantillonsPage`
  accepte maintenant `drawerPersonnalise` et `afficherExtrasCollecteur` (défaut `true`), sans
  rien changer par défaut. La cloche de notifications (et son chargement,
  `_loadUnreadCount()`) n'est plus construite quand `afficherExtrasCollecteur` est `false`. Les
  actions "Confirmer l'achat" et "Planifier la livraison" sont forcées à `null` dans ce cas,
  sans même regarder `canConfirm`/`canPlanifier`.
- `lib/3_degustateur/tableau_de_bord/widgets/app_drawer.dart` et
  `lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart` : l'ouverture de
  `MesEchantillonsPage` passe désormais `afficherExtrasCollecteur: false` et
  `drawerPersonnalise: AppDrawer(...)` — une nouvelle instance du **même** `AppDrawer` du rôle
  courant, construite avec exactement les callbacks déjà reçus par le tiroir d'origine (aucune
  navigation réinventée).
- Aucun import circulaire : `mes_echantillons_page.dart` n'importe toujours aucun des deux
  modules `3_degustateur`/`5_chef_degustateur`.

### Vérifié

```bash
dart format lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart lib/3_degustateur/tableau_de_bord/widgets/app_drawer.dart lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart
```
Sortie brute : `Formatted 3 files (2 changed) in 0.09 seconds.`

```bash
flutter analyze lib test
```
Sortie brute : `49 issues found. (ran in 20.3s)` — 0 erreur, conforme à la référence. Ce
résultat prouve au passage que les callbacks passés à `AppDrawer(...)` dans les deux tiroirs
correspondent exactement à son constructeur (sinon : erreur de compilation).

```bash
flutter test
```
Sortie brute : `108 tests`, **107 réussis**, 1 échec déjà connu
(`test/widget_test.dart: Counter increments smoke test`). Aucune régression.

### Non fait

Rien.

### HORS PÉRIMÈTRE

Rien.
