# Retours d'utilisation — critiques, décisions et questions ouvertes

Document écrit à partir de sessions de test de l'application, en tant qu'utilisateur (pas en
tant que développeur). On critique le **fonctionnement**, pas le code.

On avance **plateforme par plateforme**. Chaque nouvelle session ajoute une section.

| Plateforme | Statut |
|---|---|
| Connexion | Vu — rien à changer |
| Collecteur | Vu — 9 points |
| Dégustateur (normal) | En cours — notifications, gestion et évaluation des échantillons |
| Chef dégustateur | Partiellement — il partage les mêmes pages que le dégustateur |
| Laboratoire | Pas encore vu |
| Direction (PDG) | Pas encore vu |

Aucune modification de code n'a été faite. C'est une liste de choses à décider et à corriger.

**Suite donnée.** Les points décidés de ce document sont découpés en huit tâches exécutables,
listées dans [`files/taches/README.md`](../files/taches/README.md) (tâches 05 à 12). Les
paragraphes marqués **« Vérifié dans le code »** ont été confrontés au code réel le 27/08/2026,
et certains disaient autre chose que ce qui avait été observé à l'écran.

---

## 1. Page de connexion

Rien à changer.
Email, mot de passe, mot de passe oublié : tout est correct et la connexion fonctionne.

---

## 2. Compte Collecteur

### 2.1 Champ de recherche : le texte d'aide est coupé

**Le problème.** Dans la page « Mes échantillons », le champ de recherche affiche
« Rechercher référence, fournisseur, localisation… ». Le texte est plus grand que la place
disponible, donc la fin est remplacée par trois points. L'utilisateur ne voit jamais la liste
complète de ce qu'il peut chercher.

**Vérifié dans le code.** Les trois points ne sont **pas** un débordement : le caractère `…`
est écrit littéralement dans le texte, à `mes_echantillons_page.dart:775`, et le mot exact est
« gouvernorat », pas « localisation ». Le vrai défaut est ailleurs : la recherche cherche aussi
dans la **variété** (`mes_echantillons_page.dart:131-139`), ce qui n'est jamais annoncé.

**À faire.** Réécrire le texte d'aide pour qu'il annonce les quatre champs réellement cherchés
— référence, fournisseur, gouvernorat, variété — sans le caractère `…`, en réduisant la taille
si nécessaire. → **tâche 05**

### 2.2 Boutons de filtre

Il y a quatre boutons : « Tous », « Enregistré », « Négociation » et « Achat conclu »
(`mes_echantillons_page.dart:829-889`).

**Vérifié dans le code.** Le bouton « Inclure achetés » noté ici n'existe pas. Il s'appelle
« Achat conclu ». Aucun autre retour pour l'instant.

### 2.3 Modification d'un échantillon : règle actuelle correcte

Le collecteur peut modifier **ou supprimer** un échantillon **seulement** tant que :
- les dégustateurs ne l'ont pas encore évalué, **et**
- l'échantillon n'est pas encore arrivé physiquement à l'entreprise.

Une fois ces deux étapes passées, la modification et la suppression sont bloquées.
C'est bien comme ça. Rien à changer.

Conséquence importante sur l'historique des valeurs : voir la section 6.

### 2.4 Détails de négociation : unité et montants

**Le problème.** Dans le budget proposé, le prix est affiché **par litre**.
L'entreprise ne travaille jamais en litres. Elle travaille en **tonnes**.

**À faire.**
1. La tonne devient l'unité par défaut partout. Le litre disparaît de cet écran.
2. Le prix par tonne est déjà affiché : le garder.
3. Ajouter la **quantité proposée par le PDG** (en tonnes).
4. Ajouter le **prix total** = quantité × prix par tonne.

Donc trois lignes visibles dans les détails de négociation :

| Ligne | Exemple |
|---|---|
| Quantité proposée | 30 T |
| Prix par tonne | 8 000 DT / T |
| Prix total | 240 000 DT |

### 2.5 Confirmation de négociation : champ remarque manquant

**À faire.** Dans la fenêtre de confirmation de la négociation, ajouter un champ
« Remarque du collecteur ». Le collecteur doit pouvoir écrire un commentaire libre au moment
où il confirme.

### 2.6 Photos : on ne sait pas à quelle bouteille appartient la photo

**Le problème.** Le collecteur enregistre un fournisseur, puis ajoute **plusieurs**
échantillons pour ce même fournisseur, dans **un seul formulaire**. Il peut prendre une photo.
Mais comme il n'y a qu'un seul formulaire, la photo n'est rattachée à aucun échantillon
précis. On ne sait pas de quelle bouteille il s'agit.

**Solution proposée.**

| Situation | Comportement |
|---|---|
| 0 échantillon saisi, il tente d'ajouter une photo | Message : « Remplissez d'abord les détails de l'échantillon pour ajouter une photo. » |
| 1 échantillon saisi | La photo est rattachée automatiquement à cet échantillon. Aucune question. |
| 2 échantillons ou plus | Fenêtre : « À quelle bouteille appartient cette photo ? » avec la liste des bouteilles saisies. |

### 2.7 Remarques : même problème que les photos

Même règle que le point 2.6. Quand le collecteur écrit une remarque et qu'il y a plusieurs
bouteilles, on lui demande à quelle bouteille la remarque appartient. Il peut écrire ce qu'il
veut.

### 2.8 Recherche par dates : la signification des dates n'est pas claire

Le collecteur peut chercher par dates. Deux dates posent question.

**Date d'arrivée de l'échantillon à l'entreprise.**
Est-ce la date où l'échantillon est **physiquement reçu** à l'entreprise, ou la date que le
collecteur a **prévue** pour l'arrivée ? Les deux ne sont pas la même chose et il faut
choisir. Voir la question 5 en section 7.

**Date d'arrivée du stock.**
Même question. Ici l'hypothèse est que c'est la date **prévue** d'arrivée, parce que personne
dans l'application ne vient confirmer que le stock est réellement arrivé. À confirmer.

### 2.9 Référence bouteille : la construire automatiquement

**Le problème.** Aujourd'hui la référence de la bouteille est écrite à la main. Sur beaucoup
de bouteilles pour un même fournisseur, c'est long et il peut y avoir des erreurs ou des
doublons.

**À faire.** Pendant l'enregistrement des petites bouteilles d'échantillon qui appartiennent
au même fournisseur, le collecteur saisit dans cet ordre :

1. le nom **ou** le code du fournisseur
2. le numéro de la citerne
3. la quantité

Et la référence de la bouteille s'écrit **toute seule**, sous cette forme :

```
codeounomfournisseur_numerociterne_quantiteT
```

Exemple avec le bordereau : fournisseur `S.T`, citerne `C3`, quantité `30` donne :

```
S.T_C3_30T
```

Le collecteur ne tape plus la référence lui-même.

**Petit point à confirmer.** Le « T » à la fin veut dire tonnes, donc la quantité utilisée
dans la référence est celle de la citerne (30 T), pas le volume de la petite bouteille
(1 litre). À valider.

---

## 3. Compte Dégustateur (dégustateur normal)

Cette plateforme est riche. Elle sera revue en plusieurs fois. Pour l'instant, seule la
partie **notifications** a été traitée.

### 3.1 Blocage pour les tests

**Vérifié dans le code : le mock n'est pas désactivé. C'est le serveur Django qui ne
répondait pas.**

L'application appelle `http://127.0.0.1:8000` (`lib/config.dart:6-9`). Quand ce serveur ne
répond pas, la fonction `avecSecours()` (`lib/core/services/resultat_service.dart:21-35`)
affiche des données de démonstration **en lecture** et refuse toute **écriture**. D'où le
message « Action indisponible avec les données de démonstration, réessayez lorsque le serveur
répond » vu sur le bouton de notification
(`3_degustateur/gestion_echantillons/gestion_echantillons_page.dart:153-176`).

Le bandeau « Données de démonstration — serveur injoignable »
(`lib/core/widgets/bandeau_demonstration.dart:30`) l'annonce déjà en haut de l'écran.

**Rien à coder.** Pour tester les boutons, il faut démarrer le backend Django.

### 3.2 Notifications : qui envoie quoi au dégustateur

Tableau complet des échanges de notifications qui concernent le dégustateur normal.

| Entre | Notification ? | Détail |
|---|---|---|
| Dégustateur ↔ Dégustateur | **Non** | Les dégustateurs ne s'envoient rien entre eux. |
| Direction (PDG) → Dégustateur | **Oui** | Voir 3.3 |
| Dégustateur → Chef dégustateur | **Oui** | Voir 3.4 |
| Dégustateur → Technicien laboratoire | **Oui** | Voir 3.5 |
| Collecteur → Dégustateurs (et chef dégustateur) | **Oui** | Voir 3.6 |

### 3.3 Direction → Dégustateur : évaluation urgente

**Quand.** La direction clique sur le bouton « évaluation urgente ».

**Qui reçoit.** Le dégustateur concerné.

**Ce qui est écrit.** « Évaluation urgente » + la référence de l'échantillon.

**Ce qui se passe au clic.** L'application ouvre directement l'échantillon concerné, celui
sur lequel l'évaluation urgente doit être faite.

### 3.4 Dégustateur → Chef dégustateur : évaluation soumise

**Quand.** Un dégustateur soumet une évaluation.

**Qui reçoit.** Le chef dégustateur.

**Ce qui est écrit.** Le nom du membre qui a soumis + la référence de l'échantillon.

### 3.5 Dégustateur → Technicien laboratoire : analyse urgente

**Quand.** Le dégustateur a besoin du résultat d'analyse rapidement.

**Qui reçoit.** Le technicien de laboratoire.

**Ce que ça fait.** Le dégustateur peut envoyer une demande d'**analyse urgente** au
laboratoire, pour un échantillon précis, pour lui demander de traiter cet échantillon en
priorité.

### 3.6 Collecteur → Dégustateurs : mouvement sur un échantillon

**Qui reçoit.** Tous les dégustateurs, **y compris le chef dégustateur**.

**Trois cas déclenchent une notification :**

1. le collecteur soumet un **nouvel** échantillon ;
2. le collecteur **modifie les détails** d'un échantillon ;
3. le collecteur **fixe ou modifie la date de livraison** de l'échantillon.

### 3.7 Petit point non tranché

Le sens inverse n'a pas été évoqué : est-ce que le dégustateur envoie parfois une
notification à la **direction** ? Pour l'instant on ne prévoit rien dans ce sens. À
confirmer plus tard.

### 3.8 Page « Gestion des échantillons »

**Ce qui va bien.** L'ensemble de la page est correct. Les boutons de filtre « Évalué »,
« En cours » et « Évaluation soumise » sont bons. Rien à changer de ce côté.

**Important.** C'est **la même page pour le dégustateur et pour le chef dégustateur**. Toute
modification décidée ici s'applique donc automatiquement aux deux rôles. Elle doit être faite
**une seule fois, dans un seul fichier** — pas copiée dans le module du chef dégustateur.

**Un seul point à ajouter :** le filtre par dates, décrit en 3.10.

### 3.9 Page « Évaluation des échantillons »

Tout est correct sur cette page. Rien à changer.

Une seule chose à ajouter : **le même filtre par dates** que celui décrit en 3.10. Exactement
le même comportement que dans la page de gestion des échantillons, pas une deuxième version
écrite différemment.

### 3.10 Filtre par dates : trois dates différentes

**Où.** Sur le bouton calendrier, dans **trois pages** :
- Gestion des échantillons
- Évaluation des échantillons
- Analyses laboratoire (voir 3.11)

**Pour qui.** Le dégustateur **et** le chef dégustateur.

**Le problème.** Aujourd'hui le calendrier ne distingue pas les différents sens qu'une date
peut avoir. Or le dégustateur a trois besoins différents.

**À faire.** Permettre de choisir sur quelle date on filtre :

| Date | Ce que le dégustateur cherche | Exemple |
|---|---|---|
| Date d'ajout dans l'application | Les échantillons qui viennent d'être enregistrés par le collecteur | « Qu'est-ce qui a été saisi aujourd'hui ? » |
| Date de livraison prévue | Les échantillons qui **vont** arriver à cette date | « Qu'est-ce qui arrive le 26 octobre 2026 ? » |
| Date de présence physique confirmée | Les échantillons **réellement** présents dans l'entreprise à cette date | « Qu'est-ce qui est arrivé pour de vrai ce jour-là ? » |

**Précision sur la troisième date.** C'est la date du jour où quelqu'un a appuyé sur le bouton
de confirmation de présence physique. Pas une date prévue, une date constatée.

**Lien avec un point encore ouvert.** Qui appuie sur ce bouton de présence physique n'est pas
encore décidé — voir la section 5 et la question 7. Ce filtre dépend de cette décision.

### 3.11 Page « Analyses laboratoire » : aligner la carte sur celle de la direction

Cette page existe pour le dégustateur et le chef dégustateur, et les deux partagent déjà le
même fichier de carte (`lib/core/widgets/analyse_labo/analyse_card.dart`).

**Vérifié dans le code : les deux captures comparées ne viennent pas de la même page.**
La carte avec « Approuver » et « Refuser » est celle de la page **Analyse organoleptique** de
la direction (`lib/1_ceo/analyse_organoleptique/widgets/panel_section.dart:68-144`). Celle du
dégustateur est la page **Analyses laboratoire**. Ce sont deux écrans différents, avec deux
modèles de données différents. La demande reste valable : il s'agit d'ajouter trois éléments à
la carte du dégustateur, pas d'aligner deux versions d'une même carte. → **tâche 10**

**Ce qui est bien et qu'il faut garder.** La carte de la direction a les boutons
« Approuver » et « Refuser ». Le dégustateur ne les a pas. C'est correct, il ne doit pas les
avoir.

**Ce qu'il manque au dégustateur.** Trois choses présentes sur la carte de la direction et
absentes de celle du dégustateur.

| Élément | Chez la direction | Chez le dégustateur aujourd'hui | À faire |
|---|---|---|---|
| Bouton urgent | Bouton avec l'icône cloche **et** le mot « Urgent » | Seulement une petite icône cloche, sans mot | Mettre exactement le même bouton que la direction : même icône, même mot « Urgent » |
| Quantité | Pastille « Qté : 12T » bien visible | Absente | Afficher la quantité sur la carte du dégustateur aussi |
| Numéro d'enregistrement | La référence en haut (`CHEMLALI-C4`), et juste en dessous le numéro dans l'application (`2026/0002`) | La référence en haut, mais pas ce numéro en dessous | Reprendre la même structure : référence en haut, numéro d'enregistrement en dessous |

**Règle générale à retenir.** La carte d'échantillon doit être **la même partout**. Ce qui
change d'un rôle à l'autre, ce sont uniquement les boutons d'action autorisés (« Approuver »
et « Refuser » réservés à la direction). La mise en page, la quantité, la référence et le
numéro sont identiques pour tout le monde.

**Point vérifié — ce n'est pas un défaut.** `ANL-188-2026` et `ECH-EN-ATTENTE` sont deux
valeurs de démonstration écrites en dur dans
`lib/core/analyses/ligne_analyse_labo_service.dart:105-143`. Elles ne s'affichent que lorsque
le serveur ne répond pas, et disparaîtront avec le vrai backend.

**À ajouter aussi.** Le même bouton calendrier et le même filtre par dates que dans les deux
autres pages — voir 3.10.

---

## 4. Ce que montre le bordereau papier

Photo fournie : « Bordereau de réception des échantillons d'information », Al Jazira,
N° 0041, daté du 26/10/2025.

Faits observés sur le papier :

- Une seule feuille contient **plusieurs fournisseurs** à la fois.
- Colonnes du papier : Gouvernorat / Zone, Code fournisseur, Référence bouteille, Scellage,
  Achat confirmé, Camion réservé, Remarques.
- Chaque fournisseur a **plusieurs citernes**, chacune avec sa propre quantité en tonnes.
  Exemples lus sur la photo :
  - Saâd Talbi (code S.T, zone Zaâfrana) : C1 – 10 T, C2 – 10 T, C3 – 30 T, C5 – 2 T
  - Hatem Douzi (code H.D, zone Bouhajla) : C2 – 30 T, C5 – 30 T
  - Ridha Amari (code R.A) : P1 – 15 T, P2 – 15 T, P5 – 25 T, P6 – 25 T, P7 – 20 T,
    P8 – 20 T, C1 – 60 T, C2 – 60 T, C3 – 60 T
  - F. Smara (code F.S) : P6 – 13 T, P7 – 13 T, P8 – 13 T
  - K. Sidaoui (code K.S, zone Zaâfrana) : C8 – 63 T – 1 litre, C9 – 63 T – 1 litre
- Les tonnages sont donc **écrits sur le bordereau dès la réception des échantillons**, avant
  toute dégustation.
- La mention « 1 litre » à côté de deux lignes correspond au volume de l'échantillon prélevé.
- Les colonnes « Achat confirmé » et « Camion réservé » sont vides sur cette feuille : elles
  sont remplies plus tard.

**Ce que ça remettait en cause — résolu le 27/08/2026.** La crainte était que l'application,
qui donne un stock à chaque échantillon, ne corresponde pas au papier, qui liste des citernes
par fournisseur.

Réponse donnée : **une bouteille est prélevée par citerne**, et **la quantité est connue dès le
dépôt**. C'est exactement ce que fait déjà l'application : le modèle `EchantillonCollecteur`
porte `numCiterne` et `quantiteEstimee` par échantillon
(`echantillon_collecteur.dart:99-100`), et le formulaire d'ajout demande déjà les deux,
bouteille par bouteille.

**Rien à restructurer.** Cette section devient une note de contexte.

---

## 5. Phase de réception : à rediscuter, avec le laboratoire

Ce sujet n'est pas tranché. Il doit être rediscuté avant de coder.

**Ce qu'on observe dans la réalité.** C'est le **technicien de laboratoire** qui reçoit
physiquement les bouteilles en premier. C'est lui le premier à les avoir en main dans
l'entreprise.

**Ce qu'on veut éviter.** Que le collecteur puisse encore modifier ou supprimer un échantillon
alors que la bouteille est déjà arrivée dans l'entreprise. Ce n'est pas forcément de la
mauvaise volonté : c'est surtout le risque d'un geste accidentel.

**Le raisonnement.** Plus la réception physique est constatée **tôt** dans l'application, plus
vite l'échantillon est verrouillé, et moins il y a de risque de modification ou de suppression
par le collecteur. Comme le laboratoire est le premier à voir les bouteilles, c'est lui qui
pourrait déclencher ce verrouillage le plus tôt.

**La tension à résoudre.** On ne veut pas donner beaucoup de travail au technicien de
laboratoire dans l'application. Son rôle doit rester léger. Mais on veut quand même qu'il
puisse intervenir sur ce point précis.

**Pistes à discuter.**
- Le laboratoire coche simplement « bouteilles reçues » à l'arrivée. Une seule action, rien
  d'autre.
- Ou une autre personne fait ce constat, si on estime que même une case à cocher est de trop
  pour le laboratoire.
- Dans les deux cas : à partir de ce constat, l'échantillon devient non modifiable et non
  supprimable par le collecteur.

**Décision prise le 27/08/2026 : on ne change rien.** Le bouton de réception physique reste
au **dégustateur** (et au chef dégustateur). Vérifié dans le code : c'est déjà le cas, et eux
seuls y ont droit (`backend_new/echantillons/views.py:223-239`, permission
`IsDegustateur | IsChefDegustation`).

Le sujet du laboratoire reste ouvert pour plus tard, mais il est **hors du plan de travail
actuel**. Rien à coder.

---

## 6. Décision : plus d'historique ancienne valeur / nouvelle valeur

**Ce qui était prévu avant.** Quand un échantillon était modifié après sa réception physique,
l'application devait garder l'ancienne valeur et la nouvelle, et montrer les deux à tous les
rôles.

**Ce qui est décidé maintenant : on supprime ça.**

**Pourquoi.** Cette règle n'a plus de raison d'être. Le collecteur ne peut modifier ou
supprimer un échantillon que **tant qu'il n'est pas arrivé physiquement** dans l'entreprise
(règle 2.3). Une fois l'échantillon reçu, il ne peut plus rien changer du tout. Donc il n'y a
jamais de modification « après coup » à tracer.

**Ce qu'on fait à la place.** La modification s'affiche simplement telle quelle, avec la
nouvelle valeur. Pas d'ancienne valeur affichée à côté.

**Attention.** Ce point contredit une règle actuellement écrite dans le fichier `CLAUDE.md`
du projet, à la section « Sample States » :
« *Once `recuPhysiquement = true`, any field edit must store the previous value. All roles see
old + new values.* »
Cette ligne devra être supprimée ou réécrite dans `CLAUDE.md` en même temps que le code.

---

## 7. Questions à poser dans l'entreprise

À poser à quelqu'un qui fait le travail réellement. Les réponses changent le déroulement
complet de l'application, donc à traiter avant de coder quoi que ce soit.

### Question 1 — Le collecteur donne-t-il la quantité dès le départ ?

Quand le collecteur apporte les échantillons à l'entreprise, est-ce qu'il indique **en même
temps** la quantité de stock disponible chez le fournisseur ? Et le prix ?

Le bordereau semble dire oui : les tonnes sont écrites dès la réception des échantillons.

**RÉPONDU le 27/08/2026 — oui, dès le dépôt.** Et l'application le fait déjà : le formulaire
d'ajout du collecteur demande la quantité estimée en tonnes pour chaque bouteille
(`formulaire_dialog.dart:1045-1052`). L'ordre de travail est le bon, il n'y a pas d'attente
inutile à supprimer.

### Question 2 — Une citerne = un échantillon ?

Pour un même fournisseur il y a plusieurs citernes (C1, C2, C3…), chacune avec sa quantité.

- Est-ce qu'on prélève **un échantillon par citerne** ?
- Ou est-ce qu'un seul échantillon représente **plusieurs citernes** du même fournisseur ?
- Ou est-ce que plusieurs échantillons du même fournisseur partagent **une seule** citerne ?

**RÉPONDU le 27/08/2026 — une bouteille par citerne.** Le stock reste donc attaché à
l'échantillon, comme aujourd'hui. Aucune restructuration.

### Question 3 — Comment le collecteur saisit-il autant de citernes ?

Un fournisseur peut avoir 9 citernes (exemple Ridha Amari sur le bordereau). Il faut savoir
comment il fait dans la vraie vie pour tout noter, sinon la saisie dans l'application sera
trop longue.

**Toujours ouverte**, mais moins urgente : le formulaire permet déjà d'ajouter plusieurs
bouteilles d'un coup pour un même fournisseur, et la tâche 07 supprime la saisie manuelle de la
référence, qui était le plus long à taper.

### Question 4 — Le PDG propose la quantité sur quoi exactement ?

Le PDG propose une quantité et un prix. Est-ce que sa proposition porte sur :

- une citerne précise,
- l'ensemble des citernes d'un fournisseur,
- ou l'échantillon ?

Et le collecteur confirme la négociation pour la même chose ?

### Question 5 — Quelle date compte pour le travail du collecteur ?

Pour l'arrivée de l'échantillon à l'entreprise : est-ce la date de **réception réelle** ou la
date **prévue** par le collecteur ? Laquelle sert vraiment dans le travail de tous les jours ?

### Question 6 — Qui confirme que le stock est arrivé ?

Aujourd'hui, personne dans l'application ne coche « le stock est arrivé ». Est-ce que
quelqu'un devrait le faire ? Sinon, la date d'arrivée du stock restera toujours une date
prévue, jamais une date confirmée.

### Question 7 — Qui constate en premier l'arrivée physique des bouteilles ?

**RÉPONDU le 27/08/2026 — on garde le dégustateur.** Voir la section 5.

---

## 8. Point d'attention général

L'application sera utilisée pendant une période de très gros volume de travail. Toute étape
d'attente ajoutée (attendre la dégustation avant de saisir le stock, ressaisir un fournisseur
citerne par citerne) doit être justifiée. Si le papier fait les choses en une fois,
l'application ne doit pas les faire en trois.
