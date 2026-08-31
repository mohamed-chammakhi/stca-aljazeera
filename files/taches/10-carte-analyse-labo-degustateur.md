# Tâche 10 — Carte « Analyses laboratoire » du dégustateur

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Source de la demande : `docs/retours-utilisation-et-questions.md`, point 3.11.

À faire **après** la tâche 09.

---

## Contexte

Le propriétaire a comparé deux captures d'écran côte à côte et demandé que la carte du
dégustateur ressemble davantage à celle de la direction.

**Précision importante, à connaître avant de coder :** les deux captures ne viennent pas de la
même page.

- La carte avec « Approuver », « Refuser » et le bouton « Urgent » vient de la page **Analyse
  organoleptique de la direction** : `lib/1_ceo/analyse_organoleptique/widgets/panel_section.dart`
  (Approuver L68-74, Refuser L76-82, Urgent L96-144), posée sur `BaseSampleCard`
  (`lib/1_ceo/widgets/base_sample_card.dart`).
- La carte du dégustateur vient de la page **Analyses laboratoire** :
  `lib/core/widgets/analyse_labo/analyse_card.dart`, modèle `LigneAnalyseLabo`.

Ce sont deux pages différentes, avec deux modèles de données différents. Il ne s'agit donc
**pas** de fusionner deux versions d'une même carte. Il s'agit d'ajouter trois éléments à la
carte du dégustateur.

Bonne nouvelle : `analyse_card.dart` est **déjà partagé** entre le dégustateur
(`lib/3_degustateur/analyse_labo/analyse_laboratoire_page.dart:522-526`) et le chef dégustateur
(`lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart:500-504`). Une seule
modification suffit pour les deux rôles.

**Ce qui reste comme aujourd'hui :** le dégustateur n'a pas les boutons « Approuver » et
« Refuser ». C'est voulu, ne les ajoute pas.

---

## CONSIGNE

Tout se passe dans `lib/core/widgets/analyse_labo/analyse_card.dart`.

### 1. Le mot « Urgent » toujours visible

Aujourd'hui, dans `_UrgentLaboBtn` (L148-196), l'icône est toujours affichée (L174-180) mais le
libellé `'Urgent'` **n'apparaît que si l'analyse est déjà urgente** (`if (isUrgent)` L181).
Avant de cliquer, l'utilisateur ne voit qu'une petite cloche sans explication.

Afficher l'icône **et** le mot « Urgent » dans les deux cas, comme le fait la direction.
Garde la différence d'icône entre l'état normal et l'état urgent
(`Icons.notifications_outlined` / `Icons.notifications_active`).

### 2. Afficher la quantité dans l'en-tête

La quantité n'apparaît aujourd'hui que dans le détail déplié
(`DetailItem('Quantité estimée', …)` L369-370). Le propriétaire la veut visible sans déplier,
comme la pastille `Qté : 12T` de la direction.

Le champ existe déjà : `quantiteEstimee` sur `lib/core/analyses/ligne_analyse_labo.dart:18`.

**N'écris pas une nouvelle pastille.** Réutilise `_QuantityPill`, déjà écrite dans
`lib/core/widgets/gestion_echantillons/echantillon_card.dart:352` (format `'Qté : $quantite T'`
L365). Si elle est privée, sors-la dans un fichier partagé de `lib/core/widgets/` et fais
pointer les deux cartes dessus — c'est la règle 1 du `CLAUDE.md`.
Une pastille identique existe aussi dans
`lib/core/widgets/evaluation_echantillons/echantillon_card.dart:230` : profite-en pour n'en
garder qu'une seule.

Si `quantiteEstimee` est vide, n'affiche pas la pastille.

### 3. Le numéro d'enregistrement sous la référence

La ligne avec l'icône `Icons.tag` (L97-110) affiche `analyse.id`, qui vaut par exemple
`ANL-188-2026` — c'est le numéro de l'**analyse**, pas celui de l'échantillon.

La direction affiche sous la référence le numéro d'enregistrement de l'échantillon,
`2026/0002` (`base_sample_card.dart:102-112`).

Remplace `analyse.id` par `analyse.echantillonId`
(`lib/core/analyses/ligne_analyse_labo.dart:9`), qui contient déjà ce format.

Remarque : `echantillonId` est **déjà affiché** plus bas dans le détail déplié, sous le libellé
« N° échantillon » (`analyse_card.dart:355`). Une fois qu'il est visible dans l'en-tête, cette
ligne du détail fait doublon — supprime-la, ne laisse pas la même information à deux endroits.

### 4. Le filtre par dates

Ajoute sur cette page le filtre par dates unifié de la tâche 09.

---

## Une question à poser, pas à décider

Le titre de la carte affiche `analyse.echantillonNom`
(« Chemlali - Lot A - Sfax », L73), alors que la direction affiche `referenceBouteille`
(« CHEMLALI-C4 »).

Le modèle `LigneAnalyseLabo` **n'a pas** de champ `referenceBouteille`. L'ajouter demande de
toucher à l'API Django.

**Tu ne le fais pas de toi-même.** Écris la question sous `## QUESTION` et livre les quatre
points ci-dessus, qui n'en dépendent pas.

---

## Ce que tu ne fais pas

- Tu n'ajoutes ni « Approuver » ni « Refuser » à la carte du dégustateur.
- Tu ne touches pas à `ECH-EN-ATTENTE` ni à `ANL-188-2026` dans
  `lib/core/analyses/ligne_analyse_labo_service.dart:105-143`. Ce sont des données de
  démonstration écrites en dur, utilisées quand le serveur ne répond pas. Ce n'est pas un
  défaut.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

`test/carte_echantillon_test.dart` teste déjà le débordement des en-têtes de carte sur un écran
360×780. Ajoute le même genre de test pour la carte d'analyse laboratoire : la pastille de
quantité et le mot « Urgent » ne doivent pas faire déborder l'en-tête avec une référence longue.

Donne les sorties chiffrées réelles dans ton rapport.

---

## CONSIGNE DE REPRISE — fais la carte maintenant, sans le filtre

Le propriétaire a ouvert l'application et constaté que ces changements n'y sont pas. Ils sont
attendus.

**La tâche 09 n'est pas faite** : elle a été interrompue et Codex n'avait rien écrit. Le filtre
par dates unifié n'existe donc pas encore.

**Fais quand même les points 1, 2 et 3 de la consigne ci-dessus** — ils ne dépendent d'aucun
filtre :

1. le mot « Urgent » toujours visible à côté de l'icône cloche ;
2. la quantité affichée dans l'en-tête de la carte ;
3. le numéro d'enregistrement de l'échantillon sous la référence, et la ligne devenue doublon
   supprimée du détail déplié.

**Saute le point 4** (« Le filtre par dates »). Il sera ajouté avec la tâche 09. Note-le sous
« Non fait » avec cette raison.

### Rappel de ce qui compte

Tout se passe dans `lib/core/widgets/analyse_labo/analyse_card.dart`, un fichier **déjà
partagé** par le dégustateur et le chef dégustateur. Une seule modification sert les deux rôles.

**N'écris pas une nouvelle pastille de quantité.** Réutilise celle qui existe déjà dans
`lib/core/widgets/gestion_echantillons/echantillon_card.dart`. Si elle est privée, sors-la dans
un fichier partagé de `lib/core/widgets/` et fais pointer les cartes dessus. C'est la règle 1
du `CLAUDE.md`, et une pastille identique traîne aussi dans
`lib/core/widgets/evaluation_echantillons/echantillon_card.dart` : profites-en pour n'en garder
qu'une seule.

**Tu n'ajoutes ni « Approuver » ni « Refuser »** à la carte du dégustateur. C'est voulu.

### La question sur le titre de la carte reste posée

Le titre affiche `analyse.echantillonNom` (« Chemlali - Lot A - Sfax ») alors que la direction
affiche `referenceBouteille` (« CHEMLALI-C4 »). `LigneAnalyseLabo` n'a pas ce champ, et
l'ajouter demande de toucher à l'API Django.

**Ne le fais pas de toi-même.** Livre les trois points ci-dessus, qui n'en dépendent pas, et
écris la question sous `## QUESTION`.

### Sur les tests

Pas de test d'écran ici : ces pages vont chercher des données à l'ouverture et ne se stabilisent
jamais dans un test. Si tu veux vérifier quelque chose, fais-le sur une fonction pure. Sinon,
dis-le sous « Non fait » et n'insiste pas.

### Vérification

```bash
flutter analyze lib test
flutter test
```

Référence : **50 problèmes, 0 erreur** ; **101 tests réussis** avec le seul échec connu
`test/widget_test.dart`.

Si `flutter` refuse de s'exécuter chez toi, dis-le franchement et ne revendique aucun chiffre.
