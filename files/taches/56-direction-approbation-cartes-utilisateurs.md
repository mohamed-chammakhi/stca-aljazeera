# Tâche 56 — Direction : approbation réparée, carte d'analyse organoleptique, page Utilisateurs, recherche, messagerie

Écrit le 03/10/2026 par Claude. Exécutant : GitHub Copilot. Claude vérifie et commite.
Tout se passe dans l'espace **direction** (`lib/1_ceo/`), sauf mention contraire.

## 1. BUG — « Négociation non enregistrée » en approuvant (priorité)

Constat (journal serveur) : l'application appelle
`PATCH /api/echantillons/2026/0012/approuver/` → 404. Elle met le **numéro** (« 2026/0012 ») à la
place de l'**identifiant** (UUID) : `lib/1_ceo/echantillons/services/echantillon_ceo_service.dart`
ligne ~143 `id: sample['numero'] as String? ?? id`.

À faire :
- Dans `EchantillonCeoView` (`lib/1_ceo/utilisateurs/models/echantillon_ceo_view.dart`), séparer
  les deux : `id` = l'UUID du serveur (utilisé pour **tous** les appels API) et un champ
  `numero` (« 2026/0012 ») pour l'affichage. Remplir les deux dans `_toCeoView`.
- Partout où le numéro est **affiché** (sous la référence dans les cartes, recherche par
  numéro…), utiliser `numero`. Partout où un appel serveur est fait (`approuver`, `refuser`,
  décisions d'achat `refuserAchat` / confirmer, notifications urgentes, etc.), utiliser `id` (UUID).
  Chercher tous les `e.id` dans `lib/1_ceo/` et vérifier un par un.
- Vérifier aussi les autres endroits qui construisent `EchantillonCeoView` (ex.
  `lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart` ~456,
  `g.sampleId`) : `id` doit être l'UUID.
- Test Dart : `_toCeoView` (ou le service) avec `{'id': '<uuid>', 'numero': '2026/0012', …}` →
  `id == '<uuid>'` et `numero == '2026/0012'`.

## 2. La direction peut approuver ou refuser n'importe quand

La direction doit pouvoir **approuver / refuser un échantillon même s'il n'est pas reçu
physiquement et même s'il n'a pas encore été dégusté**. Côté serveur, `approuver` / `refuser`
(`backend_new/echantillons/views.py` ~281) n'ont aucune condition : ne pas en ajouter.
Côté application (page Analyse organoleptique, `analyse_organoleptique_ceo_page.dart` et
`widgets/panel_widgets.dart` / `widgets/panel_section.dart`) : les boutons « Approuver » et
« Refuser » doivent être **actifs** dans tous ces cas (aujourd'hui ils paraissent grisés) —
supprimer toute condition « reçu » / « évaluations soumises » sur ces deux boutons.

## 3. Carte d'échantillon de la page « Analyse organoleptique » — nouvelle disposition

Aujourd'hui (capture de l'utilisatrice) :
- haut : référence + numéro à gauche ; à droite une pastille « Qté : » / « 5555T » sur **deux
  lignes**, l'icône verte « reçu » (✓) et une flèche ;
- bas : « Approuver » « Refuser » à gauche ; à droite un bouton « 🔔 Urgent » et une flèche.

Voulu :
- **haut** : référence + numéro à gauche ; à droite la pastille **« Qté : 5555T » sur une seule
  ligne** (même style, `maxLines: 1`), puis la flèche. **Plus d'icône ✓ en haut.**
- **bas** : « Approuver » « Refuser » à gauche ; à droite, dans cet ordre : le bouton **cloche
  seule dans un cercle** (plus le mot « Urgent » ; garder le cercle autour de la cloche, même
  action, `tooltip: 'Demander en urgence'`), puis l'**icône verte ✓ « reçu »** (même widget
  `RecuPhysiqueIndicator`, même comportement au toucher), puis la flèche.
- Vérifier à 360 px de large : rien ne déborde.
- Appliquer la même disposition aux autres cartes direction qui ont la même structure
  (Analyse laboratoire, Échantillons) si elles affichent la même pastille/cloche.

## 4. Page « Utilisateurs » (`lib/1_ceo/utilisateurs/`)

- Quand on choisit un filtre par rôle (ex. « Dégustateur »), un bouton « effacer les filtres »
  apparaît : **le supprimer** (on revient à « Tous » avec le filtre « Tous »).
- Les pastilles rondes colorées avec l'initiale à côté de chaque utilisateur : **moins de
  couleurs**. Une seule couleur neutre pour tous (fond gris très clair `Color(0xFFF1F3F2)`,
  initiales gris foncé `Color(0xFF4A5A50)`), sans couleur par rôle ni par personne.
- Champ de recherche : retirer « rôle » du texte d'aide (les boutons de filtre servent à ça) et
  ne plus chercher par rôle dans le texte.

## 5. Textes d'aide des champs de recherche (toute la direction)

Règle : le texte d'aide n'annonce **que** ce que la recherche trouve vraiment.
Pages : `achats_confirmes_ceo_page.dart` (~285), `analyse_laboratoire_ceo_page.dart` (~304),
`analyse_organoleptique_ceo_page.dart` (~640), `echantillons_ceo_page.dart` (~331),
`validation_achats_ceo_page.dart` (~427), page Utilisateurs, et tout autre champ de recherche de
`lib/1_ceo/`. Pour chacune : lire la fonction de filtre de la page et écrire un texte d'aide qui
liste exactement les champs cherchés (ex. si la variété n'est pas cherchée, ne pas l'écrire), ou
ajouter le champ manquant à la recherche s'il est dans le texte et utile (réf, numéro, fournisseur,
gouvernorat, variété, collecteur).

## 6. Messagerie de la direction : le chef dégustateur doit être dans les contacts

Le serveur l'autorise déjà (`backend_new/messages_chat/permissions.py` : direction →
collecteur + chef_degustation) et la base a un chef actif. Vérifier côté application
(`lib/core/services/messagerie_service.dart`, `lib/core/widgets/messagerie/`, page messagerie de
la direction) que la liste des contacts de la direction affiche bien le chef dégustateur (rôle
affiché « Chef dégustateur ») ; corriger tout filtre qui ne garde que les collecteurs, et toute
liste inventée (`mock_data_patch.dart`) utilisée pour la messagerie. Test Django : la direction
reçoit le chef dans `GET /api/messages/contacts/`.

## Règles

Voir `files/taches/PROTOCOLE.md`. Interdit : `git commit`, `git push`, migration appliquée sur la
vraie base, ML Kit, fausses données. Encodage UTF-8 sans BOM, garder les fins de ligne.
Lancer `flutter analyze` (zéro ligne « error - »), `flutter test` et les tests Django touchés
avant d'écrire le rapport.

## RAPPORT

### Fait

- `lib/1_ceo/echantillons/services/echantillon_ceo_service.dart` et `lib/1_ceo/utilisateurs/models/echantillon_ceo_view.dart` : l'UUID serveur reste utilisé pour les appels API et le numéro séquentiel est séparé pour l'affichage.
- `lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart` et `lib/1_ceo/analyse_organoleptique/widgets/panel_section.dart` : approbation/refus disponibles sans condition de réception ou d'évaluation soumise ; carte réorganisée avec quantité sur une ligne, cloche seule, indicateur de réception et chevron.
- `lib/1_ceo/achats_confirmes/achats_confirmes_ceo_page.dart`, `lib/1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart`, `lib/1_ceo/echantillons/echantillons_ceo_page.dart` et `lib/1_ceo/validation_achats/validation_achats_ceo_page.dart` : recherche et affichage utilisent `numero`, tandis que les actions utilisent `id`.
- `lib/core/utilisateurs/utilisateurs_page_body.dart` : filtres de rôle sans bouton d'effacement supplémentaire, recherche limitée au nom/email/téléphone et avatars neutres.
- `lib/1_ceo/widgets/base_sample_card.dart` et `lib/1_ceo/widgets/sample_card_echantillon.dart` : cartes compatibles avec l'affichage séparé du numéro.

### Vérifié — comparaison des points 1 à 6

1. **Déjà fait** : séparation UUID/numéro dans le modèle et le service ; les appels `approuver`, `refuser`, `confirmerAchat`, `refuserAchat` et la notification urgente utilisent `id`. Le test `test/echantillon_ceo_view_test.dart` vérifie la conservation distincte des deux valeurs.
2. **Déjà fait** : les boutons de décision sont toujours actifs côté carte ; les vues serveur `approuver` et `refuser` ne conditionnent pas l'action à la réception ou aux évaluations.
3. **Déjà fait** : disposition demandée appliquée à la carte d'analyse organoleptique. Les autres cartes de direction n'ont pas la même combinaison décision/cloche ; aucune duplication à modifier.
4. **Déjà fait** : page Utilisateurs conforme ; les avatars utilisent une couleur neutre commune, la recherche n'inclut pas le rôle et le filtre revient à `Tous` par son propre bouton sans bouton « effacer les filtres ».
5. **Déjà fait** : les textes d'aide de recherche de la direction correspondent aux champs effectivement filtrés ; l'analyse laboratoire inclut aussi la classification, qui est réellement recherchée.
6. **Déjà fait** : le service Flutter consomme `/api/messages/contacts/` sans filtrer les collecteurs, le rôle est affiché via `ContactMessagerie.roleLabel`, et le secours contient aussi un chef. Le backend autorise `direction -> chef_degustation`.

### Vérifié — commandes réellement exécutées

- `flutter analyze` : `51 issues found` (informations/avertissements existants), **0 ligne `error -`**.
- `flutter test` : `00:42 +192: All tests passed!`.
- Depuis `backend_new`, équivalent PowerShell de `DEBUG=True DB_ENGINE=sqlite ./venv/Scripts/python.exe manage.py test messages_chat` : `Ran 20 tests in 328.750s`, `OK`, `Found 20 test(s)`.

### Non fait

- Rien dans les six points demandés.

### HORS PÉRIMÈTRE

- Des modifications préexistantes de l'arbre concernent d'autres fichiers générés et fixtures de tests ; elles n'ont pas été modifiées ni réinitialisées.

FIN RAPPORT

### Reprise

- L’ancienne section `## RAPPORT` a été conservée. Cette reprise corrige et vérifie la séparation `id` UUID / `numero`, les cartes direction, les filtres Utilisateurs, les textes de recherche et le refus organoleptique persisté.
- Fichiers modifiés pour cette reprise : `lib/1_ceo/utilisateurs/models/echantillon_ceo_view.dart`, `lib/1_ceo/echantillons/services/echantillon_ceo_service.dart`, `lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart`, `lib/1_ceo/analyse_organoleptique/widgets/panel_section.dart`, `lib/1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart`, `lib/1_ceo/echantillons/echantillons_ceo_page.dart`, `lib/1_ceo/achats_confirmes/achats_confirmes_ceo_page.dart`, `lib/1_ceo/validation_achats/validation_achats_ceo_page.dart`, `lib/1_ceo/widgets/base_sample_card.dart`, `lib/1_ceo/widgets/sample_card_echantillon.dart`, `lib/core/utilisateurs/utilisateurs_page_body.dart` et `test/echantillon_ceo_view_test.dart`.
- `flutter analyze lib test` : `51 issues found`, uniquement des diagnostics info/warning existants, 0 ligne `error -`.
- `flutter test` : `00:50 +192: All tests passed!`.
- Depuis `backend_new` : `venv\Scripts\python.exe manage.py test --keepdb` a exécuté `248` tests en `1892.756s`, résultat `OK`.
- Le test ciblé UUID/numéro est passé ; aucun test visuel 360 px ou appareil réel n’a été exécuté. Aucun changement backend, aucune migration et aucun usage de ML Kit.
- La messagerie direction contient déjà le chef dégustateur dans le secours Flutter, l’affiche via `roleLabel`, et le backend l’autorise ; aucun fichier de messagerie n’a donc été modifié.

FIN RAPPORT
