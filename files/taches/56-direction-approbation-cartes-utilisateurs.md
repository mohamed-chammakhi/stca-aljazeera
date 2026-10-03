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
