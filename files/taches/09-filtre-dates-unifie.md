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
