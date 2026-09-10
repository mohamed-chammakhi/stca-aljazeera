# Laboratoire — Notifications & Idées

> Décisions tranchées le 2026-09-10 (voir §4) — pas encore codées, sauf ce qui est marqué
> « déjà existant ».

**Rappel de droits (tranché dans [`01_collecteur.md`](01_collecteur.md) §6.1) :**
le laboratoire ne modifie **jamais** un échantillon. Il produit ses analyses — objets
**rattachés** à l'échantillon, pas les données de l'échantillon lui-même.
Il n'a **pas de messagerie** (tranché D22).

Il ne voit que les échantillons `recuPhysiquement = true`
([`role_laboratoire.md`](../role_laboratoire.md)).

---

## 1. Scan du rapport d'analyse papier

### 1.1 — 📌 La fonctionnalité a déjà existé, puis a été retirée

Ce n'est **pas** une fonctionnalité neuve : c'est une **réactivation**.

- [`role_laboratoire.md`](../role_laboratoire.md) la spécifie déjà :
  > « **Photo upload** — take or upload a photo of the physical paper analysis report.
  > AI automatically detects and extracts table values to fill the form fields.
  > Technician reviews and confirms. »
- mais [`docs/production-and-deployment-guide.md`](../../docs/production-and-deployment-guide.md)
  acte sa suppression :
  > « The Azure Document Intelligence OCR integration (bottle-label / lab-report photo
  > scanning) **was removed** from both the backend and the app… Credentials and
  > reactivation notes are archived at `backend_new/.env.ocr-archive` (gitignored). »

⚠️ **Les deux documents se contredisent aujourd'hui.** Le guide de déploiement doit être
mis à jour quand cette décision est appliquée (voir §5, L2).

---

### 1.2 — ✅ TRANCHÉ (L1) — moteur retenu : **ML Kit on-device**, pas Azure

**Le problème posé :** Azure Document Intelligence est le meilleur moteur, mais il est
**payant** — et un coût récurrent risquait de rendre la fonctionnalité labo inutilisable
en pratique.

**Ce qui débloque la décision :** le raisonnement « Azure est meilleur » suppose un
problème que ce document **n'a pas**.

L'IA documentaire générique coûte cher parce qu'elle doit répondre à une question
ouverte : *quel est ce document, quels tableaux contient-il, quelles sont ses colonnes ?*

Le rapport d'analyse, lui, n'a **rien d'ouvert** :

| Contrainte | Conséquence |
|------------|-------------|
| Valeurs **imprimées** (confirmé), jamais manuscrites | l'OCR de texte imprimé suffit — c'est le point fort de ML Kit |
| **Template fixe**, toujours le même laboratoire | l'extraction devient déterministe, pas de l'inférence |
| **7 champs connus** + critères libres (voir §1.4) | « trouver 7 mots connus et lire le nombre à côté », pas « comprendre un tableau » |
| **Revue humaine obligatoire** avant soumission | une erreur d'OCR coûte 3 secondes de frappe, jamais une analyse fausse |

→ Ce qu'on paierait à Azure, c'est de l'**inférence de mise en page dont on n'a pas besoin**.

**📌 Le tableau n'est pas un obstacle, il aide.**
ML Kit renvoie une *bounding box* par bloc de texte. Sur un tableau :
« trouver le libellé `Acidité`, prendre le nombre situé **sur la même ligne**
(même coordonnée y) » est de la **géométrie fiable**, pas de la devinette.
Un tableau est plus facile à lire qu'un paragraphe.

**Bénéfices annexes :**
- gratuit, **définitivement** — aucun coût récurrent, aucun compte à créer
- fonctionne **hors ligne** — cohérent avec l'approche offline-first du projet
- **aucun document ne quitte le téléphone** — pas d'envoi à un tiers

⚠️ **Contrainte pratique relevée, au-delà du prix :** une souscription Azure impose une
carte bancaire en devises — friction réelle pour une entreprise tunisienne,
indépendamment du montant. C'est souvent le vrai blocage, pas le tarif.

---

### 1.3 — ✅ TRANCHÉ (L2) — Azure reste une **porte de sortie**, pas une suppression

Azure n'est **ni utilisé, ni effacé**. Les identifiants restent archivés dans
`backend_new/.env.ocr-archive`, et l'appel d'extraction passe derrière un **flag de
configuration** dans [`lib/config.dart`](../../lib/config.dart).

**Raison :** si les rapports réels s'avèrent trop dégradés (photocopies pâles, scans de
travers), basculer sur Azure ne doit coûter qu'un changement de flag — **pas une
réécriture**. L'UI, le formulaire et l'étape de revue restent identiques dans les deux cas.

→ **Règle d'architecture :** l'extraction doit être appelée derrière une **interface**,
jamais en appelant ML Kit directement depuis la page.

---

### 1.4 — ✅ TRANCHÉ (L3) — le tableau du papier devient le tableau de l'app

**La demande, mot pour mot :** *« une photo peut porter un tableau de valeurs qui doit
être extrait et mis dans un tableau de valeurs dans l'app — chaque valeur / champ doit
être placé au bon endroit. »*

L'extraction a donc **deux cibles**, pas une seule. Les deux existent déjà dans
[`backend_new/analyses/models.py`](../../backend_new/analyses/models.py) :

| Sur le papier | Dans l'app | Modèle |
|---------------|------------|--------|
| `Acidité 0,32` | champ typé `acidite` | `AnalyseLabo` — 7 colonnes fixes |
| `Indice de peroxyde 12,4` | champ typé `indice_peroxyde` | idem |
| `K232` / `K270` / `ΔK` | `k232` / `k270` / `delta_k` | idem |
| `Humidité` / `Impuretés` | `humidite` / `impuretes` | idem |
| toute autre ligne du tableau | ligne `label` + `valeur` + `unite` | `CritereAnalyse` |

📌 **`CritereAnalyse` a déjà exactement la bonne forme** pour recevoir les lignes non
typées — `label`, `valeur`, `unite`, `valeur_min`, `valeur_max`, `conforme`.
Rien à créer côté modèle de données.

**La photo est conservée** comme **preuve** (champ `photo` existant), pour que n'importe
qui puisse vérifier une valeur contre l'original.

---

### 1.5 — ✅ TRANCHÉ (L4) — template réel reçu : **certificat 188-2026**

Le fichier a été fourni le 2026-08-05. Le formulaire de saisie a été refait
d'après lui.

**Ce que le rapport contient réellement — 28 valeurs, pas 13 :**

| Tableau | Lignes | Méthode imprimée |
|---------|--------|------------------|
| Résultats principaux | 8 | ISO 660 / 662 / 663, COI/T.20 n°19, n°20, n°35 |
| Composition en stérols | 8 | COI/T20.DOC n°26 Rev.5 |
| Esters méthyliques d'acides gras | 12 | COI/T20.DOC n°33 Rev.1 |

**Trois surprises par rapport à ce que ce document supposait :**

1. ⚠️ **Le rapport n'imprime AUCUNE norme.** Il ne donne que les valeurs
   mesurées. `CritereAnalyse.valeur_min` / `valeur_max` ne peuvent donc **pas**
   être alimentés par le papier — les seuils viennent de la norme COI et vivent
   dans `lib/core/analyses/normes_coi.dart` (miroir Python
   `backend_new/analyses/normes_coi.py`). C'est le seul fichier à corriger si le
   laboratoire rectifie un seuil.
2. ⚠️ **Le rapport est en anglais**, l'app en français → la correspondance
   libellé imprimé → champ est une traduction, pas une recopie.
3. ⚠️ **`ECN42` existait sur le papier et manquait à l'app.** À l'inverse,
   **Polyphénols totaux et Tocophérols n'existent nulle part sur le rapport** :
   ils avaient été inventés. Retirés.

**Séparateur décimal : la virgule** (`0,30`, `0,003`). Le champ de saisie
n'acceptait que le point. `lireDecimal()` / `lire_decimal()` acceptent les deux.

**Vérification du tableau des seuils :** les 28 valeurs du certificat 188-2026
passent toutes, et le classement calculé ressort « Extra Vierge » — la même
conclusion que celle imprimée sur le papier. C'est la seule preuve dont on
dispose que les seuils du code sont ceux qu'applique le laboratoire, puisque le
papier ne les imprime pas. Le cas est figé dans
[`test/normes_coi_test.dart`](../../test/normes_coi_test.dart) et dans
`NormesCoiTests` côté Django.

**Deux pertes silencieuses corrigées au passage :** le formulaire envoyait 5
champs que `analyses/serializers.py` ne déclarait pas, et `labo_service.dart`
n'en sérialisait que 7. Dans les deux cas le technicien saisissait des valeurs
qui disparaissaient sans message d'erreur.

ℹ️ La question « que faire d'une ligne non reconnue ? » a été posée puis **écartée par
l'utilisateur** : le template est fixe, le cas ne se présentera pas.
→ Si un jour un second laboratoire entre en jeu, cette question devra être **rouverte**.

---

### 1.6 — ✅ TRANCHÉ (L8) — écran de revue avant soumission

La revue humaine est **obligatoire** (elle est ce qui rend le moteur gratuit acceptable —
§1.2). Forme retenue :

- les valeurs issues de l'OCR sont **visuellement distinguées** de celles saisies à la
  main (fond légèrement teinté tant que non confirmées)
- un champ que l'OCR n'a pas trouvé est marqué **« non détecté »**, jamais laissé vide en
  silence

Le technicien doit savoir d'un coup d'œil ce qu'il doit vérifier, sinon il valide tout en
bloc et la revue devient une formalité.

---

## 2. Version web du laboratoire

### 2.1 — ✅ TRANCHÉ (L5) — scan = **mobile**, import/export = **web**

📌 **Contrainte technique :** `google_mlkit_text_recognition` est **Android / iOS
uniquement**. ML Kit **ne tourne pas** sur le web.

Ce n'est **pas une limitation à contourner** — ça correspond à l'usage réel :

| | Mobile | Web |
|---|--------|-----|
| Entrée du document | 📷 **photo du papier** | 📁 **fichier importé** (scanner de bureau, PDF, export d'un autre système) |
| Extraction | ML Kit on-device | voir L6 ci-dessous |
| Usage typique | technicien devant la paillasse | technicien à son poste, traitement par lot |

On pointe un téléphone vers une feuille ; sur un poste fixe on a un scanner qui produit
un fichier. La séparation est **naturelle**.

→ **À écrire noir sur blanc pour que personne ne tente plus tard de forcer le scan
caméra dans le build web.**

---

### 2.2 — ✅ TRANCHÉ (L6) — pas d'extraction côté web

**Décision retenue :** pas d'extraction automatique sur le web — import de données
structurées uniquement (voir L7). Sur un poste fixe, la donnée existe le plus souvent déjà
sous forme de fichier — la ré-OCRiser serait un détour. OCR serveur et Azure restent des
options non retenues pour l'instant, pas des besoins bloquants.

---

### 2.3 — ✅ TRANCHÉ (L7) — import / export : formats et périmètre

- **Import** : Excel `.xlsx` + CSV
- **Import** : **plusieurs analyses en une fois** (traitement par lot)
- **Import** : rattachement par la **référence (`ref`)** ; référence inconnue ou ambiguë →
  rejet clair de la ligne, pas d'écriture silencieuse
- **Export** : réservé au laboratoire pour l'instant (le CEO pourra être ajouté plus tard
  si un besoin réel apparaît)

📌 [`role_laboratoire.md`](../role_laboratoire.md) disait déjà « **Export analysis results is
supported** » sans préciser le format — c'est maintenant précisé ci-dessus.

⚠️ **Un import écrit dans la base sans repasser par la revue humaine du §1.6.**
Il lui faut donc **son propre garde-fou** : prévisualisation avant validation, et refus
d'écrasement silencieux d'une analyse déjà `Soumis`.

---

## 3. Notifications

### 3.1 — REÇUES par le laboratoire

| Type | Émetteur | Statut |
|------|----------|--------|
| `ANALYSE_URGENTE` | Dégustateur / Chef dégustateur | ✅ **existe déjà** — [`notification_labo_service.dart`](../../lib/4_laboratoire/notifications/services/notification_labo_service.dart) |

✅ **Tranché (L9) :**
- **Nouvel échantillon disponible** — quand un échantillon passe `recuPhysiquement = true`,
  il **apparaît chez le laboratoire** (effet de bord acté §2.4 de
  [`01_collecteur.md`](01_collecteur.md)). **Oui, notifier** — c'est le déclencheur de son
  travail.
- **Décoche de réception physique** — si le chef dégustateur annule la réception
  (§1.4 de [`04_chef_degustateur.md`](04_chef_degustateur.md)), l'échantillon **disparaît**
  de la liste du labo. **Oui, notifier si l'analyse est déjà `En cours`** — sinon inutile.

### 3.2 — ÉMISES par le laboratoire

| Événement | Destinataire | Statut |
|-----------|--------------|--------|
| **Analyse soumise** | CEO (`analyse_soumise`) | ✅ existe déjà — §1.1 de [`02_ceo.md`](02_ceo.md) |
| ❓ **Analyse hors normes** | CEO | = **C7** dans [`02_ceo.md`](02_ceo.md) §1.3 — alerte distincte de `analyse_soumise` |
| ❓ **Analyse soumise** | Chef dégustateur | = **CD3** dans [`04_chef_degustateur.md`](04_chef_degustateur.md) §3 |

✅ **La détection « hors normes » est automatique** depuis L4. L'API expose
`parametres_hors_normes` sur chaque analyse, déduit des valeurs — jamais saisi.
Aucune saisie dédiée n'est nécessaire.

📌 **Point important pour C7 :** une valeur peut sortir de la norme **sans que le
classement change**. Un stérol ou un acide gras anormal trahit un *mélange*, pas
une dégradation : le classement reste « Extra Vierge ». L'alerte au directeur ne
peut donc **pas** être déduite du classement — elle doit lire
`parametres_hors_normes`, sinon un mélange passerait inaperçu.

---

## 4. Récapitulatif des décisions

| # | Question | Impact |
|---|----------|--------|
| ~~L1~~ | ~~Quel moteur d'extraction ?~~ → ✅ **ML Kit on-device**, gratuit, hors ligne, suffisant car template fixe + revue humaine | résolu |
| ~~L2~~ | ~~Azure supprimé définitivement ?~~ → ✅ **conservé comme porte de sortie** derrière un flag `config.dart` | résolu |
| ~~L3~~ | ~~Où atterrissent les valeurs extraites ?~~ → ✅ **7 champs typés** de `AnalyseLabo` + `CritereAnalyse` pour le reste | résolu |
| ~~L5~~ | ~~Scan caméra sur le web ?~~ → ✅ **non — ML Kit est mobile only.** Scan = mobile, import/export = web | résolu |
| ~~L4~~ | ~~Template réel du rapport~~ → ✅ **certificat 188-2026 reçu**. 28 valeurs en 3 tableaux, décimales à la virgule, **aucune norme imprimée** → seuils COI dans `normes_coi.dart` | résolu |
| ~~L6~~ | ~~Extraction côté web : aucune / serveur / Azure ?~~ → ✅ **aucune** — import de données structurées seulement | résolu |
| ~~L7~~ | ~~Import/export : formats, lot, rattachement, périmètre~~ → ✅ **Excel + CSV, par lot, rattachement par référence, export réservé au labo** | résolu |
| ~~L8~~ | ~~Forme de l'écran de revue (§1.6)~~ → ✅ **valeurs OCR distinguées visuellement, champ non détecté marqué comme tel** | résolu |
| ~~L9~~ | ~~Notifier le labo à l'arrivée d'un échantillon ? Et à la décoche ?~~ → ✅ **oui aux deux**, la décoche seulement si l'analyse est déjà en cours | résolu |

**Déjà existant, rien à faire :**
- ✅ `ANALYSE_URGENTE` reçue — implémentée
- ✅ `analyse_soumise` → CEO — implémentée
- ✅ `CritereAnalyse` — le modèle a déjà la bonne forme pour les valeurs extraites
- ✅ champ `photo` sur `AnalyseLabo` — le stockage de la preuve existe

---

## 5. Pistes envisagées puis écartées

| Piste écartée | Pourquoi | Décision retenue |
|---------------|----------|------------------|
| **Azure Document Intelligence** comme moteur principal | Coût récurrent + carte en devises → risquait de rendre la fonctionnalité labo inutilisable. Et son avantage (inférence de mise en page) ne sert à rien sur un template fixe à 7 champs | **ML Kit on-device**, gratuit (§1.2) |
| **Supprimer Azure** définitivement | Aucun plan B si les rapports réels sont trop dégradés | Conservé derrière un **flag de configuration** (§1.3) |
| **Tesseract** comme alternative gratuite | Plus ancien, généralement **moins bon** que ML Kit sur photo de téléphone — aucun gain | ML Kit (§1.2) |
| **OCR serveur** (PaddleOCR / docTR) pour le mobile | Exigerait le réseau et 1–2 Go de RAM serveur pour un gain nul sur du texte imprimé | ML Kit on-device (§1.2) |
| **Dialogue de mapping** pour chaque ligne non reconnue | Écarté par l'utilisateur : le template est fixe, le cas ne se présente pas | Correspondance figée depuis le template réel (§1.5) |
| **Forcer le scan caméra dans le build web** | ML Kit ne tourne pas sur le web, et un poste fixe a un scanner, pas une caméra pointée sur une feuille | Scan = mobile, import = web (§2.1) |
| **Une bibliothèque de documents** (page dédiée, recherche, archives) | Ce n'était pas la demande : l'enjeu est que **les valeurs** atterrissent au bon endroit, pas d'archiver des fichiers | Extraction vers `AnalyseLabo` + `CritereAnalyse`, photo conservée comme preuve (§1.4) |

---

## 6. À compléter
_(en attente du template réel du rapport d'analyse — L4)_
