# Tâche 02 — Le fournisseur : une seule requête au lieu de deux

## CONSIGNE

### Le problème

Quand le collecteur enregistre un échantillon, l'application fait **deux appels réseau à la
suite** :

1. elle crée la fiche du fournisseur avec `POST /api/fournisseurs/` ;
2. elle enregistre l'échantillon.

Si le premier échoue, le code attrape l'erreur et continue quand même
(`lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart`, vers la ligne 378).
L'échantillon part, mais sans fiche fournisseur créée.

**Décision du propriétaire :** l'échantillon doit **toujours** s'enregistrer, et le collecteur ne
doit jamais être embêté avec ce détail.

### Ce que j'ai vérifié — la première requête est inutile

Trois constats, à vérifier toi-même avant de commencer :

1. **Le serveur sait déjà tout faire en une fois.**
   `backend_new/echantillons/serializers.py` contient `_resolve_fournisseur()`. Ce code accepte
   `fournisseur_nom` ou `code_fournisseur` envoyés **avec l'échantillon**, retrouve la fiche
   existante, ou en crée une. Tout se passe dans la même requête.

2. **L'application envoie déjà le nom.**
   `lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart`, méthode
   `_toDjangoMap()` vers la ligne 94 : elle place `fournisseur_nom` dans le corps de la requête
   quand le nom n'est pas vide.

3. **L'identifiant créé par la première requête n'est jamais envoyé au serveur.**
   `_toDjangoMap()` n'envoie aucun champ `fournisseur` contenant l'identifiant. La valeur
   retournée par `_resoudreFournisseur()` ne sert qu'à remplir un champ local, lignes 443 et 455
   du dialogue.

Autrement dit : la première requête ne sert à rien pour l'enregistrement. Elle ne fait
qu'ajouter une occasion d'échouer.

---

### Ce qu'il faut faire

Dans `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` :

**Supprime l'appel à `FournisseurService.instance.create(...)`** et le `try/catch` qui
l'entoure, vers la ligne 378. L'enregistrement se fait désormais en une seule requête, celle de
l'échantillon.

**Garde tout le reste de `_resoudreFournisseur()` :**
- les suggestions de noms pendant la saisie ;
- la détection des fournisseurs proches (`findNearDuplicates`) et le dialogue qui demande au
  collecteur s'il s'agit du même fournisseur.

Ces deux fonctions aident à la saisie. Elles ne créent rien, elles ne doivent pas disparaître.

**Ce qui reste à décider dans le code :** si le collecteur choisit un fournisseur existant dans
les suggestions, l'application doit envoyer ce fournisseur-là, pas seulement le nom tapé.
Vérifie ce que `_toDjangoMap()` envoie dans ce cas — si `code_fournisseur` est déjà rempli, tout
va bien ; sinon, écris une `## QUESTION` plutôt que de deviner.

---

### Ce que ça change pour le collecteur

- Il tape un nom, il enregistre, c'est fini. Une seule requête part.
- Soit tout s'enregistre, soit rien. Il n'y a plus de résultat à moitié fait.
- Il ne voit jamais de message parlant de « fiche fournisseur ».

---

### Tests

**Django**, dans `backend_new/echantillons/tests.py` — vérifie d'abord si ces cas sont déjà
couverts, et n'ajoute que ce qui manque :

1. créer un échantillon avec un `fournisseur_nom` inconnu → la fiche fournisseur est créée, et
   l'échantillon lui est bien rattaché ;
2. créer un échantillon avec un `fournisseur_nom` qui existe déjà → **aucune fiche en double**
   n'est créée, l'échantillon est rattaché à la fiche existante ;
3. créer un échantillon sans nom de fournisseur → pas d'erreur.

**Flutter** : si un test couvre le dialogue d'enregistrement, vérifie qu'il ne s'attend plus à un
appel vers `/api/fournisseurs/` au moment de sauver.

---

### Vérification

```bash
cd project3
flutter analyze lib test
flutter test
./backend_new/venv/Scripts/python.exe backend_new/manage.py test --keepdb
```

Repères à ne pas faire baisser : **139 tests Django au vert**, `flutter test` vert sauf
`widget_test.dart` (cassé avant ce chantier).

**À la main, avec le backend lancé :** enregistrer un échantillon avec un nom de fournisseur
jamais utilisé. Vérifier ensuite dans la liste des fournisseurs que la fiche existe et qu'elle
n'apparaît qu'une fois.

---

### Hors périmètre

Ne touche pas au mode hors ligne. Si le téléphone n'a aucun réseau, rien ne s'enregistre — c'est
un autre chantier, prévu plus tard.

---

## RAPPORT

### Fait

- `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` — le collecteur conserve les suggestions et l'avertissement de nom proche, mais l'enregistrement ne crée plus une fiche fournisseur dans un appel séparé et n'affiche plus de détail technique à ce sujet.
- `lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart` — l'échantillon envoie directement le nom saisi au serveur dans son unique requête; le nom et le code renvoyés restent visibles après l'enregistrement.
- `lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart` — le nom fournisseur renvoyé par Django est conservé dans l'échantillon affiché.
- `test/echantillon_collecteur_service_test.dart` — nouveau test garantissant un seul `POST /api/echantillons/`, avec `fournisseur_nom` et sans identifiant fournisseur local.
- `backend_new/echantillons/tests.py` — trois régressions garantissent la création et la liaison d'un nom inconnu, la réutilisation sans doublon d'un nom existant, et l'acceptation d'un échantillon sans fournisseur.

### Vérifié

- `rg -n "FournisseurService\.instance\.create|api/fournisseurs" lib/2_collecteur/mes_echantillons` : aucune occurrence (sortie vide).
- `flutter analyze lib test` : code 1, **51 diagnostics préexistants** (11 avertissements, 40 informations), aucun nouveau diagnostic B2/B3.
- `flutter test` : **95 réussis, 1 échec**. Échec unique connu : `test/widget_test.dart:19`, `Expected: exactly one matching candidate`, `Actual: Found 0 widgets with text "0"`.
- `flutter test test/echantillon_collecteur_service_test.dart` : **1 test réussi** lors de la validation B2 ciblée.
- `./venv/Scripts/python.exe manage.py test echantillons users --keepdb -v 1` depuis `backend_new/` : **48 tests réussis en 245,708 s**, `OK`.
- `./venv/Scripts/python.exe manage.py test --keepdb -v 1` depuis `backend_new/` : une exécution globale antérieure de cette session a réussi **153 tests en 638,576 s**, avant l'ajout des quatre derniers tests de régression. La tentative globale finale a été interrompue après **2 381,5 s** sans aucune sortie; elle ne constitue ni un succès ni un échec de tests. Les applications modifiées sont couvertes par les 48 tests ciblés finaux ci-dessus.
- `git diff --check` : aucune erreur d'espace; uniquement les avertissements de conversion LF/CRLF existants.

### Non fait

- La vérification manuelle avec le backend lancé et un fournisseur inédit n'a pas été exécutée sur téléphone : aucune session applicative authentifiée ni appareil de test n'a été utilisé pendant cette tâche.

### HORS PÉRIMÈTRE

- Le mode hors ligne reste inchangé, conformément à la consigne.
