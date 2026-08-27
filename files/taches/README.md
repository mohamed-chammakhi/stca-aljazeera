# Les tâches — index et ordre d'exécution

Ce dossier contient les tâches à exécuter une par une. **Lis toujours `PROTOCOLE.md` avant
d'ouvrir une tâche.**

Une tâche = un fichier = un commit relu par le propriétaire du projet.
Tu n'exécutes qu'**une seule tâche à la fois**, et tu ne commites jamais.

---

## État du dépôt — à lire avant de toucher à quoi que ce soit

Le dépôt contient aujourd'hui des **modifications non commitées** appartenant à la tâche 04
(fusion dégustateur / chef dégustateur, étape 4 : les services). Elles sont volontaires et
attendent la relecture du propriétaire.

**Tu ne les annules pas, tu ne les commites pas, tu ne les corriges pas.**
Si `git status` te surprend, c'est normal — continue ta tâche.

La tâche 04 contient aussi une `## QUESTION` déjà répondue et une étape 5 non commencée.
Elle ne fait pas partie de la série 05-12.

---

## Ordre d'exécution

| # | Fichier | Sujet | Dépend de |
|---|---|---|---|
| 05 | `05-recherche-collecteur-libelles.md` | Texte d'aide de la recherche du collecteur | — |
| 06 | `06-photo-et-remarque-par-bouteille.md` | Photo et remarque rattachées à une bouteille précise | — |
| 07 | `07-reference-bouteille-automatique.md` | La référence bouteille s'écrit toute seule | **06** (même fichier) |
| 08 | `08-negociation-en-tonnes.md` | Tonnes, quantité du PDG, prix total, remarque | — |
| 09 | `09-filtre-dates-unifie.md` | Un seul filtre par dates sur les six pages | — |
| 10 | `10-carte-analyse-labo-degustateur.md` | Bouton « Urgent », quantité, numéro d'enregistrement | **09** |
| 11 | `11-supprimer-historique-ancienne-valeur.md` | Supprimer l'historique ancienne / nouvelle valeur | — |
| 12 | `12-notifications-degustateur.md` | Combler les quatre écarts de notifications | — |

Les deux seules dépendances réelles sont **06 avant 07** et **09 avant 10**. Le reste peut être
fait dans n'importe quel ordre.

Ces huit tâches viennent de `docs/retours-utilisation-et-questions.md`, qui est le document
d'origine écrit par le propriétaire après avoir utilisé l'application.

---

## Ce qu'on attend de toi à chaque tâche

1. Lire `PROTOCOLE.md`, puis `CLAUDE.md` à la racine.
2. Lire le fichier de tâche en entier **avant** d'écrire une ligne de code.
3. Exécuter uniquement ce que la consigne demande.
4. Écrire ton rapport dans le même fichier, sous `## RAPPORT`.
5. Ne pas commiter.

---

## Les questions que ces tâches vont probablement déclencher

Elles sont prévues. Quand tu tombes dessus, tu écris la question sous `## QUESTION` et tu
t'arrêtes **pour cette partie seulement** — tu livres tout le reste de la tâche.

| Tâche | Question attendue |
|---|---|
| 08 | Le champ « remarque du collecteur » demande-t-il une migration Django ? |
| 10 | Faut-il ajouter `referenceBouteille` au modèle d'analyse laboratoire côté Django ? |
| 11 | Supprimer `edit_history` du modèle Django produit une migration — la crée-t-on ? |
| 12 | L'évaluation urgente va-t-elle à un seul dégustateur, à tous, et le chef la reçoit-il ? |

**Exception à la règle des migrations :** la tâche 12 t'autorise explicitement à créer la
migration qui ajoute des valeurs au type de notification. Le précédent est établi dans
`backend_new/notifications/migrations/`. Aucune autre migration n'est autorisée sans réponse.

---

## Deux choses à ne jamais oublier

**Le linter de ce projet ne signale pas le code mort.** `unused_import`, `unused_element` et
`unused_local_variable` sont autorisés. Avant de supprimer un fichier, prouve avec `grep` que
plus personne ne l'importe, et donne le résultat brut.

**Un chiffre sans commande derrière est considéré comme faux.** Si tu écris que les tests
passent, donne la commande et sa sortie. La suite Django prend environ 3 minutes 30 sans
`--keepdb` : ne conclus pas à un blocage avant 400 secondes.
