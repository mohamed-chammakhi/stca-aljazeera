# Protocole d'exécution — à lire avant chaque tâche

Tu es l'**exécuteur**. Claude est le planificateur et le relecteur. Ce fichier fixe les
règles qui valent pour toutes les tâches, sans exception.

---

## 1. Comment se déroule une tâche

1. Tu reçois un nom de fichier, `files/taches/NN-titre.md`. **Le message qui te l'envoie ne
   contient rien d'autre. Toutes les règles sont ici, dans ce fichier. Lis-le en entier.**
2. Tu lis `files/taches/README.md` : il donne l'ordre des tâches et l'état du dépôt.
3. Tu lis `CLAUDE.md` à la racine du projet. Ses deux règles priment sur tout le reste.
4. Tu ouvres le fichier de tâche et tu le lis **en entier avant d'écrire une ligne de code**.
   S'il contient déjà un `## RAPPORT` et une section `### RÉPONSE À LA QUESTION`, c'est une
   **reprise** : la réponse t'était destinée, lis-la, et ajoute une section `### Reprise` à
   ton rapport au lieu d'écraser ce qui est écrit.
5. Tu exécutes **uniquement** ce que la consigne demande.
6. Tu écris ton compte rendu **dans le même fichier**, sous `## RAPPORT`.
7. Tu ne commites jamais. Claude relit le diff et commite lui-même.

---

## 2. Le canal de questions — la règle la plus importante

Tu tournes en mode non interactif : tu ne peux pas t'arrêter pour demander.
**Tu ne dois donc jamais deviner.**

Si tu rencontres l'une de ces situations :

- la consigne est ambiguë et deux lectures mènent à des codes différents ;
- il faudrait supprimer ou modifier quelque chose de visible par l'utilisateur, sans que
  la consigne le demande explicitement ;
- tu découvres un défaut réel en dehors du périmètre de la tâche ;
- une des deux règles du `CLAUDE.md` risque d'être enfreinte ;
- il faudrait changer la base de données, une permission, ou une route existante ;

alors :

1. **Tu n'écris aucun code.**
2. Tu écris ta question dans le fichier de tâche sous un titre `## QUESTION`.
3. Tu t'arrêtes.

Une question posée coûte cinq minutes. Une supposition fausse coûte une journée. Sur ce
projet, s'arrêter pour demander a déjà évité trois erreurs.

Tu peux poser plusieurs questions à la fois, numérotées.

---

## 3. Ce que tu ne fais jamais

- **Aucun `git commit`, `git push`, `git reset`, `git checkout` destructif.**
  Tu ne touches pas au dépôt. Claude s'en charge après relecture.
- **Aucune modification du remote.**
- **Rien en dehors du périmètre de la consigne.** Si tu vois un problème ailleurs, tu le
  signales sous `## HORS PÉRIMÈTRE` dans ton rapport, et tu n'y touches pas.
- **Aucune nouvelle bibliothèque d'état** (Provider, Riverpod, BLoC, GetX).
  `StatefulWidget` + `setState()` uniquement.
- **Aucune suppression d'un fichier « inutilisé » sans preuve.** Le linter de ce projet
  autorise `unused_element` et `unused_import` : il ne signale jamais le code mort.
  Vérifie avec `grep` que personne n'importe le fichier.

---

## 4. Ce que ton rapport doit contenir

Sous `## RAPPORT`, dans cet ordre :

1. **Fait** — la liste des fichiers créés, modifiés, supprimés, avec une ligne par fichier
   disant *ce qui change pour l'utilisateur*, pas ce que fait le code.
2. **Vérifié** — les commandes que tu as **réellement exécutées**, avec leur sortie chiffrée :

   ```bash
   flutter analyze lib test
   flutter test
   ```

   Pour la suite Django, **place-toi d'abord dans `backend_new`** :

   ```bash
   cd backend_new
   ./venv/Scripts/python.exe manage.py test --keepdb
   ```

   **Lancée depuis la racine du projet, elle ne teste rien** et affiche `Found 0 test(s)`.
   Mesuré le 27/08/2026 : lancée correctement, elle exécute **158 tests en 800 secondes**.
   Ne conclus pas à un blocage avant 15 minutes.

### Les deux échecs déjà connus

Ces deux-là échouaient avant toi. Ne les corrige pas, ne les compte pas comme une régression,
mais ne t'en sers pas pour couvrir un autre échec.

| Suite | Test | Pourquoi |
|---|---|---|
| `flutter test` | `test/widget_test.dart` — *Counter increments smoke test* | Test modèle livré par Flutter, qui teste un compteur inexistant dans cette application |
| Django | `chef.tests.ChefDashboardApiTests.test_delai_alignement_and_classifications_use_submitted_evaluations` | Échoue sur `extra_vierge` : attendu 3, obtenu 1. Vérifié sur un dépôt sans aucune modification |

État de référence : `flutter analyze lib test` → 50 diagnostics, 0 erreur ;
`flutter test` → 97 réussis, 1 échec ; Django → 158 tests, 1 échec.

3. **Non fait** — tout ce que la consigne demandait et que tu n'as pas fait, avec la raison.
4. **HORS PÉRIMÈTRE** — les problèmes vus ailleurs, non corrigés.

### Règle d'honnêteté

Tu n'écris jamais qu'une chose fonctionne sans avoir exécuté la commande qui le prouve.
Si un test échoue, tu donnes sa sortie exacte. Si tu as sauté une étape, tu le dis.
Un chiffre annoncé sans commande derrière sera considéré comme faux.

Quand tu comptes quelque chose (occurrences, tests, fichiers), **donne la commande et son
résultat brut**. Un décompte partiel présenté comme total a déjà induit une relecture en
erreur.

---

## 5. Le projet en trois lignes

Application multi-rôles de collecte et d'évaluation d'huile d'olive pour **Al Jazeera STCA**
(Tunisie). Interface en **français**. Cinq rôles : direction (`1_ceo/`), collecteur
(`2_collecteur/`), dégustateur (`3_degustateur/`), laboratoire (`4_laboratoire/`), chef
dégustateur (`5_chef_degustateur/`). Backend Django dans `backend_new/`, Python du projet :
`backend_new/venv/Scripts/python.exe`.

Nous sommes en **phase de correction locale**, pas de déploiement. La feuille de route est
dans [`plan_correction.md`](../plan_correction.md).
