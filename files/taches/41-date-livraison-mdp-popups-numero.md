# Tâche 41 — Filtre « Livraison échantillon », fenêtres du mot de passe, numéro après 9999

Lis `files/taches/PROTOCOLE.md` (dont « Même correction pour tous les rôles »), puis
`CLAUDE.md`. Flutter + backend. Aucune migration.

## A — Filtre « Livraison échantillon » : la date annoncée par le collecteur, quel que soit le statut

Règle de la propriétaire : quand on cherche par **Livraison échantillon**, un échantillon
doit apparaître à la date que le collecteur a **annoncée** dans l'application (« je le livre
tel jour »), même si son statut a changé depuis (ex. achat conclu). Ce n'est **pas** la date
de réception physique.

Constaté par Claude, à vérifier et corriger :
- le collecteur filtre sur `e.dateArriveeEchantillon` (`mes_echantillons_page.dart:~203`) ;
  la direction sur `e.dateArriveeEchantillon ?? e.dateLivraisonPrevue` ;
  `lib/core/utils/date_filter_utils.dart` utilise `dateArriveeEchantillon` ou
  `dateLivraisonEchantillon` selon le modèle ;
- côté serveur, `date_arrivee_echantillon` sert à la fois de date **annoncée** (planifiée
  par `_onScheduleArrivee` du collecteur) et, dans `backend_new/chef/views.py:96`, est
  renvoyée comme `date_reception_physique`. Il faut savoir si quelque chose **écrase**
  `date_arrivee_echantillon` au changement de statut ou à la réception (grep dans
  `echantillons/`, `analyses/`, `notifications/`, `ceo/`, `chef/`, `degustateur/`,
  les `signals.py` et les vues d'actions de statut). Cherche aussi le cas « période »
  (date de début / fin annoncée) : quel champ la stocke ?

À faire :
1. Écris dans ton rapport, en 5 lignes max, quel champ contient la date annoncée et ce qui
   le modifie.
2. Si un changement de statut ou la réception efface / remplace la date annoncée, corrige-le
   pour qu'elle soit conservée (sans migration ; si une migration est indispensable,
   `## QUESTION`).
3. Dans **tous les écrans** qui proposent le filtre `DateFilterType.livraisonEchantillon`
   (collecteur, dégustateur, chef, direction, labo : grep), le filtre utilise la date
   annoncée (date exacte, ou début de période si seule une période a été donnée), jamais
   la date de réception physique.
4. `chef/views.py:96` : ne renvoie plus la date annoncée sous le nom
   `date_reception_physique` ; renvoie la vraie date de réception (le champ utilisé par
   `DateFilterType.receptionPhysique` côté Flutter). Vérifie que l'écran qui lit cette
   clé affiche toujours la bonne chose.
5. Test : un échantillon au statut achat conclu, avec une date annoncée au 10/10 et une
   réception au 12/10 → le filtre « Livraison échantillon » au 10/10 le trouve, au 12/10 non.

## B — Changement de mot de passe : une fenêtre pour chaque erreur

`lib/core/widgets/change_password_dialog.dart` (utilisé par les 5 profils). Aujourd'hui les
erreurs s'affichent en texte au-dessus des champs. La propriétaire veut **une fenêtre**
(`AlertDialog`, bouton `OK`) pour chacun de ces cas, avec un titre et un message clairs :
- l'ancien mot de passe est incorrect (réponse du serveur) → `Ancien mot de passe incorrect`
- le nouveau mot de passe ne respecte pas les règles → `Mot de passe trop faible`, avec la
  liste des règles non respectées (reprends les règles déjà vérifiées dans le code / par le
  serveur, n'en invente pas)
- la confirmation ne correspond pas → `Les mots de passe ne correspondent pas`
- tout autre refus du serveur → son message.
Retire l'ancien texte d'erreur au-dessus des champs (pour ne pas afficher deux fois).
Les champs gardent ce qui a été tapé. Test widget : un test par fenêtre.

## C — Numéro d'échantillon après 9999

`backend_new/echantillons/models.py`, `save()` : le numéro est `ANNÉE/0001`, et il
recommence à 1 chaque année. Le prochain numéro est pris avec
`order_by('-numero').first()` : c'est un tri **alphabétique**. Après `2026/9999`, le
numéro `2026/10000` est rangé **avant** `2026/9999` (« 1 » < « 9 »), donc le calcul
redonne `2026/10000` → doublon → l'enregistrement plante.

Décision : on garde `ANNÉE/numéro` avec au moins 4 chiffres ; après 9999 le numéro
continue simplement : `2026/10000`, `2026/10001`… (pas de lettres).
- Calcule le prochain numéro sur la **valeur numérique** maximale de l'année (pas sur le
  tri texte). Protège contre deux enregistrements simultanés (réessaie en cas
  d'`IntegrityError`, comme `_create_supplier_with_generated_code`).
- `numero` est un `CharField(max_length=20)` : assez long, pas de migration.
- Côté Flutter, vérifie que rien ne suppose 4 chiffres (tri des listes par numéro, découpe
  de la chaîne, largeur fixe) ; si une liste trie par numéro en texte, trie par
  (année, numéro) en nombres.
- Test backend : avec un échantillon `2026/9999` existant, le suivant est `2026/10000`,
  puis `2026/10001`.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera `flutter analyze lib
test`, `flutter test` et les tests Django.

## RAPPORT
