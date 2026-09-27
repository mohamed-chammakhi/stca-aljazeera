# Contrôle manuel — une ligne à la fois

Ce fichier n'est pas pour Claude. C'est pour toi, propriétaire du projet.
But : vérifier que l'app marche vraiment, sans te noyer. Une ligne = 5 minutes max.
Coche au fur et à mesure. Si une ligne échoue, note-le et passe à la suivante —
tu me montreras la liste des échecs à la fin, on les traite un par un, pas en panique.

**Comptes de test** (mot de passe pour tous : `Test@12345`) :

| Rôle | Email |
|------|-------|
| Collecteur | collecteur@stca.tn |
| Dégustateur | degustateur@stca.tn |
| Chef dégustateur | chef@stca.tn |
| Technicien labo | labo@stca.tn |
| Direction | direction@stca.tn |

**Installation** : ouvre deux fenêtres de navigateur différentes (une normale + une en
navigation privée, ou deux navigateurs différents) pour être connecté à deux comptes en
même temps. Fais l'action dans une fenêtre, regarde le résultat dans l'autre.

---

## Section 1 — Un échantillon existe pour tout le monde

- [ ] Connecté comme **collecteur**, enregistre un nouvel échantillon.
- [ ] Connecté comme **direction**, il apparaît dans sa liste + une notification arrive.
- [ ] Connecté comme **chef**, il apparaît aussi + notification.

## Section 2 — Réception physique

- [ ] Connecté comme **dégustateur** ou **chef**, coche "reçu" sur cet échantillon.
- [ ] Chez le **collecteur**, notification reçue.
- [ ] Chez la **direction**, notification reçue.
- [ ] Chez le **labo**, l'échantillon apparaît dans sa liste + notification.

## Section 3 — Annuler la réception

- [ ] Décoche "reçu" sur le même échantillon.
- [ ] Collecteur + direction notifiés.
- [ ] Si le labo avait commencé une analyse dessus : il est notifié aussi. Sinon : pas de notification (normal, c'est voulu).

## Section 4 — Négociation

- [ ] Connecté comme **direction**, propose une négociation sur un échantillon.
- [ ] Collecteur notifié, clique sur la notification → ça ouvre bien l'échantillon.

## Section 5 — Messagerie texte

- [ ] Collecteur envoie un message à la direction. Reçu côté direction, badge non-lu visible.
- [ ] Ouvre la conversation côté direction → badge disparaît.
- [ ] Chef envoie un message à un **autre chef** (s'il y en a un deuxième compte de test).
- [ ] Vérifie que le **dégustateur simple** et le **labo** n'ont AUCUN bouton "Messagerie".

## Section 6 — Messagerie photo et référence

- [ ] Envoie un message avec une photo (galerie). Elle s'affiche bien.
- [ ] Envoie un message avec une référence d'échantillon attachée. Clique dessus depuis l'autre compte → ouvre la bonne page.

## Section 7 — Modifier / supprimer un message

- [ ] Modifie un message que tu as envoyé toi-même. "modifié" apparaît.
- [ ] Supprime un message que tu as envoyé. Il disparaît.
- [ ] Essaie de faire pareil sur un message **reçu** (pas le tien) → aucune option ne doit être proposée.

## Section 8 — Achat confirmé

- [ ] Direction confirme un achat. Collecteur + chef notifiés.

---

## À la fin

Compte tes ✅ et tes ❌. Donne-moi juste la liste des ❌ (numéro de section + ce qui
s'est mal passé) — pas besoin de tout réexpliquer, une phrase par échec suffit. On les
corrige un par un, jamais tous en même temps.
