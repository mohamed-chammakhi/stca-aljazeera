# Tâche 23 — Le filtre calendrier du dégustateur et du chef doit avoir les mêmes choix
# que celui du collecteur

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Modules concernés : `3_degustateur/gestion_echantillons`, `5_chef_degustateur/gestion_echantillons`.

---

## Contexte

Le filtre par date (l'icône calendrier dans la barre du haut) du collecteur propose 4 choix
(`lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart`, ~L570-575) :

```dart
availableTypes: const [
  DateFilterType.enregistrement,
  DateFilterType.livraisonEchantillon,
  DateFilterType.receptionPhysique,
  DateFilterType.arriveeStock,
],
```

Le même filtre, sur les pages "Gestion des échantillons" du dégustateur et du chef, n'en
propose que 3 — il manque `DateFilterType.arriveeStock` ("Livraison du stock") :

- `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart`, ~L49-53
  (`static const _dateFilterTypes`)
- `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart`, ~L49-53
  (même variable)

Le propriétaire veut les mêmes choix des deux côtés. Aucun autre travail n'est nécessaire :
- Le libellé ("Livraison du stock") vient du même enum partagé
  (`DateFilterTypeX.label` dans `lib/core/widgets/search_date_filter_bar.dart`) — il est donc
  déjà correct sans rien changer.
- La donnée existe déjà : `dateGestionEchantillon()` dans `lib/core/utils/date_filter_utils.dart`
  gère déjà `DateFilterType.arriveeStock` pour le modèle `Echantillon` utilisé par ces deux
  pages (retourne `echantillon.dateLivraisonStock`, ~L58-59) — c'est le même modèle et la
  même fonction que la page du collecteur utilise pour ses propres filtres, rien à écrire ici
  non plus.

---

## CONSIGNE

Dans les deux fichiers listés ci-dessus, ajoute `DateFilterType.arriveeStock,` à la liste
`_dateFilterTypes`, pour qu'elle devienne identique à celle du collecteur (4 choix, même
ordre) :

```dart
static const _dateFilterTypes = [
  DateFilterType.enregistrement,
  DateFilterType.livraisonEchantillon,
  DateFilterType.receptionPhysique,
  DateFilterType.arriveeStock,
];
```

C'est tout. Une ligne par fichier.

---

## Ce que tu ne fais pas

- Tu ne touches à rien d'autre dans ces deux fichiers.
- Tu ne touches pas à `date_filter_utils.dart`, `search_date_filter_bar.dart`, ni à la page du
  collecteur : ils sont déjà corrects, la tâche ne fait que copier la liste des choix.
- Tu ne touches à aucune autre page (labo, CEO) même si elle a un filtre par date différent —
  seuls le dégustateur et le chef sont concernés par cette demande.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport. Référence : 49 diagnostics/0 erreur,
108 tests (107 réussis + 1 échec déjà connu) avant cette tâche.

## RAPPORT

Faite directement par Claude, sans passer par Codex : le changement est une ligne identique
dans deux fichiers, sans ambiguïté et sans risque (l'enum et la fonction de correspondance
existaient déjà, utilisés tels quels par la page du collecteur). Envoyer ça à Codex aurait
juste ajouté une attente pour rien.

### Fait

- `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart` : le filtre par
  date propose maintenant "Livraison du stock" en plus des trois choix existants — les mêmes
  quatre choix que le collecteur, dans le même ordre.
- `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart` : même ajout.

### Vérifié

```bash
dart format lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart
```
Sortie brute : `Formatted 2 files (0 changed) in 0.08 seconds.`

```bash
flutter analyze lib test
```
Sortie brute : `49 issues found.` — 0 erreur, conforme à la référence.

```bash
flutter test
```
Sortie brute : `108 tests`, **107 réussis**, 1 échec déjà connu
(`test/widget_test.dart: Counter increments smoke test`). Aucune régression.

### Non fait

Rien.

### HORS PÉRIMÈTRE

Rien.

---

## Note sur la suppression (deuxième point demandé dans le même message)

Le propriétaire a aussi redemandé si le dégustateur et le chef peuvent supprimer les
échantillons qu'ils ont enregistrés. Question posée en retour : est-ce que n'importe lequel
des deux peut supprimer n'importe quel échantillon non enregistré par un collecteur (déjà le
comportement depuis la tâche 22), ou seulement ce que chacun a personnellement ajouté (ce qui
demanderait un nouveau champ en base de données) ? Réponse du propriétaire : la première
option, déjà en place. Aucun code à écrire pour ce point.
