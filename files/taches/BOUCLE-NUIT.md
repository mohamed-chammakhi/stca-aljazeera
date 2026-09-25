# Boucle de nuit — ce que Claude fait à chaque réveil

But : faire avancer `FILE-ATTENTE.md` sans la propriétaire, en consommant peu.
Un réveil = une vérification courte. Pas de relecture complète du projet à chaque fois.

## À chaque réveil

1. **Codex tourne-t-il encore ?** (processus `codex.exe` lancé par Claude, ou fichier
   `files/taches/codex_NN.txt` absent)
   → Oui : se rendormir 25 min. Rien d'autre.

2. **Codex s'est arrêté sur sa limite ?** (sortie contenant `usage limit`, `rate limit`
   ou `try again`)
   → Lire l'heure de retour écrite par Codex. Se rendormir jusqu'à 5 min après
   (max 1 h par réveil, répéter si besoin). Puis relancer **la même tâche** :
   « Reprends la tâche NN là où tu t'es arrêté (le code déjà modifié est dans l'arbre) ».
   Pas d'heure lisible → réessayer toutes les 60 min.

3. **Codex a fini la tâche** →
   - lire son `## RAPPORT` (et `## QUESTION` s'il y en a) ;
   - `flutter analyze lib test` (référence : 55 remarques, 0 erreur) et `flutter test` ;
   - relire le diff des points délicats ; corriger soi-même si ≤ 20 lignes ;
   - vérifier que les autres rôles ont reçu la même correction (règle du PROTOCOLE) ;
   - tout est vert → commit (jamais de push), ligne « Terminée et commitée » dans
     `FILE-ATTENTE.md` et `ETAT.md` ;
   - un test échoue et la correction dépasse 20 lignes → renvoyer à Codex avec l'erreur
     exacte (une fois). Deuxième échec → noter sous « Questions pour la propriétaire » et
     passer à la suivante.

4. **Tâche suivante** : prendre la première ligne non faite de « Prochaines demandes »,
   écrire `files/taches/NN-….md` (même format que les tâches précédentes, avec tous les
   rôles concernés), lancer Codex en arrière-plan avec `< /dev/null`.

5. File vide et Codex arrêté → réveil toutes les 60 min seulement pour voir si la
   propriétaire a ajouté des demandes.

## Serveur du téléphone

Le téléphone parle au serveur lancé depuis `../project3-serveur` (copie git séparée, même
base `backend_new/db.sqlite3`, même dossier `media`), en `--noreload`. Codex travaille dans
`project3/` : ses fichiers à moitié finis ne touchent plus le téléphone.
Après chaque commit vérifié : `git -C ../project3-serveur checkout --detach main`,
sauvegarde de la base, `migrate` depuis `project3-serveur`, puis redémarrage du serveur.

## Ce que Claude ne fait JAMAIS seul la nuit

- Décider une règle métier, un texte vu par les clients finaux, ou un choix que la
  propriétaire n'a pas donné → question notée, tâche mise de côté, on passe à la suivante.
- Supprimer des données de la base, changer les modèles sans que la demande le dise.
- `git push`, `--force`, `git stash`, réécrire l'historique.
- Formater des dossiers entiers (seulement les fichiers de la tâche).

## Questions pour la propriétaire

*(vide)*
