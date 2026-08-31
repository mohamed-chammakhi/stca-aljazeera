# Tâche 06 — Photo et remarque rattachées à une bouteille précise

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Source de la demande : `docs/retours-utilisation-et-questions.md`, points 2.6 et 2.7.

---

## Contexte

Le formulaire d'ajout d'échantillon du collecteur
(`lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart`, 1319 lignes) est
**un seul formulaire** qui contient : un fournisseur, une localisation, et une **liste de
bouteilles** (`List<BouteilleRow> _bouteilles`, L99). Chaque bouteille donne naissance à un
échantillon séparé (`_save()`, L423-456 ; le formulaire l'annonce lui-même à L877 :
« N bouteilles → N échantillons séparés seront créés »).

Deux problèmes.

### Problème 1 — la photo peut créer une bouteille fantôme

La photo est gérée **au niveau du formulaire**, pas au niveau de la bouteille :
`_photoBytes` / `_photoName` (L103-104), `_pickPhoto` (L106-123), zone d'affichage unique en
bas du formulaire (L614-630).

Le rattachement se fait dans `_targetRowForPhoto()` (L127-141) :
- si la première bouteille n'a pas encore de photo, la photo va sur elle ;
- **sinon, la fonction ajoute une bouteille entièrement nouvelle** et met la photo dessus
  (L134-136).

Autrement dit, prendre une deuxième photo crée une bouteille supplémentaire que l'utilisateur
n'a pas demandée, et qui deviendra un échantillon de plus à l'enregistrement. C'est un vrai
défaut, pas une préférence d'affichage.

De plus, l'aperçu (L185-226) ne montre jamais que la dernière photo prise, et `_removePhoto`
(L145-148) n'efface que l'aperçu, pas `row.photoBytes`.

### Problème 2 — la remarque est recopiée sur toutes les bouteilles

Il y a un seul `_remarquesCtrl` (L86, UI L633-690). À l'enregistrement, son contenu est copié
**à l'identique sur chaque échantillon créé** (L445-447). Impossible d'écrire une remarque qui
ne concerne qu'une bouteille.

---

## CONSIGNE

### Partie A — la photo

1. Supprimer le comportement de `_targetRowForPhoto()` qui ajoute une bouteille. Prendre une
   photo ne doit **jamais** créer de bouteille.

2. Appliquer les trois cas décidés par le propriétaire :

   | Situation | Comportement attendu |
   |---|---|
   | Aucune bouteille saisie (aucune ligne remplie) | Afficher le message : « Remplissez d'abord les détails de l'échantillon pour ajouter une photo. » et ne rien attacher. |
   | Une seule bouteille | La photo est attachée à cette bouteille, sans aucune question. |
   | Deux bouteilles ou plus | Ouvrir une fenêtre « À quelle bouteille appartient cette photo ? » listant les bouteilles saisies (utilise leur référence, ou « Bouteille N » si la référence est vide). |

3. Déplacer l'affichage de la photo dans la carte de chaque bouteille, `_BouteilleCard`
   (L907-1057), pour que l'utilisateur voie quelle bouteille a déjà une photo.
   `BouteilleRow` porte **déjà** `photoBytes` et `photoName`
   (`widgets/dialogs/bouteille_row.dart:5-47`) — n'ajoute pas de nouveau champ pour ça.

4. Corriger `_removePhoto` pour qu'il efface bien la photo de la bouteille concernée, pas
   seulement l'aperçu.

### Partie B — la remarque

5. Ajouter un champ remarque **par bouteille** dans `BouteilleRow` (un `TextEditingController`
   de plus, sur le même modèle que `refCtrl`, `varieteCtrl`, `numCiterneCtrl`, `qteCtrl`), et
   l'afficher dans `_BouteilleCard`.

6. À l'enregistrement (`_save()`, L423-456), chaque `EchantillonCollecteur` reçoit **sa
   propre** remarque, plus la remarque globale recopiée.

7. Décision à prendre et à signaler dans ton rapport : garde-t-on aussi le champ remarque
   global du formulaire (L633-690) ? Si tu penses qu'il faut le supprimer, **ne le supprime
   pas** — pose la question sous `## QUESTION`. C'est un élément visible par l'utilisateur.

### Partie C — ne pas casser l'envoi

8. `mes_echantillons_page.dart:708-743` (`onSaveMultiple`) envoie un échantillon par bouteille
   et appaire `photos[i]` avec `nouveaux[i]`. Cette correspondance par index doit rester juste
   après tes changements. Vérifie-la explicitement.

9. Le mode modification (`_save()`, L398-420) n'écrit que `_bouteilles.first`. Ne change pas ce
   comportement dans cette tâche.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Ajoute au moins un test qui prouve que prendre une photo avec deux bouteilles saisies
n'augmente pas la taille de `_bouteilles`.

Donne les sorties chiffrées réelles dans ton rapport.

## QUESTION

`EchantillonCollecteur` ne possède qu'un seul champ `remarques`. La consigne demande que chaque
échantillon reçoive sa remarque propre « plus la remarque globale recopiée », mais ne précise pas
la valeur à enregistrer lorsque les deux sont renseignées : concaténation, ordre et séparateur.

Quel format exact faut-il envoyer dans ce seul champ ? Ajouter une donnée distincte pour la
remarque globale nécessiterait une modification de modèle et probablement une migration, ce qui
n'est pas autorisé sans votre accord.


### RÉPONSE À LA QUESTION

**Une seule remarque, par bouteille.** Pas de concaténation, pas de nouveau champ, pas de
migration.

Concrètement, le point 7 de la consigne est tranché dans ce sens : **la case remarque globale
du formulaire disparaît** (`_remarquesCtrl`, déclaré L86, affiché L633-690, recopié sur tous
les échantillons L445-447). Elle est remplacée par une remarque portée par chaque
`BouteilleRow`, qui va dans le champ `remarques` de l'échantillon créé pour cette bouteille.

C'est exactement ce que demandait le propriétaire : savoir à quelle bouteille appartient une
remarque. Une remarque recopiée à l'identique sur cinq échantillons ne répond à rien.

**Attention au mode modification** (`_save()` L398-420) : il ne traite que `_bouteilles.first`.
La remarque de cette bouteille doit continuer à être lue et réécrite correctement. Ne change
pas le reste de ce mode.

Reprends la tâche 06 en entier, parties A, B et C.

## RAPPORT

### Fait

- Aucun code modifié : attente de la décision sur la représentation des deux remarques dans le
  champ unique existant.

### Vérifié

- Vérifications Flutter non exécutées : la tâche est arrêtée avant toute modification, en attente
  de la réponse à la question ci-dessus.

### Non fait

- Les changements photo, remarque par bouteille et le test demandé ne sont pas réalisés, car la
  règle de non-supposition bloque d'abord la valeur à écrire pour chaque échantillon.

### HORS PÉRIMÈTRE

- Aucun problème hors périmètre corrigé ou modifié.
