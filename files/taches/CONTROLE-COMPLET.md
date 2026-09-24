# Contrôle complet — chaque action de l'application

Ce fichier est pour toi, propriétaire du projet.

Chaque ligne = **une action** faite par une personne, puis **ce que les autres doivent
voir** ensuite. Cette liste a été faite en lisant le vrai code du serveur (24/09/2026),
pas de mémoire.

**Comment faire une ligne :**
1. Fais l'action dans une fenêtre, avec le compte indiqué.
2. Dans l'autre fenêtre, connecte-toi avec le compte qui doit voir le résultat.
   **Recharge la page** (l'application ne se met pas à jour toute seule).
3. Coche si c'est bon. Sinon, écris une phrase à côté et passe à la suivante.

**⚠️ = j'ai lu le code et je sais déjà que ce point ne marche pas, ou n'existe pas.**
Vérifie-le quand même à l'écran, puis dis-moi si tu veux qu'on le corrige.

**Comptes de test** (mot de passe pour tous : `Test@12345`) :
collecteur@stca.tn · degustateur@stca.tn · chef@stca.tn · labo@stca.tn · direction@stca.tn

---

## A. Enregistrer, modifier, supprimer un échantillon

- [ ] **Le collecteur enregistre un échantillon** (une bouteille).
  → Direction, chef et dégustateur : il apparaît dans leur liste **+ notification « Nouvel échantillon »**.
- [ ] **Le collecteur enregistre plusieurs bouteilles d'un coup** pour un même fournisseur.
  → Même chose : une notification par bouteille chez direction, chef et dégustateur.
- [ ] **Le collecteur ajoute une photo à une bouteille.**
  → Chez le dégustateur et le chef : la photo est visible quand on déplie la carte.
- [ ] **Le collecteur modifie un échantillon** (fournisseur, lieu, variété, quantité, remarque, photo, citerne).
  → Direction, chef, dégustateur : la nouvelle valeur est visible **+ notification « Échantillon modifié »**.
- [ ] **Le collecteur supprime un échantillon** (seulement possible s'il n'est pas encore reçu).
  → Direction et chef : il disparaît **+ notification « Échantillon supprimé »**.
  → Dégustateur : il disparaît (pas de notification, c'est le code actuel).
- [ ] **Le collecteur essaie de supprimer un échantillon déjà reçu** → l'application refuse, avec un message.
- [ ] **Le dégustateur enregistre un échantillon** depuis « Gestion des échantillons ».
  → Direction et chef : il apparaît **+ notification « Nouvel échantillon »**.
- [ ] **Le chef modifie puis supprime un échantillon qu'il (ou le dégustateur) a enregistré.**
  → Les autres voient le changement, puis la disparition.
- [ ] **Le dégustateur essaie de supprimer un échantillon enregistré par un collecteur** → refusé, avec un message.

## B. Les dates — chaque date doit être visible par les bonnes personnes

- [ ] **Le collecteur met ou change la date de livraison de l'échantillon** (quand la bouteille doit arriver).
  → Direction : la nouvelle date est visible sur la carte **+ notification « Échantillon modifié »**.
  → Chef et dégustateur : **notification « Échantillon modifié »**.
  → ⚠️ Chef et dégustateur : **la date n'est affichée nulle part** sur la page « Gestion des
    échantillons ». La carte ne montre aucune date. Elle apparaît seulement dans le
    formulaire d'évaluation. *(C'est ce que tu as demandé : à corriger.)*
- [ ] **Le dégustateur coche « reçu »** → la date de réception est enregistrée.
  → Direction : la date de réception est visible.
  → ⚠️ Chef et dégustateur : la date de réception n'est pas affichée sur leur carte (seulement « Oui / Non »).
- [ ] **Le collecteur met la date de livraison du stock** (une date, ou « entre le … et le … »).
  → Chef et dégustateur : **notification « Date de livraison ajoutée »**.
  → Direction : la date est visible sur la carte (pas de notification, c'est le code actuel).
  → ⚠️ Chef et dégustateur : la date n'est pas affichée sur leur carte, seulement dans la notification.
- [ ] **Le collecteur change la date de livraison du stock.**
  → Chef et dégustateur : **notification « Date de livraison modifiée »** avec la nouvelle date.
- [ ] **Le filtre par dates** chez le collecteur, le dégustateur et le chef : les 4 choix
  (enregistrement, livraison de l'échantillon, réception physique, arrivée du stock)
  trouvent bien les bons échantillons.

## C. Réception physique

- [ ] **Le dégustateur (ou le chef) coche « reçu ».**
  → Collecteur, direction, chef : **notification « Échantillon reçu physiquement »** avec la date et l'heure.
  → Labo : l'échantillon apparaît dans sa liste **+ notification « Échantillon disponible pour analyse »**.
  → Collecteur : il ne peut plus supprimer cet échantillon.
- [ ] **Le dégustateur décoche « reçu ».**
  → Collecteur, direction, chef : **notification « Réception physique annulée »**.
  → Labo : l'échantillon disparaît de sa liste.
  → Labo : notification **seulement** si une analyse était déjà commencée dessus.

## D. Évaluation organoleptique

- [ ] **La direction demande une évaluation urgente** sur un échantillon reçu.
  → Tous les dégustateurs + le chef : **notification « Évaluation urgente »**.
- [ ] **La direction demande une évaluation urgente sur un échantillon PAS encore reçu** → refusé, avec un message.
- [ ] **Le dégustateur remplit une évaluation et l'enregistre sans la soumettre.**
  → Il peut encore la modifier ou la supprimer.
- [ ] **Le dégustateur soumet son évaluation.**
  → Chef : **notification « Évaluation soumise »** avec le nom du dégustateur.
  → Le dégustateur ne peut plus la modifier.
- [ ] **Le dernier dégustateur soumet** (tout le monde a évalué cet échantillon).
  → Direction et chef : **notification « Toutes les évaluations soumises »**.
  → Direction : les résultats sont visibles dans « Analyse organoleptique ».

## E. Analyse laboratoire

- [ ] **Le dégustateur (ou le chef) demande une analyse urgente** sur un échantillon reçu.
  → Labo : **notification « Analyse laboratoire urgente »**.
- [ ] **Le labo commence une analyse, l'enregistre sans la soumettre.**
  → Il peut encore la modifier ou la supprimer.
- [ ] **Le labo soumet l'analyse.**
  → Direction et chef : **notification « Analyse soumise »**.
  → Direction, chef, dégustateur : les résultats sont visibles dans « Analyses laboratoire ».
  → Le labo ne peut plus la modifier.

## F. Négociation et achat

- [ ] **La direction propose une négociation** (prix, quantité en tonnes).
  → Collecteur : **notification « Proposition de négociation »**. Il clique dessus → la bonne carte s'ouvre.
  → Collecteur : la carte passe en « en négociation », avec le prix et la quantité.
- [ ] **La direction change sa proposition.**
  → Collecteur : **notification « Négociation mise à jour »**.
- [ ] **Le collecteur envoie sa proposition d'achat** (prix, remarque, camion, citerne, dates de livraison du stock).
  → Direction : **notification « Proposition d'achat en attente »**.
- [ ] **La direction renvoie en négociation** (refuse le prix, donne un motif et un nouveau prix).
  → Collecteur : **notification « Négociation à revoir »** avec le motif.
  → La carte montre le nombre de tours de négociation.
- [ ] **La direction confirme l'achat.**
  → Direction et chef : **notification « Achat confirmé »**.
  → L'échantillon apparaît dans « Achats confirmés » chez la direction.
  → ⚠️ Collecteur : **aucune notification**. Le code n'envoie rien au collecteur à ce moment-là.
- [ ] **La direction refuse l'achat** (avec un motif).
  → ⚠️ Collecteur : **aucune notification**. Il voit le refus seulement en rechargeant.
- [ ] **La direction refuse l'échantillon** (avant toute négociation).
  → ⚠️ Collecteur : **aucune notification**.

## G. Sessions de dégustation

- [ ] **Le chef crée une session** avec des participants.
  → Chaque participant : **notification « Nouvelle session »**.
- [ ] **Le dégustateur crée une session.**
  → Elle est « en attente de validation ». Chef : **notification « Nouvelle session »**.
- [ ] **Le chef approuve la session du dégustateur.** → Elle passe à « planifiée ».
  → ⚠️ Le dégustateur qui l'a créée ne reçoit **aucune notification**.
- [ ] **Le chef refuse la session du dégustateur.** → Elle disparaît de la liste.
  → ⚠️ Le dégustateur ne reçoit **aucune notification**.
- [ ] **Un participant confirme sa présence.** → Le chef voit la présence confirmée.
- [ ] **Quelqu'un qui n'est pas participant essaie de confirmer sa présence** → refusé.

## H. Messagerie

Qui parle à qui : collecteur ↔ direction, collecteur ↔ chef, direction ↔ chef, chef ↔ autre chef.
Le dégustateur simple et le labo n'ont pas de messagerie.

- [ ] **Le collecteur envoie un message à la direction.**
  → Direction : le message arrive, badge « non lu » visible. Elle ouvre la conversation → le badge disparaît.
- [ ] **Le collecteur envoie un message au chef.** → Même chose chez le chef.
- [ ] **La direction écrit au chef.** → Même chose.
- [ ] **Le chef écrit à un autre chef** (si un 2ᵉ compte chef existe).
- [ ] **Envoyer une photo** (galerie, puis appareil photo). → Elle s'affiche chez l'autre personne.
- [ ] **Envoyer une référence d'échantillon.** → L'autre personne clique dessus → la bonne page s'ouvre pour son rôle.
- [ ] **Modifier son propre message.** → « modifié » apparaît chez les deux personnes.
- [ ] **Supprimer son propre message.** → Il disparaît chez les deux personnes.
- [ ] **Sur un message reçu** (pas le tien) → aucune option modifier/supprimer.
- [ ] **Le dégustateur et le labo** → aucun bouton « Messagerie » dans leur menu.

## I. Notifications (pour chaque rôle)

- [ ] **Cliquer sur une notification** → elle passe en « lue », et la bonne page s'ouvre.
- [ ] **« Tout marquer comme lu »** → le compteur de la cloche tombe à 0.
- [ ] **Le compteur de la cloche** montre le bon nombre de notifications non lues.

## J. Comptes utilisateurs (seul le chef peut les modifier, la direction peut seulement les voir)

- [ ] **Le chef crée un compte** (par exemple un 2ᵉ dégustateur). → La personne peut se connecter.
- [ ] **Le chef modifie un compte.** → Le changement est visible chez la direction.
- [ ] **Le chef désactive un compte.** → La personne ne peut plus se connecter. Elle ne reçoit plus de notifications.
- [ ] **Le chef réactive le compte.** → La personne peut de nouveau se connecter.
- [ ] **Le chef essaie de se désactiver lui-même** → refusé, avec un message.
- [ ] **La direction ouvre la page Utilisateurs** → elle voit la liste mais ne peut rien modifier.

## K. Connexion et profil (pour chacun des 5 rôles)

- [ ] **Connexion** avec le bon mot de passe → la bonne page d'accueil pour le rôle.
- [ ] **Connexion avec un mauvais mot de passe** → message d'erreur clair.
- [ ] **Changer son mot de passe** dans le profil → la connexion marche avec le nouveau.
- [ ] **Déconnexion** → retour à la page de connexion.

---

## À la fin

Donne-moi seulement ce qui a échoué : la lettre de la partie, l'action, et une phrase.
Pour les ⚠️, dis-moi juste « oui, à corriger » ou « non, on laisse ».
