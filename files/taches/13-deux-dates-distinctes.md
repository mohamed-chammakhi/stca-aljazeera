# Tâche 13 — La date prévue ne doit plus être écrasée

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Décision du propriétaire, 31/08/2026 : **le champ ne doit pas être écrasé à l'arrivée.**

À faire **avant** la tâche 09, qui en dépend.

---

## Le problème

Un échantillon a deux dates différentes dans la vraie vie :

- la date que le **collecteur annonce** quand il enregistre l'échantillon ;
- la date où l'échantillon **arrive réellement** dans l'entreprise.

Côté serveur, il n'existe qu'**un seul champ** pour les deux : `date_arrivee_echantillon`
(`backend_new/echantillons/models.py:81`).

Et à la confirmation de réception, ce champ est **écrasé** :

```
backend_new/echantillons/views.py:199
    obj.date_arrivee_echantillon = timezone.now()
```

**Conséquence : la date annoncée par le collecteur est détruite.** Personne ne peut plus savoir
ce qui était prévu, ni si une livraison était en retard. Dans une période de forte activité,
c'est une information qui compte.

## Flutter attend déjà les deux dates

Le modèle du collecteur les a toutes les deux :

```
lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart:108   dateArriveeEchantillon    (prévue)
lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart:112   dateReceptionEchantillon  (réelle)
```

Et le service documente lui-même le manque, dans ses commentaires
(`echantillon_collecteur_service.dart:75-79`) :

```dart
// date_arrivee_echantillon (scheduled) is not in this endpoint — always null.
'date_arrivee_echantillon': null,
// date_arrivee_echantillon from API = actual physical reception date.
'date_reception_echantillon': api['date_arrivee_echantillon'],
```

Le contournement est donc déjà écrit dans le code. On le supprime en donnant au serveur le
champ qui lui manque.

---

## CONSIGNE

1. **Ajoute `date_reception_echantillon`** au modèle `Echantillon`
   (`DateTimeField(null=True, blank=True)`), et expose-le dans le sérialiseur.

   **Garde exactement ce nom.** Il correspond à `dateReceptionEchantillon` côté Flutter, qui
   existe déjà. C'est la règle 1 du `CLAUDE.md` : même chose, même nom.

2. **`views.py:199` écrit désormais dans le nouveau champ**, plus dans l'ancien :

   ```python
   obj.date_reception_echantillon = timezone.now()
   ```

   Pense à mettre à jour la liste `update_fields` de la ligne suivante.

3. **`date_arrivee_echantillon` retrouve son seul sens : la date prévue par le collecteur.**
   Plus rien ne l'écrase, jamais.

4. **Migration de données pour les échantillons déjà reçus.** Pour toutes les lignes où
   `recu_physiquement=True`, recopie `date_arrivee_echantillon` dans
   `date_reception_echantillon` : c'est la date réelle qui s'y trouve aujourd'hui.

   **Laisse `date_arrivee_echantillon` tel quel pour ces lignes.** La date prévue d'origine est
   perdue, on ne peut pas l'inventer ; garder la valeur actuelle vaut mieux que la vider.
   Signale ce choix dans ton rapport.

5. **Côté Flutter, supprime le contournement** dans
   `echantillon_collecteur_service.dart:75-79` : les deux dates viennent maintenant chacune de
   son propre champ. Retire aussi les deux commentaires devenus faux.

   Vérifie que `fromJson` (`echantillon_collecteur.dart:204-208`) lit bien les deux, au lieu de
   forcer `dateReceptionEchantillon: null`.

6. **Un test Django** qui prouve le comportement : un échantillon a une date prévue, on
   confirme sa réception, et **la date prévue est toujours là** après l'opération, à côté de la
   date réelle. C'est le seul vrai critère de réussite.

---

## Ce que tu ne fais pas

- Tu ne touches pas au filtre par dates. C'est la tâche 09, qui viendra après.
- Tu ne changes pas qui a le droit de confirmer la réception : cela reste le dégustateur et le
  chef dégustateur.

---

## Vérification

```bash
flutter analyze lib test
flutter test
cd backend_new
./venv/Scripts/python.exe manage.py test echantillons --keepdb
```

La suite `echantillons` seule prend environ 2 minutes et contient ton nouveau test. Lance-la
au minimum. La suite complète prend environ 800 secondes ; lance-la si tu en as le temps.

Référence : **50 problèmes, 0 erreur** ; **101 tests Flutter réussis** avec le seul échec connu
`test/widget_test.dart` ; suite `echantillons` : **25 tests, tous verts** avant ton ajout.

Si `flutter` refuse de s'exécuter chez toi, dis-le et ne revendique aucun chiffre. La suite
Django, elle, doit être lancée : c'est elle qui prouve que la migration passe.

## RAPPORT

### Fait

- `backend_new/echantillons/models.py` — un échantillon conserve désormais séparément la date d'arrivée annoncée par le collecteur et la date de sa réception physique.
- `backend_new/echantillons/serializers.py` — l'API renvoie les deux dates sous leurs noms distincts ; la date de réception réelle reste pilotée par l'action serveur et n'est pas modifiable directement par un client.
- `backend_new/echantillons/views.py` — confirmer la réception renseigne uniquement `date_reception_echantillon` et ne détruit plus la date prévue.
- `backend_new/echantillons/migrations/0013_echantillon_date_reception_echantillon.py` — le nouveau champ est créé et, pour chaque échantillon déjà reçu, l'ancienne valeur est copiée comme date réelle. `date_arrivee_echantillon` est volontairement laissée intacte : la date prévue d'origine est perdue et ne peut pas être reconstruite.
- `backend_new/echantillons/tests.py` — la réception physique vérifie le nouveau champ et un test dédié prouve que date prévue et date réelle coexistent après confirmation.
- `lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart` — le collecteur envoie sa date prévue au serveur et reçoit désormais chaque date depuis son propre champ, sans l'ancien contournement.
- `lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart` — le modèle Flutter lit les deux dates indépendamment au lieu de forcer la date de réception à `null`.
- `files/mapbackend.md` — la carte de continuité backend documente la séparation des deux dates, la migration des données et les vérifications effectuées.

### Vérifié

Commande de cohérence de migration, lancée depuis `backend_new` :

```powershell
.\venv\Scripts\python.exe manage.py makemigrations --check --dry-run
```

Sortie :

```text
No changes detected
```

Le premier lancement du nouveau test a atteint la base et appliqué la migration `0013`, mais l'assertion comparait deux représentations textuelles de fuseaux différents (`+01:00` contre `Z`) :

```text
Applying echantillons.0013_echantillon_date_reception_echantillon... OK
Ran 1 test in 1.685s
FAILED (failures=1)
AssertionError: '2026-09-03T16:38:20.684056+01:00' != '2026-09-03T15:38:20.684056Z'
```

Après correction pour comparer les instants parsés :

```powershell
.\venv\Scripts\python.exe manage.py test echantillons.tests.CollectorEchantillonApiTests.test_physical_reception_preserves_scheduled_arrival_date --keepdb -v 2
```

```text
Found 1 test(s).
Ran 1 test in 1.618s
OK
```

Suite Django demandée, depuis `backend_new` :

```powershell
.\venv\Scripts\python.exe manage.py test echantillons --keepdb
```

```text
Found 26 test(s).
System check identified no issues (0 silenced).
Ran 26 tests in 45.844s
OK
```

Suite Django complète :

```powershell
.\venv\Scripts\python.exe manage.py test --keepdb
```

```text
Found 160 test(s).
System check identified no issues (0 silenced).
Ran 160 tests in 459.444s
OK
```

L'échec Chef documenté comme préexistant ne s'est pas reproduit dans cette exécution : les 160 tests ont réussi.

Formatage Dart réellement exécuté depuis la racine :

```powershell
dart format lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart
```

```text
Formatted 2 files (1 changed) in 0.01 seconds.
```

Recherche brute des écritures de production qui écraseraient encore la date prévue :

```powershell
rg -n '\.date_arrivee_echantillon\s*=|update_fields=.*date_arrivee_echantillon' backend_new --glob '!**/migrations/**' --glob '!**/tests.py'
```

```text
Aucune sortie (code 1).
```

Recherche brute des deux commentaires de contournement devenus faux :

```powershell
rg -n 'scheduled.*not in this endpoint|from API = actual physical reception date' lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart
```

```text
Aucune sortie (code 1).
```

Contrôle du diff :

```powershell
git diff --check
```

```text
Aucune erreur (code 0). Git affiche seulement ses avertissements de conversion LF vers CRLF pour les fichiers Python/Markdown suivis.
```

Les deux commandes Flutter demandées ont été lancées séparément :

```powershell
flutter analyze lib test
flutter test
```

Toutes deux se sont arrêtées avant l'analyse ou la découverte des tests avec la même sortie ; aucun chiffre Flutter n'est donc revendiqué :

```text
CreateFile failed 5 (Access is denied.)
Flutter failed to run "git -c log.showSignature=false log HEAD -n 1 --pretty=format:%ad --date=iso".
The flutter tool cannot access the file or directory.
```

La commande Git citée fonctionne pourtant lorsqu'elle est exécutée directement dans `C:\Users\takwa\Documents\flutter` ; le refus vient du lancement interne par le processus Dart de Flutter dans cet environnement.

### Non fait

- Aucune analyse ni suite de tests Flutter n'a pu démarrer, car l'outil Flutter refuse de lancer sa commande Git interne avec `CreateFile failed 5`. Les commandes ont été tentées sans revendiquer de résultat.

### HORS PÉRIMÈTRE

- `files/backend_sprint_plan.md`, référencé par `AGENTS.md`, `CLAUDE.md` et `files/mapbackend.md`, est absent du dépôt ; il n'a pas été recréé dans cette tâche.
- `files/taches/ETAT.md`, que seul Claude doit tenir à jour, indique encore que le sens de la date d'arrivée attend une réponse de l'entreprise, alors que la décision du 31/08/2026 figure dans cette tâche.
- Des consommateurs hérités utilisent encore `date_arrivee_echantillon` comme date réelle, notamment dans les calculs/tableaux de bord, les vues Chef/Dégustateur/Analyses et certains modèles/services Flutter. Ils n'ont pas été modifiés ici, car la consigne interdit de toucher aux filtres de dates et annonce explicitement la tâche 09 comme étape suivante dépendante.
