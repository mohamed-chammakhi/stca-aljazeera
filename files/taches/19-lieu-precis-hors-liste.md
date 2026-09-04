# Tâche 19 — Un champ pour un lieu précis, hors de la liste gouvernorat/délégation

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Modules concernés : `2_collecteur`, `3_degustateur`, `5_chef_degustateur`.

---

## Contexte

Vérifié avant d'écrire cette tâche : la liste des gouvernorats et délégations
(`assets/img/delegations.geojson`, lue par `GeoService`) est déjà complète — **24
gouvernorats, 264 délégations**, comptés directement dans le fichier. Ce n'est donc pas la
liste qu'il faut agrandir.

Ce qui manque : un endroit précis (village, lieu-dit, ferme...) ne rentre jamais dans une
liste de délégations, quelle qu'elle soit — une délégation couvre une zone entière. Le
propriétaire veut un champ texte libre pour que le collecteur précise ce niveau de détail
quand le gouvernorat + la délégation ne suffisent pas.

Bonne nouvelle : ce champ **existe déjà à moitié**. `EchantillonCollecteur` a un champ
`cite` (`lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart` L85), lu
depuis l'API (`fromJson` L192), mais **jamais renvoyé** — `toJson()` (L226-247) ne l'inclut
pas. Le modèle partagé du dégustateur/chef dégustateur
(`lib/core/models/echantillon_evaluation.dart`) n'a pas ce champ du tout.

---

## CONSIGNE

### 1. Collecteur

- Dans `EchantillonCollecteur.toJson()`, ajoute `'cite': cite ?? '',` — le champ existe déjà
  côté modèle, il manque juste à l'envoi.
- Dans `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart`, ajoute un
  champ texte libre juste après le champ "Délégation" (~L517), label **"Lieu précis
  (optionnel)"**, indice **"Ex: nom du village, du lieu-dit..."**, lié à `_gouvernorat`'s
  voisin `_delegation` — utilise le champ `cite` du modèle. Pré-remplis-le en modification
  (`e?.cite`), envoie sa valeur dans `_save()` comme les autres champs texte du formulaire
  (vide → `null`, comme `remarques`).

### 2. Dégustateur et chef dégustateur

- Ajoute `cite` à `lib/core/models/echantillon_evaluation.dart` (`String? cite`), avec
  lecture/écriture JSON comme `gouvernorat`/`delegation` (~L27-28, L41-42, L57-58, L73-74).
- Dans les deux formulaires
  (`lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` ~L546 et
  `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`,
  section "SHARED: LOCALISATION" équivalente), ajoute le même champ, au même endroit
  (juste après "Délégation"), avec le même label et le même indice que pour le collecteur.
  **Les deux formulaires doivent avoir exactement le même texte** — c'est la règle 1 du
  `CLAUDE.md`.

---

## Ce que tu ne fais pas

- Tu ne touches pas à `assets/img/delegations.geojson` ni à `GeoService` : la liste
  gouvernorat/délégation ne change pas.
- Tu ne fusionnes pas les deux formulaires dégustateur/chef dégustateur en un seul fichier —
  ce n'est pas le sujet ici (voir tâche 09 pour le pourquoi de cette séparation actuelle).
- Tu ne rends pas ce champ obligatoire.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport.
