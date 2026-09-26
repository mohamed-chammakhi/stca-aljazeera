# Tâche 43 — Un fournisseur = un nom + un lieu ; suppression du code fournisseur

Lis `files/taches/PROTOCOLE.md` (dont « Même correction pour tous les rôles »), puis
`CLAUDE.md`. Backend + Flutter. **Migrations autorisées pour cette tâche.**
À faire **après** les tâches 40, 41 et 42 (elles touchent les mêmes fichiers).

## Note de reprise (26/09/2026)

Une première tentative a été interrompue (erreur 401 de Codex). Son travail partiel,
**backend seulement et sans migration**, est sur la branche
`wip/tache43-codex-interrompue` (commit `aa4bc2ae`) : tu peux le lire avec
`git show wip/tache43-codex-interrompue -- backend_new/` et t'en inspirer, mais repars de
`main` (le code a changé depuis : tâches 47 et 47b, `ref` n'existe plus, `numero` et
`referenceBouteille` partout). Le test de parcours `backend_new/core/tests_parcours.py`
et `test/cablage_api_test.dart` doivent rester verts : régénère les fichiers
`test/fixtures/api/` en relançant le test de parcours si les réponses changent
(le code fournisseur disparaît).

## Le problème

Le serveur relie un échantillon à un fournisseur **par le nom seul**
(`echantillons/serializers.py`, `_supplier_by_name_or_create` : `nom__iexact`). Deux vrais
fournisseurs qui s'appellent tous les deux « hami », l'un à Gabès et l'autre à Sfax,
deviennent donc **un seul** fournisseur, et leurs échantillons sont mélangés.

## Règle de la propriétaire

Un fournisseur, c'est **un nom + un lieu (gouvernorat + délégation)**.

- La liste de suggestions du champ Fournisseur affiche le nom **avec son lieu** :
  `hami — Gabès (El Hamma)`, `hami — Sfax (Sakiet Ezzit)`. Si la délégation est vide :
  `hami — Gabès`. Si le lieu est vide : `hami`.
- Choisir une suggestion remplit le nom **et** le gouvernorat + la délégation du formulaire.
- Si, après avoir choisi « hami — Gabès », la personne change le gouvernorat ou la
  délégation, ce n'est **plus** le même fournisseur : à l'enregistrement, le serveur crée
  (ou retrouve) le fournisseur « hami » avec le **nouveau** lieu.
- Deux fournisseurs différents avec le **même nom au même lieu** (même gouvernorat et même
  délégation) : décision de la propriétaire (25/09/2026) — c'est au collecteur de préciser
  le nom (« hami ben salah », « hami (fils) »). Pas de champ téléphone, pas d'autre
  critère : même nom + même lieu = même fournisseur.
- Pas de fenêtre de confirmation (la fenêtre « fournisseurs proches » a été supprimée en
  tâche 39 et ne revient pas).

## A — Backend

1. `fournisseurs/models.py` : le lieu du fournisseur = `region` (gouvernorat, déjà là) +
   un nouveau champ `delegation` (`CharField(max_length=100, blank=True)`). Migration.
2. Correspondance : `_supplier_by_name_or_create` cherche
   `nom__iexact` **et** `region__iexact` = gouvernorat de l'échantillon **et**
   `delegation__iexact` = délégation de l'échantillon (vides comparés à vides). Pas trouvé →
   nouveau fournisseur avec ce nom et ce lieu. Vérifie d'où viennent `region` et la
   délégation dans les données envoyées (le gouvernorat et la délégation sont saisis dans
   le formulaire d'échantillon) ; en **modification**, garde la règle actuelle (on ne
   change pas le fournisseur si le champ n'est pas envoyé) mais si nom ou lieu changent,
   relie au bon fournisseur selon la même règle.
3. **Données existantes** (migration de données) : pour chaque fournisseur sans lieu,
   remplis `region` / `delegation` avec le gouvernorat / la délégation de ses échantillons.
   S'il a des échantillons dans **plusieurs** lieux différents, sépare-le : un fournisseur
   par lieu, et chaque échantillon rattaché à celui de son lieu. Écris dans le rapport ce
   que la migration fait sur la base actuelle (3 fournisseurs : omar, hami, omarr).
4. **Suppression de `code_fournisseur`** (confirmée par la propriétaire le 25/09/2026) : c'est un reste de la première conception (le
   collecteur tapait un code). Il n'est la clé de rien : la clé primaire est `id` (UUID).
   Supprime le champ (migration), `_create_supplier_with_generated_code` (remplace par une
   simple création), et partout où il apparaît dans les serializers, vues (`search_fields`,
   `ordering_fields`), filtres, tests (`SF-42`…), signaux, tableaux de bord (`ceo/`,
   `chef/`, `degustateur/`…). Grep `code_fournisseur` dans tout `backend_new/` hors `venv`
   et hors anciennes migrations : il ne doit plus rester que les migrations.
5. `fournisseurs/serializers.py` : expose `delegation`. Garde les limites de la tâche 40
   (un collecteur ne voit que ses fournisseurs).
6. Tests : deux « hami » à Gabès et à Sfax → deux fournisseurs distincts ; même nom + même
   lieu → même fournisseur ; changement de gouvernorat en modification → autre
   fournisseur ; la migration de données sépare un fournisseur à deux lieux.

## B — Flutter

1. `lib/core/models/fournisseur.dart` : retire `codeFournisseur`, ajoute `delegation`.
   Libellé de suggestion : fonction unique partagée (ex. `libelleFournisseur(f)`) qui
   produit `hami — Gabès (El Hamma)` selon les règles ci-dessus.
2. Les trois formulaires d'échantillon (collecteur, dégustateur, chef) : `ChampAutocomplete`
   du fournisseur affiche ce libellé ; `onSelection` remplit nom + gouvernorat + délégation
   (le champ texte garde seulement le **nom**). Le `sousTitre` actuel (`f.region`) devient
   inutile si le lieu est dans le libellé : ne l'affiche pas deux fois.
3. Retire `codeFournisseur` de **tous** les modèles d'échantillon Dart et de tous les
   écrans / recherches / services (grep `codeFournisseur`, `code_fournisseur` dans `lib/`
   et `test/`). Là où on affichait le fournisseur, affiche le nom (déjà fait par la tâche 40)
   et, dans les fiches de détail, le lieu si utile.
4. Référence bouteille : elle utilise déjà le **nom** (tâche 39) ; ne change rien.
5. Tests : libellé (4 cas), sélection qui remplit le lieu, et plus aucun `codeFournisseur`.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera les tests Flutter et
Django, puis appliquera les migrations après une sauvegarde de la base.

## RAPPORT
