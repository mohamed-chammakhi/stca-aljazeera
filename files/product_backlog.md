# Product Backlog & Sprint Planning

> Structured around the actor-inheritance hierarchy from the use case diagrams
> (User ← Administrator / Panel Member / Collector ; Panel Member ← Panel Evaluation Supervisor).
> CRUD operations on the same entity are bundled into a single sub-story.
> Auto-triggered notifications appear as fan-out arrows inside the sequence diagrams of the features that fire them — they are not a standalone backlog feature.

## Product Backlog

| ID | Feature | User Story | Priority | Estimation |
|----|---------|------------|----------|------------|
| 1 | Authentication | 1- As a User, I can authenticate with my email and password to access my role-specific interface. | High | 4 Days |
| 2 | Profile management | 2- As a User, I can manage my profile (update personal information, password, and profile picture). | Medium | 3 Days |
| 3 | User management | 3- As an Administrator, I can manage users (add, activate/deactivate, delete). | High | 5 Days |
| 4 | Sample management | 4.1- As a Collector / Panel Member, I can manage samples (add, edit, delete) according to workflow restrictions and edit-history rules.<br>4.2- As a Collector, I can extract bottle label information from a handwritten photo using AI-assisted OCR.<br>4.3- As a Panel Member, I can confirm the physical reception of a sample at the company.<br>4.4- As a Collector / Administrator, I can consult the geographic coverage of samples on a map.<br>4.5- As a Collector, I can confirm a purchase by submitting negotiation and stock delivery information after sample approval. | High | 14 Days |
| 5 | Sample evaluation | 5- As a Panel Member, I can fill, save as draft, and submit organoleptic evaluation forms for samples assigned to me. | High | 6 Days |
| 6 | Tasting session management | 6.1- As a Panel Member, I can manage tasting sessions (create, edit, delete) and confirm my attendance.<br>6.2- As a Panel Evaluation Supervisor, I can approve or refuse tasting sessions proposed by panel members. | High | 6 Days |
| 7 | Cross-panel supervision | 7- As a Panel Evaluation Supervisor, I can compare evaluations side-by-side and use AI-assisted divergence detection to identify deviating evaluations. | High | 7 Days |
| 8 | Laboratory analysis management | 8.1- As a Laboratory Technician, I can manage laboratory analysis reports (add manually, edit, delete).<br>8.2- As a Laboratory Technician, I can scan paper laboratory reports so that AI-assisted OCR automatically extracts analysis values. | High | 8 Days |
| 9 | Direction monitoring & decisions | 9.1- As an Administrator, I can consult global dashboards summarizing the sample pipeline, organoleptic evaluations, laboratory results, and confirmed purchases.<br>9.2- As an Administrator, I can approve or refuse a sample at any decision stage and mark a sample as urgent to prioritize its evaluation by panel members.<br>9.3- As an Administrator, I can approve confirmed purchases and define the desired stock delivery date. | High | 7 Days |

**Total estimation: 60 days across 9 features.**

---

## Sprint Planning

| Sprint | Focus | IDs | Features | Duration |
|--------|-------|-----|----------|----------|
| Sprint 1 | Platform foundation & sample pipeline — every role can log in, profiles are managed, the Administrator provisions users, and the sample enters the system from the field through OCR-assisted acquisition, physical reception, geographic mapping, and collector-side purchase confirmation. | 1, 2, 3, 4 | Authentication, Profile management, User management, Sample management | 26 Days |
| Sprint 2 | Panel evaluation workflow — sensory analysis through tasting sessions and AI-assisted divergence detection. | 5, 6, 7 | Sample evaluation, Tasting session management, Cross-panel supervision | 19 Days |
| Sprint 3 | Laboratory analysis & direction decisions — closing the loop with OCR-scanned lab reports and final purchase decisions. | 8, 9 | Laboratory analysis management, Direction monitoring & decisions | 15 Days |
| **Total** | Full product backlog | 1 → 9 | All features | **60 Days** |

---

## Narrative arc (for the jury defense)

- **Sprint 1** delivers the platform foundation and the entire sample-acquisition pipeline. Anyone can log in, the Administrator provisions accounts, and then the sample enters the system: the Collector registers it on-site with AI-assisted OCR on the handwritten bottle label, the Panel Member confirms its physical arrival at the company, the geographic coverage map contextualizes where samples come from, and once approved, the Collector closes the negotiation with stock delivery information.
- **Sprint 2** runs the sensory side: panel members evaluate received samples through tasting sessions they organize themselves, and the Panel Evaluation Supervisor catches outliers using AI-assisted divergence detection.
- **Sprint 3** closes the loop: the Laboratory Technician scans paper laboratory reports through a second OCR pipeline, and the Administrator consults all consolidated evidence (organoleptic + laboratory + purchase status) to take the final purchase decision, mark urgent samples, and define stock delivery dates.

---

## Mapping to signature sequence diagrams (jury-priority)

Each business-critical user story maps to one diagram the jury should see:

| Diagram | User Story | Actor | Archetype |
|---------|-----------|-------|-----------|
| Authentication | 1 | User | Reference auth template |
| Add sample with OCR | 4.2 | Collector | Multi-step wizard with Loop fragment |
| Confirm physical reception | 4.3 | Panel Member | State-transition with edit-history rule |
| Confirm purchase | 4.5 | Collector | Negotiation + stock delivery submission |
| Submit organoleptic evaluation | 5 | Panel Member | Lock-after-submit alt branch |
| Approve tasting session | 6.2 | Panel Evaluation Supervisor | Approval flow |
| Detect panel divergence | 7 | Panel Evaluation Supervisor | AI-assisted alt fragment |
| Scan laboratory report | 8.2 | Laboratory Technician | OCR archetype (second instance) |
| Decide sample purchase | 9.2 + 9.3 | Administrator | Approve/refuse with urgent-flag and stock-delivery trigger |

CRUD-style sub-stories (3, 4.1, 6.1, 8.1) reuse the canonical management diagrams (consult/edit/delete) and are drawn once each. Every workflow event that triggers a notification (add sample, mark urgent, confirm reception, submit evaluation, scan lab report, approve purchase) shows the notification fan-out as a final arrow inside its own sequence diagram — no separate "notifications" diagram is needed.
