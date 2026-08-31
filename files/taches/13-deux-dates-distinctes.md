# Tâche 13 — La date prévue ne doit plus être écrasée

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Décision du propriétaire, 31/08/2026 : **le champ ne doit pas être écrasé à l'arrivée.**

À faire **avant** la tâche 09, qui en dépend.

---

## Le problème

Un échantillon a deux dates différentes dans la vraie vie :

- la date que le **collecteur annonce** quand il enregistre l'échantillon ;
- la date où l'échantillon **arrive réellement** dans l'entreprise.

Côté serveur, il n'existe qu'**un seul champ** pour les deux : `date_arrivee_echantillon`
(`backend_new/echantillons/models.py:81`).

Et à la confirmation de réception, ce champ est **écrasé** :

```
backend_new/echantillons/views.py:199
    obj.date_arrivee_echantillon = timezone.now()
```

**Conséquence : la date annoncée par le collecteur est détruite.** Personne ne peut plus savoir
ce qui était prévu, ni si une livraison était en retard. Dans une période de forte activité,
c'est une information qui compte.

## Flutter attend déjà les deux dates

Le modèle du collecteur les a toutes les deux :

```
lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart:108   dateArriveeEchantillon    (prévue)
lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart:112   dateReceptionEchantillon  (réelle)
```

Et le service documente lui-même le manque, dans ses commentaires
(`echantillon_collecteur_service.dart:75-79`) :

```dart
// date_arrivee_echantillon (scheduled) is not in this endpoint — always null.
'date_arrivee_echantillon': null,
// date_arrivee_echantillon from API = actual physical reception date.
'date_reception_echantillon': api['date_arrivee_echantillon'],
```

Le contournement est donc déjà écrit dans le code. On le supprime en donnant au serveur le
champ qui lui manque.

---

## CONSIGNE

1. **Ajoute `date_reception_echantillon`** au modèle `Echantillon`
   (`DateTimeField(null=True, blank=True)`), et expose-le dans le sérialiseur.

   **Garde exactement ce nom.** Il correspond à `dateReceptionEchantillon` côté Flutter, qui
   existe déjà. C'est la règle 1 du `CLAUDE.md` : même chose, même nom.

2. **`views.py:199` écrit désormais dans le nouveau champ**, plus dans l'ancien :

   ```python
   obj.date_reception_echantillon = timezone.now()
   ```

   Pense à mettre à jour la liste `update_fields` de la ligne suivante.

3. **`date_arrivee_echantillon` retrouve son seul sens : la date prévue par le collecteur.**
   Plus rien ne l'écrase, jamais.

4. **Migration de données pour les échantillons déjà reçus.** Pour toutes les lignes où
   `recu_physiquement=True`, recopie `date_arrivee_echantillon` dans
   `date_reception_echantillon` : c'est la date réelle qui s'y trouve aujourd'hui.

   **Laisse `date_arrivee_echantillon` tel quel pour ces lignes.** La date prévue d'origine est
   perdue, on ne peut pas l'inventer ; garder la valeur actuelle vaut mieux que la vider.
   Signale ce choix dans ton rapport.

5. **Côté Flutter, supprime le contournement** dans
   `echantillon_collecteur_service.dart:75-79` : les deux dates viennent maintenant chacune de
   son propre champ. Retire aussi les deux commentaires devenus faux.

   Vérifie que `fromJson` (`echantillon_collecteur.dart:204-208`) lit bien les deux, au lieu de
   forcer `dateReceptionEchantillon: null`.

6. **Un test Django** qui prouve le comportement : un échantillon a une date prévue, on
   confirme sa réception, et **la date prévue est toujours là** après l'opération, à côté de la
   date réelle. C'est le seul vrai critère de réussite.

---

## Ce que tu ne fais pas

- Tu ne touches pas au filtre par dates. C'est la tâche 09, qui viendra après.
- Tu ne changes pas qui a le droit de confirmer la réception : cela reste le dégustateur et le
  chef dégustateur.

---

## Vérification

```bash
flutter analyze lib test
flutter test
cd backend_new
./venv/Scripts/python.exe manage.py test echantillons --keepdb
```

La suite `echantillons` seule prend environ 2 minutes et contient ton nouveau test. Lance-la
au minimum. La suite complète prend environ 800 secondes ; lance-la si tu en as le temps.

Référence : **50 problèmes, 0 erreur** ; **101 tests Flutter réussis** avec le seul échec connu
`test/widget_test.dart` ; suite `echantillons` : **25 tests, tous verts** avant ton ajout.

Si `flutter` refuse de s'exécuter chez toi, dis-le et ne revendique aucun chiffre. La suite
Django, elle, doit être lancée : c'est elle qui prouve que la migration passe.
