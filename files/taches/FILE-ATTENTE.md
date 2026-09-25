# File d'attente — l'ordre des travaux

Règle : **on finit toujours la tâche du haut avant de commencer la suivante.**
Une nouvelle demande de la propriétaire va **en bas** de la liste, jamais devant une
tâche déjà commencée. Une tâche n'est « terminée » que quand elle est vérifiée
(`flutter analyze`, `flutter test`), approuvée par la propriétaire et commitée.

Claude tient cette liste à jour. Codex ne travaille que sur la tâche marquée « EN COURS ».

| # | Demande | Qui | État |
|---|---------|-----|------|
| 1 | Dates de livraison sur la carte dégustateur / chef | Claude | Terminée et commitée |
| 2 | Suppression des données de démonstration | Claude | Terminée et commitée |
| 3 | Tâche 36 : session expirée, photo en grand, suggestions, bouton Ajouter | Codex | Terminée et commitée |
| 4 | Écran rouge en cherchant par date (collecteur, « Jour exact ») | Claude | Terminée et commitée |
| 5 | Tâche 37 : les formulaires ne se ferment plus en touchant à côté | Codex | Terminée et commitée |
| 6 | Rester connecté : 8 h sans utilisation, puis reconnexion | Claude | Terminée et commitée |
| 7 | Tâche 38 : suggestions fournisseur / variété visibles + ordre réf, citerne, quantité, variété | Codex | Terminée et commitée |
| 8 | Suppression des données d'essai de la base (4 fournisseurs, 5 échantillons) — sauvegarde : `backend_new/sauvegarde_avant_nettoyage_2026-09-25.json` | Claude | Terminée |
| 9 | Tâche 39 : plus de fenêtre « fournisseurs proches », référence avec le nom, fenêtre « ancienne / nouvelle référence » en modification | Codex | Terminée et commitée |
| 10 | Message « Impossible de charger les données » remplacé : cause claire (session, serveur) ; liste vide = « le système est tout neuf » | Claude | Terminée et commitée |
| 11 | Tâche 40 : (1) variété même couleur que les autres champs ; (2) suggestions limitées aux fournisseurs / variétés du collecteur ; (3) titres et indications plus foncés ; (4) obligatoires = 1 bouteille, fournisseur, référence ; (5) nom du fournisseur au lieu de F-000x | Codex | Terminée et commitée |
| 12 | Tâche 41 : filtre « Livraison échantillon » = date annoncée même après achat conclu ; fenêtres d'erreur du changement de mot de passe ; numéro après 2026/9999 → 2026/10000 (bug de tri) | Codex | Terminée et commitée |
| 13 | Tâche 42 : mot de passe oublié — code à 6 chiffres envoyé à l'email du compte, 15 min, 4 essais | Codex | Terminée et commitée — adresse d'envoi à configurer (docs/MISE-EN-SERVICE.md) |
| 14 | Tâche 43 : fournisseur = nom + gouvernorat + délégation (« hami — Gabès »), deux homonymes restent distincts ; suppression du code fournisseur F-000x | Codex | Limite Codex atteinte — relance automatique à 23h33 (suppression du code confirmée le 25/09) |
| 15 | Tâche 44 : messagerie — citer une bouteille : recherche sur le serveur (tous les champs), 15 plus récentes, détails (référence, fournisseur, lieu, citerne, quantité, variété), fenêtre qui ne passe plus sous la barre du téléphone | Codex | En attente (après 43) |
| 16 | Mot de passe du compte direction@stca.tn remis à « test123 » | Claude | Terminée |
| 17 | Tâche 45 : message vertical → bandeau 3 s ; compteurs « total » retirés (tous rôles) ; phrase « Consultation seule » retirée ; Utilisateurs : toucher = fiche, statut dans la fiche, date lisible ; utilisateur supprimé gardé dans la liste ; profil : retour au tableau de bord + « Mot de passe oublié ? » | Codex | En attente (après 44) |
| 18 | Chef : tableau de bord « Bad state: No element » + « Un problème est survenu » sur Gestion des échantillons (classification vide) | Claude | Terminée et commitée |
| 19 | Deux comptes de test : test1@stca.tn et test2@stca.tn (dégustateurs, mot de passe test123) | Claude | Terminée |
| 20 | Tâche 46 : déconnexion qui ferme tout ; valeurs vides sans plantage ; suggestions dégustateurs ; enregistrement impossible en dégustateur ; formulaire dégustateur = collecteur (+ collecteur facultatif avec suggestions) ; évaluation (numéro, date, photo, débordement) ; textes longs ; sessions (obligatoires, date) ; chef : sans Membres du panel, Utilisateurs inchangée sauf total, rôle en liste, fenêtre de succès, email unique ; mot de passe généré envoyé par email | Codex | En attente (après 45) |

**Accord git (25/09/2026) :** la propriétaire a donné son accord pour commiter les
lignes 1 à 6 en une seule fois, quand la tâche 37 est finie et que `flutter analyze` +
`flutter test` passent. Si un test échoue, on corrige d'abord, on ne commite pas.

## Prochaines demandes

Écris une demande par ligne, dans l'ordre voulu. Claude en fait une tâche, dans l'ordre.
Pendant la nuit, voir `BOUCLE-NUIT.md`.

*(vide)*
