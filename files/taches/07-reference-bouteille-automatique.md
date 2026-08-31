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
