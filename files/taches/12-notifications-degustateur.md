# Tâche 12 — Notifications du dégustateur : combler les écarts

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Source de la demande : `docs/retours-utilisation-et-questions.md`, points 3.2 à 3.6.

---

## Contexte

Le propriétaire a listé les cinq échanges de notifications qui concernent le dégustateur. Le
code a été comparé point par point avec cette liste. **Trois choses sur cinq marchent déjà.**
Cette tâche ne traite que les écarts.

Le système est réel, pas simulé : les notifications viennent de Django
(`backend_new/notifications/`), avec des données de démonstration qui n'apparaissent qu'en
build de développement quand le serveur ne répond pas
(`lib/core/services/resultat_service.dart:28`, `if (kReleaseMode) rethrow;`).

### Ce qui est déjà conforme — ne pas y toucher

| Décision du document | État réel |
|---|---|
| 3.2 — Les dégustateurs ne s'envoient rien entre eux | Correct, aucune notification de ce type n'existe |
| 3.3 — Direction → dégustateur : évaluation urgente, avec la référence, et le clic ouvre l'échantillon | Fait de bout en bout. Envoi : `lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart:330`. Serveur : `backend_new/notifications/views.py:130-195`. Le clic amène bien à l'échantillon : `lib/3_degustateur/tableau_de_bord/homepage_page.dart:83-94` passe `echantillonCible`, et la page d'évaluation fait défiler jusqu'à lui (`evaluation_echantillons_page.dart:92-133`). Testé dans `test/evaluation_urgente_navigation_test.dart` |
| 3.5 — Dégustateur → laboratoire : analyse urgente | Fait de bout en bout. Envoi : `lib/core/analyses/ligne_analyse_labo_service.dart:15-20`. Serveur : `backend_new/notifications/views.py:62-127`, envoyé à tous les techniciens laboratoire actifs |

---

## CONSIGNE

### Écart 1 — Le nom du membre manque dans « Évaluation soumise »

Le document 3.4 demande : *« Le nom du membre qui a soumis + la référence de l'échantillon. »*

Le serveur envoie bien la notification au chef dégustateur, en excluant l'auteur
(`backend_new/notifications/signals.py:165-174`), mais le texte est :

```
Une evaluation de {reference} a ete soumise.
```

**Le nom du dégustateur n'y est pas.** L'auteur est pourtant disponible : `instance.degustateur`
est utilisé juste au-dessus pour l'exclusion.

À faire : ajouter le prénom et le nom du dégustateur au message, sur le même modèle que
`views.py:118` et `:167` qui écrivent déjà `{prenom} {nom}` pour les demandes urgentes.

### Écart 2 — La notification de modification est trop étroite

Le document 3.6 demande une notification quand *« le collecteur modifie les détails d'un
échantillon »*.

Aujourd'hui `backend_new/notifications/signals.py:107-122` ne se déclenche que si
`statut_labo`, `statut_ceo` ou `variete` a changé. Modifier la quantité estimée, les remarques,
le gouvernorat, la référence bouteille, le numéro de citerne, la délégation ou la cité ne
prévient **personne**.

À faire : élargir la liste des champs qui déclenchent `ECHANTILLON_MODIFIE` pour couvrir les
détails que le collecteur saisit réellement. La liste des champs saisis par le collecteur se lit
dans `lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart:98-101` et dans le
formulaire d'ajout.

Attention à ne pas provoquer une avalanche : une modification doit produire **une** notification,
pas une par champ changé.

### Écart 3 — La date de livraison ne prévient personne

Le document 3.6 demande une notification quand *« le collecteur fixe ou modifie la date de
livraison »*. Le propriétaire y tient : c'est ce qui permet au dégustateur de savoir ce qui
arrive.

**Rien de tel n'existe.** Les champs `date_livraison_stock` et `date_livraison_stock_fin`
(`backend_new/echantillons/models.py:103-104`) ne sont pas dans le test de
`signals.py:108-112`. L'application `backend_new/planifications/` n'a **ni `signals.py`, ni
import de `Notification`**. Les seules traces sont deux types présents uniquement dans les
données de démonstration Flutter (`DATE_LIVRAISON_AJOUTEE`, `DATE_LIVRAISON_MODIFIEE`,
`lib/3_degustateur/notifications/services/notification_degustateur_service.dart:95-116`) et une
note de souhait dans `files/notifications/02_ceo.md:39-40`.

À faire : créer la notification côté serveur, envoyée à **tous les dégustateurs, y compris le
chef dégustateur** (c'est ce que dit le document 3.6). Réutilise les deux types déjà nommés
dans les données de démonstration plutôt que d'en inventer d'autres — même chose, même nom.

**Sur les migrations :** ajouter une valeur à `Type` produit une migration. Ici c'est autorisé,
sans poser de question, parce que le précédent est établi : `0002_alter_notification_section_alter_notification_type.py`,
`0004_alter_notification_type.py` et `0005_alter_notification_type.py` existent déjà et ne font
que ça. Signale simplement la migration créée dans ton rapport. Toute autre modification de la
base reste soumise à la règle du `PROTOCOLE.md` : tu poses la question.

### Écart 4 — Un nom de type qui ne correspond pas

Le serveur envoie le type `EVALUATION_URGENTE`
(`backend_new/notifications/models.py`, `views.py:130-195`).

Les pages du dégustateur et du chef dégustateur ne connaissent que `DEGUSTATION_URGENTE`
(`lib/3_degustateur/notifications/notifications_degustateur_page.dart:365` et le même endroit
côté chef). La notification arrive donc, mais sans sa bonne icône ni sa bonne couleur.

À faire : aligner sur le nom du serveur, `EVALUATION_URGENTE`, dans les deux pages et dans les
données de démonstration qui utilisent l'ancien nom. C'est la règle 1 du `CLAUDE.md`.

Pendant que tu y es, vérifie les types du tableau de bord de la direction
(`lib/1_ceo/notifications/services/notification_ceo_service.dart:9-80`) : ils sont écrits en
**minuscules** alors que le serveur utilise des majuscules. Si ce n'est que des données de
démonstration, dis-le dans ton rapport et corrige. Si cela touche du vrai code d'affichage,
signale-le sous `## HORS PÉRIMÈTRE`.

---

## Une question à poser, pas à décider

Le document 3.3 dit que l'évaluation urgente va au **« dégustateur concerné »**.
Le serveur l'envoie à **tous** les dégustateurs actifs **et** au chef dégustateur
(`backend_new/notifications/views.py:155-158`), et le message affiché au PDG après l'envoi dit
« Notification urgente envoyée à tous les dégustateurs »
(`analyse_organoleptique_ceo_page.dart:336`).

La même hésitation est déjà notée dans `files/notifications/02_ceo.md:91-105`.

**Ne change rien à ce comportement.** Écris la question sous `## QUESTION` : faut-il prévenir un
seul dégustateur, tous les dégustateurs, et le chef reçoit-il aussi ?

---

## Ce que tu ne fais pas

- Tu ne touches pas au dossier `files/notifications/`. Son `README.md` dit lui-même, ligne 4,
  que rien n'y est validé ni implémenté. C'est un dossier de réflexion, pas une spécification.
- Tu ne fais pas marcher les boutons avec les données de démonstration. Le vrai serveur arrive,
  c'est la décision du propriétaire.
- Tu n'ajoutes aucune navigation nouvelle au clic sur une notification. Aujourd'hui seule la
  section « évaluations » ouvre l'échantillon ; le collecteur
  (`mes_echantillons_page.dart:114-116`) et le laboratoire
  (`notifications_labo_page.dart:213`) n'ont aucune navigation. C'est un sujet à part, non
  décidé par le propriétaire — signale-le sous `## HORS PÉRIMÈTRE`.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
./backend_new/venv/Scripts/python.exe backend_new/manage.py test --keepdb
```

`backend_new/notifications/tests.py` contient déjà 15 tests (`NotificationApiTests` L13,
`NotificationSignalTests` L315). Ajoute un test de signal pour la notification de date de
livraison, et un test qui vérifie que le nom du dégustateur apparaît dans le message
« évaluation soumise ».

Donne les sorties chiffrées réelles dans ton rapport.
