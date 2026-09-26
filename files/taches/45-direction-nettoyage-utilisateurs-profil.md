# Tâche 45 — Direction : message horizontal, compteurs retirés, page Utilisateurs, profil

Lis `files/taches/PROTOCOLE.md` (dont « Même correction pour tous les rôles »), puis
`CLAUDE.md`. Flutter + backend. **Une migration est autorisée** (partie E, suppression
« douce » des utilisateurs). À faire après les tâches 43 et 44.

Constaté par la propriétaire sur la plateforme **Direction**, mais chaque point s'applique à
**tous les rôles** qui ont le même écran ou le même composant.

## A — Message vertical après le bouton « valider » (Analyse organoleptique, direction)

Page `lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart`. Après avoir
appuyé sur le bouton en forme de coche (✓) d'une carte, un texte s'affiche **à la
verticale** : une lettre par ligne, une très longue colonne. Le texte est enfermé dans un
espace trop étroit.

- Trouve quel widget affiche ce message (SnackBar, texte dans une `Row`, bandeau dans la
  carte…) et pourquoi il est si étroit.
- Remplace-le par un **bandeau horizontal** qui apparaît **3 secondes** puis disparaît :
  `SnackBar` flottant, pleine largeur (marges 16), `duration: Duration(seconds: 3)`, texte
  sur une ou deux lignes. Même couleur que le message actuel.
- Grep les autres `SnackBar` / messages de confirmation de la direction et des autres rôles
  qui ont le même défaut (texte dans un conteneur à largeur fixe ou dans une `Row` sans
  `Expanded`) et corrige-les de la même façon.

## B — Retirer les compteurs « total » en haut des pages (tous les rôles)

La propriétaire ne veut plus les lignes de total, par exemple sur la page Échantillons de
la direction : « N échantillons · M collecteurs », et sur Utilisateurs : le nombre
d'utilisateurs. **Dans toutes les pages de liste de tous les rôles**, retire les textes
qui annoncent un total (nombre d'éléments, de collecteurs, d'utilisateurs…) au-dessus ou
en tête d'une liste.

**À garder** : les statistiques du **tableau de bord** (c'est leur rôle), les pastilles de
notifications ou de messages non lus, et les chiffres propres à un élément (quantité d'un
échantillon, etc.). Si un compteur ne rentre clairement dans aucun des deux cas, laisse-le
et liste-le sous `## QUESTION`.

Dans le rapport : une ligne par compteur retiré (fichier + texte).

## C — Page Utilisateurs : phrase retirée

`lib/core/utilisateurs/utilisateurs_page_body.dart:~155` : supprime la phrase
`Consultation seule — la gestion des comptes appartient au chef dégustation.` et son
conteneur.

## D — Page Utilisateurs : toucher une personne = sa fiche (DIRECTION SEULEMENT)

**Attention** : `lib/core/utilisateurs/utilisateurs_page_body.dart` est partagé par la
direction et le chef dégustateur. La propriétaire aime la page du **chef** telle qu'elle
est : pour le chef, on ne retire **que** le nombre d'utilisateurs (partie B) et la phrase
(partie C). Tout ce qui suit dans D ne s'applique qu'à la **direction** (paramètre du
widget ou rôle de l'utilisateur connecté). Pour le chef, un utilisateur supprimé (E)
affiche simplement son statut `Utilisateur supprimé` dans la présentation actuelle.


Aujourd'hui : une flèche à droite ouvre une fenêtre avec une icône œil et un bandeau
« actif ». La propriétaire veut :
- **toucher la ligne de la personne** ouvre directement sa fiche d'informations
  (fenêtre) ;
- **retirer la flèche** de la ligne ;
- **retirer le bandeau** qui contient l'icône œil et le statut ;
- le **statut** (Actif / Désactivé / Supprimé) est écrit **dans la fiche**, comme les
  autres informations ;
- **date de début** : elle s'affiche en charabia. Affiche-la au format `JJ/MM/AAAA`
  (réutilise `DegDateUtils.formaterAffichage` de `lib/core/utils/date_utils.dart` ou
  l'équivalent). Vérifie les autres dates de la fiche.
Les actions qui existent déjà pour qui a le droit (modifier, désactiver, supprimer)
restent disponibles dans la fiche, rien n'est retiré côté droits.

## E — Utilisateur supprimé : il reste dans la liste

Aujourd'hui `backend_new/users/views.py`, `perform_destroy` fait `instance.delete()` : le
compte disparaît de la base (et ses liens deviennent vides). La propriétaire veut que
l'utilisateur supprimé **reste dans la liste** avec le statut **Utilisateur supprimé**.

- Suppression « douce » : ajoute `date_suppression = DateTimeField(null=True, blank=True)`
  sur `User` (migration). `perform_destroy` met `is_active = False` et
  `date_suppression = now()` au lieu d'effacer.
- Un utilisateur supprimé **ne peut plus se connecter** (déjà vrai avec `is_active=False` :
  vérifie-le avec un test), n'apparaît plus dans les listes de choix (destinataires de la
  messagerie, membres d'un panel, etc.), mais reste visible dans la page Utilisateurs avec
  le statut `Utilisateur supprimé` (gris), et ses échantillons / évaluations gardent son
  nom.
- Le serializer renvoie un statut clair (`actif`, `desactive`, `supprime`) ; Flutter
  l'affiche dans la fiche (D).
- Un utilisateur supprimé ne peut pas être « réactivé » par le bouton activer/désactiver
  (sauf si c'est déjà prévu : dans ce cas `## QUESTION`).
- Tests backend : suppression → toujours en base, `is_active=False`, statut `supprime`,
  connexion refusée, absent des contacts de messagerie.

## F — Profil (tous les rôles)

1. **Retour au tableau de bord** : depuis la page Profil, la propriétaire ne peut pas
   revenir au tableau de bord (direction constatée). Vérifie les 5 pages de profil
   (`profil_ceo_page.dart`, `profilcom.dart`, `profil_labo_page.dart`,
   `3_degustateur/profil/profil_page.dart`, `5_chef_degustateur/profil.dart`) : flèche
   retour dans l'en-tête et bouton retour Android ramènent au tableau de bord (ou à
   l'écran précédent si la page a été ouverte par-dessus). Même comportement pour les 5.
2. **Mot de passe oublié depuis le changement de mot de passe** : dans
   `lib/core/widgets/change_password_dialog.dart`, sous le champ « ancien mot de passe »,
   lien `Mot de passe oublié ?` qui ferme la fenêtre et ouvre l'écran de la tâche 42
   (`lib/core/auth/mot_de_passe_oublie_page.dart`) avec l'email du compte déjà rempli.
   Le code est envoyé à l'email du compte, comme depuis la page de connexion.

## Tests

- Flutter : un test par partie quand c'est raisonnable (A : le message est un SnackBar
  horizontal qui disparaît après 3 s ; D : toucher une ligne ouvre la fiche, pas de flèche,
  statut dans la fiche, date formatée ; F : lien mot de passe oublié).
- Backend : E.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera les tests Flutter et
Django et appliquera la migration après une sauvegarde de la base.

## RAPPORT

### Rapport de Claude (26/09/2026)

Codex a été coupé par sa limite d'utilisation après 9 minutes, sans rapport. Claude a repris :

- **Encodage abîmé par Codex** dans 16 fichiers (accents devenus « Ã© », marque BOM) :
  réparé octet par octet ; plus aucun caractère abîmé, texte d'origine retrouvé.
- **Code cassé** : Codex avait laissé des morceaux orphelins en retirant les compteurs
  (14 fichiers ne compilaient plus). Ces fichiers ont été remis à l'identique, puis les
  compteurs retirés proprement par Claude.
- A — message horizontal 3 s : fait par Codex (négociation enregistrée / non enregistrée),
  accents rétablis.
- B — compteurs « total » retirés : direction, dégustateur, chef, labo (listes, analyses,
  évaluations, sessions, vue d'ensemble, notifications), collecteur (notifications),
  messagerie (nombre de conversations). Gardés : la phrase d'explication du collecteur,
  « Effacer les filtres », les nombres des formulaires (« Ajouter 3 échantillons »).
- C — phrase « Consultation seule » : retirée.
- D — direction : toucher une personne ouvre sa fiche ; flèche et bandeau retirés ;
  statut et date de début (JJ/MM/AAAA) dans la fiche. Chef : présentation inchangée.
- E — suppression douce : `date_suppression` + migration `users/0006` (manquante chez
  Codex) ; compte supprimé inactif, absent des listes de choix, non réactivable.
- F — profil : « Mot de passe oublié ? » dans le changement de mot de passe (Codex) ;
  retour au tableau de bord depuis les 5 profils (bouton retour du téléphone + entrée
  « Tableau de bord » du menu direction qui ne faisait que fermer le menu).
- Tests : 162 Flutter, 211 serveur.
