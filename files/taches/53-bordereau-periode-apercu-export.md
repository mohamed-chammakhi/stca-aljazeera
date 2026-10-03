# Tâche 53 — Bordereau : période, aperçu, export (partager / imprimer), mise en page soignée

Écrit le 03/10/2026 par Claude. Exécutant : GitHub Copilot. Claude vérifie et commite.

Code actuel (tâche 51.7) :
- `lib/core/services/bordereau_pdf_service.dart` : regroupement + création du PDF (paquet `pdf`) ;
- `lib/core/widgets/bouton_bordereau.dart` : bouton de la barre du haut (choix d'**un** jour,
  puis `Printing.sharePdf`) ;
- utilisé par `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart`,
  `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart`,
  `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart`.
- Tests : `test/bordereau_regroupement_test.dart`.

Le PDF est fabriqué **dans l'application** (Dart, paquets `pdf` + `printing`), pas par le
serveur. On garde ça. Le PDF n'est **pas stocké** dans l'application : il est créé à la demande.

## 1. Choix d'une période (au lieu d'un seul jour)

- Remplacer `showDatePicker` par `showDateRangePicker` (début → fin ; un seul jour = début et
  fin identiques). Titre « Période du bordereau », boutons « Annuler » / « Valider », locale fr.
  Dernière date possible : aujourd'hui.
- Filtre sur la **date d'enregistrement dans l'application** (`dateAjout`), en heure locale,
  bornes incluses. Remplacer `lignesDuJour` par `lignesDeLaPeriode(lignes, debut, fin)`.
- Si rien dans la période : « Aucun échantillon enregistré dans l'application pendant cette
  période. » (et si un seul jour : « … ce jour-là. »).

## 2. Après la génération : page d'aperçu avec export

Ouvrir une page plein écran « Bordereau » qui montre le PDF avec `PdfPreview` (paquet `printing`) :
- bouton **Partager** (e-mail, WhatsApp, Drive, Enregistrer sur le téléphone… = feuille de
  partage Android) → `Printing.sharePdf`, nom de fichier `bordereau_AAAA-MM-JJ.pdf` ou
  `bordereau_AAAA-MM-JJ_AAAA-MM-JJ.pdf` pour une période ;
- bouton **Imprimer** → `Printing.layoutPdf` (la fenêtre d'impression Android propose les
  imprimantes connectées au téléphone et « Enregistrer au format PDF ») ;
- désactiver dans `PdfPreview` le changement de format de page et l'orientation
  (`canChangePageFormat: false`, `canChangeOrientation: false`, `canDebug: false`) ;
- libellés en français. En cas d'erreur : « Le bordereau n'a pas pu être créé. Réessayez. »

## 3. Mise en page du PDF (noir et blanc, propre, proche du modèle papier)

Modèle papier de la société (photo vue par Claude) :
- **En-tête** : un cadre à 2 colonnes. À gauche le logo Al Jazeera
  (`assets/img/Aljazia_logo.png`, le même que la page de connexion). À droite, un cadre avec
  en haut, sur une ligne grisée claire, le titre « Bordereau de réception des échantillons
  d'information » (centré, gras), puis une ligne de 3 cases : « Date : JJ/MM/AAAA » (date de
  création du bordereau = aujourd'hui) | « Ver : 00 » | « Page X/Y ».
- Sous l'en-tête, à droite : « Période : du JJ/MM/AAAA au JJ/MM/AAAA » (ou « Jour : JJ/MM/AAAA »
  si un seul jour).
- **Tableau** (bordures fines noires, en-tête en majuscules, gras, fond gris très clair, centré) :
  `GOUVERNORAT / ZONE` | `FOURNISSEUR` | `RÉFÉRENCE COLLECTEUR` | `SCELLAGE` | `REMARQUES`.
  Une ligne par fournisseur (même nom + même lieu), plusieurs échantillons empilés dans la
  même case, une ligne de texte par échantillon, alignés entre Référence et Scellage
  (même nombre de lignes, même ordre). Lignes alternées blanc / gris très clair comme le papier.
  Le tableau peut continuer sur plusieurs pages : répéter l'en-tête du tableau
  (`pw.Table` dans `MultiPage` avec `repeatHeader` / `TableHelper`), et l'en-tête de page sur
  chaque page (`header:` de `MultiPage`) avec « Page X/Y ».
- **Pas** de colonnes « Achat confirmé » ni « Camion réservé ».
- **Pied** (après le tableau, sans cadre, comme le papier) : « DATE : JJ/MM/AAAA » à gauche,
  « AGENT : nom(s) du/des collecteur(s) » au centre/droite, puis « SIGNATURE » à droite avec
  un espace vide d'environ 3 cm au-dessous.
- Police : garder Alegreya (accents) ; tailles lisibles (titre 13–14, tableau 9–10).
- Pas de couleur à part le gris clair.

## 4. Tests

- Mettre à jour `test/bordereau_regroupement_test.dart` : filtre par période (bornes incluses,
  heure locale, un seul jour), message vide.
- Ajouter un test qui appelle `genererPdf` (période de 2 jours, 2 fournisseurs, 3 échantillons)
  et vérifie que des octets PDF non vides sont produits (commencent par `%PDF`). Utiliser
  `TestWidgetsFlutterBinding.ensureInitialized()` pour charger les assets.

## Règles

Voir `files/taches/PROTOCOLE.md`. Interdit : `git commit`, `git push`, ML Kit.
Encodage UTF-8 sans BOM, garder les fins de ligne de chaque fichier.
Le même bouton et la même page servent aux 3 rôles (collecteur, dégustateur, chef) : un seul code.
Lancer `flutter analyze` (zéro ligne « error - ») et `flutter test` avant d'écrire le rapport.

## RAPPORT

### Fait

- `lib/core/services/bordereau_pdf_service.dart` : le bordereau filtre maintenant une période locale bornée incluse, produit une mise en page noir et blanc paginée avec en-têtes répétés, et génère les noms de fichiers pour un jour ou une période.
- `lib/core/widgets/bouton_bordereau.dart` : le bouton ouvre un sélecteur de période en français, signale les périodes vides et ouvre l’aperçu commun aux trois rôles.
- `lib/core/widgets/apercu_bordereau_page.dart` : nouvelle page plein écran `Bordereau` avec `PdfPreview`, partage et impression en français.
- `test/bordereau_regroupement_test.dart` : tests des bornes, du jour unique, des messages vides et de la génération d’un PDF de deux jours avec deux fournisseurs et trois échantillons.
- `files/taches/53-bordereau-periode-apercu-export.md` : ajout du présent rapport.

### Vérifié

- `flutter test test/bordereau_regroupement_test.dart` : `6` tests réussis.
- `flutter analyze lib test` : `52 issues found` (diagnostics existants de type info/warning), `0` ligne `error -`.
- `flutter test` : `187` tests réussis, `0` échec.

### Non fait

- Aucun test manuel sur téléphone Android de la feuille de partage, des imprimantes connectées ou de l’option « Enregistrer au format PDF ».
- Les tests Django n’ont pas été lancés : cette tâche ne modifie ni le backend ni la base et ne demande aucune migration.

### HORS PÉRIMÈTRE

- Les diagnostics Flutter préexistants restants dans d’autres fichiers n’ont pas été corrigés.
- Les changements Git déjà présents dans `files/taches/FILE-ATTENTE.md`, `backend_new/` et les fichiers générés des plateformes n’ont pas été modifiés volontairement.

FIN RAPPORT
