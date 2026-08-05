# Protocole d'exécution — à lire avant chaque tâche

Tu es l'**exécuteur**. Claude est le planificateur et le relecteur. Ce fichier fixe les
règles qui valent pour toutes les tâches, sans exception.

---

## 1. Comment se déroule une tâche

1. Tu reçois un fichier `files/taches/NN-titre.md`. Il contient une section `## CONSIGNE`.
2. Tu lis `CLAUDE.md` à la racine du projet. Ses deux règles priment sur tout le reste.
3. Tu exécutes **uniquement** ce que la consigne demande.
4. Tu écris ton compte rendu **dans le même fichier**, sous `## RAPPORT`.
5. Tu ne commites jamais. Claude relit le diff et commite lui-même.

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
   ./backend_new/venv/Scripts/python.exe backend_new/manage.py test --keepdb
   ```

   La suite Django prend environ **3 minutes 30** sans `--keepdb`. Ne conclus pas à un
   blocage avant 400 secondes.

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
