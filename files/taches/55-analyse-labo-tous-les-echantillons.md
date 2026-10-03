# Tâche 55 — Page « Analyse laboratoire » du dégustateur et du chef : tous les échantillons

Écrit le 03/10/2026 par Claude. Exécutant : GitHub Copilot. Claude vérifie et commite.

## Constat

La page « Analyse laboratoire » du **dégustateur** et du **chef dégustateur**
(`lib/3_degustateur/analyse_labo/analyse_laboratoire_page.dart`,
`lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart`) charge
`GET /api/analyses/echantillons/` (`lib/core/analyses/ligne_analyse_labo_service.dart`).
Côté serveur, `LabEchantillonListView` (`backend_new/analyses/views.py`, ~ligne 23) ne renvoie
que `recu_physiquement=True` **pour tous les rôles**. Résultat : page vide tant que rien n'est reçu.

## Décision de l'utilisatrice

- Dégustateur et chef : voir **tous** les échantillons dans cette page, même s'ils ne sont pas
  encore reçus physiquement et même sans analyse de laboratoire.
- Laboratoire : **inchangé** — il ne voit que les échantillons reçus physiquement.
- Direction : inchangé (garder le filtre actuel pour la direction).

## A. Serveur

1. `LabEchantillonListView.get_queryset` : filtrer `recu_physiquement=True` seulement si le rôle
   est `laboratoire` ou `direction` ; pour `degustateur` et `chef_degustation`, tous les
   échantillons. Garder `select_related` et l'ordre (ajouter `-date_ajout` en premier critère
   utile pour les non reçus : ordre `-date_ajout`).
2. `LabEchantillonAnalyseSerializer` : ajouter `recu_physiquement` et
   `date_reception_echantillon` aux champs s'ils n'y sont pas.
3. Ne pas toucher aux autres vues (`AnalyseListCreateView`, `AnalyseDetailView`) : le labo ne
   peut toujours analyser qu'un échantillon reçu.
4. Tests Django (`backend_new/analyses/tests.py`) : dégustateur et chef voient un échantillon non
   reçu ; laboratoire ne le voit pas ; direction ne le voit pas.

## B. Application

1. Modèle `lib/core/analyses/ligne_analyse_labo.dart` : ajouter `recuPhysiquement` (bool, défaut
   `false`) lu depuis `recu_physiquement`, et l'inclure dans `toJson`.
2. Carte `lib/core/widgets/analyse_labo/analyse_card.dart` (partagée dégustateur + chef) :
   - statut affiché clairement, du plus en amont au plus avancé :
     « Pas encore reçu dans la société » (non reçu) → « En attente d'analyse » (reçu, pas
     d'analyse) → statut actuel de l'analyse (en cours / terminée…) ;
   - pour un échantillon non reçu : pas de tableau de résultats, et le bouton « analyse
     urgente » (s'il existe sur la carte) est **désactivé** avec le petit texte
     « Disponible après la réception physique ».
3. Filtres de la page (statut) : ajouter un filtre « Pas encore reçu » si la page a des filtres de
   statut ; vérifier que les compteurs et la recherche marchent avec les non reçus.
4. Vérifier les deux pages (dégustateur et chef) : aucun texte « null », pas de plantage quand
   `analyse` est absente.

## Tests Flutter

- Ajouter un test sur `analyse_card.dart` : échantillon non reçu → texte « Pas encore reçu dans
  la société » et bouton urgent désactivé (s'il existe) ; reçu sans analyse → « En attente
  d'analyse ».
- Mettre à jour les tests/fixtures touchés.

## Règles

Voir `files/taches/PROTOCOLE.md`. Interdit : `git commit`, `git push`, migration appliquée sur la
vraie base, ML Kit, fausses données. Même comportement pour le dégustateur et le chef. Encodage
UTF-8 sans BOM, garder les fins de ligne. Lancer `flutter analyze` (zéro ligne « error - »),
`flutter test` et les tests Django (`analyses`) avant d'écrire le rapport.
