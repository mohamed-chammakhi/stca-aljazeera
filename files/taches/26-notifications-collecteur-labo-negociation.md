# Tâche 26 — Notifications manquantes : collecteur (réception), laboratoire
# (nouvel échantillon), collecteur (négociation proposée/mise à jour)

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Cette tâche touche le backend Django (`backend_new/`) et un peu de frontend Flutter
(`lib/2_collecteur/notifications/`). Elle vient de `files/notifications/` (carnet de
décisions notifications, maintenant tranché) — les décisions D1, D3, D4, D5, L9 de ce
carnet, mais **seulement leur part confirmée réellement manquante après vérification
directe dans le code** (le carnet était en partie obsolète : beaucoup de choses qu'il
présentait comme manquantes existent déjà — voir la section "Ce qui existe déjà" ci-dessous,
n'y touche pas).

---

## Contexte — le système de notifications existant

`backend_new/notifications/` a déjà un modèle `Notification` générique (destinataire,
type, titre, message, échantillon, section, is_read) avec des signaux Django
(`backend_new/notifications/signals.py`, sur `post_save`/`pre_delete` de `Echantillon`,
`EvaluationOrganoleptique`, `AnalyseLabo`, `SessionDegustation`) qui créent déjà des
notifications pour plusieurs événements. Toutes les pages de notification Flutter (CEO,
dégustateur, chef, labo, **collecteur inclus**) consomment déjà le même endpoint réel
`GET /api/notifications/` (filtré serveur par `destinataire=request.user`) — **aucune page
frontend n'a besoin d'être re-câblée pour recevoir une nouvelle notification**, il suffit
que le backend en crée une avec le bon `destinataire`.

### Ce qui existe déjà — NE PAS RECONSTRUIRE, NE PAS TOUCHER

- `NOUVEL_ECHANTILLON` à la création d'un échantillon → Direction, Chef dégustation,
  Dégustateur (`signals.py:113-127`)
- `ECHANTILLON_RECU` quand `recu_physiquement` passe de `False` à `True` → Direction,
  Chef dégustation (`signals.py:132-145`) — **cette tâche AJOUTE le collecteur comme
  destinataire supplémentaire de ce même événement, ne change rien d'autre**
- `ACHAT_CONFIRME`, `ECHANTILLON_MODIFIE`, `ECHANTILLON_SUPPRIME`,
  `DATE_LIVRAISON_AJOUTEE`/`MODIFIEE` (livraison du **stock**, pas de l'échantillon),
  `EVALUATION_SOUMISE`/`TOUTES_EVALUATIONS`, `ANALYSE_SOUMISE`, `NOUVELLE_SESSION` — tous
  déjà câblés dans `signals.py`
- `ANALYSE_URGENTE`, `EVALUATION_URGENTE` — déjà câblés dans `notifications/views.py`,
  testés dans `notifications/tests.py`
- `PROPOSITION_ACHAT_ATTENTE` → Direction, quand le collecteur confirme un achat
  (`echantillons/views.py:245-263`, méthode `_notify_purchase_proposal`)
- `NEGOCIATION_A_REVOIR` → le collecteur (`obj.collecteur`), avec le contre-prix et le
  motif, déjà dans le message (`echantillons/views.py` autour de la ligne 418) — c'est le
  cas du **refus de prix / renvoi en négociation** (§3 de `files/notifications/02_ceo.md`),
  déjà entièrement construit et testé (`test/refus_dialog_test.dart` +
  `chef.tests`/`ceo` côté Django)
- Le popup de confirmation avant "Confirmer l'achat" côté CEO — déjà là
  (`ConfirmerAchatDialog` dans `lib/1_ceo/validation_achats/widgets/decision_dialog.dart`)

### Ce qui manque réellement — le périmètre de cette tâche

1. **Le collecteur n'est jamais notifié quand son échantillon est reçu physiquement.**
   `signals.py:132-145` notifie Direction + Chef dégustation sur `recu_physiquement`
   `False → True`, mais jamais `obj.collecteur`. C'est la décision D2.4 de
   [`files/notifications/01_collecteur.md`](../notifications/01_collecteur.md) §2.4 — le
   collecteur doit recevoir cette notification comme les autres.

2. **Le laboratoire n'est jamais notifié qu'un nouvel échantillon lui est disponible.**
   [`role_laboratoire.md`](../role_laboratoire.md) dit que le labo ne voit que les
   échantillons `recu_physiquement = true` — c'est exactement le même événement que le
   point 1 ci-dessus. Décision L9 de
   [`files/notifications/05_laboratoire.md`](../notifications/05_laboratoire.md) §3.1 :
   il faut prévenir le labo à ce moment-là, c'est le déclencheur de son travail.

3. **Le CEO qui propose ou met à jour une négociation (`approuver()`) ne notifie
   personne.** Vérifié dans `echantillons/views.py:219-234` — l'action `approuver` (qui
   sert à la fois à proposer une négociation la première fois ET à la mettre à jour
   ensuite, en rappelant la même action avec de nouveaux chiffres — c'est déjà la
   fonctionnalité "mettre à jour la négociation" demandée en D5, elle existe déjà comme
   action, il ne lui manque que la notification) sauvegarde l'échantillon mais n'appelle
   jamais `Notification.objects.create(...)`. Décisions D4 + D5 de
   [`files/notifications/01_collecteur.md`](../notifications/01_collecteur.md).

4. **Cliquer sur une notification, côté page Notifications du collecteur, ne fait
   rien.** Vérifié dans
   [`lib/2_collecteur/notifications/notifications_collecteur_page.dart:89-92`](../../lib/2_collecteur/notifications/notifications_collecteur_page.dart#L89) —
   `_onTap` marque juste comme lu et ferme, sans naviguer vers l'échantillon. Le modèle
   `NotificationCollecteur` a déjà `echantillonId` (déjà rempli par le vrai serveur, champ
   `echantillon` du `NotificationSerializer`) — la donnée existe, seule la navigation
   manque. C'est la demande de
   [`files/notifications/02_ceo.md`](../notifications/02_ceo.md) §2.1.

---

## CONSIGNE

### 1. Backend — `backend_new/notifications/signals.py`

Dans `on_echantillon_saved`, la branche `if old_recu is False and instance.recu_physiquement:`
(ligne ~132) :
- ajoute `instance.collecteur` aux destinataires de la notification `ECHANTILLON_RECU`
  existante, **si `instance.collecteur` n'est pas `None`** (le champ est nullable). Ne
  crée pas une notification séparée avec un texte différent — même notification, un
  destinataire de plus, en réutilisant `_get_users_by_roles` + le queryset du collecteur
  concaténé (ou une liste Python simple si plus lisible).
- ajoute, dans la même branche, une notification distincte vers **tous les utilisateurs
  actifs du rôle Laboratoire** (`User.Role.LABORATOIRE` — vérifie le nom exact de la
  constante dans `backend_new/users/models.py`), type `Notification.Type.NOUVEL_ECHANTILLON`
  (c'est un nouvel échantillon disponible **pour lui**, même sémantique que le type déjà
  utilisé à la création — pas besoin d'un type dédié), titre et message adaptés au labo
  (ex. "Échantillon disponible pour analyse"), section `Notification.Section.ANALYSES`.

### 2. Backend — `backend_new/echantillons/views.py`, action `approuver`

Après le `obj.save()` de `approuver()` (ligne ~233), notifie `obj.collecteur` (si non
`None`) :
- si c'est la **première fois** que `budget_negociation` est renseigné sur cet
  échantillon (valeur précédente vide/`None` avant ce `save()` — utilise le même genre de
  snapshot `pre_save` que `signals.py` fait déjà pour `STOCK_DELIVERY_FIELDS`, ou compare
  simplement avant/après dans la vue elle-même), envoie un nouveau type
  `Notification.Type.NEGOCIATION_PROPOSEE` ("Proposition de négociation")
- si `budget_negociation` **changeait déjà** avant cet appel (mise à jour), envoie
  `Notification.Type.NEGOCIATION_MISE_A_JOUR` ("Négociation mise à jour")
- dans les deux cas, message en texte simple avec la référence, le prix et la quantité —
  même style que `NEGOCIATION_A_REVOIR` déjà en place (`f"{ref} : la direction propose
  {prix}..."`), **pas** de nouveau champ structuré sur le modèle `Notification` (le
  modèle collecteur `NotificationCollecteur` a bien des champs `budgetNegociation` /
  `dateLivraisonStockSouhaitee` côté Flutter, mais ils ne sont alimentés par aucun champ
  réel du `NotificationSerializer` — ce sont des champs jamais branchés, **ne les
  branche pas**, ce n'est pas le périmètre de cette tâche ; reste au texte libre comme le
  reste de l'app)
- section `Notification.Section.ACHATS_VALIDATION` (cohérent avec `PROPOSITION_ACHAT_ATTENTE`)

Ajoute les deux nouveaux types au `TextChoices` de `backend_new/notifications/models.py`
(`NEGOCIATION_PROPOSEE`, `NEGOCIATION_MISE_A_JOUR`), migration Django à générer
(`python manage.py makemigrations notifications`).

### 3. Frontend — `lib/2_collecteur/notifications/notifications_collecteur_page.dart`

Dans `_onTap` (ligne ~89), si `n.echantillonId != null`, navigue vers la page de détails
de l'échantillon **du collecteur** (regarde comment `mes_echantillons_page.dart` ouvre
déjà le détail d'un échantillon donné par son id, et réutilise le même chemin — ne crée
pas un second mécanisme de navigation). Si l'échantillon n'existe plus/id introuvable, ne
plante pas — reste sur la page notifications (comportement actuel).

---

## Ce que tu ne fais pas

- Tu ne touches à rien de la liste "Ce qui existe déjà" plus haut.
- Tu ne construits pas la messagerie (D27, W7 — hors périmètre, réservée).
- Tu ne touches pas à la "décoche" / annulation de réception physique
  (`_onToggleRecu` dans `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart`
  et son équivalent chef) — **elle est aujourd'hui volontairement bloquée** ("Une
  réception confirmée ne peut pas être annulée") et il n'existe aucun endpoint serveur
  pour l'inverse. Ce n'est pas un oubli de notification, c'est une règle produit actuelle
  qui n'a pas été retranchée — hors périmètre de cette tâche, à traiter séparément après
  décision explicite du propriétaire du projet.
- Tu ne branches pas `budgetNegociation` / `dateLivraisonStockSouhaitee` sur le modèle
  `NotificationCollecteur` — reste au texte libre dans `message`, comme le reste de
  l'app (voir point 2 ci-dessus).
- Tu ne crées pas de nouvelle page ni de nouveau service frontend — les pages de
  notifications existent déjà pour tous les rôles concernés.

---

## Vérification à exécuter

Backend :
```bash
cd backend_new
python manage.py makemigrations notifications --check --dry-run  # avant, pour voir l'etat
python manage.py makemigrations notifications
python manage.py migrate
python manage.py test notifications echantillons
```

Frontend :
```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport. Référence : 49 diagnostics/0 erreur
Flutter (peut varier légèrement selon l'état du dépôt à ce moment, donne le vrai chiffre),
108 tests Flutter (107 réussis + 1 échec déjà connu). Pour Django, donne le nombre de
tests exécutés et le nombre d'échecs — doit être 0 échec nouveau (les tests existants ne
doivent pas régresser).

## RAPPORT

Complète cette section : ce qui a été fait, les vérifications avec leurs vrais résultats
chiffrés, et tout écart avec cette consigne (fichier différent, nom de constante différent
de ce que ce document suppose, etc.) — explique pourquoi plutôt que de forcer.
