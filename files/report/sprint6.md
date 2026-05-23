# Chapter 8 - Study and Realization of Sprint 6

## Introduction

Sprint 6 is structured around dashboards and geographic visualization.

- Administrator Dashboard
- Panel Member Dashboard
- Geographic Map

## 1. Sprint 6 Backlog

This section presents the backlog of the sixth sprint, detailing the user stories and their associated tasks with the estimated duration.

**Table 8.1 - Sprint 6 Backlog**

| ID | User Story | Tasks | Duration (Days) |
|---|---|---|---|
| 14 | As an administrator, I can consult a dashboard summarizing samples, laboratory analyses, organoleptic evaluations, and confirmed purchases in order to monitor the overall process. | 14.1 Design the administrator dashboard interface.<br>14.2 Display sample indicators.<br>14.3 Display laboratory analysis indicators.<br>14.4 Display organoleptic evaluation indicators.<br>14.5 Display confirmed purchase indicators. | 7 |
| 15 | As a Panel Member / Panel Evaluation Supervisor, I can consult my dashboard in order to follow my evaluation activity and related indicators. | 15.1 Design the panel member dashboard interface.<br>15.2 Display evaluation activity indicators.<br>15.3 Display pending and submitted evaluations.<br>15.4 Display recent activity related to the user.<br>15.5 Display panel supervision indicators for the supervisor when applicable. | 7 |
| 16 | As a collector, I can consult the geographic map of samples in order to follow visited and unvisited collection areas. | 16.1 Design the geographic map interface.<br>16.2 Display Tunisian delegations on the map.<br>16.3 Display visited and unvisited areas.<br>16.4 Display sample information by geographic area.<br>16.5 Add map interaction such as zooming and selecting areas. | 4 |

## 2. User Story 1: Administrator Dashboard

The administrator dashboard summarizes the main indicators of the application. It gives a global view of samples, laboratory analyses, organoleptic evaluations, and confirmed purchases.

### 2.1 Design

**Textual Description of the "Administrator Dashboard" Use Case**

**Table 8.2 - Textual description of the "Administrator Dashboard" use case**

| Use Case | Administrator Dashboard |
|---|---|
| Actors | Administrator / CEO |
| Description | This use case allows the administrator to consult a dashboard summarizing the main process indicators, including samples, laboratory analyses, organoleptic evaluations, and confirmed purchases. |
| Pre-condition | The administrator is authenticated and has access to the dashboard. |
| Main Scenario | 1. The administrator opens the dashboard page.<br>2. The system loads the global indicators.<br>3. The system displays sample statistics.<br>4. The system displays laboratory analysis statistics.<br>5. The system displays organoleptic evaluation statistics.<br>6. The system displays confirmed purchase and stock follow-up indicators.<br>7. The administrator consults the indicators to monitor the overall process. |
| Post-condition | The administrator has a summarized view of the current state of the process. |
| Exception Scenarios | 2. If no data is available, the system displays the message "Aucune donnée disponible". Return to step 2.<br>3, 4, 5, or 6. If one indicator cannot be loaded, the system displays the message "Impossible de charger cet indicateur". Return to step 3, 4, 5, or 6 according to the indicator in progress.<br>1. If the administrator is not authenticated or unauthorized, the system blocks access and displays the message "Accès non autorisé". Return to step 1 after authentication with an authorized account.<br>2. If the dashboard cannot be loaded, the system displays the error message "Impossible de charger le tableau de bord". Return to step 1. |

## 3. User Story 2: Panel Member Dashboard

Panel members and the panel evaluation supervisor use the dashboard to follow their evaluation activity. The supervisor can also consult additional indicators related to panel supervision.

### 3.1 Component Organisation

The panel member dashboard is built as a composite Flutter page. A single orchestrator widget owns the page state and the date filters, while the page itself is split into six self-contained sections, one per indicator. Each section owns its own loading and error state, receives its data through constructor parameters, and is rendered as a stateless widget. The orchestrator triggers the six data fetches in parallel, so the page becomes usable as soon as the fastest section responds; a section that fails to load surfaces a local error message without blanking the rest of the page.

**Figure 8.3 — Overall layout of the panel member dashboard.**
*Image to insert: a vertical screenshot capture of the full dashboard from top to bottom, showing the header bar with the bell icon and the six sections stacked in their natural reading order.*

### 3.2 Indicators

An indicator, in the context of this dashboard, is a numerical or graphical summary of a recurring question the taster answers during the working day: where do my samples stand, what is late, am I keeping up with the panel, how is my work distributed across the olive categories. The six indicators below are presented in the order in which they appear on the page, from the most actionable at the top to the historical follow-up at the bottom.

#### 3.2.1 Evaluation Pipeline

**Figure 8.4 — Distribution of the taster's samples across the four states of the evaluation workflow.**
*Image to insert: the "Pipeline de mes évaluations" card with the four coloured counters (Réceptionné, Non évaluée, En cours, Soumise) and their respective values.*

The pipeline section is a counting indicator. It restricts the global sample collection to the samples assigned to the connected taster, then groups those samples by their current workflow state and reports the count of each group. The four states reproduce the natural progression of a sample inside the panel process, from physical reception to a submitted evaluation. The pipeline is the only section of the dashboard that does not aggregate over time: it always reflects the live snapshot of the workflow, so that a sample that moves from one state to another is reflected the next time the section reloads.

#### 3.2.2 Urgent Evaluations

**Figure 8.5 — Urgent evaluations grouped by priority origin.**
*Image to insert: the "Évaluations urgentes" card with the "Demandes urgentes — Direction" subgroup at the top and the "Critique — 2j et plus" subgroup below, showing the day-of-delay badges and the eye icon used for dismissal.*

The section gathers in one place every sample that requires immediate attention and arranges them under two distinct origins. The first subgroup, *Direction priority*, contains the samples that have been explicitly flagged as urgent by the administrator; these samples appear in the list regardless of how long they have been waiting. The second subgroup, *critical delay*, applies a temporal rule: a sample enters this subgroup when the number of days between its physical reception and the current date is greater than or equal to two, where two days is the operational target the panel has set for itself. Each entry carries the sample reference, the collector in charge and the geographical origin, plus a coloured badge that displays the actual delay in days when the entry belongs to the critical subgroup. The eye icon on the right of an entry hides that entry from the urgent list locally on the dashboard; it does not change the state of the underlying sample in the rest of the application.

#### 3.2.3 Session Attendance

**Figure 8.6 — Attendance rate and upcoming tasting session.**
*Image to insert: the "Présence aux séances" card showing the green attendance donut, the three counters (Séances présent, Séances manquées, Total) and the "Prochaine séance" sub-card with the date, the location and the countdown chip.*

The attendance section answers a simple question about reliability and is split in two parts. The upper part computes the attendance rate of the connected taster as

> `attendance_rate = sessions_attended / (sessions_attended + sessions_missed)`

The denominator excludes sessions for which the taster was not invited, so the rate reflects only the sessions the taster was expected to attend. The numeric counters next to the donut report the two numbers that enter the formula, plus their sum, so that the rate can be cross-checked at a glance. The lower part of the section reads the next session from the list of upcoming sessions ordered by date, displays its date and location, and renders a chip with the remaining number of days until that session takes place.

#### 3.2.4 Submission Delay

**Figure 8.7 — Comparison between the taster's submission delay and the panel average.**
*Image to insert: the "Délai de soumission" card showing the three summary tiles (Mon délai moy., Moy. panel, Évals. comptées), the signed difference under the personal tile, and the line chart with the orange solid curve for the personal value plotted against the dashed green curve for the panel average.*

The submission delay of a single evaluation is defined as the number of days elapsed between the reception of the sample and the submission of the evaluation form. From this elementary quantity the section derives two averages over the selected period: a personal average, computed over the evaluations submitted by the connected taster, and a panel average, computed over the evaluations submitted by every panel member during the same period. The three summary tiles report the personal average, the panel average and the signed difference between the two; a downward arrow rendered in green indicates that the taster is faster than the panel, while an upward arrow rendered in red indicates the opposite. The line chart below the tiles traces both averages on the same time axis so that the periods responsible for the gap can be located visually.

#### 3.2.5 Classifications by Category

**Figure 8.8 — Monthly distribution of the organoleptic categories assigned by the taster.**
*Image to insert: the "Mes classifications" card with the grouped bar chart over four months (Jan, Fév, Mar, Avr) and the legend "Extra Vierge / Vierge / Lampante".*

For every month of the selected period, the indicator counts the number of evaluations the taster has submitted with each of the three organoleptic categories the panel uses: extra virgin, virgin and lampante. The three counts of a given month are drawn side by side as a cluster of three bars, and the clusters are aligned along a monthly time axis. The choice of the month as the grouping granularity is driven by the rhythm of the olive harvest: classifications observed on samples collected at the beginning of the season tend to differ from those observed at the end, and the monthly view exposes that drift without forcing the user to read individual evaluation records.

#### 3.2.6 Recent Activity

**Figure 8.9 — Chronological timeline of the taster's recent events.**
*Image to insert: the "Activité récente" card showing the vertical timeline with green dots (submitted evaluations), the blue dot (confirmed attendance), the red dot (missed session) and the "x sur x — tout chargé" footer.*

The last section is a reverse-chronological feed that merges three families of events into a single timeline: evaluation events such as a submission or a draft start, attendance events such as a confirmed presence or a missed session, and profile events such as a profile update. Each entry combines a coloured marker that encodes the family of the event, a short textual label, and a timestamp. The list is loaded by batches of five entries and extends itself progressively as the user scrolls towards the bottom; an optional period selector at the top of the section restricts the feed to a given date range and is shared with the other time-aware sections of the dashboard.

### 3.3 Implementation Notes

The two chart-based sections of the dashboard, submission delay and classifications, are rendered with the `fl_chart` library, respectively as a line chart and as a grouped bar chart. The attendance donut and the activity timeline are not standard chart shapes and are drawn directly with a `CustomPainter`, which leaves full control over the arc thickness, the colour transitions and the spacing between dots on the vertical axis. The date filter exposed in the header bar of the time-aware sections only affects the section it belongs to, so the taster can narrow one indicator without losing the global view on the others. Finally, the decoupled-section design is what makes a partial failure acceptable: if one section cannot complete its data fetch, the affected card displays its own error message while the five remaining cards keep showing their indicators, which is essential on a page whose value lies precisely in the independence of its indicators.

## 4. User Story 3: Geographic Map

The collector consults a geographic map to follow sample coverage by area. The map helps the collector distinguish visited and unvisited areas and consult sample information linked to geographic zones.

### 4.1 Design

**Textual Description of the "Geographic Map" Use Case**

**Table 8.3 - Textual description of the "Geographic Map" use case**

| Use Case | Geographic Map |
|---|---|
| Actors | Collector |
| Description | This use case allows the collector to consult a geographic map of samples in order to follow visited and unvisited collection areas. |
| Pre-condition | The collector is authenticated and has access to the geographic map interface. Geographic data is available in the system. |
| Main Scenario | 1. The collector opens the geographic map page.<br>2. The system displays the map of Tunisian delegations.<br>3. The system marks visited and unvisited areas.<br>4. The collector zooms, moves on the map, or selects an area.<br>5. The system displays sample information related to the selected area.<br>6. The collector uses the map to follow geographic coverage. |
| Post-condition | The collector has consulted the geographic coverage of collected samples. |
| Exception Scenarios | 2. If geographic data cannot be loaded, the system displays the error message "Impossible de charger les données géographiques". Return to step 1.<br>5. If no sample exists in a selected area, the system displays the message "Aucun échantillon disponible pour cette zone". Return to step 4.<br>2. If the map cannot be displayed, the system displays the error message "Impossible d'afficher la carte". Return to step 1.<br>1. If the user is not authenticated or is not a collector, the system blocks access and displays the message "Accès réservé aux collecteurs". Return to step 1 after authentication with a collector account. |
