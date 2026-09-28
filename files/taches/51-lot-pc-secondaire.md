# Tâche 51 — lot de 7 corrections pour le PC secondaire

Écrit le 28/09/2026 par Claude (PC principal). À faire par l'agent du **PC secondaire**
(voir `LIMITES-PC-SECONDAIRE.md`), puis vérifié sur le PC principal (Flutter, tests, téléphone).

## Règles pour ce lot

1. `git pull --rebase origin main`, puis `git checkout -b pc2-lot-51`.
   **Tout le travail va sur la branche `pc2-lot-51`. Jamais sur `main`.**
2. Un commit par point (51.1, 51.2…), message qui commence par le numéro. Après chaque
   commit : `git push -u origin pc2-lot-51`.
3. Ajouter au *sparse checkout* les fichiers listés dans chaque point avant de les modifier
   (`git sparse-checkout add <chemin>`).
4. Flutter n'est pas installé ici : écrire le Dart avec soin (imports, `const`, `switch`
   exhaustifs, pas de variable inutilisée). Le PC principal lancera `flutter analyze` et
   `flutter test`. Ne pas modifier `pubspec.lock` (le PC principal fera `flutter pub get`).
5. Django : lancer les tests de chaque application touchée et
   `python manage.py makemigrations --check --dry-run` (créer la migration si besoin).
6. Rappel des règles du projet : français simple dans l'application, aucun code d'erreur
   technique affiché, pas de fausses données, **jamais ML Kit**, même correction pour tous
   les rôles qui partagent un écran. Encodage UTF-8 sans BOM, garder les fins de ligne du fichier.
7. Si un point n'est pas clair : l'écrire dans la section « Questions » en bas de ce fichier,
   le pousser, et passer au point suivant.
8. À la fin : remplir la section « Compte rendu » en bas (ce qui est fait, ce qui n'est pas
   testé, fichiers touchés), commit, push. Le PC principal fusionne dans `main`.

---

## 51.1 — OCR Azure (fin de la tâche 50b) + une photo par échantillon pour les deux dégustateurs

**A. Terminer 50b** : suivre la section « REPRISE » de `50b-ocr-document-intelligence-et-mlkit.md`.
Fusionner la branche `tache-50b-en-cours` dans `pc2-lot-51` (`git merge origin/tache-50b-en-cours`),
puis mettre à jour `EchantillonOcrApiTests` dans `backend_new/echantillons/tests.py`
(réglages `AZURE_DOCINTEL_ENDPOINT/KEY`, faux appel POST + lecture de `Operation-Location`,
cas 503 quand non configuré ou quand Azure ne répond pas) et la section Azure de
`docs/MISE-EN-SERVICE.md`.

**B. Photo par échantillon** : aujourd'hui, dans le formulaire d'ajout du collecteur, chaque
ligne de bouteille (`BouteilleRow`) a **sa propre photo** (appareil photo ou galerie) et son
bouton « Lire l'étiquette ». Dans les formulaires du dégustateur et du chef, il n'y a
**qu'une photo pour tout le formulaire** (`_photoBytes`, `_photoName`). Faire comme le
collecteur : une photo par ligne, choix appareil photo / galerie, bouton « Lire l'étiquette »
par ligne (grisé si Azure n'est pas configuré), photo envoyée avec l'échantillon de sa ligne.

Fichiers :
- modèle : `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart`
  (voir `PickBottlePhoto`, `_pickPhoto(ImageSource, BouteilleRow)`, vers la ligne 120 et 1045) ;
- à modifier : `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`
  et `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`
  (et le service d'envoi de chaque rôle si l'envoi de la photo doit passer par ligne).

---

## 51.2 — Direction : enlever la carte du tableau de bord

Dans `lib/1_ceo/tableau_de_bord/tableau_de_bord.dart` (ligne ~483 : `_fs(8, const MapCtaCard())`),
supprimer la carte et son espacement. Supprimer `lib/1_ceo/tableau_de_bord/widgets/map_cta_card.dart`
si plus rien ne l'utilise. Vérifier que la mise en page reste propre (pas de trou).

---

## 51.3 — Notifications : plus de « Échantillon modifié » pour la direction, et référence au lieu du numéro

Fichier : `backend_new/notifications/signals.py`.
- Les deux envois `ECHANTILLON_MODIFIE` (vers la ligne 230 et 250) : retirer `User.Role.DIRECTION`
  des destinataires (le chef et les dégustateurs continuent de les recevoir).
- `_sample_ref` (ligne ~55) : afficher d'abord la **référence** de l'échantillon
  (`reference_bouteille`), le numéro `2026/0007` seulement s'il n'y a pas de référence.
  Cela vaut pour toutes les notifications de tous les rôles.
- Vérifier aussi l'affichage côté application : `lib/1_ceo/notifications/` doit montrer
  `echantillon_reference` (déjà envoyé par `backend_new/notifications/serializers.py`) et pas le
  numéro. Si `lib/1_ceo/notifications/services/notification_ceo_service.dart` contient encore des
  notifications inventées (`'2026/0001'`…), vérifier si elles sont affichées ; si oui, les enlever
  (pas de fausses données).
- Tests Django : adapter ou ajouter un test (la direction ne reçoit plus « modifié » ; le texte
  contient la référence).

---

## 51.4 — Chef : une session dont la date est passée ne peut plus être approuvée ni refusée

Une session **en attente** dont la date et l'heure sont passées est « morte ».
- Serveur (`backend_new/sessions_degustation/views.py`, actions approuver / refuser) : refuser
  avec le message « Cette session est passée : elle ne peut plus être approuvée ni refusée. »
- Application : ne plus afficher les boutons Approuver / Refuser pour ces sessions, dans
  `lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart` (ligne ~566,
  `isPending`) et `lib/5_chef_degustateur/tableau_de_bord/widgets/home_sessions_section.dart`
  (lignes ~166 et ~195). Afficher à la place un petit texte gris « Date passée ».
- Test Django pour le refus serveur.

---

## 51.5 — Direction : case « Réception physique » comme chez le dégustateur

Chez la direction, cocher « Réception physique » affiche un affichage vertical cassé.
Chez le dégustateur, on voit simplement « Réception physique confirmée »
(`lib/core/widgets/gestion_echantillons/echantillon_card.dart`, ligne ~226).
Faire la même chose pour la direction : chercher l'affichage dans
`lib/1_ceo/widgets/base_sample_card.dart` (ligne ~277) et
`lib/1_ceo/widgets/sample_card_echantillon.dart` (ligne ~163), et réutiliser le même rendu
que la carte du dégustateur (idéalement le même widget).

---

## 51.6 — Dégustateur : meilleur message si l'échantillon n'est pas reçu

Aujourd'hui, soumettre une évaluation sur un échantillon non reçu affiche
« L echantillon doit etre recu physiquement avant evaluation. »
(`backend_new/evaluations/serializers.py`, ligne ~39).
Remplacer par : « Cet échantillon n'est pas encore arrivé à la société. Cochez d'abord
« Réception physique » sur sa fiche, puis soumettez l'évaluation. »
Vérifier que l'application affiche bien ce texte tel quel (pas de message générique), pour le
dégustateur **et** le chef.

---

## 51.7 — Bordereau de réception en PDF

Modèle papier : « Bordereau de réception des échantillons d'information » (logo Al Jazeera,
titre, date, puis un tableau, puis en bas DATE / AGENT / SIGNATURE).

**Choix de l'utilisatrice :**
- Un bordereau = **une date** choisie. Il contient tous les échantillons ajoutés ce jour-là
  (`date_ajout`), **regroupés par fournisseur**. Le collecteur ne voit que ses échantillons ;
  le dégustateur et le chef voient ceux de tous les collecteurs.
- **Pas de numéro** de bordereau, pas d'historique : le PDF est fait à la demande.
- Colonnes **à ne pas mettre** : « Camion réservé » et « Achat confirmé ».

**Colonnes du tableau** (une ligne par fournisseur, plusieurs échantillons dans la même case) :
| Gouvernorat / Zone | Fournisseur | Référence collecteur | Scellage | Remarques |
- Gouvernorat / Zone : `gouvernorat` (+ `delegation` si rempli).
- Fournisseur : nom du fournisseur.
- Référence collecteur : la référence saisie dans l'application (`reference_bouteille`),
  une par échantillon.
- Scellage : une ligne par échantillon, `num_citerne — quantite_estimee` (ex. « C1 — 10T »).
- Remarques : `remarque_collecteur` s'il y en a.
- En bas : DATE (date du bordereau), AGENT (nom du collecteur ; s'il y en a plusieurs ce jour-là,
  les lister), SIGNATURE (case vide).

**Où** : un bouton « Bordereau » dans la page de gestion des échantillons du collecteur, du
dégustateur et du chef. Il ouvre un choix de date, puis génère le PDF et permet de
l'enregistrer / partager sur le téléphone. Si aucun échantillon ce jour-là : message
« Aucun échantillon ajouté ce jour-là. »

**Comment** : générer le PDF dans l'application avec les paquets `pdf` et `printing`
(les ajouter à `pubspec.yaml` ; **ne pas** toucher à `pubspec.lock`). Mettre le code commun
dans `lib/core/services/bordereau_pdf_service.dart` (un seul code pour les 3 rôles). Les données
viennent de la liste d'échantillons déjà chargée par chaque page (filtrée sur la date).
Ajouter un test Dart simple sur le regroupement par fournisseur
(`test/bordereau_regroupement_test.dart`), sans générer de vrai PDF.

---

## Questions (agent du PC secondaire)

_(vide)_

## Compte rendu (agent du PC secondaire)

_(à remplir à la fin)_
