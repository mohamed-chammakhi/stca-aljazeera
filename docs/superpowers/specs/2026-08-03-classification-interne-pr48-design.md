# Classification sensorielle interne PR-48 — Design

**Date :** 2026-08-03
**Source :** PR-48 « Classification sensorielle interne de l'huile d'olive », VER 00, 15/05/2026
**Portée :** formulaire d'évaluation organoleptique, tous dégustateurs (rôles `3_degustateur` et `5_chef_degustateur`), plus l'affichage lecture seule côté CEO.

---

## 1. Objectif

Le formulaire d'évaluation actuel n'affiche qu'une seule classification : la catégorie
réglementaire COI (Extra Vierge / Vierge / Vierge Ordinaire / Lampante).

Le PR-48 ajoute une **seconde couche, interne à l'entreprise** : une fois qu'une huile est
confirmée extra vierge, le panel la range dans une classe maison (Extra A+ → Extra C) selon
son profil positif — fruité, amertume, piquant.

Ce document décrit comment les deux couches cohabitent dans l'application.

## 2. Décisions validées avec le propriétaire du projet

| Question | Décision |
|---|---|
| Échelle des attributs positifs | **0 → 5**, pas de 0,5 (le PR-48 raisonne sur cette échelle) |
| Échelle des défauts | **0 → 10**, inchangée (le PR-48 n'en parle pas ; échelle COI) |
| Qui voit la classe interne | **Dégustateur ET chef dégustateur** |
| Type de fruité | **3 valeurs** : Vert / Vert-mûr / Mûr (aujourd'hui : booléen 2 valeurs) |
| Cas non couverts par la grille | Le dégustateur **choisit la classe à la main** dans une liste. Chaque dégustateur le fait pour sa propre fiche, chef inclus. |
| Critère « profil harmonieux » (§8, §9), non chiffré dans le PR-48 | **Case à cocher** « profil non harmonieux » proposée sur les deux classes hautes. Cochée, elle renvoie vers le choix manuel. L'app n'invente aucun seuil d'harmonie. |
| Anciennes données 0–10 | Sans objet : la table `evaluations_evaluationorganoleptique` est **vide** (vérifié le 2026-08-03). |

## 3. Les deux niveaux

### Niveau 1 — Classification COI (inchangée)

Calculée depuis la médiane des défauts et le fruité. Aucun seuil ne change.

| Condition | Classe |
|---|---|
| médiane défauts = 0 et fruité > 0 | Extra Vierge |
| 0 < médiane défauts ≤ 3,5 et fruité > 0 | Vierge |
| 3,5 < médiane défauts ≤ 6, ou fruité = 0 | Vierge Ordinaire |
| médiane défauts > 6 | Lampante |

La médiane des défauts reste le **maximum** des six défauts perçus, sur l'échelle 0–10.

### Niveau 2 — Classe interne PR-48

**Condition préalable (PR-48 §6) :** le niveau 1 doit valoir **Extra Vierge**. Si ce n'est pas
le cas, le bloc « classe interne » est affiché grisé, non modifiable, avec le message :

> Classification interne non applicable — réservée aux huiles extra vierges (PR-48 §6).

Aucune classe interne n'est alors enregistrée (`classe_interne` reste vide).

## 4. Grille de décision

Les lignes sont testées **de haut en bas**. La première qui correspond intégralement gagne.
Cet ordre est la règle de résolution des chevauchements du PR-48 §8 ; il est documenté ici
parce que le document source ne le précise pas.

| # | Classe | Fruité (0–5) | Type de fruité | Amertume (0–5) | Piquant (0–5) |
|---|---|---|---|---|---|
| 1 | **Extra A+** | ≥ 5 | Vert | > 3 et < 4,5 | ≥ 3 et ≤ 5 |
| 2 | **Extra A** | > 3,5 et < 4,5 | Vert | > 2,5 et < 4 | ≥ 2,5 et ≤ 5 |
| 3 | **Extra B+** | ≥ 3 et ≤ 3,5 | Vert | > 2,5 et < 3,5 | ≥ 3 et ≤ 5 |
| 4 | **Extra B** | ≥ 2,5 et ≤ 3 | Vert ou Vert-mûr | > 2,5 et < 3,5 | ≥ 2 et ≤ 3,5 |
| 5 | **Extra B−** | ≤ 2 | Mûr | ≤ 2,5 | ≤ 2,5 |
| 6 | **Extra C** | ≤ 2 | indifférent | ≤ 2 | ≤ 2 |

Effets de l'ordre descendant :

- fruité **exactement 3** → Extra B+ (ligne 3 rencontrée avant la ligne 4)
- fruité 1,5 / amertume 1,5 / piquant 1,5, type Mûr → Extra B− (ligne 5 avant la ligne 6)

L'échelle étant plafonnée à 5, la ligne 1 se lit « fruité au maximum ».

### Le critère non chiffré : profil harmonieux

Le PR-48 §8 ajoute à Extra A+ un quatrième critère, « **Profil harmonieux** », et le §9
(« Priorité à l'équilibre ») interdit les deux classes hautes à une huile « si un attribut
domine fortement les autres ». **Aucun chiffre n'est donné** pour mesurer cette domination.

L'application n'invente pas de seuil. À la place : lorsque la grille rend **Extra A+ ou
Extra A**, une case à cocher apparaît sous la classe :

> ☐ Profil non harmonieux — un attribut domine les autres (PR-48 §9)

Cochée, la classe automatique est annulée : la fiche bascule en « hors grille » (§5) avec le
motif « Profil non harmonieux (§9) », et le dégustateur choisit une classe dans la liste
manuelle — **privée d'Extra A+ et d'Extra A**, puisque le §9 les interdit dans ce cas.

Décochée, rien ne change. La case n'apparaît pas sur les classes B+ et inférieures : le §9 ne
vise que les deux classes hautes (nommées « Extra+ » et « Extra bonne » dans une version
antérieure du document, qui subsiste au §6).

## 5. Cas hors grille

Le PR-48 §8 laisse des intervalles sans classe. Exemples réels :

| Fruité | Type | Amertume | Piquant | Pourquoi aucune ligne ne colle |
|---|---|---|---|---|
| 4,7 | Vert | 3,5 | 4 | Extra A s'arrête sous 4,5 ; Extra A+ démarre à 5 |
| 2,3 | Vert | 3 | 3 | Extra B démarre à 2,5 ; Extra B− plafonne à 2 |
| 5 | Vert | 3,0 pile | 4 | Extra A+ exige amertume **strictement** > 3 |
| 2 | Vert | 4,5 | 5 | amertume et piquant écrasent le fruité (cas §9) |

S'y ajoute un cinquième déclencheur : la case « profil non harmonieux » cochée sur une
Extra A+ ou une Extra A (voir §4).

**Comportement :** le formulaire affiche un badge orange **« Hors grille »** accompagné du
motif calculé (ex. « Fruité 4,7 : entre Extra A et Extra A+ »), et un bouton **« Choisir la
classe »** ouvrant une liste :

Extra A+ · Extra A · Extra B+ · Extra B · Extra B− · Extra C · **Extra déséquilibrée**

`Extra déséquilibrée` est citée aux §6 et §9 du PR-48 mais absente du tableau §8. Elle
n'existe donc **que** par choix manuel — aucune règle automatique ne l'attribue, faute de
seuil chiffré dans le document source. Le quatrième exemple ci-dessus (fruité 2 / amertume
4,5 / piquant 5) tombe naturellement hors grille et devient donc sélectionnable en
« Extra déséquilibrée », conformément au §9.

Une classe choisie manuellement porte une pastille **« Choisie manuellement »** avec le nom
du dégustateur et la date, pour la traçabilité exigée au §14.

Le choix manuel n'est proposé **que** lorsque la grille ne rend aucune classe. Quand une
ligne correspond, la classe est automatique et non modifiable.

## 6. Effet de bord du changement d'échelle — corrigé

Trois helpers sont codés en dur sur 0–10 et deviendraient faux pour les attributs positifs :

| Helper | Emplacement actuel | Problème sur 0–5 |
|---|---|---|
| `_intensiteLabel` | `3_degustateur/.../formulaire_evaluation.dart:160`, `5_chef_degustateur/.../evaluation_slider.dart:29` | Délicat ≤3 / Moyen ≤6 / Robuste >6 → un fruité à 5/5 afficherait « Moyen », rien ne serait jamais « Robuste » |
| `_sliderPositifColor` | `evaluation_slider.dart:44` | mêmes seuils 3 et 6 → un fruité excellent garde la couleur du milieu |
| `_sliderColor` | `formulaire_evaluation.dart:243`, `evaluation_slider.dart:37` | s'applique aux défauts, reste sur 3 et 6 — **inchangé** |

Nouveaux seuils, **attributs positifs uniquement** : Délicat ≤ 1,5 · Moyen ≤ 3 · Robuste > 3.

En dehors de ça, les deux échelles ne se rencontrent jamais : aucune formule ne met un
attribut positif et un défaut dans la même opération (vérifié côté Dart et côté Django), la
classification COI ne teste le fruité que comme « > 0 », et la grille PR-48 exige défauts = 0.

## 7. Architecture — où vit le code

Le projet applique la règle « même chose = même nom, un seul fichier » (CLAUDE.md). La logique
de classification est aujourd'hui **dupliquée trois fois** ; c'est précisément le motif qui a
déjà produit un bug en production sur ce projet.

### Nouveau — logique partagée

**`lib/core/classification/classification_interne.dart`** — fichier pur, sans widget :

- `const double kMaxPositif = 5.0;` · `const double kMaxDefaut = 10.0;` · `const double kPasSlider = 0.5;`
- `ClassificationHuile calculerClassificationCoi({required double medianeDefauts, required double fruite})`
  — extraite des trois copies existantes
- `ClasseInterne? calculerClasseInterne({required ClassificationHuile coi, required double fruite, required TypeFruite typeFruite, required double amertume, required double piquant, bool profilNonHarmonieux = false})`
  — retourne `null` quand aucune ligne ne correspond, quand `coi != extraVierge`, ou quand
  `profilNonHarmonieux` annule une Extra A+ / Extra A
- `bool classeSoumiseAHarmonie(ClasseInterne c)` — vrai pour `extraAPlus` et `extraA`
- `List<ClasseInterne> classesChoisissablesManuellement({required bool profilNonHarmonieux})`
  — la liste complète, privée d'Extra A+ et d'Extra A quand le profil est déclaré non harmonieux
- `String motifHorsGrille({...})` — texte explicatif affiché sous le badge « Hors grille »
- `String intensiteLabel(double valeur, {required bool positif})`

**`lib/core/widgets/carte_classification.dart`** — la carte à deux niveaux, consommée par les
deux formulaires et par la feuille CEO en lecture seule.

**`lib/core/models/enums.dart`** — ajout de `ClasseInterne` et `TypeFruite`, avec leurs
extensions `toJson` / `label` / `colorValue` / `fromJson`, sur le modèle de
`ClassificationHuile` déjà présent.

### Modifiés — Flutter

| Fichier | Changement |
|---|---|
| `lib/core/models/evaluation_organoleptique.dart` | `fruiteVert` (bool) → `typeFruite` (`TypeFruite`) ; ajout `classeInterne`, `classeInterneManuelle`, `classeInterneMotif` |
| `lib/3_degustateur/evaluation_echantillons/formulaire_evaluation.dart` | sliders positifs 0–5 ; 3 chips de type de fruité ; carte à deux niveaux ; sélecteur manuel ; suppression de la logique COI locale au profit du `core` |
| `lib/5_chef_degustateur/formulaire_evaluation.dart` | idem |
| `lib/5_chef_degustateur/evaluation_echantillons/widgets/evaluation_slider.dart` | seuils d'intensité et de couleur dépendants de l'échelle |
| `lib/5_chef_degustateur/evaluation_echantillons/widgets/classification_card.dart` | remplacée par `core/widgets/carte_classification.dart` |
| `lib/1_ceo/widgets/shared_evaluation_form_sheet.dart` | affiche les deux niveaux en lecture seule ; `fruiteVert` → `typeFruite` |
| `lib/1_ceo/utilisateurs/models/mock_data_patch.dart` | `fruiteVert:` → `typeFruite:` ; notes positives ramenées sur 0–5 |
| `lib/3_degustateur/.../mock_echantillons.dart`, `lib/5_chef_degustateur/.../mock_echantillons.dart`, `lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart` | idem |

Les deux `formulaire_evaluation.dart` restent deux fichiers distincts dans cette itération —
leur fusion complète est un chantier séparé. Ce qui est mutualisé ici, c'est **tout ce qui
décide d'une classification**, c'est-à-dire la partie qui avait dérivé.

### Modifiés — backend Django

**`backend_new/evaluations/models.py`** :

```python
class TypeFruite(models.TextChoices):
    VERT     = 'vert',     'Vert'
    VERT_MUR = 'vert_mur', 'Vert-mûr'
    MUR      = 'mur',      'Mûr'

class ClasseInterne(models.TextChoices):
    EXTRA_A_PLUS       = 'extra_a_plus',       'Extra A+'
    EXTRA_A            = 'extra_a',            'Extra A'
    EXTRA_B_PLUS       = 'extra_b_plus',       'Extra B+'
    EXTRA_B            = 'extra_b',            'Extra B'
    EXTRA_B_MOINS      = 'extra_b_moins',      'Extra B−'
    EXTRA_C            = 'extra_c',            'Extra C'
    EXTRA_DESEQUILIBRE = 'extra_desequilibre', 'Extra déséquilibrée'
```

- `fruite_vert` (BooleanField) → **supprimé**, remplacé par `type_fruite` (CharField, choices, default `vert`)
- ajout `classe_interne` (CharField, choices, blank)
- ajout `classe_interne_manuelle` (BooleanField, default False)
- ajout `classe_interne_motif` (CharField 200, blank) — motif « hors grille » figé au moment du choix
- ajout `classe_interne_choisie_le` (DateTimeField, null, blank) — horodatage du choix manuel.
  Un champ dédié est nécessaire : `date_modification` est en `auto_now` et bougerait à chaque
  enregistrement. Le nom du dégustateur vient du champ `degustateur` déjà présent.
- ajout `profil_non_harmonieux` (BooleanField, default False) — case du §9

**`backend_new/evaluations/classification.py`** — nouveau. Miroir Python de la grille §4,
utilisé pour valider côté serveur ce que le client envoie. La duplication Dart/Python est
assumée : le client doit calculer en direct pendant la saisie, le serveur ne doit pas faire
confiance au client. Les deux implémentations sont couvertes par le même jeu de cas de test.

**Migration `0005_pr48_classification_interne.py`** — ajoute `type_fruite`, recopie
`fruite_vert` (`True` → `vert`, `False` → `mur`) via `RunPython`, supprime `fruite_vert`,
ajoute les trois champs de classe interne. La table est vide en local, mais la recopie est
écrite pour rester correcte sur tout autre environnement.

**`backend_new/evaluations/serializers.py`** — expose les nouveaux champs et valide :

1. `fruite`, `amertume`, `piquant` ∈ [0 ; 5]
2. défauts ∈ [0 ; 10]
3. si la classification COI ≠ `extra_vierge` → `classe_interne` doit être vide
4. si `classe_interne_manuelle` est faux et `classe_interne` non vide → doit être égale au
   résultat de `calculer_classe_interne(...)`
5. si la grille rend une classe, `classe_interne_manuelle` doit être faux
6. si `profil_non_harmonieux` est vrai → `classe_interne` ne peut valoir ni `extra_a_plus`
   ni `extra_a` (PR-48 §9)

## 8. Écran — carte de classification

Une carte, deux blocs empilés, dans le formulaire de dégustation :

```
┌──────────────────────────────────────────────┐
│ CATÉGORIE COI                    Méd. déf 0.0│
│ ● Extra Vierge                                │
│   Médiane défauts = 0.0 et Fruité > 0.0       │
├──────────────────────────────────────────────┤
│ CLASSE INTERNE                        PR-48   │
│ ● Extra A                                     │
│   Fruité 4.0 vert · Amertume 3.0 · Piquant 3.5│
│   ☐ Profil non harmonieux — un attribut       │
│     domine les autres (§9)                    │
└──────────────────────────────────────────────┘
```

La case n'apparaît que sur Extra A+ et Extra A.

Variante hors grille :

```
├──────────────────────────────────────────────┤
│ CLASSE INTERNE                        PR-48   │
│ ⚠ Hors grille                                 │
│   Fruité 4.7 : entre Extra A et Extra A+      │
│              [ Choisir la classe ]            │
└──────────────────────────────────────────────┘
```

Variante non applicable :

```
├──────────────────────────────────────────────┤
│ CLASSE INTERNE                        PR-48   │
│ ○ Non applicable                              │
│   Réservée aux huiles extra vierges (§6)      │
└──────────────────────────────────────────────┘
```

Couleurs des classes internes, dégradé du vert de marque vers le gris :
Extra A+ `#38835A` · Extra A `#4E9A6B` · Extra B+ `#6B8143` · Extra B `#8A9A5B` ·
Extra B− `#A8A878` · Extra C `#9E9E9E` · Extra déséquilibrée `#E64A19` ·
Hors grille `#F57C00`.

## 9. Tests

Même jeu de cas des deux côtés, pour garantir que Dart et Python ne dérivent pas.

**`test/classification_interne_test.dart`** et **`backend_new/evaluations/tests.py`** :

1. un cas nominal par classe (6 cas)
2. les quatre cas hors grille du §5
3. fruité exactement 3 → Extra B+ (et non Extra B)
4. fruité 1,5 tout plat, type Mûr → Extra B− (et non Extra C)
5. défaut non nul → COI ≠ Extra Vierge → classe interne `null`
6. fruité 0 → COI = Vierge Ordinaire → classe interne `null`
7. cas Extra A+ nominal + `profilNonHarmonieux = true` → classe interne `null`, et la liste
   manuelle ne contient ni Extra A+ ni Extra A
8. cas Extra B+ nominal + `profilNonHarmonieux = true` → toujours Extra B+ (le §9 ne vise
   que les deux classes hautes)

**Tests sérialiseur uniquement :** rejet d'un `fruite` à 7 (hors 0–5), rejet d'une
`classe_interne` renseignée alors que le COI vaut `lampante`, rejet d'une `classe_interne`
automatique qui ne correspond pas à la grille, acceptation d'une `classe_interne` manuelle
sur un cas hors grille.

## 10. Hors périmètre

- Fusion complète des deux `formulaire_evaluation.dart`
- Consolidation des médianes du panel par le chef (§10 du PR-48) — le chef voit sa propre
  classe interne comme tout dégustateur ; l'agrégation panel est un chantier distinct
- Registre interne de classification et cahier de dégustation FO-06 (§11)
- Statistiques et suivi de tendance par classe interne (§12)
