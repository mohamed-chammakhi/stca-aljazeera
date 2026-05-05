# backend_sprint_plan.md — Backend Development Order

> Read this before starting any backend work. It defines which module to implement first and the order of sprints.

---

## Important: Start with Collector, NOT Authentication

Authentication (JWT login) is implemented in **Sprint 2**, not Sprint 1.
Sprint 1 begins with the **Collector module** — supplier and sample CRUD APIs.
This is intentional: the Collector is the entry point of the entire data pipeline.

---

## Sprint Order

| Sprint | Focus | Key APIs |
|--------|-------|----------|
| **Sprint 1** | Collector — Sample & Supplier CRUD | `/api/fournisseurs/`, `/api/echantillons/` |
| **Sprint 2** | Collector — OCR + Map + Authentication | `/api/echantillons/ocr/`, `/api/collecteur/carte/`, `/api/auth/` |
| **Sprint 3** | Taster — Reception, Evaluation, Sessions | `/api/evaluations/`, `/api/sessions/` |
| **Sprint 4** | Lab Technician — Analysis + OCR | `/api/analyses/`, `/api/analyses/ocr/` |
| **Sprint 5** | CEO + Head Taster — Dashboards, Approval | `/api/ceo/dashboard/`, `/api/chef/dashboard/*` |
| **Sprint 6** | Notifications, Offline Sync, Messaging | `/api/notifications/`, `/api/messages/` |

---

## Sprint 1 — Collector Core (start here)

### Models to create
- `Fournisseur` — nom, gouvernorat, délégation, téléphone, adresse
- `Echantillon` — numero (auto: `YYYY/NNNN`), reference_bouteille, fournisseur FK, variété, gouvernorat, délégation, quantité, scellage, statut, recuPhysiquement, editHistory, dateArriveeEchantillonPrevue, dateArriveeEchantillonPrevueFin, prixFinal, camionLivraison, planificationLivraison

### Statut values (Echantillon — collector side)
`receptionne` → `recu_physiquement` → `en_negociation` → `achat_confirme`

### Edit history rule
Once `recuPhysiquement=true`, any field edit must store the old value in `editHistory` (list field on the model). All roles see old + new value.

### Endpoints to build
| Method | URL | Description |
|--------|-----|-------------|
| GET, POST | `/api/fournisseurs/` | List and create suppliers |
| GET, PUT, PATCH, DELETE | `/api/fournisseurs/{id}/` | Retrieve, update, delete supplier |
| GET, POST | `/api/echantillons/` | List (collector-scoped) and create samples |
| POST | `/api/echantillons/bulk/` | Create multiple samples in one request |
| GET, PUT, PATCH, DELETE | `/api/echantillons/{id}/` | Retrieve, update, delete sample |
| POST | `/api/echantillons/{id}/confirmer-achat/` | Confirm purchase (set prixFinal, camion, etc.) |

### Filtering & search on `/api/echantillons/`
- Filter by: `statut`, `date_enregistrement`, `gouvernorat`
- Search by: `numero`, `reference_bouteille`, `fournisseur__code`, `variete`
- Pagination: `{ "count": N, "results": [...] }`

### Permissions
- Collector can only see/edit/delete their own samples.
- DELETE is blocked if `statut != 'receptionne'`.

---

## Sprint 2 — OCR + Map + Auth

### OCR endpoint
`POST /api/echantillons/ocr/` — accepts `multipart/form-data` with an image field.
Uses Gemini Vision API. Returns JSON with extracted fields (reference_bouteille, variété, quantité, fournisseur).

### Map endpoint
`GET /api/collecteur/carte/` — returns visited delegations for the logged-in collector, annotated with sample count.

### Auth endpoints
| URL | Description |
|-----|-------------|
| `POST /api/auth/login/` | Returns access + refresh JWT tokens |
| `POST /api/auth/refresh/` | Refresh access token |
| `POST /api/auth/logout/` | Blacklist refresh token |
| `GET /api/users/me/` | Returns full user profile + role |

Custom JWT serializer must inject: `role`, `nom`, `prenom` into the token payload.

### Role-based permissions
Create permission classes: `IsCollecteur`, `IsDegustateur`, `IsLaboratoire`, `IsDirection`, `IsChefPanel`.
Apply them to all viewsets.

---

## Sprint 3 — Taster

### Models
- `EvaluationOrganoleptique` — echantillon FK, degustateur FK, COI attributes (fruitéVert, amertume, piquant, etc.), classification (extra_vierge / vierge / lampante), statut (en_attente / en_cours / soumis)

### Key endpoints
| URL | Description |
|-----|-------------|
| `POST /api/echantillons/{id}/confirmer-reception/` | Sets recuPhysiquement=true, dateReceptionEchantillon |
| `GET, POST /api/evaluations/` | List and create evaluations |
| `GET, PUT, PATCH /api/evaluations/{id}/` | Edit evaluation |
| `POST /api/evaluations/{id}/soumettre/` | Submit evaluation (status → soumis) |
| `GET, POST /api/sessions/` | List and create tasting sessions |
| `POST /api/sessions/{id}/approuver/` | Head Taster approves session |
| `POST /api/sessions/{id}/refuser/` | Head Taster refuses session |

---

## Sprint 4 — Lab Technician

### Models
- `AnalyseLabo` — echantillon FK, technicien FK, acidite, indice_peroxyde, k232, k270, delta_k, humidite, impuretes, statut (en_attente / en_cours / soumis), fichier_rapport (ImageField)

### Key endpoints
| URL | Description |
|-----|-------------|
| `GET /api/analyses/` | List analyses (lab-scoped: recuPhysiquement=true only) |
| `POST /api/analyses/ocr/` | AI extraction from paper report image |
| `POST /api/analyses/` | Create new analysis |
| `PUT, PATCH /api/analyses/{id}/` | Edit analysis |
| `POST /api/analyses/{id}/soumettre/` | Submit analysis |
| `GET /api/analyses/{id}/export/` | Export as PDF/CSV |

---

## Sprint 5 — CEO & Head Taster

### Key endpoints
| URL | Description |
|-----|-------------|
| `GET /api/ceo/dashboard/` | KPIs, pipeline, collector performance, purchase evolution |
| `POST /api/echantillons/{id}/approuver/` | CEO approves purchase |
| `POST /api/echantillons/{id}/refuser/` | CEO refuses purchase |
| `GET /api/users/` | List all users (CEO only) |
| `POST /api/users/` | Create new user account |
| `PATCH /api/users/{id}/` | Update role or activate/deactivate |
| `GET /api/chef/evaluations/` | All evaluations grouped by sample, with divergence flag |
| `GET /api/chef/dashboard/pipeline/` | Sample counts by state |
| `GET /api/chef/dashboard/delai/` | Average submission delay per taster |
| `GET /api/chef/dashboard/alignement/` | Divergence % per taster |
| `GET /api/chef/dashboard/classifications/` | Monthly classification bar chart data |
| `GET /api/chef/dashboard/urgentes/` | Samples with pending evaluations |
| `GET /api/chef/dashboard/presence/` | Chef attendance stats |

---

## Sprint 6 — Notifications, Offline, Messaging

### Notification model
Fields: id (UUID), destinataire FK, type, titre, message, echantillon FK (SET_NULL), section, is_read, date_creation.

Notification triggers (Django signals):
- `NOUVEL_ECHANTILLON` — sample created
- `ECHANTILLON_MODIFIE` — any field edited (not a status transition)
- `ECHANTILLON_SUPPRIME` — sample deleted (pre_delete signal)
- `ECHANTILLON_RECU` — recuPhysiquement flipped True
- `PREMIERE_EVALUATION` — first taster submits evaluation
- `TOUTES_EVALUATIONS` — all active tasters submitted
- `ANALYSE_SOUMISE` — lab submits analysis
- `ACHAT_CONFIRME` — statut_collecteur → achat_confirme

### Notification endpoints
| URL | Description |
|-----|-------------|
| `GET /api/notifications/` | List notifications for logged-in user |
| `PATCH /api/notifications/{id}/lire/` | Mark one as read |
| `POST /api/notifications/lire-tout/` | Mark all as read |
| `GET /api/notifications/non-lus/` | Unread count |

### Message model
Fields: id (UUID), expediteur FK, destinataire FK, contenu, horodatage, is_read.
Endpoints: `GET/POST /api/messages/`, `PATCH /api/messages/{id}/lire/`.
