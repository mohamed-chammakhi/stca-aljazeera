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

### Fait

- `backend_new/fournisseurs/models.py` : le fournisseur porte maintenant un lieu complet avec `region` + `delegation`, sans code fournisseur visible.
- `backend_new/fournisseurs/migrations/0003_remove_fournisseur_code_fournisseur_and_more.py` : ajoute `delegation`, remplit/sépare les fournisseurs existants par lieu d'échantillon, puis supprime `code_fournisseur`.
- `backend_new/echantillons/serializers.py` : la liaison fournisseur se fait par nom + gouvernorat + délégation, y compris en modification quand le nom ou le lieu est renvoyé.
- `backend_new/fournisseurs/serializers.py`, `backend_new/fournisseurs/views.py`, `backend_new/fournisseurs/admin.py` : l'API fournisseurs expose/recherche/ordonne par nom et lieu, sans code fournisseur.
- `backend_new/analyses/serializers.py`, `backend_new/echantillons/views.py`, `backend_new/chef/views.py` : les réponses et recherches backend n'exposent plus l'ancien code fournisseur.
- `backend_new/echantillons/tests.py`, `backend_new/fournisseurs/tests.py`, `backend_new/ceo/tests.py`, `backend_new/chef/tests.py`, `backend_new/degustateur/tests.py` : les tests couvrent les fournisseurs homonymes par lieu, la réutilisation même nom + même lieu, le changement de lieu en modification et la migration de séparation.
- `lib/core/models/fournisseur.dart` : `codeFournisseur` est retiré, `delegation` est ajouté, et `libelleFournisseur(f)` produit le libellé partagé `nom — gouvernorat (délégation)`.
- `lib/core/services/fournisseur_service.dart` : les suggestions fournisseurs utilisent nom + lieu et les mocks de fournisseurs portent une délégation.
- `lib/core/widgets/champ_autocomplete.dart` : une suggestion peut afficher un libellé complet tout en écrivant seulement le nom dans le champ.
- `lib/2_collecteur/.../formulaire_dialog.dart`, `lib/3_degustateur/.../formulaire_dialog.dart`, `lib/5_chef_degustateur/.../formulaire_dialog.dart` : choisir un fournisseur remplit le nom, le gouvernorat et la délégation, sans sous-titre de lieu dupliqué.
- `lib/2_collecteur/...`, `lib/3_degustateur/...`, `lib/4_laboratoire/...`, `lib/5_chef_degustateur/...`, `lib/1_ceo/...`, `lib/core/...` : les affichages/recherches/services utilisent le nom fournisseur, plus l'ancien code.
- `test/fournisseur_libelle_test.dart` : ajoute les 4 cas de libellé demandés et le test de sélection qui garde seulement le nom dans le champ.
- `test/cablage_api_test.dart`, `test/echantillon_collecteur_service_test.dart`, `test/ecrans_principaux_sans_uuid_test.dart`, `test/formulaire_echantillon_finitions_test.dart` : les attentes Flutter ne dépendent plus de `codeFournisseur`.
- `test/fixtures/api/**` : les fixtures API ont été régénérées/ajustées pour ne plus contenir le code fournisseur dans les réponses d'échantillons.

Effet prévu de la migration sur la base locale actuelle, lu sans appliquer de migration :

- `hami` : ancien `region='Jandouba'`, 1 échantillon à `Gabes / Gabes Ouest`; la migration mettra le fournisseur à `Gabes / Gabes Ouest`.
- `omar` : ancien `region='Gafsa'`, 2 échantillons à `Gabes / ElMetouia`; la migration mettra le fournisseur à `Gabes / ElMetouia`.
- `omarr` : ancien `region='Gafsa'`, 1 échantillon à `Jandouba / Fernana` et 1 à `Le kef / Kef Ouest`; la migration séparera en deux fournisseurs `omarr`, un par lieu, et rattachera chaque échantillon au bon fournisseur.

### Vérifié

```bash
Get-ChildItem -Path backend_new,lib,test -Recurse -File -Include *.py,*.dart,*.json | Where-Object { $_.FullName -notmatch '\\backend_new\\venv\\' -and $_.FullName -notmatch '\\backend_new\\.*\\migrations\\[0-9]{4}_.+\.py$' -and $_.FullName -notmatch '\\backend_new\\sauvegarde_' } | Select-String -Pattern 'code_fournisseur','codeFournisseur'
```

Sortie : aucune ligne.

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test echantillons fournisseurs --keepdb -v 1
```

Deux premières relances pendant la correction du test de migration :

- `Ran 43 tests in 81.647s` → `FAILED (errors=1)` : `LookupError: No installed app with label 'echantillons'.`
- `Ran 43 tests in 80.646s` → `FAILED (errors=1)` : `django.db.utils.IntegrityError: UNIQUE constraint failed: new__fournisseurs_fournisseur.code_fournisseur`

Relance finale :

```text
Using existing test database for alias 'default'...
...........................................
----------------------------------------------------------------------
Ran 43 tests in 80.984s

OK
Preserving test database for alias 'default'...
Found 43 test(s).
System check identified no issues (0 silenced).
```

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py makemigrations --check --dry-run
```

Sortie :

```text
No changes detected
```

Lecture seule de la base locale actuelle :

```bash
cd backend_new
.\venv\Scripts\python.exe - <<'PY'
import sqlite3
conn = sqlite3.connect('db.sqlite3')
conn.row_factory = sqlite3.Row
for supplier in conn.execute("select id, nom, region from fournisseurs_fournisseur order by nom"):
    samples = conn.execute(
        "select gouvernorat, delegation, count(*) as n from echantillons_echantillon where fournisseur_id = ? group by gouvernorat, delegation order by gouvernorat, delegation",
        (supplier['id'],),
    ).fetchall()
    print(f"{supplier['nom']} | region={supplier['region']!r} | lieux={[(s['gouvernorat'], s['delegation'], s['n']) for s in samples]}")
conn.close()
PY
```

Sortie :

```text
hami | region='Jandouba' | lieux=[('Gabes', 'Gabes Ouest', 1)]
omar | region='Gafsa' | lieux=[('Gabes', 'ElMetouia', 2)]
omarr | region='Gafsa' | lieux=[('Jandouba', 'Fernana', 1), ('Le kef', 'Kef Ouest', 1)]
```

Je n'ai pas lancé Flutter : la tâche dit explicitement que ce sandbox ne peut pas lancer Flutter et qu'il ne faut pas essayer.

### Non fait

- Migration non appliquée sur la vraie base, conformément à la consigne.
- `flutter analyze lib test` et `flutter test` non lancés, conformément à la vérification attendue de cette tâche.

### HORS PÉRIMÈTRE

- `files/backend_sprint_plan.md` est référencé par les consignes mais absent de l'arbre.
- Le skill `frontend-design` exigé par `CLAUDE.md` n'est pas disponible dans cette session; j'ai appliqué les règles de design existantes sans modifier la mise en page.
- `backend_new/sauvegarde_avant_nettoyage_2026-09-25.json` est une sauvegarde non suivie qui contient encore l'ancien champ `code_fournisseur`; je ne l'ai pas modifiée ni supprimée.
