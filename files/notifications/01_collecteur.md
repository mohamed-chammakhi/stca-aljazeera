# Collecteur — Notifications & Idées

> Carnet d'idées brut, organisé. Non validé, non implémenté.
> Dernière mise à jour : 2026-08-01

---

## 1. Notifications ÉMISES par le collecteur

### 1.1 — Confirmation d'achat
**Déclencheur :** le collecteur confirme l'achat d'un échantillon (`Achat confirmé`)
**Destinataires :** les autres utilisateurs (à préciser lesquels exactement)

⚠️ **Problème — spam de notifications**
Si tout le monde reçoit la notification à chaque confirmation, ça génère un flux
massif → confusion, notifications noyées.
Pistes non tranchées :
- limiter les destinataires par rôle (qui a réellement besoin de savoir ?)
- regrouper (une notification « 5 achats confirmés aujourd'hui » au lieu de 5)
- distinguer notification *push* vs simple entrée dans un centre de notifications

⚠️ **Problème — date de livraison obligatoire ou non ?**
Quand le collecteur confirme l'achat, doit-il **obligatoirement** saisir une date de
livraison de l'échantillon ? → considéré comme **très nécessaire**.
À trancher : champ obligatoire bloquant, ou optionnel avec relance ?

⚠️ **Problème — modification des dates mal configurée**
Le collecteur peut changer les dates, mais cette optionnalité n'est **pas bien
configurée dans le projet** :
- qui a le droit de modifier une date déjà confirmée ?
- une modification de date doit-elle re-notifier les destinataires ?
- lien avec la règle existante « une fois `recuPhysiquement = true`, tout edit doit
  conserver l'ancienne valeur » → la modification de date doit-elle suivre la même
  règle d'historique (ancienne date + nouvelle date visibles) ?

---

### 1.2 — Confirmation physique de réception (page « Mes échantillons »)
**Déclencheur :** le collecteur clique sur le bouton *check* dans sa page
« Mes échantillons » (que le bouton soit activé ou désactivé)
**Comportement souhaité :** afficher un petit **ruban / bandeau** au clic, exactement
comme dans la page *Gestion des échantillons* du dégustateur.

Texte du ruban : « confirmation physique de réception » — ⚠️ **vocabulaire à revoir**,
trouver une formulation plus propre / plus courte en français.

Référence d'implémentation existante :
[`lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart`](../../lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart)

---

## 2. Notifications REÇUES par le collecteur

### 2.1 — Détails de négociation
**Émetteur :** CEO
**État actuel :** le collecteur reçoit uniquement le **nom de l'échantillon** + une
mention générique « détails de négociation ».

⚠️ **Problème — contenu trop pauvre**
Il manque le contenu réel de la négociation (prix / intervalle proposé, conditions,
qui a proposé quoi). À définir : que doit contenir exactement cette notification ?

---

### 2.2 — Mise à jour de négociation
**Émetteur :** CEO
❓ **Manque fonctionnel :** il faut créer une action **« mettre à jour la négociation »**
côté CEO — elle n'existe pas aujourd'hui. La notification de mise à jour en découle.

---

### 2.3 — Confirmation « stock reçu »
**Émetteur :** à préciser (probablement CEO ou l'acteur qui réceptionne le stock)
**Contenu :** confirmation que le stock a bien été reçu.

---

### 2.4 — Confirmation « échantillon reçu »
**Émetteur :** dégustateur / chef dégustateur
**Déclencheur :** clic sur le bouton de réception physique.

Règle demandée (bidirectionnelle) :
- **clic** → le collecteur reçoit une notification
- **déclic / annulation** → le collecteur reçoit aussi une notification

Effets de bord attendus quand un échantillon est marqué reçu :
- il **apparaît chez le laboratoire**
- il **apparaît dans la page d'évaluation** du dégustateur **et** du chef dégustateur

---

## 3. Calendrier & dates (soulevé côté collecteur, sujet transverse)

### 3.1 — Le calendrier doit se caler sur 3 types de dates
Le calendrier doit changer selon l'option de date choisie :

1. **Livraison / arrivée du stock** par le collecteur — à une date spécifique
2. **Livraison de l'échantillon** par le collecteur — à une date spécifique
3. **Date d'enregistrement de l'échantillon** dans l'app

❓ À trancher : filtre unique avec sélecteur de type de date, ou 3 vues distinctes ?

---

### 3.2 — Saisie manuelle de la date dans la recherche
⚠️ **Problème :** aujourd'hui, quand l'utilisateur **écrit** la date au lieu de la
choisir dans le calendrier, ça ne fonctionne pas bien.

**Comportement souhaité** (comme sur la plupart des sites web) :
- l'utilisateur tape les chiffres
- les séparateurs `/` s'insèrent **automatiquement**
- le curseur **saute automatiquement** au champ suivant quand la valeur est complète
  (ex : je tape `31` dans le jour → saut automatique vers le mois)

✅ **LE COMPOSANT EXISTE DÉJÀ DANS LE PROJET — rien à écrire, rien à chercher ailleurs**

[`lib/3_degustateur/gestion_echantillons/widgets/date_input_field.dart`](../../lib/3_degustateur/gestion_echantillons/widgets/date_input_field.dart)

Son en-tête dit exactement ce que tu demandes :
> « reusable date input — auto-format, clamping, calendar picker, real-time preview »

Ce qu'il fait déjà :
- insertion automatique des `/` aux positions 2 et 4 → `JJ/MM/AAAA`
- **clamping** : un jour saisi > 31 est ramené à 31, un mois > 12 à 12
- sélecteur calendrier **et** saisie manuelle passent par la **même validation**
- aperçu en temps réel

→ **À réutiliser tel quel** dans la barre de recherche du collecteur (et partout où une
date se saisit). Usage : `DateInputField(controller: dateCtrl)`.

❓ Seul point à vérifier : il vit aujourd'hui dans le module `3_degustateur/`. S'il sert à
plusieurs rôles, faut-il le déplacer dans un dossier partagé (`core/` ou `widgets/`) ?

---

### 3.3 — Intervalle de négociation côté CEO (impacte le collecteur)
Le CEO doit pouvoir définir les détails de négociation sous forme d'**intervalle**
(en option — pas obligatoire).

⚠️ **Problème :** le CEO ne peut saisir que des **nombres**. La façon d'écrire un
intervalle est compliquée :
- il faudrait un séparateur (`/` ou autre) indiquant clairement l'intervalle
- ❌ **pas** deux sélecteurs type calendrier côte à côte → trop lourd, trop chargé
  visuellement

❓ **Décision UI à trouver :** une solution propre pour saisir « de X à Y » dans un
seul champ, sans surcharger l'écran.

---

## 4. Barre de recherche (page listes du collecteur)

### 4.1 — Le hint doit montrer TOUS les critères, pas des « ... »
**État actuel :** le hint gris de la barre de recherche est tronqué par des `...`,
donc le collecteur ne voit pas ce qu'il peut réellement chercher.

**Souhaité :** afficher **tous** les critères en clair dans le hint, quitte à
**réduire la taille de la police** du hint pour que tout tienne.

Critères recherchables par le collecteur :
- **Référence** (ref)
- **Fournisseur**
- **Zone / région**
- **Variété**

❓ À trancher : si même en police réduite ça ne tient pas, alternative possible
(hint qui défile en boucle, ou libellés sous la barre) — mais l'option retenue par
défaut reste : **tout afficher, police plus petite**.

---

### 4.2 — Autocomplétion depuis les valeurs déjà enregistrées
**Souhaité :** comportement type Google — dès que le collecteur tape quelques lettres,
l'app **suggère** des valeurs qui existent déjà dans le système.

Source des suggestions : les valeurs **saisies lors de l'enregistrement** des
échantillons (donc pas une liste figée).
Champs concernés en priorité : **variété** et **fournisseur** (et par extension zone).

Implication : ces valeurs doivent être **réellement enregistrées / persistées** dans
l'app comme référentiel réutilisable, pas juste stockées à plat dans chaque échantillon.

✅ **TRANCHÉ — l'autocomplétion sert AVANT TOUT à l'enregistrement, pas à la recherche**

L'autocomplétion doit être active dans le **formulaire d'enregistrement d'un nouvel
échantillon**. Deux bénéfices, le second est le vrai enjeu :

1. **Rapidité** — le collecteur ne retape pas un fournisseur déjà connu
2. ⚠️ **Intégrité des données du dashboard CEO** — le dashboard CEO affiche les
   **performances par fournisseur**. Si le nom du fournisseur change d'un échantillon
   à l'autre (« Ben Ali » / « ben ali » / « BenAli »), les agrégations sont **fausses** :
   un même fournisseur est compté comme plusieurs.

→ **Règle :** un échantillon doit être rattaché **au même nom de fournisseur** à chaque
fois. Le nom ne doit pas pouvoir devenir « n'importe quoi ».

✅ **TRANCHÉ (Q6) — le fournisseur devient une entité avec ID**

Le fournisseur n'est plus une simple chaîne recopiée dans chaque échantillon, mais une
**entité du référentiel référencée par un ID** (`fournisseur_id`).

⚠️ **Ça ne change rien à l'expérience de saisie : le collecteur écrit toujours librement.**
Il tape, l'autocomplétion propose les fournisseurs connus :
- il **clique sur une suggestion** → l'échantillon est rattaché à l'ID existant
- il **continue à écrire un nom nouveau** → un nouveau fournisseur est créé (avec le
  garde-fou anti-doublon du Q7 ci-dessous)

L'ID est une mécanique interne, invisible pour le collecteur. Aucun champ n'est bloqué en
liste déroulante fermée.

**Vérification faite dans le code — le dashboard agrège bien par fournisseur :**
[`lib/1_ceo/tableau_de_bord/models/dashboard_models.dart`](../../lib/1_ceo/tableau_de_bord/models/dashboard_models.dart)
```dart
class FournisseurStat {
  final String name;
  final String region;
  final int achats;
  final double valeur;
}
```
alimente `supplier_frequency_card.dart`. Donc **nom + région + nb achats + valeur** sont
agrégés par fournisseur → un nom mal orthographié = une ligne fantôme dans la carte.

💡 **Effet de bord utile :** `FournisseurStat` porte déjà une `region`. Si le fournisseur
est une entité, **la région vient avec lui** au lieu d'être re-saisie à chaque échantillon
→ un fournisseur ne peut plus se retrouver rattaché à deux régions différentes.

---

✅ **TRANCHÉ (Q7) — création d'un nouveau fournisseur : par le collecteur, avec garde-fou**

Le collecteur **peut** créer un nouveau fournisseur depuis le formulaire (indispensable
sur le terrain, parfois hors ligne). Mais avant création, l'app détecte les **quasi-doublons** :

> « Un fournisseur proche existe déjà : **Agricole Ben Ali** — c'est lui ? »
> [ Oui, c'est lui ]  [ Non, créer un nouveau ]

Pas de validation CEO requise (bloquerait le collecteur en déplacement).

---

✅ **TRANCHÉ (Q8) — variété : SAISIE LIBRE + autocomplétion, PAS de liste fermée**

Le collecteur **écrit la variété lui-même**. L'app l'aide avec une **autocomplétion façon
barre de recherche Google** : il tape quelques lettres, l'app propose les variétés déjà
enregistrées, il peut cliquer sur une suggestion ou continuer à écrire la sienne.

→ **Aucun champ n'est bloqué en liste déroulante fermée.** L'autocomplétion est une aide,
jamais une contrainte.

**Vérification faite :** la variété n'apparaît **dans aucun fichier de**
`lib/1_ceo/tableau_de_bord/` → elle n'entre dans **aucun calcul du dashboard CEO**.
Elle sert à l'affichage, aux filtres et à la recherche. Donc pas d'enjeu d'intégrité
dashboard qui justifierait de contraindre la saisie.

⚠️ Si la variété entre **plus tard** dans les calculs du dashboard, il faudra rouvrir la
question — à ce moment-là seulement.

---

✅ **TRANCHÉ (Q9) — zone / région : liste fermée avec ID**

Même traitement que le fournisseur. À noter : le projet a déjà un `GeoService`
([`lib/2_collecteur/carte_geo/services/geo_service.dart`](../../lib/2_collecteur/carte_geo/services/geo_service.dart))
qui parse `assets/img/delegations.geojson` → **la liste officielle des délégations existe déjà**.

→ La zone doit venir de cette source, pas d'une saisie libre. Ça garantit aussi la
cohérence avec la carte géographique et avec le champ `region` de `FournisseurStat`.

ℹ️ **C'est le seul champ réellement en liste fermée.** C'est justifié : les délégations
tunisiennes sont une liste **officielle et figée**, déjà présente dans l'app — le
collecteur n'a aucune raison d'en inventer une. Fournisseur et variété, eux, restent en
saisie libre assistée.

---

## 5. Détails d'un échantillon — date d'enregistrement (⚠️ transverse, tous les rôles)

La liste des échantillons est déjà triée du **plus récent au plus ancien**.
Il manque, dans la **page de détails** de l'échantillon, la **date d'enregistrement
dans l'app**.

Affichage souhaité : `Enregistré le JJ/MM/AAAA`

**Portée : TOUS les rôles** qui ont accès à une page de détails d'échantillon
(collecteur, CEO, dégustateur, chef dégustateur, laboratoire) — pas seulement le
collecteur.

Lien avec §3.1 : c'est la même donnée que le 3ᵉ type de date du filtre calendrier
(« date d'enregistrement de l'échantillon dans l'app ») → une seule source de vérité.

❓ À trancher : afficher aussi l'**heure** ? (utile si plusieurs échantillons le même jour)

---

## 6. Verrouillage après réception + messagerie Chef Dégustateur ↔ Collecteur

### 6.1 — Verrouillage
**Règle :** dès qu'un échantillon est **reçu physiquement dans l'entreprise**, le
collecteur ne peut **plus rien modifier ni supprimer** dessus.

L'échantillon devient en lecture seule côté collecteur : plus d'édition de champs,
plus de suppression.

✅ **TRANCHÉ (Q1) — qui peut encore modifier après réception**

| Rôle | Droit après réception physique |
|------|-------------------------------|
| **Collecteur** | ❌ aucune modification, aucune suppression — lecture seule |
| **Chef dégustateur** | ✅ peut modifier, **avec historique** (ancienne + nouvelle valeur) |
| **Dégustateur** | ✅ peut modifier, **avec historique** (ancienne + nouvelle valeur) |
| **CEO** | ❌ **ni modifier, ni ajouter, ni supprimer** un échantillon — exactement les mêmes restrictions que le collecteur verrouillé |
| **Laboratoire** | ❌ **jamais** — il ne modifie aucun échantillon (c'est déjà le fonctionnement actuel de l'app) |

✅ **TRANCHÉ (Q13) — le CEO ne touche jamais un échantillon.**
Il ne peut ni le **modifier**, ni en **ajouter** un, ni en **supprimer** un. C'est la règle
du collecteur verrouillé, appliquée au CEO en permanence.
Cohérent avec le `CLAUDE.md` : « le CEO supervise tout mais ne touche jamais un échantillon ».

✅ **TRANCHÉ — le laboratoire non plus.** Il produit ses analyses, il ne modifie pas
l'échantillon.

→ **Seuls le chef dégustateur et le dégustateur peuvent modifier un échantillon après
réception**, et toujours avec historisation (ancienne + nouvelle valeur).

ℹ️ **Ce que ces rôles font par ailleurs n'est pas une modification d'échantillon :** le CEO
saisit les détails de négociation (§2.1, §3.3) et valide les achats ; le laboratoire saisit
ses résultats d'analyse. Ce sont des objets **rattachés** à l'échantillon, pas les données
de l'échantillon lui-même.

⚠️ **Impact sur le `CLAUDE.md` du projet**
La règle actuelle dit :
> « Une fois `recuPhysiquement = true`, tout edit doit conserver l'ancienne valeur.
> Tous les rôles voient ancienne + nouvelle valeur. »

Elle reste **valide**, mais doit être **précisée** : l'historisation concerne les edits du
**chef dégustateur et du dégustateur**. Le collecteur, lui, n'a plus aucun droit d'édition
→ pour lui il n'y a rien à historiser.

Lien : cette règle recoupe D3 (§1.1) sur la modification des dates après confirmation
d'achat — la question reste ouverte pour les dates saisies **avant** réception.

---

### 6.2 — Messagerie (page indépendante dans le Drawer)

✅ **TRANCHÉ (Q2 + Q4) — messagerie générale, PAS un fil par échantillon**

C'est une **page à part entière**, accessible depuis le **Drawer**, comme n'importe quelle
autre section. Ce n'est **pas** un fil attaché à chaque échantillon.
Fonctionnement de référence : **Messenger**.

**Raison d'être :** puisque le collecteur ne peut plus corriger lui-même (§6.1), il lui
faut un canal pour signaler ce qui doit être modifié.

---

#### Qui parle à qui — règles de contacts (✅ tranché Q10 + Q11)
| Rôle | A une messagerie ? | Ses contacts possibles |
|------|--------------------|------------------------|
| **Chef dégustateur** | ✅ oui | **plusieurs collecteurs** (tous ceux de l'entreprise) + **CEO** |
| **Collecteur** | ✅ oui | **maximum 2 chefs dégustateurs** (ceux qui existent dans l'entreprise) + **CEO** |
| **CEO** | ✅ oui | **collecteurs** + **chefs dégustateurs** |

📝 **Vocabulaire du Drawer collecteur :** on écrit **« Messagerie Direction »**, jamais
« Messagerie CEO ».
| **Dégustateur** (simple) | ❌ **non** | — |
| **Laboratoire** | ❌ **non** | — |

⚠️ **Conséquence à noter :** le dégustateur simple **peut modifier** un échantillon après
réception (§6.1) mais **n'a pas de messagerie**. Donc si le collecteur constate une erreur
introduite par un dégustateur, il ne peut le signaler qu'au chef dégustateur ou au CEO,
qui relaiera. C'est cohérent hiérarchiquement — juste à assumer.

---

#### 💡 Référence à un échantillon dans un message
Un utilisateur peut **mentionner / référencer un échantillon** dans un message.
La référence est **cliquable** → elle ouvre la page de détails de cet échantillon,
**dans la version correspondant au rôle de celui qui clique** (le collecteur voit sa page
de détails, le chef dégustateur voit la sienne).

C'est ce qui remplace le « fil par échantillon » : le lien vers l'échantillon vit
**dans** le message, pas l'inverse.

---

✅ **TRANCHÉ (Q3) — notifications & non-lus, modèle Messenger**

1. **Notification système (push)** — comme n'importe quelle app, l'utilisateur peut
   l'**activer ou la désactiver** dans ses réglages
2. **Badge dans l'app** — à l'ouverture, un **compteur rouge** indique le nombre de
   messages non lus (sur l'entrée « Messagerie » du Drawer)
3. **Dans la page Messagerie** — l'expéditeur d'un message non lu est mis en évidence :
   **nom en gras** + **pastille / nombre rouge** sur sa conversation

---

✅ **TRANCHÉ (Q5) — confidentialité**
Seuls les **participants à la conversation** y ont accès. Personne d'autre — ni le CEO,
ni les autres rôles — ne peut lire un échange auquel il ne participe pas. Modèle Messenger.

---

✅ **TRANCHÉ (Q12) — pièces jointes autorisées**
Un message peut contenir une **pièce jointe / photo** (utile pour montrer un défaut, une
étiquette, un bidon…).

❓ Reste à préciser : types de fichiers acceptés (photo seule ou aussi PDF ?), taille max,
et comportement hors ligne (le collecteur est parfois sans réseau sur le terrain → la photo
part-elle en file d'attente ?).

---

## 7. Photo de l'échantillon (⚠️ transverse : collecteur ET dégustateur)

**Constat :** le collecteur et le dégustateur partagent **le même formulaire
d'enregistrement**. Ce qui suit vaut donc pour les deux.

### 7.1 — Prise de photo à l'enregistrement
Deux sources possibles, les deux obligatoires :
- 📷 **Appareil photo** — prise directe
- 🖼️ **Galerie** — photo déjà présente sur le téléphone

### 7.2 — Consultation de la photo depuis les détails
Dans la **page de détails de l'échantillon**, une **icône photo** permet d'ouvrir et de
**voir la photo prise**.

→ Sans cette icône, la photo est enregistrée mais invisible : elle ne sert à rien.

❓ Reste à préciser :
- une seule photo par échantillon, ou plusieurs ?
- la photo est-elle modifiable / remplaçable après enregistrement ? (et si oui, le
  verrouillage du §6.1 s'y applique-t-il aussi une fois l'échantillon reçu ?)
- comportement hors ligne : la photo part en file d'attente jusqu'au retour du réseau ?
  (même question que les pièces jointes de la messagerie — D27)

---

## 8. Récapitulatif des décisions bloquantes

| # | Question ouverte | Impact |
|---|------------------|--------|
| D1 | Qui reçoit la notif « achat confirmé » ? Groupée ou unitaire ? | anti-spam |
| D2 | Date de livraison d'échantillon : obligatoire à la confirmation d'achat ? | flux métier |
| D3 | Qui peut modifier une date confirmée, et faut-il re-notifier + historiser ? | traçabilité |
| D4 | Contenu exact de la notification « détails de négociation » | contenu notif |
| D5 | Créer l'action « mettre à jour la négociation » côté CEO | fonctionnalité manquante |
| D6 | Solution UI pour saisir un intervalle numérique en un seul champ | UI CEO |
| D7 | Filtre calendrier : sélecteur unique ou 3 vues ? | UI collecteur |
| D8 | Vocabulaire du ruban de confirmation physique | wording |
| D9 | Si les 4 critères ne tiennent pas dans le hint même en petit → plan B ? | UI recherche |
| ~~D10~~ | ~~Autocomplétion : saisie libre autorisée hors suggestions ?~~ → **oui**, avec détection de quasi-doublon | référentiel |
| ~~D11~~ | ~~Suggestions dans le formulaire d'enregistrement ?~~ → ✅ **OUI, c'est le cas d'usage principal** (dashboard CEO) | résolu |
| ~~D18~~ | ~~Fournisseur = entité avec ID ?~~ → ✅ **OUI**, `fournisseur_id` + région portée par l'entité | résolu |
| ~~D19~~ | ~~Qui crée un nouveau fournisseur ?~~ → ✅ **le collecteur**, avec détection de quasi-doublon | résolu |
| ~~D20~~ | ~~Variété / zone en référentiel ?~~ → ✅ **variété = liste fermée** (recherche), **zone = liste fermée via `GeoService`** | résolu |
| ~~D13~~ | ~~Verrouillage : qui peut encore éditer ?~~ → ✅ collecteur bloqué ; **chef dégustateur + dégustateur** éditent avec historique | résolu |
| ~~D14~~ | ~~Fil libre ou par échantillon ?~~ → ✅ **page Messagerie indépendante** dans le Drawer + référence cliquable vers un échantillon | résolu |
| ~~D15~~ | ~~Notification sur message ?~~ → ✅ **push activable/désactivable** + badge rouge non-lus (modèle Messenger) | résolu |
| ~~D16~~ | ~~Correction appliquée depuis le fil ?~~ → ✅ sans objet : messagerie indépendante, la correction se fait sur la fiche | résolu |
| ~~D17~~ | ~~Qui voit le fil ?~~ → ✅ **uniquement les participants** | résolu |
| ~~D21~~ | ~~Le dégustateur simple a-t-il une messagerie ?~~ → ✅ **non** | résolu |
| ~~D22~~ | ~~Laboratoire / CEO : messagerie ?~~ → ✅ **labo : non** ; **CEO : oui** (collecteurs + chefs dégustateurs) | résolu |
| ~~D23~~ | ~~Pièces jointes ?~~ → ✅ **oui** | résolu |
| ~~D24~~ | ~~Le CEO peut-il modifier un échantillon ?~~ → ✅ **non, lecture seule** | résolu |
| ~~D25~~ | ~~Variété : option « autre » ?~~ → ✅ **sans objet — saisie libre + autocomplétion, jamais de liste fermée** | résolu |
| ~~D26~~ | ~~Formuler les droits du CEO~~ → ✅ **ni modifier, ni ajouter, ni supprimer un échantillon** ; négociation ≠ échantillon | résolu |
| ~~D28~~ | ~~Le laboratoire peut-il modifier un échantillon ?~~ → ✅ **jamais** | résolu |
| D27 | Pièces jointes : types acceptés, taille max, comportement hors ligne ? | messagerie |
| D29 | Photo échantillon : une seule ou plusieurs ? | §7 |
| D30 | Photo remplaçable après enregistrement ? Et après réception (verrouillage §6.1) ? | §7 |

**Principe transverse dégagé :** l'autocomplétion **assiste** la saisie, elle ne la
**contraint** jamais. Seule exception : la zone/délégation, qui vient d'une liste
officielle déjà présente dans l'app.
| D12 | Date d'enregistrement : avec ou sans heure ? | détails échantillon |
| D13 | Verrouillage après réception : personne n'édite, ou seul le collecteur est bloqué ? | ⚠️ conflit avec règle CLAUDE.md |
| D14 | Messagerie : fil libre ou fil rattaché à un échantillon ? | archi messagerie |
| D15 | Un message déclenche-t-il une notification ? | notif |
| D16 | Le chef dégustateur peut-il appliquer la correction depuis le fil ? | droits |
| D17 | CEO / dégustateur : accès en lecture au fil ? | droits |

---

## 9. Pistes envisagées puis écartées

> Trace des options étudiées et rejetées. **La décision finale reste celle des sections
> ci-dessus** — ce tableau ne sert qu'à justifier les choix (utile pour le rapport).

| Piste écartée | Pourquoi | Décision retenue |
|---------------|----------|------------------|
| Variété en **liste déroulante fermée** | Contraindrait la saisie ; le collecteur doit pouvoir écrire lui-même | Saisie libre + autocomplétion (§4.2) |
| Autocomplétion **uniquement dans la recherche** | Passe à côté du vrai enjeu : les doublons naissent à l'enregistrement | Autocomplétion **à l'enregistrement** avant tout (§4.2) |
| Fournisseur en **texte libre** | Les agrégations du dashboard CEO deviennent fausses — un fournisseur compté plusieurs fois | Entité avec `fournisseur_id` (§4.2) |
| Création de fournisseur **validée par le CEO** | Bloquerait le collecteur en déplacement, parfois hors ligne | Création libre + garde-fou anti-doublon (§4.2) |
| **Fil de discussion par échantillon** | Trop lourd, multiplie les fils | Page Messagerie indépendante + référence cliquable vers l'échantillon (§6.2) |
| **Verrouillage total** après réception (personne n'édite) | Rendrait la messagerie inutile : signaler une correction que personne ne peut appliquer | Collecteur bloqué ; chef dég. + dég. éditent **avec historique** (§6.1) |
| Chercher un **package externe** pour le masque de saisie de date | Inutile, le composant existe déjà dans le projet | Réutiliser `DateInputField` (§3.2) |

---

## 10. À compléter
_(l'utilisateur ajoutera d'autres idées ici)_
