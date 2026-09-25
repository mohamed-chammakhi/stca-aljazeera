# Tâche 40 — Formulaire échantillon : finitions + suggestions par collecteur + nom du fournisseur

Lis `files/taches/PROTOCOLE.md` avant de commencer (dont « Même correction pour tous les
rôles »). Lis ensuite `CLAUDE.md` à la racine.

Flutter **et** backend (partie B seulement). Aucune migration.

Les trois formulaires d'ajout / modification d'échantillon :
```
lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart
lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
```

---

## A — Même apparence pour les champs avec suggestions

Les champs « Variété d'olive » et « Nom / Code fournisseur » utilisent `ChampAutocomplete`
(`lib/core/widgets/champ_autocomplete.dart`), qui a son propre style (fond `#FAFAF7`,
titre en `GoogleFonts.alegreya` couleur `kOlive`, bordure différente). Les autres champs
du formulaire (ex. « N° citerne ») utilisent `_InlineLabel` + `_fieldDec(...)`.
Résultat : les couleurs ne sont pas les mêmes.

Donne à `ChampAutocomplete` des paramètres optionnels (ex. `InputDecoration? decoration`,
`Widget? titre` ou `TextStyle? styleTitre`, `TextStyle? styleTexte`) et, dans les trois
formulaires, passe-lui **exactement** la décoration et le titre des autres champs du même
formulaire (`_fieldDec('…')`, même widget/style de titre). Sans ces paramètres, le widget
garde son style actuel (ne casse pas les autres écrans).

## B — Suggestions : un collecteur ne voit que SES fournisseurs et SES variétés

Règle de la propriétaire : un collecteur ne doit pas découvrir les fournisseurs ou les
variétés saisis par les autres collecteurs.

- **Backend** `backend_new/fournisseurs/views.py`, `FournisseurListCreateView` : ajoute
  `get_queryset()` : si `request.user.role == User.Role.COLLECTEUR` →
  `Fournisseur.objects.filter(echantillons__collecteur=request.user).distinct().order_by('nom')`
  (la relation inverse s'appelle `echantillons`, voir `echantillons/models.py`). Les autres
  rôles voient tout, comme aujourd'hui. Fais pareil pour `FournisseurDetailView` (un
  collecteur ne lit / modifie que les fournisseurs de ses échantillons).
- **Variétés** : `VarieteService` lit `/api/echantillons/`, déjà limité aux échantillons du
  collecteur côté serveur (vérifie `echantillons/views.py`, `get_queryset`). Vérifie-le et
  écris-le dans ton rapport. Pour le collecteur, **ne mets pas** la liste de variétés
  « connues » en dur (`_varietesConnues`) si elle vient d'autres saisies — elle est fixe,
  donc elle peut rester.
- **Changement de compte sur le même téléphone** : `FournisseurService` et `VarieteService`
  gardent une liste en mémoire (`_cache`). Si un collecteur se déconnecte et qu'un autre se
  connecte sur le même téléphone, il verrait la liste du précédent. Vide ces deux caches à
  la connexion et à la déconnexion (cherche où `saveTokens` / `clearTokens` sont appelés, ou
  la déconnexion dans les profils, et appelle `invalidateCache()` des deux services).
- **Test backend** dans `backend_new/fournisseurs/tests.py` : deux collecteurs A et B, chacun
  un échantillon avec un fournisseur différent → A ne reçoit que le sien en `GET
  /api/fournisseurs/` ; un dégustateur reçoit les deux.

Ne change pas la façon dont le serveur relie un nom tapé à un fournisseur existant
(`_supplier_by_name_or_create`). Seules les **suggestions** sont limitées.

## C — Titres et indications des champs plus foncés

Dans les trois formulaires : les titres des champs (ex. « N° citerne », `_InlineLabel`) et
les indications grises dans les champs (`hintText`, ex. « Ex: Z1 ») sont trop clairs.
Garde **la même teinte** mais plus foncée (pas une autre couleur) : par exemple
`Color.lerp(couleurActuelle, Colors.black, 0.35)` ou la nuance `shade` plus foncée de la
même couleur. Applique la même chose au titre et à l'indication des champs de la partie A,
pour que tout reste identique. Le texte tapé par l'utilisateur ne change pas.

## D — Champs obligatoires

Règle de la propriétaire, pour l'ajout **et** la modification :
- **obligatoires** : au moins une bouteille, le fournisseur, la référence de chaque
  bouteille (elle se remplit toute seule, mais elle peut être effacée par erreur) ;
- **tout le reste est facultatif** : n° citerne, variété, quantité, remarque, photo,
  gouvernorat, délégation, date de livraison, etc.

À faire :
- Dans les trois formulaires, le bouton d'enregistrement vérifie ces 3 règles, avec un
  message clair : `Ajoutez au moins une bouteille.`, `Le fournisseur est obligatoire.`,
  `La référence bouteille est obligatoire pour la bouteille N.`. Aucune autre vérification
  bloquante.
- Marque d'un astérisque (comme `Référence bouteille` aujourd'hui) le titre du champ
  fournisseur ; retire l'astérisque de tout autre champ qui en aurait un.
- **Backend** : vérifie dans `echantillons/serializers.py` et `echantillons/models.py` que
  `num_citerne`, `variete`, `quantite_estimee` (et les autres champs du formulaire)
  acceptent une valeur vide ou absente. Si un champ est obligatoire côté serveur sans
  migration nécessaire (`required=False`, `allow_blank=True`, `allow_null=True` dans le
  serializer), corrige-le. Si ça demande une **migration**, ne la fais pas : écris-le sous
  `## QUESTION`. Ajoute un test : création avec seulement fournisseur + référence → 201.

## E — Afficher le NOM du fournisseur, jamais son code interne

Dans la fiche de détail d'un échantillon, « Fournisseur » affiche `F-0002` au lieu de
« hami ». `F-0002` est le `code_fournisseur` que le serveur donne automatiquement
(`echantillons/serializers.py`, `_create_supplier_with_generated_code`). Il ne doit plus
jamais être montré.

- Partout où l'écran affiche `codeFournisseur` pour dire « Fournisseur » (grep
  `DetailItem('Fournisseur', e.codeFournisseur)` et équivalents : `1_ceo/…` dans
  achats_confirmes, analyse_laboratoire, analyse_organoleptique, validation_achats,
  `widgets/sample_card_echantillon.dart`, et **tous les autres rôles** — collecteur,
  dégustateur, chef, labo, cartes, groupes, notifications…), affiche le nom du
  fournisseur. Si le modèle Dart de cet écran n'a pas le nom, ajoute-le à partir du JSON
  (`fournisseur_nom` ou équivalent : vérifie ce que renvoie le serializer) avec repli sur
  le code seulement si le nom est vide.
- La recherche peut continuer à chercher dans le code **et** le nom.
- Ne supprime pas `code_fournisseur` de la base : il sert d'identifiant unique interne.
- Titre du champ du formulaire : `Nom / Code fournisseur` → `Fournisseur` (trois
  formulaires).

---

## Tests

- Flutter : validation (un seul test par règle de D : pas de bouteille, pas de fournisseur,
  référence vide, et « seulement fournisseur + référence » passe) ; un test que la fiche
  de détail montre le nom et pas `F-000…` (sur un des écrans).
- Backend : les tests de B et D.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera
`flutter analyze lib test`, `flutter test` et les tests Django.

Dans ton rapport, liste pour chaque partie (A à E) les fichiers touchés et les rôles
couverts.

## RAPPORT

### Fait

- Partie A — apparence des champs avec suggestions :
  - `lib/core/widgets/champ_autocomplete.dart` : le champ autocomplete accepte une décoration, un titre et un style texte optionnels, sans changer son style par défaut ailleurs.
  - `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` : les champs `Fournisseur` et `Variété d'olive` utilisent le même titre et la même décoration que les autres champs du formulaire collecteur.
  - `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : même harmonisation pour le formulaire dégustateur.
  - `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : même harmonisation pour le formulaire chef.

- Partie B — suggestions limitées au collecteur connecté :
  - `backend_new/fournisseurs/views.py` : un collecteur ne liste, lit, modifie ou supprime que les fournisseurs liés à ses propres échantillons ; les autres rôles gardent la vue complète.
  - `backend_new/fournisseurs/tests.py` : test ajouté avec deux collecteurs et un dégustateur.
  - `lib/core/services/auth_service.dart` : les caches fournisseurs et variétés sont vidés à la connexion et à la déconnexion.
  - Vérifié dans `backend_new/echantillons/views.py` : `EchantillonViewSet.get_queryset()` filtre déjà `/api/echantillons/` sur `collecteur=user`, donc `VarieteService` ne voit que les variétés du collecteur connecté. La liste fixe `_varietesConnues` reste inchangée.

- Partie C — titres et indications plus foncés :
  - `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_decorations.dart` et `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` : hints et labels du formulaire collecteur foncés dans la même famille.
  - `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : hints, labels et titres du formulaire dégustateur foncés.
  - `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : même correction pour le formulaire chef.

- Partie D — champs obligatoires :
  - `lib/core/utils/validation_echantillon_formulaire.dart` : validation partagée pour les 3 règles demandées.
  - Les trois formulaires d'échantillon utilisent cette validation : au moins une bouteille, fournisseur obligatoire, référence bouteille obligatoire par bouteille.
  - `backend_new/echantillons/serializers.py` : les champs facultatifs du formulaire sont acceptés absents ou vides côté API sans migration.
  - `backend_new/echantillons/tests.py` : test création avec seulement fournisseur + référence.
  - `test/formulaire_echantillon_finitions_test.dart` : tests Flutter ajoutés pour les 4 cas de validation demandés.

- Partie E — nom fournisseur affiché :
  - `lib/1_ceo/...` : les cartes/détails CEO affichent `fournisseurAffichage`, avec nom prioritaire et code en repli ; la recherche garde code et nom.
  - `lib/2_collecteur/...` : la carte détail collecteur affiche le nom fournisseur et la recherche inclut le nom.
  - `lib/3_degustateur/...` et `lib/5_chef_degustateur/...` : la recherche des échantillons inclut le nom fournisseur.
  - `lib/4_laboratoire/echantillons_labo/models/echantillon_labo.dart` : le modèle labo lit `fournisseur_nom` avant `code_fournisseur`.
  - `lib/core/models/echantillon.dart`, `lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart`, `lib/1_ceo/utilisateurs/models/echantillon_ceo_view.dart` : getters d'affichage fournisseur ajoutés.
  - `test/formulaire_echantillon_finitions_test.dart` : test ajouté pour vérifier que la fiche détail affiche `hami` et pas `F-0002`.

### Vérifié

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test fournisseurs echantillons -v 1
```

Sortie :

```text
Found 38 test(s).
System check identified no issues (0 silenced).
Ran 38 tests in 177.129s
OK
```

Non lancé, conformément à la consigne de cette tâche :

```bash
flutter analyze lib test
flutter test
```

### Non fait

- Je n'ai pas lancé Flutter : la fiche dit explicitement que le sandbox ne peut pas lancer Flutter et demande de ne pas essayer.
- Je n'ai pas créé de migration : les corrections backend nécessaires ont été faites dans le serializer uniquement.

### HORS PÉRIMÈTRE

- `files/backend_sprint_plan.md` est référencé par les instructions mais absent du dépôt.
- La capacité `frontend-design` demandée par `CLAUDE.md` n'est pas disponible dans cette session (`tool_search frontend-design` → 0 outil).
