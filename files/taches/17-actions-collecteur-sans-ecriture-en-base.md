# Tâche 17 — Ajouter/modifier/supprimer un échantillon sans écrire en base, en mode démonstration

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Module concerné : `2_collecteur` uniquement.
Fichier : `lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart`.

---

## Contexte

Le propriétaire veut pouvoir essayer toutes les actions du module collecteur (ajouter,
modifier, supprimer un échantillon) juste pour voir le résultat à l'écran, **sans qu'aucune
écriture ne parte vers le serveur réel**, **sans bouton ni interrupteur à activer**, et
**sans perdre les données de démonstration existantes**.

Le mécanisme qu'il faut est déjà à moitié là. L'application entre déjà automatiquement en
mode démonstration (bandeau orange "Données de démonstration — serveur injoignable",
`lib/core/widgets/bandeau_demonstration.dart`) dès que le serveur Django ne répond pas —
et seulement en dehors d'un build de production (`avecSecours()`,
`lib/core/services/resultat_service.dart`, rethrow si `kReleaseMode`). C'est ce bandeau
qui sert d'indication : pas besoin d'en ajouter une autre.

Le problème : une fois dans ce mode, les quatre méthodes d'écriture de
`EchantillonCollecteurService` **refusent** l'action au lieu de l'appliquer localement :

```dart
if (_usingMockData) {
  throw StateError('Création indisponible avec les données de démonstration.');
}
```

Present dans `createEchantillon` (~L174), `createEchantillonWithImage` (~L188),
`updateEchantillon` (~L213), `deleteEchantillon` (~L229).

---

## CONSIGNE

Dans ces quatre méthodes, quand `_usingMockData` est vrai, **n'envoie rien au serveur** et
simule un succès au lieu de lancer une exception :

1. `createEchantillon(e)` et `createEchantillonWithImage(e, ...)` : renvoie `e` tel quel
   (l'appelant, `mes_echantillons_page.dart`, construit déjà un objet complet côté client
   avant l'appel — regarde `formulaire_dialog.dart` `_save()` pour voir comment l'id et le
   numéro sont déjà générés localement). N'essaie pas d'envoyer l'image dans
   `createEchantillonWithImage` en mode démonstration : ignore `imageBytes`/`filename`,
   renvoie l'échantillon sans photo.
2. `updateEchantillon(e)` : renvoie `e` tel quel, sans appeler `_api.patch`.
3. `deleteEchantillon(id)` : ne fait rien (pas d'appel réseau), renvoie normalement.

Le résultat attendu : le collecteur ajoute/modifie/supprime un échantillon exactement comme
d'habitude, la carte apparaît/se met à jour/disparaît dans la liste comme avec un vrai
serveur, le bandeau orange reste affiché pour rappeler que rien n'est enregistré, et rien
n'est perdu au rechargement des données de démonstration (`mockEchantillons()` n'est pas
modifiée : elle reste la même liste de scénarios de départ à chaque redémarrage).

---

## Ce que tu ne fais pas

- Tu ne touches pas à `confirmerAchat()` : elle continue de refuser l'action en mode
  démonstration pour l'instant, ce n'est pas dans cette tâche.
- Tu ne changes rien au comportement quand le serveur répond normalement.
- Tu ne construis aucun interrupteur ni bouton "mode aperçu" : le comportement est
  automatique, déclenché par l'échec de connexion au serveur, comme aujourd'hui.
- Tu ne touches à aucun autre module que `2_collecteur`.
- Tu ne modifies pas `mockEchantillons()` ni les scénarios de démonstration existants.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport.
