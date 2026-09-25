# Al Jazeera STCA — Mise en service dans l'entreprise

Ce document s'adresse à la personne qui prendra en charge l'application dans
l'entreprise (responsable informatique ou prestataire). Il liste ce qui est
**indispensable** avant que les équipes l'utilisent au quotidien.

L'application se compose de deux parties :

- **l'application mobile** (Flutter), installée sur les téléphones des collecteurs,
  dégustateurs, chef dégustateur, laboratoire et direction ;
- **le serveur** (Django, dossier `backend_new/`), qui garde toutes les données et que les
  téléphones interrogent en permanence.

Sans serveur allumé et joignable, l'application mobile ne peut rien afficher.

---

## 1. Le serveur : allumé en permanence et joignable

Pendant le développement, le serveur tournait sur un ordinateur portable et les
téléphones y étaient reliés par câble USB. **Ce n'est pas utilisable en entreprise.**

Il faut :

- une machine **toujours allumée** (serveur de l'entreprise, ou hébergement en ligne) ;
- une **adresse fixe** pour la joindre (nom de domaine ou adresse IP fixe) ;
- de préférence un accès en **HTTPS** (connexion chiffrée), surtout si le serveur est
  joignable depuis Internet : les mots de passe et les données des échantillons y
  transitent.

L'adresse du serveur est inscrite dans l'application mobile **au moment de la
construction** de l'application :

```
flutter build apk --release --dart-define=API_BASE_URL=https://adresse-du-serveur
```

Sans ce réglage, l'application cherche le serveur sur `http://127.0.0.1:8000`, ce qui ne
marche qu'en développement avec un câble. **Chaque fois que l'adresse du serveur change, il
faut reconstruire et réinstaller l'application sur les téléphones.**

## 2. Le fichier de réglages du serveur (`backend_new/.env`)

Tous les réglages sensibles sont dans un fichier `backend_new/.env`, **jamais** dans le
code. Ce fichier n'est pas enregistré dans git et ne doit être partagé avec personne.
Un modèle existe : `backend_new/.env.example`.

À régler obligatoirement avant la mise en service :

| Réglage | Valeur en entreprise | Pourquoi |
|---|---|---|
| `SECRET_KEY` | une longue chaîne aléatoire, propre à l'entreprise | protège les connexions ; la valeur de développement ne doit **jamais** servir en production |
| `DEBUG` | `False` | en `True`, le serveur affiche des détails techniques en cas d'erreur |
| `ALLOWED_HOSTS` | l'adresse réelle du serveur (ex. `app.aljazeera-stca.tn`) | la valeur de développement accepte n'importe quelle adresse (`*`) |
| `DB_ENGINE`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT` | une base **PostgreSQL** avec un mot de passe propre à l'entreprise | la base SQLite de développement ne convient pas à plusieurs utilisateurs en même temps |
| Réglages email (section 3) | l'adresse d'envoi de l'entreprise | sans eux, « Mot de passe oublié » ne peut pas envoyer de code |

Pour créer une `SECRET_KEY` :

```
python -c "import secrets; print(secrets.token_urlsafe(50))"
```

Après avoir réglé la base de données, créer les tables :

```
python manage.py migrate
```

## 3. L'adresse email d'envoi — indispensable pour « Mot de passe oublié »

Quand un utilisateur oublie son mot de passe, l'application lui envoie un **code à
6 chiffres** par email :

- le code est envoyé **uniquement** à l'email enregistré sur son compte ;
- il est valable **15 minutes**, avec **4 essais** au maximum ; ensuite il faut en demander
  un nouveau.

Pour envoyer un email, le serveur a besoin d'une **boîte d'expédition**, c'est-à-dire
l'adresse « de la part de » qui apparaît chez le destinataire. Une seule adresse sert à
toute l'application. Tant qu'elle n'est pas configurée, **aucun email ne part** : le code
s'affiche seulement dans le journal du serveur.

### Avec un compte Gmail (le plus simple)

1. Créer un compte Gmail **réservé à l'application** (ex. `aljazeera.stca.app@gmail.com`).
   Ne pas utiliser la boîte personnelle d'un employé : si cette personne part, les emails
   s'arrêtent.
2. Sur ce compte, activer la **validation en deux étapes** (Compte Google → Sécurité).
3. Créer un **mot de passe d'application** (Compte Google → Sécurité → Mots de passe des
   applications). Google affiche un code de 16 lettres. Le copier.
4. L'inscrire dans `backend_new/.env` :

```
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=aljazeera.stca.app@gmail.com
EMAIL_HOST_PASSWORD=le-code-de-16-lettres
DEFAULT_FROM_EMAIL=Al Jazeera STCA <aljazeera.stca.app@gmail.com>
```

5. Redémarrer le serveur, puis tester « Mot de passe oublié » avec un vrai compte.

Si l'entreprise a sa propre messagerie (Outlook / Microsoft 365, hébergeur…), on utilise
ses réglages SMTP à la place de ceux de Gmail ; le principe est le même.

**Ne jamais** écrire ce mot de passe dans le code, dans un document partagé ou dans un
message.

## 4. Les comptes utilisateurs

- Chaque personne a **son propre compte** (un email, un mot de passe, un rôle :
  collecteur, dégustateur, chef dégustateur, laboratoire, direction). Ne pas partager un
  compte entre plusieurs personnes.
- L'**email de chaque compte doit être réel et lu par la personne** : c'est là qu'arrive
  le code « Mot de passe oublié ».
- Un collecteur ne voit que ses propres échantillons, ses propres fournisseurs et ses
  propres variétés dans les suggestions.
- Supprimer les comptes de test créés pendant le développement avant la mise en service.

## 5. Connexion et sécurité côté utilisateur

- Un utilisateur reste connecté tant qu'il utilise l'application. Après **8 heures sans
  l'utiliser**, il doit retaper son email et son mot de passe.
- Changement de mot de passe : depuis la page Profil de chaque rôle.

## 6. Sauvegardes

Les données (échantillons, évaluations, analyses, fournisseurs, comptes) sont toutes dans
la base du serveur. **Prévoir une sauvegarde automatique au moins quotidienne**, gardée
sur un autre support que le serveur lui-même, et vérifier de temps en temps qu'une
restauration fonctionne.

- Base PostgreSQL : `pg_dump` planifié (tâche planifiée Windows ou `cron`).
- Photos des échantillons : dossier `backend_new/media/`, à sauvegarder aussi.

## 7. Liste de contrôle avant la mise en service

- [ ] Serveur installé sur une machine toujours allumée, joignable par une adresse fixe
- [ ] HTTPS en place si le serveur est joignable depuis Internet
- [ ] `backend_new/.env` : `SECRET_KEY` nouvelle, `DEBUG=False`, `ALLOWED_HOSTS` réel
- [ ] Base PostgreSQL avec mot de passe propre à l'entreprise, `migrate` exécuté
- [ ] Adresse email d'envoi configurée et « Mot de passe oublié » testé avec un vrai compte
- [ ] Application mobile construite avec `API_BASE_URL` = adresse du serveur, puis
      installée sur les téléphones
- [ ] Un compte par personne, avec un email réel ; comptes de test supprimés
- [ ] Sauvegarde automatique de la base et du dossier `media/` en place et testée
