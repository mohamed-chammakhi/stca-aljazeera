# Agile / Scrum — Al Jazeera STCA Project

---

## 1. Overview

The development of the Al Jazeera STCA application follows the **Scrum** agile framework.
The project is organized into **6 sprints of 2 weeks each**, for a total development cycle of
**12 weeks**. The team adopts the following Scrum roles:

| Scrum Role | Responsible |
|---|---|
| Product Owner | Project supervisor / company stakeholder |
| Scrum Master | Team lead |
| Development Team | Frontend (Flutter) + Backend (Django) developers |

Each sprint follows the standard Scrum ceremonies: Sprint Planning, Daily Standups,
Sprint Review, and Sprint Retrospective.

The system serves **5 distinct roles**:

| Role | Module |
|---|---|
| Direction / CEO | 1_ceo/ |
| Collecteur (Sample Collector) | 2_collecteur/ |
| Dégustateur (Taster) | 3_degustateur/ |
| Technicien Labo (Lab Technician) | 4_laboratoire/ |
| Chef de Panel (Head Taster) | 5_chef_degustateur/ |

---

## 2. Product Backlog

Each user story follows the format: "As a [role], I want to [action] so that [benefit]."

Priority scale (MoSCoW):
  M = Must Have
  S = Should Have
  C = Could Have

Story points scale (Fibonacci): 1 · 2 · 3 · 5 · 8 · 13

---

### EPIC 1 — Authentication & User Management

| ID     | User Story                                                                                                                  | Priority | Points | Sprint |
|--------|-----------------------------------------------------------------------------------------------------------------------------|----------|--------|--------|
| US-001 | As any user, I want to log in with my email and password so that I can access my role-specific dashboard.                   | M        | 3      | 1      |
| US-002 | As any user, I want to log out so that my session remains secure.                                                           | M        | 1      | 1      |
| US-003 | As any user, I want to view and edit my profile (name, email, phone, photo) so that my information stays up to date.        | S        | 2      | 1      |
| US-004 | As any user, I want to change my password so that my account remains secure.                                                | S        | 2      | 1      |
| US-005 | As a CEO, I want to create user accounts, assign roles, and activate/deactivate accounts so that I control system access.   | S        | 5      | 5      |

---

### EPIC 2 — Sample Collection (Collector)

| ID     | User Story                                                                                                                                                                              | Priority | Points | Sprint |
|--------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|--------|--------|
| US-006 | As a Collector, I want to register a new supplier so that I can associate samples with their source.                                                                                    | M        | 3      | 2      |
| US-007 | As a Collector, I want to register one or multiple new samples at once so that the company can track them.                                                                              | M        | 5      | 2      |
| US-008 | As a Collector, I want to photograph a handwritten bottle label and have Gemini Vision OCR auto-fill the sample form so that data entry is faster and less error-prone.                 | M        | 8      | 2      |
| US-009 | As a Collector, I want to view my samples with search and status filters so that I can monitor their progress.                                                                          | M        | 5      | 2      |
| US-010 | As a Collector, I want to edit a sample's details so that I can correct mistakes or update information (with edit history tracked once the sample is physically received).              | M        | 3      | 2      |
| US-011 | As a Collector, I want to delete a sample so that invalid entries can be removed.                                                                                                       | M        | 2      | 2      |
| US-012 | As a Collector, I want to schedule the sample arrival date so that the taster knows when to expect it.                                                                                  | M        | 3      | 2      |
| US-013 | As a Collector, I want to record stock delivery details (final price, truck, sealing info) so that logistics are tracked after purchase confirmation.                                   | M        | 5      | 2      |
| US-014 | As a Collector, I want to view my samples on a geographic map of Tunisian delegations so that I can see visited vs. unvisited zones and plan future routes.                             | S        | 8      | 2      |
| US-015 | As a Collector, I want to view a dashboard with my personal KPIs and activity summary so that I can track my own performance.                                                           | S        | 5      | 2      |
| US-016 | As a Collector, I want to chat with the CEO so that I can communicate directly without leaving the app.                                                                                 | C        | 8      | 6      |
| US-017 | As a Collector, I want to register samples while offline and have them sync automatically when connectivity is restored so that I can work in areas without internet.                  | C        | 13     | 6      |

---

### EPIC 3 — Sample Tasting (Taster / Dégustateur)

| ID     | User Story                                                                                                                                        | Priority | Points | Sprint |
|--------|---------------------------------------------------------------------------------------------------------------------------------------------------|----------|--------|--------|
| US-018 | As a Taster, I want to view all samples in the system with search and date filters so that I have full visibility.                                | M        | 3      | 3      |
| US-019 | As a Taster, I want to confirm the physical reception of a sample so that the lab analysis is unlocked and the pipeline advances.                 | M        | 3      | 3      |
| US-020 | As a Taster, I want to add or edit a sample (with edit history tracked after physical reception) so that the sample list is always accurate.      | M        | 3      | 3      |
| US-021 | As a Taster, I want to run a sensory evaluation using the COI organoleptic form so that sample quality is formally assessed.                      | M        | 8      | 3      |
| US-022 | As a Taster, I want to view all my past submitted evaluations so that I can review historical assessments.                                        | M        | 3      | 3      |
| US-023 | As a Taster, I want to create and manage tasting sessions (date, time, location, participants) so that panel evaluations are organized.           | S        | 5      | 3      |
| US-024 | As a Taster, I want to view lab analysis results for samples (read-only) so that I have a complete quality picture.                               | S        | 3      | 3      |
| US-025 | As a Taster, I want to view the list of panel members so that I know who participates in evaluations.                                             | S        | 2      | 3      |
| US-026 | As a Taster, I want to view a personal dashboard showing urgent evaluations, pipeline status, submission delays, and recent activity so that I can prioritize my work. | S | 5 | 3 |

---

### EPIC 4 — Laboratory Analysis (Lab Technician)

| ID     | User Story                                                                                                                                                              | Priority | Points | Sprint |
|--------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|--------|--------|
| US-027 | As a Lab Technician, I want to view all samples assigned to me for analysis (only physically received samples) so that I know my workload.                              | M        | 3      | 4      |
| US-028 | As a Lab Technician, I want to photograph a paper analysis report and have AI automatically extract the parameter values into the form so that data entry is faster.    | M        | 8      | 4      |
| US-029 | As a Lab Technician, I want to manually enter chemical analysis parameters for a sample so that quality data is recorded even without a paper report.                   | M        | 5      | 4      |
| US-030 | As a Lab Technician, I want to submit a completed analysis so that the CEO and Taster can review the results.                                                           | M        | 3      | 4      |
| US-031 | As a Lab Technician, I want to edit or delete a submitted analysis so that errors can be corrected before approval.                                                     | S        | 3      | 4      |
| US-032 | As a Lab Technician, I want to export analysis results so that I can share them outside the app.                                                                        | S        | 3      | 4      |

---

### EPIC 5 — Executive Oversight (CEO / Direction)

| ID     | User Story                                                                                                                                                                                              | Priority | Points | Sprint |
|--------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|--------|--------|
| US-033 | As a CEO, I want to view an executive dashboard with KPIs, pipeline status, and performance charts so that I can monitor overall operations at a glance.                                                | M        | 8      | 5      |
| US-034 | As a CEO, I want to view all samples from all collectors grouped by collector, with search and date filters so that I have full visibility across the company.                                          | M        | 5      | 5      |
| US-035 | As a CEO, I want to review sensory evaluation results submitted by each taster, side by side, so that I can make informed purchase decisions.                                                           | M        | 5      | 5      |
| US-036 | As a CEO, I want to approve a sample for purchase (setting a budget and desired delivery date) or reject it so that the purchase process either advances or stops.                                      | M        | 3      | 5      |
| US-037 | As a CEO, I want to review lab analysis reports linked to each sample so that I have chemical quality data to support my decisions.                                                                     | M        | 3      | 5      |
| US-038 | As a CEO, I want to track confirmed purchases in two states (stock in transit / stock received) with dates so that logistics are fully managed.                                                         | M        | 5      | 5      |
| US-039 | As a CEO, I want to view a geographic map of Tunisian delegations showing which zones each collector has visited so that I can evaluate field coverage.                                                  | S        | 5      | 5      |
| US-040 | As a CEO, I want to manage system users (view, create, delete, activate/deactivate accounts) so that access control is maintained.                                                                      | S        | 5      | 5      |

---

### EPIC 6 — Head Taster / Chef de Panel

| ID     | User Story                                                                                                                                                                                                      | Priority | Points | Sprint |
|--------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|--------|--------|
| US-041 | As a Chef de Panel, I want to view a dashboard with pipeline counts, urgent evaluations, pending sessions, per-member delays, panel alignment, classification history, and my attendance so that I can manage the panel's performance. | M | 8 | 5 |
| US-042 | As a Chef de Panel, I want to manage samples (add, edit with history, delete before negotiation, toggle physical reception) so that the sample list stays accurate.                                              | M        | 3      | 5      |
| US-043 | As a Chef de Panel, I want to submit my own individual sensory evaluation (COI form) so that my assessment is included alongside other tasters'.                                                                 | M        | 5      | 5      |
| US-044 | As a Chef de Panel, I want to view all tasters' submitted evaluations side by side per sample, with automatic divergence detection (deviation > 1.5 from panel average), so that I can identify inconsistencies. | M        | 8      | 5      |
| US-045 | As a Chef de Panel, I want full CRUD on tasting sessions and the ability to approve or refuse sessions proposed by panel members so that sessions are properly validated.                                        | M        | 5      | 5      |
| US-046 | As a Chef de Panel, I want to view lab analyses (read-only) and the list of panel members so that I have a complete overview of operations.                                                                     | S        | 3      | 5      |

---

### EPIC 7 — Notifications (All Roles)

| ID     | User Story                                                                                                                                                | Priority | Points | Sprint |
|--------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|----------|--------|--------|
| US-047 | As any user, I want to receive role-specific notifications for relevant events (new sample, evaluation submitted, analysis submitted, purchase confirmed, etc.) so that I am informed without having to check manually. | S | 5 | 6 |
| US-048 | As any user, I want to mark individual notifications or all notifications as read so that I can track what I have already seen.                            | S        | 2      | 6      |
| US-049 | As any user, I want to tap a notification and be navigated directly to the relevant screen so that I can act on it immediately.                            | S        | 3      | 6      |

---

### EPIC 8 — Backend / Technical Infrastructure

| ID     | User Story                                                                                                                                                                        | Priority | Points | Sprint |
|--------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|--------|--------|
| US-050 | As a developer, I want the Django backend set up with PostgreSQL, JWT authentication, and role-based permissions so that the app has a secure, persistent data layer.              | M        | 5      | 1      |
| US-051 | As a developer, I want REST APIs for supplier and sample CRUD so that the Flutter app can read and write data server-side.                                                         | M        | 8      | 2      |
| US-052 | As a developer, I want REST APIs for sensory evaluations and tasting sessions so that quality assessment data is persisted on the server.                                          | M        | 8      | 3      |
| US-053 | As a developer, I want REST APIs for lab analyses so that chemical results are persisted and accessible to all roles.                                                              | M        | 5      | 4      |
| US-054 | As a developer, I want REST APIs for the CEO and Chef de Panel dashboards so that KPI data is computed and served from the backend.                                                | M        | 8      | 5      |
| US-055 | As a developer, I want a notifications API (list, mark-read, unread-count) driven by Django signals so that all roles receive live updates without polling.                        | S        | 5      | 6      |

---

## 3. Sprint Planning

---

### Sprint 1 — Authentication & Backend Foundation
Duration: 2 weeks
Goal: All 5 roles can log in, land on their respective dashboard, and the Django backend with JWT is operational.

| ID     | User Story                                              | Points |
|--------|---------------------------------------------------------|--------|
| US-001 | Login with email and password (all roles)               | 3      |
| US-002 | Logout (all roles)                                      | 1      |
| US-003 | View and edit user profile                              | 2      |
| US-004 | Change password                                         | 2      |
| US-050 | Django backend setup (PostgreSQL + JWT API)             | 5      |
| Total  |                                                         | 13     |

---

### Sprint 2 — Collector Features
Duration: 2 weeks
Goal: A Collector can register suppliers and samples (including via OCR), manage them, view them on a map, and see their dashboard.

| ID     | User Story                                                         | Points |
|--------|--------------------------------------------------------------------|--------|
| US-006 | Register a new supplier                                            | 3      |
| US-007 | Register one or multiple samples                                   | 5      |
| US-008 | Photo bottle label → Gemini Vision OCR auto-fills sample form      | 8      |
| US-009 | View samples with search and status filters                        | 5      |
| US-010 | Edit sample details (with edit history after physical reception)   | 3      |
| US-011 | Delete a sample                                                    | 2      |
| US-012 | Schedule sample arrival date                                       | 3      |
| US-013 | Record stock delivery details                                      | 5      |
| US-014 | View samples on geographic map by delegation                       | 8      |
| US-015 | Collector dashboard with KPIs                                      | 5      |
| US-051 | Supplier & sample CRUD REST APIs                                   | 8      |
| Total  |                                                                    | 55     |

---

### Sprint 3 — Taster Features
Duration: 2 weeks
Goal: A Taster can receive samples physically, run COI sensory evaluations, manage tasting sessions, and view their dashboard.

| ID     | User Story                                                               | Points |
|--------|--------------------------------------------------------------------------|--------|
| US-018 | View all samples with filters                                            | 3      |
| US-019 | Confirm physical reception of a sample                                   | 3      |
| US-020 | Add / edit sample (with edit history)                                    | 3      |
| US-021 | Run a COI sensory evaluation                                             | 8      |
| US-022 | View past submitted evaluations                                          | 3      |
| US-023 | Create and manage tasting sessions                                       | 5      |
| US-024 | View lab analyses (read-only)                                            | 3      |
| US-025 | View panel members                                                       | 2      |
| US-026 | Taster dashboard (urgentes, pipeline, delays, activity)                  | 5      |
| US-052 | Evaluation & tasting session REST APIs                                   | 8      |
| Total  |                                                                          | 43     |

---

### Sprint 4 — Lab Technician Features
Duration: 2 weeks
Goal: A Lab Technician can view assigned samples, enter chemical analysis results (manually or via AI photo extraction), and submit them.

| ID     | User Story                                                               | Points |
|--------|--------------------------------------------------------------------------|--------|
| US-027 | View samples assigned for analysis                                       | 3      |
| US-028 | Photo paper report → AI extracts values into analysis form (OCR/AI)      | 8      |
| US-029 | Manual entry of chemical analysis parameters                             | 5      |
| US-030 | Submit a completed analysis                                              | 3      |
| US-031 | Edit or delete a submitted analysis                                      | 3      |
| US-032 | Export analysis results                                                  | 3      |
| US-053 | Lab analysis REST APIs                                                   | 5      |
| Total  |                                                                          | 30     |

---

### Sprint 5 — CEO & Chef de Panel Features
Duration: 2 weeks
Goal: The CEO can monitor all operations and approve purchases. The Chef de Panel can manage the tasting panel, run evaluations, and detect divergences.

| ID     | User Story                                                                        | Points |
|--------|-----------------------------------------------------------------------------------|--------|
| US-033 | CEO executive dashboard with KPIs and charts                                      | 8      |
| US-034 | CEO view all samples from all collectors                                          | 5      |
| US-035 | CEO review sensory evaluations (all tasters side by side)                         | 5      |
| US-036 | CEO approve or reject a sample for purchase                                       | 3      |
| US-037 | CEO review lab analysis reports                                                   | 3      |
| US-038 | CEO track confirmed purchases and delivery status                                 | 5      |
| US-039 | CEO geographic map of collector coverage                                          | 5      |
| US-040 | CEO manage users (create, delete, activate/deactivate)                            | 5      |
| US-005 | CEO create accounts and assign roles                                              | 5      |
| US-041 | Chef de Panel multi-section dashboard                                             | 8      |
| US-042 | Chef de Panel manage samples                                                      | 3      |
| US-043 | Chef de Panel submit own sensory evaluation                                       | 5      |
| US-044 | Chef de Panel view all tasters' evaluations with divergence detection             | 8      |
| US-045 | Chef de Panel full CRUD on sessions + approve/refuse proposed sessions            | 5      |
| US-046 | Chef de Panel view lab analyses and panel members                                 | 3      |
| US-054 | CEO & Chef de Panel dashboard REST APIs                                           | 8      |
| Total  |                                                                                   | 90     |

---

### Sprint 6 — Notifications, Offline Sync & Final Integration
Duration: 2 weeks
Goal: All roles receive real-time notifications, the Collector can work offline, chat is available, and the full system is integrated and tested end-to-end.

| ID     | User Story                                                               | Points |
|--------|--------------------------------------------------------------------------|--------|
| US-047 | Receive role-specific notifications (all roles)                          | 5      |
| US-048 | Mark notifications as read (individual and all)                          | 2      |
| US-049 | Navigate from notification to relevant screen                            | 3      |
| US-016 | Collector ↔ CEO in-app chat                                              | 8      |
| US-017 | Offline sample registration with automatic sync                          | 13     |
| US-055 | Notifications REST API (Django signals)                                  | 5      |
| Total  |                                                                          | 36     |

---

## 4. Summary

| Metric                  | Value      |
|-------------------------|------------|
| Total user stories      | 55         |
| Total story points      | 267        |
| Must Have stories       | 33         |
| Should Have stories     | 18         |
| Could Have stories      | 4          |
| Number of roles         | 5          |
| Number of sprints       | 6          |
| Sprint duration         | 2 weeks    |
| Total project duration  | 12 weeks   |
