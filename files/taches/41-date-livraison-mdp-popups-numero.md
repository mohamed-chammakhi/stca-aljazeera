# Tâche 41 — Filtre « Livraison échantillon », fenêtres du mot de passe, numéro après 9999

Lis `files/taches/PROTOCOLE.md` (dont « Même correction pour tous les rôles »), puis
`CLAUDE.md`. Flutter + backend. Aucune migration.

## A — Filtre « Livraison échantillon » : la date annoncée par le collecteur, quel que soit le statut

Règle de la propriétaire : quand on cherche par **Livraison échantillon**, un échantillon
doit apparaître à la date que le collecteur a **annoncée** dans l'application (« je le livre
tel jour »), même si son statut a changé depuis (ex. achat conclu). Ce n'est **pas** la date
de réception physique.

Constaté par Claude, à vérifier et corriger :
- le collecteur filtre sur `e.dateArriveeEchantillon` (`mes_echantillons_page.dart:~203`) ;
  la direction sur `e.dateArriveeEchantillon ?? e.dateLivraisonPrevue` ;
  `lib/core/utils/date_filter_utils.dart` utilise `dateArriveeEchantillon` ou
  `dateLivraisonEchantillon` selon le modèle ;
- côté serveur, `date_arrivee_echantillon` sert à la fois de date **annoncée** (planifiée
  par `_onScheduleArrivee` du collecteur) et, dans `backend_new/chef/views.py:96`, est
  renvoyée comme `date_reception_physique`. Il faut savoir si quelque chose **écrase**
  `date_arrivee_echantillon` au changement de statut ou à la réception (grep dans
  `echantillons/`, `analyses/`, `notifications/`, `ceo/`, `chef/`, `degustateur/`,
  les `signals.py` et les vues d'actions de statut). Cherche aussi le cas « période »
  (date de début / fin annoncée) : quel champ la stocke ?

À faire :
1. Écris dans ton rapport, en 5 lignes max, quel champ contient la date annoncée et ce qui
   le modifie.
2. Si un changement de statut ou la réception efface / remplace la date annoncée, corrige-le
   pour qu'elle soit conservée (sans migration ; si une migration est indispensable,
   `## QUESTION`).
3. Dans **tous les écrans** qui proposent le filtre `DateFilterType.livraisonEchantillon`
   (collecteur, dégustateur, chef, direction, labo : grep), le filtre utilise la date
   annoncée (date exacte, ou début de période si seule une période a été donnée), jamais
   la date de réception physique.
4. `chef/views.py:96` : ne renvoie plus la date annoncée sous le nom
   `date_reception_physique` ; renvoie la vraie date de réception (le champ utilisé par
   `DateFilterType.receptionPhysique` côté Flutter). Vérifie que l'écran qui lit cette
   clé affiche toujours la bonne chose.
5. Test : un échantillon au statut achat conclu, avec une date annoncée au 10/10 et une
   réception au 12/10 → le filtre « Livraison échantillon » au 10/10 le trouve, au 12/10 non.

## B — Changement de mot de passe : une fenêtre pour chaque erreur

`lib/core/widgets/change_password_dialog.dart` (utilisé par les 5 profils). Aujourd'hui les
erreurs s'affichent en texte au-dessus des champs. La propriétaire veut **une fenêtre**
(`AlertDialog`, bouton `OK`) pour chacun de ces cas, avec un titre et un message clairs :
- l'ancien mot de passe est incorrect (réponse du serveur) → `Ancien mot de passe incorrect`
- le nouveau mot de passe ne respecte pas les règles → `Mot de passe trop faible`, avec la
  liste des règles non respectées (reprends les règles déjà vérifiées dans le code / par le
  serveur, n'en invente pas)
- la confirmation ne correspond pas → `Les mots de passe ne correspondent pas`
- tout autre refus du serveur → son message.
Retire l'ancien texte d'erreur au-dessus des champs (pour ne pas afficher deux fois).
Les champs gardent ce qui a été tapé. Test widget : un test par fenêtre.

## C — Numéro d'échantillon après 9999

`backend_new/echantillons/models.py`, `save()` : le numéro est `ANNÉE/0001`, et il
recommence à 1 chaque année. Le prochain numéro est pris avec
`order_by('-numero').first()` : c'est un tri **alphabétique**. Après `2026/9999`, le
numéro `2026/10000` est rangé **avant** `2026/9999` (« 1 » < « 9 »), donc le calcul
redonne `2026/10000` → doublon → l'enregistrement plante.

Décision : on garde `ANNÉE/numéro` avec au moins 4 chiffres ; après 9999 le numéro
continue simplement : `2026/10000`, `2026/10001`… (pas de lettres).
- Calcule le prochain numéro sur la **valeur numérique** maximale de l'année (pas sur le
  tri texte). Protège contre deux enregistrements simultanés (réessaie en cas
  d'`IntegrityError`, comme `_create_supplier_with_generated_code`).
- `numero` est un `CharField(max_length=20)` : assez long, pas de migration.
- Côté Flutter, vérifie que rien ne suppose 4 chiffres (tri des listes par numéro, découpe
  de la chaîne, largeur fixe) ; si une liste trie par numéro en texte, trie par
  (année, numéro) en nombres.
- Test backend : avec un échantillon `2026/9999` existant, le suivant est `2026/10000`,
  puis `2026/10001`.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera `flutter analyze lib
test`, `flutter test` et les tests Django.

## RAPPORT

### Fait
- Champ date annoncee : `Echantillon.date_arrivee_echantillon` contient la livraison echantillon annoncee par le collecteur / formulaire; les create/update peuvent l'ecrire.
- La reception physique utilise `Echantillon.date_reception_echantillon`, posee par `confirmer-reception` et effacee par `annuler-reception`.
- Les actions de statut verifiees (`approuver`, `confirmer-achat`, `refuser-achat`, `renvoyer-en-negociation`) ne remplacent pas `date_arrivee_echantillon`.
- Aucun champ backend de fin de periode de livraison echantillon n'existe; `dateLivraisonPrevueFin` est un champ mock/vue Flutter.

- `backend_new/echantillons/models.py` : les nouveaux echantillons apres `2026/9999` recoivent `2026/10000`, puis `2026/10001`, avec retry en cas d'`IntegrityError`.
- `backend_new/chef/views.py` : la vue chef renvoie la vraie reception physique dans `date_reception_physique` et filtre/ordonne cette vue par `date_reception_echantillon`.
- `lib/1_ceo/echantillons/echantillons_ceo_page.dart` : le filtre reception physique Direction ne retombe plus sur la date annoncee.
- `lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart` : meme correction du filtre reception physique.
- `lib/1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart` : meme correction du filtre reception physique.
- `lib/1_ceo/achats_confirmes/achats_confirmes_ceo_page.dart` : meme correction du filtre reception physique.
- `lib/core/widgets/change_password_dialog.dart` : les erreurs de changement de mot de passe s'affichent maintenant dans une fenetre `AlertDialog` avec bouton `OK`, sans ancien texte d'erreur sous les champs; les saisies restent en place.
- `lib/core/password_validation.dart` : les regles de mot de passe existantes sont exposees sous forme de liste pour la fenetre "Mot de passe trop faible".
- `test/date_filter_utils_test.dart` : ajoute le cas achat confirme avec livraison annoncee le 10/10 et reception le 12/10.
- `test/profile_password_service_test.dart` : ajoute un test widget par fenetre d'erreur du mot de passe.
- `backend_new/echantillons/tests.py` : ajoute le test backend `2026/9999 -> 2026/10000 -> 2026/10001`.
- `backend_new/chef/tests.py` : couvre la vraie reception physique renvoyee a l'ecran chef.

### Verifie
```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test echantillons chef -v 1
```
Sortie :
```text
Found 46 test(s).
System check identified no issues (0 silenced).
Ran 46 tests in 146.568s
OK
```

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py makemigrations --check --dry-run
```
Sortie :
```text
No changes detected
```

```bash
rg -n "dateReceptionEchantillon \?\? e\.dateArriveeEchantillon|date_reception_physique': _iso_or_none\(sample\.date_arrivee_echantillon\)|order_by\('-numero'\)" lib backend_new -g "*.dart" -g "*.py"
```
Sortie brute : aucune ligne, exit code `1`.

### Non fait
- `flutter analyze lib test` et `flutter test` non executes : la section "Verification attendue" de cette tache dit que ce sandbox ne peut pas lancer Flutter et demande de ne pas essayer. Les tests Flutter ont ete ajoutes pour Claude.
- Suite Django complete non lancee; j'ai lance les suites ciblees `echantillons chef`, suffisantes pour les changements backend de cette tache.

### HORS PERIMETRE
- `files/backend_sprint_plan.md` est reference par les consignes projet mais absent du depot.
- Le skill `frontend-design` exige par `CLAUDE.md` n'est pas disponible dans la liste des skills exposes a cette session.
- Le workspace contient deja des fichiers non suivis non lies a cette tache (`backend_new/backup_propre.json`, `backend_new/media/`, `backend_new/sauvegarde_avant_nettoyage_2026-09-25.json`, plusieurs `files/taches/codex_*.txt`, etc.); je n'y ai pas touche.
