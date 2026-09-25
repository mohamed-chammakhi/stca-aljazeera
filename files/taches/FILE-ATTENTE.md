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

**Accord git (25/09/2026) :** la propriétaire a donné son accord pour commiter les
lignes 1 à 6 en une seule fois, quand la tâche 37 est finie et que `flutter analyze` +
`flutter test` passent. Si un test échoue, on corrige d'abord, on ne commite pas.

## Prochaines demandes

*(vide)*
