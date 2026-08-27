# Tâche 11 — Supprimer l'historique ancienne valeur / nouvelle valeur

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Source de la décision : `docs/retours-utilisation-et-questions.md`, section 6.

---

## Contexte

Une règle avait été décidée au début du projet : une fois l'échantillon reçu physiquement,
chaque modification devait garder l'ancienne valeur à côté de la nouvelle, visible par tous les
rôles.

**Le propriétaire du projet a annulé cette règle.** Sa raison : le collecteur ne peut modifier
ou supprimer un échantillon que **tant qu'il n'est pas reçu physiquement**
(`lib/core/models/echantillon.dart:117-120`, `canModify` / `canDelete` exigent
`!recuPhysiquement` ; le serveur bloque aussi la suppression,
`backend_new/echantillons/views.py:202-206`). Une fois l'échantillon reçu, plus rien ne change.
Il n'y a donc jamais de modification « après coup » à tracer.

### Un fait à connaître : la fonction ne marche déjà pas

Les deux côtés ne parlent pas le même langage.

- Django stocke `edit_history` sous la forme
  `{'horodatage', 'modifie_par', 'modifications': {champ: {'avant', 'apres'}}}`
  (`backend_new/echantillons/views.py:179-188`).
- Flutter attend une liste plate sous la clé `historique`, avec `ancienne_valeur` et
  `nouvelle_valeur` (`lib/core/models/modification_champ.dart:70-85`).
- Le mot `edit_history` **n'apparaît nulle part dans `lib/`**, et le mapper
  `lib/core/services/gestion_echantillons_service.dart:16-51` ne le recopie pas.

Résultat : `Echantillon.fromJson` (`lib/core/models/echantillon.dart:166-168`) reçoit toujours
`null`, et l'historique est vide après chaque rechargement. Seules les lignes créées pendant la
session en cours s'affichent. La suppression demandée n'enlève donc pas une fonction qui
marchait.

---

## Où se trouve le code à supprimer

### Côté Flutter

| Fichier | Ce que c'est |
|---|---|
| `lib/core/models/modification_champ.dart` | Le modèle d'une ligne d'historique (`ancienneValeur` L26, `nouvelleValeur` L27) |
| `lib/core/models/echantillon_historique.dart` | La règle elle-même : liste des 7 champs suivis L19-27, `capturerAvantModification()` L32-40, `enregistrerModifications()` L48-75 avec la condition `if (!recuPhysiquement) return;` L53 |
| `lib/core/models/echantillon.dart:71` | Le champ `List<ModificationChamp> historique` (valeur par défaut L108, lecture JSON L166-168) |
| `lib/core/widgets/historique_modifications.dart` | Le panneau dépliable. Ligne ancienne → nouvelle valeur : `_LigneModification` L118-188, flèche `Icons.arrow_forward` L152 |
| `lib/core/widgets/gestion_echantillons/echantillon_card.dart:433-435` | Le seul endroit où le panneau est affiché |
| `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart:388, 407` | Appels `capturerAvantModification` / `enregistrerModifications` |
| `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart:217, 236` | Les mêmes appels côté chef |

Aucun autre rôle n'affiche l'historique : la direction, le collecteur et le laboratoire n'ont
aucune référence à `HistoriqueModifications` ni à `ModificationChamp`.

### Côté Django

| Fichier | Ce que c'est |
|---|---|
| `backend_new/echantillons/views.py:27-32` | `TRACKED_FIELDS` — les 7 champs suivis |
| `backend_new/echantillons/views.py:160-194` | `perform_update` — construit l'entrée d'historique, condition `if obj.recu_physiquement:` L178 |
| `backend_new/echantillons/models.py:110-111` | `edit_history = models.JSONField(default=list, blank=True)` |
| `backend_new/echantillons/serializers.py` | `'edit_history'` dans `fields` et dans `read_only_fields` |

---

## CONSIGNE

1. Supprimer l'affichage : le panneau `HistoriqueModifications` et son montage dans
   `echantillon_card.dart`.

2. Supprimer la construction de l'historique côté Flutter : les deux fichiers de modèle et les
   quatre appels dans les deux `formulaire_dialog.dart`.

3. Supprimer la construction de l'historique côté Django : `TRACKED_FIELDS` et le bloc
   d'historique dans `perform_update`. **Attention** : `perform_update` fait peut-être d'autres
   choses — ne supprime que le bloc d'historique, garde le reste.

4. **Avant de supprimer un fichier, prouve que plus personne ne l'importe.** Le linter de ce
   projet autorise `unused_import` et `unused_element` : il ne signalera jamais un fichier mort.
   Utilise `grep` et donne le résultat brut dans ton rapport.

5. **Mettre à jour `CLAUDE.md`**, section « Sample States ». Elle contient encore la règle
   inverse :
   « *Edit history rule: Once `recuPhysiquement = true`, any field edit must store the previous
   value. All roles see old + new values.* »
   Cette ligne doit disparaître. Le fichier `CLAUDE.md` guide toutes les sessions futures : le
   laisser faux enverrait l'agent suivant reconstruire ce qu'on vient d'enlever.

6. **Ne touche pas à `recu_physiquement` lui-même.** Il sert à verrouiller l'échantillon contre
   la modification et la suppression, et ce verrou reste. Seul l'enregistrement de l'ancienne
   valeur disparaît.

---

## Le champ de base de données : pose la question

`edit_history` est déclaré sur le modèle Django, **mais aucune migration ne l'ajoute** —
`backend_new/echantillons/migrations/0001_initial.py` ne le contient pas, et une recherche du
mot `edit_history` dans le dossier des migrations ne renvoie rien.

Supprimer le champ du modèle va donc probablement produire une migration.
**Tu ne la crées pas de toi-même.** Écris la question sous `## QUESTION` et arrête-toi là pour
cette partie. Tu peux livrer tout le reste (Flutter, `perform_update`, `CLAUDE.md`) avant de
t'arrêter, et le dire dans ton rapport.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
./backend_new/venv/Scripts/python.exe backend_new/manage.py test --keepdb
```

Donne aussi le résultat brut de la recherche des mots `ModificationChamp`, `historique` et
`edit_history` dans `lib/` et `backend_new/` après ta modification.

Donne les sorties chiffrées réelles dans ton rapport.
