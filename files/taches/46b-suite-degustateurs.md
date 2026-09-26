# Tâche 46b — Suite de la tâche 46 (parties non faites)

Lis `files/taches/PROTOCOLE.md` (dont « Même correction pour tous les rôles »), puis
`CLAUDE.md`, puis **`files/taches/46-degustateurs-formulaires-sessions-comptes.md`** : les
parties C à H y sont décrites en détail. Flutter + backend. Pas de migration sauf si une
partie l'exige (alors `## QUESTION`).

Les parties **A, B, I (Membres du panel retiré, rôle en liste) et J** de la tâche 46 sont
faites et commitées. Ne les refais pas.

**Important — encodage** : enregistre tous les fichiers en **UTF-8 sans BOM**. Lors de la
tâche 45, 16 fichiers ont été réenregistrés dans un autre encodage (« é » devenu « Ã© ») :
n'utilise pas `Set-Content` / `Out-File` de PowerShell pour réécrire un fichier ; utilise
`apply_patch`. Vérifie à la fin : `rg -l "Ã©|Ã¨|â”€" lib backend_new --glob '!**/venv/**'`
ne doit rien renvoyer.

**Important — ne laisse jamais un fichier à moitié modifié** : termine une partie avant de
passer à la suivante (si ta limite d'utilisation arrive, le code déjà écrit doit compiler).

## À faire (détails dans la tâche 46)

- **C** — Suggestions fournisseurs / variétés pour dégustateur et chef : toutes les saisies
  (collecteurs, dégustateurs, chef). Vérifie serveur et services, test serveur.
- **D** — Le dégustateur / le chef ne peut pas enregistrer un échantillon (`POST
  /api/echantillons/` → 400) : reproduis avec un test serveur (même contenu que
  `GestionEchantillonsService`), corrige, tests 201 pour les deux rôles.
- **E** — Formulaire d'échantillon du dégustateur / chef aligné sur celui du collecteur
  (photo comprise, mêmes obligations, même ordre, mêmes textes), avec un champ
  **collecteur facultatif** et sa liste de suggestions (collecteurs actifs non supprimés).
- **F** — Page « Évaluation des échantillons » (dégustateur et chef) : **déjà corrigé** :
  numéro 2026/xxxx et date lisible. Reste : l'emplacement photo avec une grande croix
  (image cassée) → emplacement propre `Pas de photo` ou la photo touchable en plein
  écran ; et le **débordement** de la fiche de détail.
- **G** — Textes longs : jamais de débordement. Test « valeurs de 300 caractères » à 360 px
  sur la carte d'échantillon et la fiche de détail d'évaluation.
- **H** — Sessions : obligatoires = titre, date, heure (application **et** serveur) ; date
  de session lisible `JJ/MM/AAAA à HH:MM` partout.
- **I (reste)** — Page Utilisateurs du **chef** : retire seulement le nombre
  d'utilisateurs s'il est encore affiché (cherche dans
  `lib/core/utilisateurs/utilisateurs_page_body.dart` un texte qui compte les
  utilisateurs). Rien d'autre ne change pour le chef.
- **Tests manquants de la 46** : A — après déconnexion, la pile ne contient que la page de
  connexion ; B — un test par modèle avec une énumération `''`.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera les tests Flutter et
Django.

## RAPPORT
