# role_laboratoire.md — Lab Technician (`4_laboratoire/`)

3 pages: sample list, notifications, and profile. No dashboard.

---

## Pages

- **Échantillons à analyser** — samples that are physically present at the company (`recuPhysiquement = true`). Filterable by state: `En attente` / `En cours` / `Soumis`. Lab technician does NOT register samples. AppBar has a bell icon (direct shortcut to the notifications page).

- **Notifications** — urgent analysis requests sent by tasters (regular or chef). Each notification carries the sample reference, sender name, and a relative timestamp. Grouped by date: `Aujourd'hui` / `Hier` / `Plus tôt`. Filterable by `Tous` / `Non lus`. Supports mark-as-read per item and "Tout marquer lu". Red left accent bar and bold title for unread items. Notification type: `ANALYSE_URGENTE`.

- **Profil** — edit personal info. No dashboard.

---

## Lab Analysis Flow

Two entry methods:

1. **Photo upload** — take or upload a photo of the physical paper analysis report. AI automatically detects and extracts table values to fill the form fields. Technician reviews and confirms. The paper photo is preserved and stored alongside the digital form.

2. **Manual entry** — fill the analysis form directly without a photo.

Export analysis results is supported.

---

## Sample States (lab view)

| State | Meaning |
|-------|---------|
| `En attente` | Analysis not yet started |
| `En cours` | Analysis started but not submitted |
| `Soumis` | Analysis submitted — read-only |

---

## What Lab Sees

Only samples with `recuPhysiquement = true`. Does not see taster evaluations or collector negotiation details.

---

## Drawer Navigation

| Item | Destination |
|------|-------------|
| Échantillons à analyser | `EchantillonsLaboPage` |
| Notifications | `NotificationsLaboPage` |
| Mon Profil | `ProfilLaboPage` |
| Déconnexion | `LoginPage` |

---

## Flutter Files

- `lib/4_laboratoire/echantillons_labo/echantillons_labo_page.dart` — main sample list, AppBar with bell icon
- `lib/4_laboratoire/echantillons_labo/models/echantillon_labo.dart`
- `lib/4_laboratoire/echantillons_labo/services/labo_service.dart`
- `lib/4_laboratoire/echantillons_labo/widgets/echantillon_labo_card.dart`
- `lib/4_laboratoire/notifications/notifications_labo_page.dart` — grouped notification list, filter chips, mark-as-read
- `lib/4_laboratoire/notifications/models/notification_labo.dart`
- `lib/4_laboratoire/notifications/services/notification_labo_service.dart`
- `lib/4_laboratoire/labo_drawer.dart` — drawer with Échantillons, Notifications, Profil, Déconnexion
- `lib/4_laboratoire/profil_labo_page.dart`
- `lib/4_laboratoire/widgets/labo_nav_mixin.dart`
