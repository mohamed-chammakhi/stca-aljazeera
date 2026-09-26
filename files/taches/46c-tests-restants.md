# Tâche 46c — Tests restants (aucun changement de comportement)

Lis `files/taches/PROTOCOLE.md`, puis `CLAUDE.md`. **Tests seulement** : ne modifie pas
`lib/` sauf pour rendre un service injectable si un test l'exige (sans changer le
comportement par défaut). Fichiers en **UTF-8 sans BOM**, via `apply_patch`.

1. **Déconnexion** (tâche 46 A) : test widget — après la déconnexion partagée, la pile de
   navigation ne contient plus que la page de connexion, et le minuteur de 30 s d'une page
   précédente ne s'exécute plus.
2. **Photo** : tests Flutter avec un faux `ApiClient` / faux service :
   - `GestionEchantillonsService.createEchantillon` avec `photoAEnvoyer` → appel
     `postMultipart` ; sans photo → `post` JSON ;
   - `GestionEchantillonsService.updateEchantillon` avec `photoAEnvoyer` → `patchMultipart` ;
     sans photo → `patch` JSON ;
   - collecteur : `EchantillonCollecteurService.updateEchantillonWithImage` → `patchMultipart`.

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera `flutter analyze lib
test` et `flutter test`.

## RAPPORT
