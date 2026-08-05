# Backend Handoff — CEO Purchase Validation ("Validation achats")

Frontend feature is implemented with mock data. This document describes what was added on the Flutter side so the backend can wire matching endpoints.

> **READ THE MOCK DATA FIRST.** It is the contract. Every field name, every value shape, every status transition the backend must support is already encoded in the mock data files listed below. Do not invent a different schema — match it.

---

## 1. Feature in one paragraph

After a collector negotiates with a supplier and submits a purchase proposal, the CEO receives a notification and validates the proposal from a dedicated page. The CEO can **Confirmer l'achat** (sample moves to `achat_confirme`) or **Refuser** with a reason (sample moves to `refuse`). The CEO reaches the page either by tapping the notification or via the drawer entry "Validation achats".

---

## 2. The mock data — read these files

These two files are the source of truth for shape, field names and status transitions. Backend serializers / DRF responses must match these exactly.

### 2.1 Sample mock data
**File:** `lib/1_ceo/utilisateurs/models/mock_data_patch.dart`

- Three new entries (IDs `2026/0012`, `2026/0013`, `2026/0014`) with `statut: StatutCeo.enNegociation` and the full proposal payload already filled in:
  - `budgetNegociation` — agreed price string, e.g. `'8.20 TND/L'`
  - `camionReserve` — truck identifier, e.g. `'204 TN 5621'`
  - `num_citerne` — optional tank number, e.g. `'CT-9821'` (one entry has `null` to exercise the optional path)
  - `quantiteCibleT` — bulk quantity in tons as string
  - `dateLivraisonStock` and optional `dateLivraisonStockFin` — date or date range
  - `collecteurNom` — collector who submitted the proposal
- Two new exposed getters at the bottom of the file:
  - `mockPropositionsEnAttente` → samples where `statut == enNegociation && budgetNegociation != null` (i.e. proposal submitted, not yet decided)
  - `mockPropositionsDecidees` → samples where `statut == achatConfirme || statut == refuse`

**Schema reminder** — `lib/1_ceo/utilisateurs/models/echantillon_ceo_view.dart` already has every field the backend needs to return for a "proposition" sample. No new model.

### 2.2 Notification mock data
**File:** `lib/1_ceo/notifications/services/notification_ceo_service.dart`

Three new `NotificationCeo` entries appended at the end of `_mock`:

```dart
NotificationCeo(
  id: 'n-ceo-008',
  type: 'proposition_achat_attente',         // ← new notification type
  titre: "Proposition d'achat en attente",
  message: "CHEMLALI-K7 (40 T) : Ahmed Dridi propose 8.20 TND/L. À valider.",
  echantillonId: '2026/0012',                // ← FK to sample
  echantillonReference: 'CHEMLALI-K7',
  section: 'ACHATS_VALIDATION',              // ← new section value
  isRead: false,
  dateCreation: DateTime(2026, 5, 20, 14, 45),
),
```

The backend must emit notifications with **exactly** these `type` and `section` strings — the Flutter routing logic in `tableau_de_bord.dart::_handleNotifNavigation` checks them as-is.

---

## 3. Status state machine

`StatutCeo` is defined in `lib/core/models/enums.dart`. The flow this feature relies on:

```
selectionne          (sample registered & approved by CEO)
   ↓
enNegociation        (collector is negotiating with supplier — proposal NOT yet submitted)
   ↓                  ↑
enNegociation + budgetNegociation set
   (collector submitted proposal — appears in "À valider")
   ↓
   ├── achatConfirme  (CEO confirmed — appears in "Achats confirmés")
   └── refuse + raisonRefus  (CEO refused)
```

**Critical:** in the current mock, `enNegociation` is overloaded — it covers both "not yet negotiated" and "proposal submitted". The frontend distinguishes by checking `budgetNegociation != null`. Backend can either keep this overloading or introduce a sub-state — but the Flutter getter logic must keep working. If you add a sub-state, update `mockPropositionsEnAttente` accordingly.

---

## 4. Endpoints the backend needs to expose

All endpoints assume JWT auth (CEO role required). JSON keys must be `snake_case`; Flutter models already do `fromJson`/`toJson`.

### 4.1 List propositions awaiting validation
```
GET /api/echantillons/?statut=en_negociation&proposition_soumise=true
```
Returns samples currently shown by the `mockPropositionsEnAttente` getter.

### 4.2 List decided propositions
```
GET /api/echantillons/?statut__in=achat_confirme,refuse
```
Mirrors `mockPropositionsDecidees`.

### 4.3 Confirm a proposal
```
POST /api/echantillons/{id}/confirmer-achat/
```
Server-side: set `statut = achat_confirme`, `stock_arrive = false`, emit notification of type `achat_confirme` (already used elsewhere).

### 4.4 Refuse a proposal
```
POST /api/echantillons/{id}/refuser-achat/
Body: { "raison_refus": "<string>" }
```
Server-side: set `statut = refuse`, `raison_refus = <body>`.

### 4.5 Notifications
The existing notification list endpoint must include entries with the new `type` and `section`. When the collector submits a proposal via the existing `confirmer_achat_dialog.dart` flow (collector side), the backend should emit:

```json
{
  "type": "proposition_achat_attente",
  "section": "ACHATS_VALIDATION",
  "titre": "Proposition d'achat en attente",
  "message": "<REF> (<QTE> T) : <COLLECTEUR> propose <PRIX>. À valider.",
  "echantillon_id": "<sample id>",
  "echantillon_reference": "<bottle ref>",
  "is_read": false,
  "date_creation": "<iso8601>"
}
```

Target audience: all users with CEO/Directeur role.

---

## 5. Frontend files added (for reference, no backend impact)

These were created/modified on the Flutter side; the backend only cares that the API matches the mock:

- **New** `lib/1_ceo/validation_achats/validation_achats_ceo_page.dart`
- **New** `lib/1_ceo/validation_achats/widgets/proposition_section.dart`
- **New** `lib/1_ceo/validation_achats/widgets/decision_dialog.dart`
- **Modified** `lib/1_ceo/widgets/ceo_drawer.dart` — added required `onValidationAchats` callback
- **Modified** `lib/1_ceo/utilisateurs/models/mock_data_patch.dart` — 3 new samples + 2 getters
- **Modified** `lib/1_ceo/notifications/services/notification_ceo_service.dart` — 3 new notifications
- **Modified** `lib/1_ceo/notifications/widgets/notification_card.dart` — new icon/color for the new type
- **Modified** `lib/1_ceo/tableau_de_bord/tableau_de_bord.dart` — routes the notification to the new page
- **Modified** 6 other CEO pages — drawer callback wiring

---

## 6. Replacement strategy (when API is ready)

`mock_data_patch.dart` is intentionally a single file — its top comment says:

> When the real API is ready, delete this file and replace the imports with service calls — nothing else changes.

So the backend work ends when:

1. A real service (e.g. `EchantillonCeoService`) returns the same `EchantillonCeoView` shape from the endpoints above.
2. `NotificationCeoService` is rewired to call the real notifications endpoint.
3. The validation page's `_confirmer` / `_refuser` methods call the real `confirmer-achat` / `refuser-achat` endpoints instead of mutating the mock list.
4. `mock_data_patch.dart` is deleted, and all `mockPropositionsEnAttente` / `mockPropositionsDecidees` references switch to the new service.

No model changes, no widget changes, no drawer changes are needed on the Flutter side.
