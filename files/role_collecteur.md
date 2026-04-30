# role_collecteur.md — Collector (`2_collecteur/`)

External participant who collects samples from across Tunisia.

---

## Pages

- **Échantillons** — own registered samples, filterable by date. Shows current state per sample (see states below).
- **Ajouter un échantillon** (FAB) — form: supplier name, origin, reference (bottle ref = sample ref — each bottle is its own `Echantillon`), variety, quantity, number of bottles, optional expected arrival date. Collector can photo the handwritten bottle label → Gemini Vision OCR auto-fills fields → collector reviews and corrects before saving. Multiple bottles → each bottle gets its own reference and is saved as a separate record.
- **Carte** — map of Tunisian delegations. Visited delegations highlighted, unvisited not. Helps plan future routes.
- **Chat** — messaging with Direction (CEO). Planned; implement if time allows.
- **Dashboard** — collector-level KPIs and activity summary.
- **Profile** — edit name, phone, email, password, photo.

**Cannot see taster evaluations.**

---

## Sample States (collector view)

| State | Edit | Delete | Notes |
|-------|------|--------|-------|
| `Réceptionné` | All fields | ✅ Yes | Not yet physically at company |
| `Réceptionné (reçu physiquement)` | Limited fields only | ❌ No | Taster confirmed physical arrival. **Edits are tracked** — previous value visible to all actors |
| `En négociation` | — | ❌ No | CEO approved for purchase. CEO's `budgetNegociation` + `dateLivraisonStockSouhaitee` shown in collapsible section. Collector can confirm purchase. |
| `Achat confirmé` | `planificationLivraison` only | ❌ No | Collector confirmed purchase with `prixFinal`, `camionLivraison`, `planificationLivraison`. |

---

## State Transitions (collector-relevant)

| Transition | Who | Fields set |
|---|---|---|
| Register → Réceptionné | Collector or Taster | All sample fields, optionally `dateArriveeEchantillon` |
| Réceptionné → recuPhysiquement | Taster | `recuPhysiquement = true`, `dateReceptionEchantillon` |
| Réceptionné → En négociation | CEO | `budgetNegociation`, `dateLivraisonStockSouhaitee` |
| En négociation → Achat confirmé | Collector | `prixFinal`, `camionLivraison`, `planificationLivraison` |
| Achat confirmé → Stock reçu | CEO or Collector | `dateArriveeStock` |

---

## Edit History Rule

Once `recuPhysiquement = true`, any field edit must store the previous value in `editHistory` (list on the model). All actors (CEO, taster, lab) see old value + new value, clearly labelled — like the "edited" indicator in messaging apps.

---

## Offline Mode (critical — do not break)

- All writes queued locally (using `sqflite` or `hive`) when offline.
- Sync runs when connection is restored, calling the same service methods that will hit the Django API.
- Sync logic lives in `CollecteurSyncService` — never in widgets.
- Queue entries: `synced: false` flag + local-only UUID. Server assigns canonical UUID on sync; local record must be updated.
