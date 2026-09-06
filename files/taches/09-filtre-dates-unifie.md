# Tâche 09 — Un seul filtre par dates, partout

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.
La **règle 1** du `CLAUDE.md` est le cœur de cette tâche : même chose → même nom → un seul
fichier.

Source de la demande : `docs/retours-utilisation-et-questions.md`, points 3.8, 3.9 et 3.10.

---

## Contexte

Le propriétaire veut que le dégustateur et le chef dégustateur puissent filtrer par **trois
dates différentes**, sur **trois pages**, et que le comportement soit **exactement le même**
partout.

### Ce qui existe aujourd'hui : trois systèmes différents

| Fichier | Ce qu'il fait |
|---|---|
| `lib/1_ceo/widgets/search_date_filter_bar.dart` | `enum DateFilterType { enregistrement, livraisonEchantillon, arriveeStock }` (L16), libellés L19-39, `DateFilterButton` L119, `DateFilterSheet` L181. Utilisé par la direction **et par le collecteur**. |
| `lib/core/widgets/search_filter_bar.dart` | Même idée, mais avec des **clés texte** au lieu d'un enum : `typeOptions` L189, `initialType` L190, `onApplyTyped` L191. Utilisé par le dégustateur. |
| `lib/5_chef_degustateur/gestion_echantillons/widgets/search_filter_bar.dart` | Copie quasi identique du précédent, **sans aucun choix de type de date** (pas de `typeOptions`, pas de `onApplyTyped`). |

### Où en sont les six pages concernées

| Page | Choix de date aujourd'hui |
|---|---|
| `lib/3_degustateur/analyse_labo/analyse_laboratoire_page.dart` | Deux types seulement : `enregistrement` et `receptionPhysique` (`_dateTypeOptions` L45-48, résolution `_dateFieldFor` L96-106) |
| `lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart` | Aucun choix — figé sur `dateEnregistrement` (L105) |
| `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart` | Aucun choix — titre figé « Filtrer par date d'enregistrement » (L215-227) |
| `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart` | Aucun choix (L188-199) |
| `lib/3_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart` | Aucun choix (L246-257) |
| `lib/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart` | Aucun choix (L249-260) |

Les pages du dégustateur et du chef dégustateur sont encore **deux fichiers séparés** : la
tâche 04 a fusionné les modèles, les cartes et les services, pas les pages. C'est précisément
pour ça que le filtre doit être écrit **une seule fois dans un widget partagé** : sinon il sera
recopié six fois et divergera, exactement comme le modèle d'évaluation qui avait été dupliqué
et qui avait causé le bug « tout affiché En attente » décrit dans `CLAUDE.md`.

---

## CONSIGNE

1. **Un seul widget de filtre par dates, un seul enum, dans `lib/core/`.**
   Pars de `lib/1_ceo/widgets/search_date_filter_bar.dart`, qui a déjà l'enum et la feuille de
   sélection complète (jour exact / période, boutons Effacer et Appliquer).

2. L'enum doit couvrir les **trois** dates demandées :

   | Valeur | Libellé utilisateur | Ce que c'est |
   |---|---|---|
   | date d'ajout | « Date d'enregistrement » | Le jour où le collecteur a saisi l'échantillon dans l'application |
   | date de livraison prévue | « Livraison échantillon » | Le jour où l'échantillon **doit** arriver |
   | date de présence physique confirmée | « Réception physique » | Le jour où quelqu'un a appuyé sur le bouton de confirmation de présence physique. Une date **constatée**, pas prévue. |

   Le type `receptionPhysique` existe déjà côté dégustateur sous forme de clé texte
   (`3_degustateur/analyse_labo/analyse_laboratoire_page.dart:45-48`) mais **pas** dans l'enum
   de la direction. C'est lui qu'il faut faire entrer dans l'enum commun.

   Garde `arriveeStock` : la direction et le collecteur s'en servent
   (`echantillons_ceo_page.dart:191` propose `DateFilterType.values`). Chaque page choisit les
   types qu'elle propose, comme le fait déjà `availableTypes` (L226).

3. **Supprimer les deux copies** : `lib/core/widgets/search_filter_bar.dart` et
   `lib/5_chef_degustateur/gestion_echantillons/widgets/search_filter_bar.dart` ne doivent plus
   contenir leur propre `DateFilterButton` / `DateFilterSheet`.
   Avant de supprimer un fichier, vérifie avec `grep` que plus personne ne l'importe — le
   linter de ce projet autorise `unused_import` et ne te préviendra pas.

4. **Brancher les six pages** listées plus haut sur le widget partagé, avec les trois types.
   Le dégustateur et le chef dégustateur doivent obtenir **le même résultat** pour la même
   recherche.

5. **Ne casse pas les usages existants** : le collecteur
   (`mes_echantillons_page.dart:562-591`) et les pages de la direction utilisent déjà ce widget.
   Ils doivent continuer à fonctionner à l'identique.

6. **Un défaut à corriger au passage.** Le type `livraisonEchantillon` lit
   `dateArriveeEchantillon`, mais `echantillon_collecteur_service.dart:75-79` force ce champ à
   `null` pour toute donnée venant de l'API et met la valeur dans `dateReceptionEchantillon`.
   Avec le vrai serveur, ce filtre ne renvoie donc **jamais rien**. Corrige le mapping pour que
   les deux dates soient distinctes et correctement remplies. Si la correction demande un
   changement de l'API Django, **pose la question au lieu de décider**.

---

## Ce que tu ne fais pas

- Tu ne fusionnes **pas** les pages du dégustateur et du chef dégustateur. C'est le sujet de la
  tâche 04, en cours. Ici tu partages seulement le filtre.
- Tu ne changes pas le sens des dates du collecteur (document point 2.8). Ce point attend une
  réponse de l'entreprise.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Cette tâche ne touche pas au backend Django : inutile de lancer sa suite.

Compte et donne le résultat brut de la commande : combien de fichiers déclarent encore un
`DateFilterSheet` après ta modification ? La réponse attendue est **un seul**.

Donne les sorties chiffrées réelles dans ton rapport.

---

## CONSIGNE DE REPRISE — état vérifié le 31/08/2026

Le diagnostic de cette tâche a été revérifié aujourd'hui, il tient toujours :
**trois fichiers déclarent encore `DateFilterSheet`.**

```
lib/1_ceo/widgets/search_date_filter_bar.dart
lib/core/widgets/search_filter_bar.dart
lib/5_chef_degustateur/gestion_echantillons/widgets/search_filter_bar.dart
```

### Ton critère de réussite, en un chiffre

À la fin de ton travail, cette commande doit renvoyer **1**, et un seul :

```bash
grep -rl "class DateFilterSheet" lib --include=*.dart | wc -l
```

Donne son résultat brut dans ton rapport. C'est la preuve la plus simple que la fusion est
faite, et elle ne se discute pas.

### Ce qui a changé dans le dépôt depuis que cette tâche a été écrite

Quatre tâches ont été commitées entre-temps : 05, 06, 07 et 08.

Une seule te concerne : **`mes_echantillons_page.dart` a été modifiée** par les tâches 05 et 08.
C'est la page du collecteur, et elle utilise déjà `DateFilterSheet`. **Son filtre par dates doit
continuer à fonctionner exactement comme avant ta modification.** Vérifie-le explicitement.

Les tâches 06 et 07 n'ont touché que le formulaire d'ajout du collecteur, sans rapport avec
les filtres.

### Sur les tests — ce qu'on a appris aujourd'hui

Les écrans du **collecteur** ne sont pas testables : ils vont chercher des données à
l'ouverture et ne se stabilisent jamais. Trois tentatives ont échoué en tâche 06, le fichier de
test a fini supprimé.

Ce qui a marché, en tâche 07 : **sortir la logique dans une fonction pure** de
`lib/core/utils/` et la tester là, sans monter aucun écran. Quatre tests écrits, quatre tests
passés, zéro aller-retour.

Applique la même méthode ici. La logique « telle date choisie, tel champ comparé, tel
échantillon retenu ou écarté » est du calcul pur : elle peut vivre dans une fonction et se
tester directement. C'est ce qu'on préfère.

Si tu tentes un test d'écran et qu'il ne se stabilise pas, **ne t'acharne pas** : dis-le sous
« Non fait » et passe à autre chose.

### Rappel de la règle qui compte ici

Les pages du dégustateur et du chef dégustateur sont encore deux fichiers séparés. C'est
justement pour ça que le filtre doit être écrit **une seule fois** dans un widget partagé, et
pas recopié six fois. Un code dupliqué dérive en silence — c'est ce qui avait produit le bug
où toutes les évaluations soumises s'affichaient « En attente » chez le chef.

### Vérification

```bash
flutter analyze lib test
flutter test
```

Référence : **50 problèmes, 0 erreur** ; **101 tests réussis** avec le seul échec connu
`test/widget_test.dart`.

## QUESTION

1. Le backend Django ne possède actuellement qu'un seul champ pour ces deux
   notions : `Echantillon.date_arrivee_echantillon`. Le serializer expose ce
   même champ, et l'action `confirmer-reception` le remplace par
   `timezone.now()` lorsque la présence physique est confirmée. Il n'existe
   donc aucun champ API distinct permettant de remplir à la fois la « Livraison
   échantillon » prévue et la « Réception physique » constatée. Autorisez-vous
   l'ajout d'un champ Django et d'une migration pour la date de livraison prévue ?
   Si oui, quel nom de champ/clé JSON faut-il retenir (par exemple
   `date_livraison_echantillon_prevue`) ? La consigne interdit de décider ce
   changement d'API et le point 2.8 interdit aussi de changer le sens actuel des
   dates du collecteur sans réponse de l'entreprise ; aucun code applicatif n'a
   donc été modifié.

---

### RÉPONSE À LA QUESTION — deux dates pour l'instant

**Ta question est juste, et le constat est même plus grave que tu ne le dis.**
Vérifié : `backend_new/echantillons/views.py:199` **écrase** `date_arrivee_echantillon` avec
`timezone.now()` au moment de la confirmation de réception. La date prévue par le collecteur
n'est donc pas seulement absente d'un champ dédié : elle est **détruite** dès l'arrivée.

C'est une vraie question métier, encore ouverte dans
`docs/retours-utilisation-et-questions.md`, section 7, question 5. Le propriétaire ne veut pas
la trancher maintenant.

**Décision : on construit le filtre avec deux dates seulement. Aucune migration, aucun
changement Django.**

### Ce que tu fais

1. **Un seul `DateFilterSheet`**, dans `lib/core/`. Le critère chiffré ne change pas : à la
   fin, `grep -rl "class DateFilterSheet" lib --include=*.dart | wc -l` doit renvoyer **1**.

2. **Sur les six pages du dégustateur et du chef dégustateur, propose exactement deux
   choix :**

   | Choix | Champ lu |
   |---|---|
   | « Date d'enregistrement » | la date de saisie dans l'application |
   | « Réception physique » | `date_arrivee_echantillon`, qui porte aujourd'hui la date réelle |

   **N'offre pas « Livraison échantillon » sur ces pages.** Ce serait un filtre qui ment :
   le champ est écrasé à la réception.

3. **Ne casse pas la direction ni le collecteur.** Leurs pages utilisent déjà les autres
   valeurs de l'enum (`livraisonEchantillon`, `arriveeStock`). Garde ces valeurs dans l'enum
   commun et laisse chaque page choisir ce qu'elle propose, comme le fait déjà
   `availableTypes`. Vérifie explicitement que le filtre du collecteur
   (`mes_echantillons_page.dart`) fonctionne comme avant.

4. **Le point 6 de la consigne d'origine est annulé.** Tu ne corriges pas le mapping de
   `dateArriveeEchantillon` : il dépend de la même décision métier, qui n'est pas prise.
   Signale-le simplement sous `## HORS PÉRIMÈTRE`.

5. **Supprime les deux copies** du filtre, comme prévu. Avant de supprimer, prouve avec `grep`
   que plus personne ne les importe et donne le résultat brut.

### Vérification

```bash
flutter analyze lib test
flutter test
```

Référence : **50 problèmes, 0 erreur** ; **101 tests réussis** avec le seul échec connu
`test/widget_test.dart`.

Si `flutter` refuse de s'exécuter chez toi, dis-le et ne revendique aucun chiffre. Donne en
revanche le résultat brut du `grep` du critère chiffré, lui ne dépend d'aucun outil.

---

## CONSIGNE DE REPRISE — 2 : les trois dates sont maintenant possibles

**Oublie la réponse précédente qui limitait à deux dates.** Le propriétaire a tranché
autrement : la date de confirmation ne doit pas remplacer la date de livraison prévue.

La **tâche 13 est faite et commitée** (`b233c10`). Le serveur a désormais deux dates
distinctes :

| Champ Django | Ce que c'est | Qui l'écrit |
|---|---|---|
| `date_arrivee_echantillon` | la date de livraison **prévue** | le collecteur, à l'enregistrement. Plus rien ne l'écrase. |
| `date_reception_echantillon` | la date d'arrivée **réelle** | le bouton de confirmation de réception |
| `date_ajout` | la date de saisie dans l'application | automatique |

Le contournement du service collecteur a été supprimé : chaque date vient de son propre champ.

### Les trois choix demandés sont donc tous disponibles

Reprends la consigne d'origine telle qu'elle est écrite plus haut, avec les **trois** types :

| Choix proposé à l'utilisateur | Champ lu |
|---|---|
| « Date d'enregistrement » | `date_ajout` |
| « Livraison échantillon » | `date_arrivee_echantillon` |
| « Réception physique » | `date_reception_echantillon` |

Les trois ont maintenant un vrai contenu. Aucun ne ment.

### Ce qui ne change pas

1. **Un seul `DateFilterSheet`.** Critère chiffré inchangé : à la fin,
   `grep -rl "class DateFilterSheet" lib --include=*.dart | wc -l` doit renvoyer **1**.

2. Les trois choix vont sur les **six pages** du dégustateur et du chef dégustateur :
   gestion des échantillons, évaluation des échantillons, analyses laboratoire.

3. **Ne casse pas la direction ni le collecteur.** Ils utilisent le même widget et la valeur
   `arriveeStock` en plus. Garde-la dans l'enum et laisse chaque page choisir ce qu'elle
   propose, via `availableTypes`.

4. **Supprime les deux copies** du filtre. Avant de supprimer, prouve avec `grep` que plus
   personne ne les importe et donne le résultat brut.

5. **Le point 6 de la consigne d'origine est réglé par la tâche 13** : le mapping des dates est
   corrigé, `livraisonEchantillon` lit maintenant un champ réellement rempli. Tu n'as plus rien
   à faire de ce côté.

6. **Aucune migration, aucun changement Django.** Tout ce qu'il fallait côté serveur est déjà
   fait.

### Sur les tests

Pas de test d'écran sur les pages du collecteur, ils ne se stabilisent jamais. Si tu as de la
logique à vérifier — « telle date choisie, tel champ comparé, tel échantillon retenu » — sors-la
dans une fonction pure de `lib/core/utils/` et teste-la là. C'est ce qui a marché en tâche 07.

### Vérification

```bash
flutter analyze lib test
flutter test
```

Référence : **50 problèmes, 0 erreur** ; **101 tests réussis** avec le seul échec connu
`test/widget_test.dart`.

---

## CONSIGNE DE REPRISE — 3 : nom clair pour "Arrivée du stock", indication sous chaque
## choix, et 4ᵉ type pour le collecteur

Trois ajouts au-dessus de tout ce qui précède. Fais-les avec le reste de la tâche, pas
séparément.

### 1. Renomme `DateFilterType.arriveeStock`

Le mot "Arrivée" laisse croire qu'une arrivée réelle est constatée par quelqu'un. Ce n'est
pas le cas : ce type lit une date **prévue par le collecteur** au moment de la négociation
(`echantillon.livraison?.dateExacte`, voir `mes_echantillons_page.dart` ~L150), jamais une
confirmation.

Dans `DateFilterTypeX` (`lib/1_ceo/widgets/search_date_filter_bar.dart` L18-40) :

| Valeur | Ancien `label` | Nouveau `label` | Nouveau `shortLabel` |
|---|---|---|---|
| `arriveeStock` | Arrivée du stock | Livraison du stock | Livraison stock |

Les trois autres libellés ne changent pas.

### 2. Une phrase d'aide sous chaque choix, dans `DateFilterSheet`

Dans le sélecteur de type (`_hasTypeSelector`, ~L301-350), sous la ligne de puces
(`widget.availableTypes.map(...)`), affiche la phrase correspondant au type **actuellement
sélectionné** (`_selectedType`) :

| Type | Phrase d'aide |
|---|---|
| `enregistrement` | Cherche les échantillons enregistrés à une date précise. |
| `livraisonEchantillon` | Cherche les échantillons que vous prévoyez de livrer à une date précise. |
| `receptionPhysique` | Cherche les échantillons réellement arrivés à l'entreprise. |
| `arriveeStock` | Cherche les dates auxquelles vous prévoyez de livrer le stock acheté. |

Un `Text` simple sous les puces suffit, même style discret que le reste de la feuille (gris,
petite taille).

### 3. Le collecteur obtient aussi "Réception physique"

`mes_echantillons_page.dart` (`_showDateFilter`, ~L583-587) ne propose aujourd'hui que
`enregistrement`, `livraisonEchantillon`, `arriveeStock`. Ajoute `receptionPhysique` comme
4ᵉ choix — le modèle `EchantillonCollecteur` porte déjà `dateReceptionEchantillon`
(`lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart` L112).

Branche-le dans le `switch` qui résout le champ à comparer (~L144-151), à côté des trois cas
existants :

```
case DateFilterType.receptionPhysique:
  raw = e.dateReceptionEchantillon;
```

### Vérification

```bash
flutter analyze lib test
flutter test
```

Même référence que ci-dessus. Donne les sorties chiffrées réelles dans ton rapport.

## RAPPORT

### Fait

- Créé `lib/core/widgets/search_date_filter_bar.dart` : tous les rôles utilisent maintenant le même `DateFilterType`, le même bouton calendrier et le même `DateFilterSheet`; `arriveeStock` affiche désormais « Livraison du stock » / « Livraison stock » et chaque type affiche sa phrase d'aide.
- Créé `lib/core/utils/date_filter_utils.dart` : les comparaisons de date exactes/périodes sont unifiées dans une fonction pure commune.
- Créé `test/date_filter_utils_test.dart` : tests unitaires prévus pour vérifier la comparaison inclusive et le choix du champ pour gestion, évaluation et analyse labo.
- Modifié `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart` : le dégustateur peut filtrer la gestion par date d'enregistrement, livraison échantillon ou réception physique.
- Modifié `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart` : le chef obtient les mêmes trois choix et la même logique que le dégustateur.
- Modifié `lib/3_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart` : l'évaluation dégustateur filtre sur les trois dates communes.
- Modifié `lib/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart` : l'évaluation chef filtre sur les trois dates communes.
- Modifié `lib/3_degustateur/analyse_labo/analyse_laboratoire_page.dart` : l'analyse labo dégustateur utilise l'enum commun au lieu des anciennes clés texte.
- Modifié `lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart` : l'analyse labo chef propose les mêmes trois dates que le dégustateur.
- Modifié `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` : le collecteur conserve ses filtres existants et gagne le choix « Réception physique ».
- Modifié `lib/core/models/echantillon.dart` : le modèle partagé distingue maintenant `date_arrivee_echantillon` et `date_reception_echantillon`.
- Modifié `lib/core/services/gestion_echantillons_service.dart` : la date de réception physique venant de l'API arrive jusqu'au modèle de gestion.
- Modifié `lib/core/models/echantillon_evaluation.dart` : le modèle liste d'évaluation porte les trois dates nécessaires au filtre.
- Modifié `lib/core/services/evaluation_service.dart` : les pages d'évaluation reçoivent `date_ajout`, `date_arrivee_echantillon` et `date_reception_echantillon`.
- Modifié `lib/core/models/mock_echantillons_evaluation.dart` : les scénarios de secours des pages d'évaluation restent filtrables.
- Modifié `lib/core/models/mock_echantillons_gestion.dart` : les scénarios de secours de gestion incluent des dates de réception physique.
- Modifié `lib/core/analyses/ligne_analyse_labo.dart` : la ligne analyse labo porte aussi la date de livraison échantillon.
- Modifié `lib/core/analyses/ligne_analyse_labo_service.dart` : l'analyse labo sépare livraison prévue et réception physique quand l'API fournit les champs.
- Modifié `lib/1_ceo/utilisateurs/models/echantillon_ceo_view.dart` : la vue CEO peut porter la date de réception physique sans casser les filtres existants.
- Modifié `lib/1_ceo/echantillons/services/echantillon_ceo_service.dart` : la date de réception physique est lue depuis l'API pour la vue CEO.
- Modifié `lib/1_ceo/echantillons/echantillons_ceo_page.dart` : la page CEO reste compatible avec `DateFilterType.values`, qui contient maintenant `receptionPhysique`.
- Modifié `lib/1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart` : le switch CEO connaît le nouveau type commun sans changer ses choix visibles.
- Modifié `lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart` : le switch CEO connaît le nouveau type commun sans changer ses choix visibles.
- Modifié `lib/1_ceo/achats_confirmes/achats_confirmes_ceo_page.dart` : le switch CEO connaît le nouveau type commun sans changer ses choix visibles.
- Modifié `lib/1_ceo/validation_achats/validation_achats_ceo_page.dart` : l'import du filtre date pointe vers `core`.
- Modifié `lib/1_ceo/tableau_de_bord/tableau_de_bord.dart` : le dashboard CEO utilise le `DateFilterSheet` commun.
- Modifié `lib/3_degustateur/sessions_degustation/sessions_degustation_page.dart` : l'import du filtre date pointe vers `core`.
- Modifié `lib/3_degustateur/tableau_de_bord/widgets/home_body.dart` : le dashboard dégustateur utilise le `DateFilterSheet` commun.
- Modifié `lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart` : l'import du filtre date pointe vers `core`.
- Modifié `lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart` : le dashboard chef utilise le `DateFilterSheet` commun.
- Modifié `lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart` : la vue d'ensemble utilise le `DateFilterSheet` commun.
- Supprimé `lib/1_ceo/widgets/search_date_filter_bar.dart` : l'ancien emplacement CEO ne déclare plus de filtre dupliqué.
- Supprimé `lib/core/widgets/search_filter_bar.dart` : l'ancienne copie core ne déclare plus de filtre date séparé.
- Supprimé `lib/5_chef_degustateur/gestion_echantillons/widgets/search_filter_bar.dart` : l'ancienne copie chef ne déclare plus de filtre date séparé.

### Vérifié

```bash
(rg -l "class DateFilterSheet" lib -g "*.dart").Count
```

Sortie brute :

```text
1
```

```bash
rg -l "class DateFilterSheet" lib -g "*.dart"
```

Sortie brute :

```text
lib\core\widgets\search_date_filter_bar.dart
```

```bash
rg -n "search_filter_bar|1_ceo/widgets/search_date_filter_bar|gestion_echantillons/widgets/search_filter_bar" lib test
```

Sortie brute : aucune sortie, exit code 1.

```bash
grep -rl "class DateFilterSheet" lib --include=*.dart | wc -l
```

Sortie brute :

```text
      1 [main] grep (25048) C:\Program Files\Git\usr\bin\grep.exe: *** fatal error - CreateFileMapping S-1-5-21-2378039868-576862018-1579538929-1001.1, Win32 error 5.  Terminating.
      0 [main] wc (26096) C:\Program Files\Git\usr\bin\wc.exe: *** fatal error - CreateFileMapping S-1-5-21-2378039868-576862018-1579538929-1001.1, Win32 error 5.  Terminating.
```

```bash
git diff --check
```

Sortie brute : exit code 0, seulement des avertissements `LF will be replaced by CRLF`.

```bash
dart format lib test
```

Sortie brute :

```text
command timed out after 120106 milliseconds
```

```bash
dart format <fichiers modifiés>
```

Sortie brute :

```text
command timed out after 120133 milliseconds
```

```bash
dart format test/date_filter_utils_test.dart
```

Sortie brute :

```text
command timed out after 30118 milliseconds
```

```bash
flutter analyze lib test
```

Sortie brute :

```text
command timed out after 300112 milliseconds
```

```bash
flutter test test/date_filter_utils_test.dart
```

Sortie brute :

```text
command timed out after 180143 milliseconds
```

```bash
flutter --version
```

Sortie brute :

```text
command timed out after 60054 milliseconds
```

### Non fait

- `flutter analyze lib test` et `flutter test` n'ont pas produit de chiffres : les commandes Flutter/Dart expirent dans cet environnement, y compris `flutter --version`. Les processus Dart restants après expiration ont été arrêtés.

### HORS PÉRIMÈTRE

- `backend_new/analyses/serializers.py` expose `date_arrivee` / `date_arrivee_echantillon`, mais pas `date_reception_echantillon` dans `LabEchantillonAnalyseSerializer`. Le frontend lit `date_reception_echantillon` quand il est fourni, mais je n'ai pas modifié Django car la consigne dit explicitement : aucune migration, aucun changement Django.

### Complément — vérification par Claude

Deux lancements de Codex se sont bloqués avant de produire ce diff (0% d'activité, aucun
fichier modifié) et ont été arrêtés puis relancés ; le rapport ci-dessus vient de la
troisième tentative, qui a bien édité le code.

Un `dart format lib test` lancé par erreur sur tout le dépôt a reformaté 92 fichiers hors du
périmètre de cette tâche (le reste du projet n'avait jamais été passé au formateur). Ces
92 fichiers ont été restaurés (`git checkout`) pour ne garder que les 33 fichiers réellement
touchés par la tâche 09.

Claude a ensuite vérifié :

```bash
flutter analyze lib test
```
Sortie brute (première passe) : `50 issues found. (ran in 60.2s)` — un `curly_braces_in_flow_control_structures`
en trop dans le nouveau `date_filter_utils.dart` (un `if` sans accolades). Corrigé.

```bash
flutter analyze lib test
```
Sortie brute (après correction) : `49 issues found. (ran in 4.7s)` — 0 erreur, conforme à la
référence après la tâche 18.

```bash
flutter test
```
Sortie brute : `108 tests`, **107 réussis**, 1 échec déjà connu
(`test/widget_test.dart: Counter increments smoke test`). Les 5 tests supplémentaires
viennent du nouveau `test/date_filter_utils_test.dart`. Aucune régression.

`grep -rl "class DateFilterSheet" lib --include=*.dart | wc -l` revérifié par Claude : `1`.
