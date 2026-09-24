# Tâche 35 — Mise à jour des écrans : tirer vers le bas + rechargement automatique

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Flutter uniquement. Aucun changement backend, aucune migration.

## Pourquoi

La propriétaire va utiliser l'application en conditions réelles, sur plusieurs téléphones
(un compte par rôle). Aujourd'hui, **aucun écran ne se met à jour tout seul** (vérifié :
aucun `RefreshIndicator`, aucun `Timer.periodic` dans `lib/`). Quand le collecteur
enregistre un échantillon, le dégustateur ne le voit qu'en quittant la page et en y
revenant. Pareil pour la cloche des notifications.

Elle veut :
1. **Tirer l'écran vers le bas** (comme Facebook ou Twitter) : la flèche de chargement
   apparaît, la liste se recharge depuis le serveur.
2. **Rechargement automatique toutes les 30 secondes**, sans rien toucher.

---

## Partie A — Un seul outil partagé

Crée `lib/core/utils/rafraichissement_periodique.dart` : un `mixin` sur `State` qui
- démarre un `Timer.periodic(const Duration(seconds: 30), ...)` ;
- appelle une méthode que la page fournit (ex. `Future<void> rechargerEnSilence()`) ;
- **n'appelle pas** si le rechargement précédent n'est pas terminé ;
- **n'appelle pas** si `!mounted` ;
- annule le timer dans `dispose()`.

Pas de nouvelle dépendance dans `pubspec.yaml`.

## Partie B — Les écrans concernés

Écrans qui chargent des données depuis le serveur :

```
lib/1_ceo/achats_confirmes/achats_confirmes_ceo_page.dart
lib/1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart
lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart
lib/1_ceo/echantillons/echantillons_ceo_page.dart
lib/1_ceo/notifications/notifications_ceo_page.dart
lib/1_ceo/tableau_de_bord/tableau_de_bord.dart
lib/1_ceo/validation_achats/validation_achats_ceo_page.dart
lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart
lib/2_collecteur/notifications/notifications_collecteur_page.dart
lib/3_degustateur/analyse_labo/analyse_laboratoire_page.dart
lib/3_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart
lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart
lib/3_degustateur/membres_panel/membres_panel_page.dart
lib/3_degustateur/notifications/notifications_degustateur_page.dart
lib/3_degustateur/sessions_degustation/sessions_degustation_page.dart
lib/3_degustateur/tableau_de_bord/homepage_page.dart (et/ou widgets/home_body.dart)
lib/4_laboratoire/echantillons_labo/echantillons_labo_page.dart
lib/4_laboratoire/notifications/notifications_labo_page.dart
lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart
lib/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart
lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart
lib/5_chef_degustateur/membres_panel/membres_panel_page.dart
lib/5_chef_degustateur/notifications/notifications_degustateur_page.dart
lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart
lib/5_chef_degustateur/tableau_de_bord/homepage_page.dart (et/ou widgets/home_body.dart)
lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart
lib/core/utilisateurs/utilisateurs_page_body.dart
lib/core/widgets/messagerie/conversations_page.dart
lib/core/widgets/messagerie/conversation_page.dart
```

**Exclus** : les pages de profil (`profil_*`) et toutes les pages de formulaire (saisie
d'évaluation, d'analyse, d'échantillon…). Un rechargement ne doit jamais effacer ce que
la personne est en train de taper.

Pour **chaque** écran de la liste :

1. **Tirer vers le bas** : entoure la liste défilante principale d'un `RefreshIndicator`
   dont `onRefresh` appelle la fonction de chargement déjà présente dans la page.
   - La liste doit pouvoir être tirée même quand elle est courte ou vide :
     `physics: const AlwaysScrollableScrollPhysics()` sur le défilement concerné.
   - Si la page affiche un écran vide ou un écran d'erreur à la place de la liste, cet
     écran doit aussi pouvoir être tiré (le mettre dans un `ListView` / `SingleChildScrollView`
     avec `AlwaysScrollableScrollPhysics`).
   - Couleur de la flèche : reprends la couleur principale déjà utilisée par la page.
     N'invente pas de nouvelle couleur.
2. **Rechargement automatique** : applique le mixin de la partie A. Le rechargement
   automatique est **silencieux** :
   - pas d'indicateur de chargement plein écran, pas de `_chargement = true` ;
   - pas de message d'erreur toutes les 30 s : si l'appel échoue, **on garde les données
     affichées telles quelles** ;
   - si le `Resultat` revient avec `estDemonstration == true` alors que la page affiche des
     données réelles, **on l'ignore** (on ne remplace jamais des vraies données par des
     données de démonstration) ;
   - on **garde** : la recherche tapée, les filtres, les cartes dépliées, l'onglet
     sélectionné, la position de défilement.
3. **Cloche des notifications** : le compteur de notifications non lues affiché dans les
   en-têtes (direction `tableau_de_bord.dart`, collecteur `mes_echantillons_page.dart`,
   dégustateur et chef `homepage_page.dart`, labo `echantillons_labo_page.dart`) doit se
   recharger lui aussi avec le rechargement automatique et avec le tirer-vers-le-bas.
   Cherche avec `grep` comment ce compteur est chargé aujourd'hui et réutilise la même
   fonction.
4. **Messagerie** (`conversation_page.dart`) : rechargement automatique seulement, et
   **ne fais pas défiler** l'écran si la personne est en train de lire d'anciens messages.
   Si le champ de saisie contient du texte, il doit rester intact.

Ne change ni les textes, ni les couleurs, ni les tailles de police, ni la mise en page
en dehors de ce qui est décrit.

Si un écran de la liste ne correspond pas à cette description (pas de liste, chargement
fait ailleurs, etc.), ne devine pas : écris-le sous `## QUESTION` pour cet écran et
continue les autres.

## Partie C — Test

Ajoute `test/rafraichissement_periodique_test.dart` qui vérifie avec `fake_async` ou
`tester.pump(const Duration(seconds: 30))` :
- la méthode de rechargement est appelée après 30 s ;
- elle n'est plus appelée après que le widget est retiré de l'arbre ;
- elle n'est pas appelée une 2ᵉ fois tant que la 1ʳᵉ n'est pas terminée.

---

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera :

```bash
flutter analyze lib test
flutter test
```

Résultat attendu : 0 erreur, 0 test en échec.

Dans ton rapport, donne la liste des écrans modifiés, écran par écran, avec une ligne :
« tirer vers le bas : oui/non — automatique : oui/non — cloche : oui/non/sans objet ».

## RAPPORT

*(Écrit par Claude : Codex a atteint sa limite d'utilisation juste avant d'écrire son rapport.
Le code était complet.)*

- `lib/core/utils/rafraichissement_periodique.dart` : mixin, timer 30 s, pas de double appel, annulé au `dispose`.
- `VueResultatService` (`bandeau_demonstration.dart`) porte le `RefreshIndicator` pour tous les écrans ; l'écran d'erreur peut aussi être tiré.
- 29 écrans : tirer vers le bas + rechargement automatique silencieux. `conversation_page.dart` : automatique seulement, ne défile que si on est déjà en bas.
- Cloche : rechargée sur les pages d'accueil de chaque rôle.

### Correction faite par Claude

Sur 16 écrans, le tirer-vers-le-bas appelait la fonction de chargement complète, qui remplace
toute la page par un indicateur de chargement (liste effacée, position de défilement perdue).
Ces écrans appellent maintenant `rechargerEnSilence` (mêmes données, sans effacer la page).
`_rafraichirTout` du tableau de bord direction supprimé, devenu inutilisé.

### Vérifié

- `flutter analyze lib test` : 55 remarques, aucune nouvelle, 0 erreur.
- `flutter test` : 118 réussis, 0 échec (3 nouveaux tests du mixin).
