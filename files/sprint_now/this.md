# Product Backlog and Sprint Planning

## 1. Product Backlog

| ID | Feature | User Story | Priority | Estimation |
|---|---|---|---|---|
| 1 | Authentication | 1.1 As a user, I can authenticate using my email and password in order to access the interface and functionalities related to my role. | High | 4 Days |
| 2 | Olive Oil Sample Evaluation | 2.1 As a Panel Member / Panel Evaluation Supervisor, I can evaluate olive oil samples by filling in organoleptic evaluation forms, saving drafts, editing them, and submitting final evaluations. | High | 7 Days |
| 3 | Olive Oil Sample Management for Panel Roles | 3.1 As a Panel Member / Panel Evaluation Supervisor, I can manage olive oil samples by adding, viewing, editing, deleting, and confirming physical reception when allowed.<br>3.2 As a Panel Member / Panel Evaluation Supervisor, I can use AI-assisted OCR to extract information from handwritten bottle labels. | High | 12 Days |
| 4 | Administrator Olive Oil Sample Consultation | 4.1 As an administrator, I can consult all registered olive oil samples grouped by collector, as well as the olive oil samples added internally, in order to follow the samples brought during the day. | High | 5 Days |
| 5 | Collector Olive Oil Sample Management | 5.1 As a collector, I can manage collected olive oil samples by adding, viewing, editing, and deleting them.<br>5.2 As a collector, I can use AI-assisted OCR to extract information from handwritten bottle labels.<br>5.3 As a collector, I can follow the negotiation state of my olive oil samples and consult purchase confirmation information when a purchase is approved. | High | 10 Days |
| 6 | Organoleptic Analysis Consultation | 6.1 As an administrator, I can consult organoleptic evaluations submitted by Panel Members and Panel Evaluation Supervisors, then approve or refuse olive oil samples based on the results.<br>6.2 As a Panel Evaluation Supervisor, I can supervise submitted evaluations and compare panel results. | High | 7 Days |
| 7 | Confirmed Purchases | 7.1 As an administrator, I can consult confirmed purchases and follow stock delivery information. | High | 6 Days |
| 8 | Laboratory Analysis Consultation | 8.1 As a Panel Member / Panel Evaluation Supervisor, I can consult laboratory analyses related to olive oil samples and request urgent laboratory analysis when needed.<br>8.2 As an administrator, I can consult laboratory analyses in order to follow the evaluation process. | Medium | 6 Days |
| 9 | Laboratory Analysis of Olive Oil Samples | 9.1 As a laboratory technician, I can manage laboratory analyses of olive oil samples by adding, viewing, editing, deleting, and submitting results. | High | 7 Days |
| 10 | Tasting Session Management | 10.1 As a Panel Member / Panel Evaluation Supervisor, I can manage tasting sessions by adding, viewing, editing, deleting, and confirming attendance.<br>10.2 As a Panel Evaluation Supervisor, I can approve or refuse proposed sessions. | Medium | 8 Days |
| 11 | User Management | 11.1 As an administrator, I can manage user accounts by adding, viewing, editing, activating/deactivating, and deleting users. | Medium | 5 Days |
| 12 | Profile Management | 12.1 As a user, I can manage my profile by viewing and updating my personal information. | Low | 3 Days |
| 13 | Panel Members Consultation | 13.1 As a Panel Member / Panel Evaluation Supervisor, I can consult the list and information of panel members. | Low | 2 Days |
| 14 | Administrator Dashboard | 14.1 As an administrator, I can consult the dashboard in order to have an overview of the olive oil evaluation and purchase process. | Low | 7 Days |
| 15 | Geographic Map | 15.1 As a collector, I can consult the geographic map of olive oil samples in order to follow visited and unvisited collection areas. | Low | 4 Days |

---

## 2. Sprint Planning

The sprint planning is organized according to **priority**, **functional dependency**, and the **main business workflow** of the application. The first sprints focus on the most important operational features, while the final sprints include support, consultation, dashboard, and visualization features.

## 2.1 Sprint Breakdown

| Sprint | Chapter / Sprint Title | Feature IDs | Features included | Duration |
|---|---|---|---|---:|
| Sprint 1 | Authentication and Olive Oil Sample Consultation | 1, 4 | **1 - Authentication**<br>**4 - Administrator Olive Oil Sample Consultation** | 9 Days |
| Sprint 2 | Olive Oil Sample Evaluation and AI-Assisted Management | 2, 3 | **2 - Olive Oil Sample Evaluation**<br>**3 - Olive Oil Sample Management for Panel Roles** | 19 Days |
| Sprint 3 | Olive Oil Sample Decision and Purchase Workflow | 6, 5, 7 | **6 - Organoleptic Analysis Consultation**<br>**5 - Collector Olive Oil Sample Management**<br>**7 - Confirmed Purchases** | 23 Days |
| Sprint 4 | Laboratory Analysis and Tasting Session Management | 9, 8, 10 | **9 - Laboratory Analysis of Olive Oil Samples**<br>**8 - Laboratory Analysis Consultation**<br>**10 - Tasting Session Management** | 21 Days |
| Sprint 5 | User and Panel Information Management | 11, 12, 13 | **11 - User Management**<br>**12 - Profile Management**<br>**13 - Panel Members Consultation** | 10 Days |
| Sprint 6 | Administrator Dashboard and Geographic Coverage | 14, 15 | **14 - Administrator Dashboard**<br>**15 - Geographic Map** | 11 Days |
| **Total** | **Full product backlog** | **1 -> 15** | **All features** | **93 Days** |

---

## 2.2 Sprint Planning Justification

The sprint planning was established according to the reordered Product Backlog while considering business priority, functional dependencies, and the logical workflow of the system. The first sprints focus on the core operational process, including authentication, olive oil sample consultation, sample evaluation, organoleptic consultation, collection management, and purchase follow-up.

The later sprints include supporting features such as user management, profile management, the administrator dashboard, panel consultation, and geographic visualization. This organization allows the project to progress from the most essential business processes toward secondary and complementary features.

---

## 3. Sprint 1 Backlog

The first sprint focuses on the core access to the application and the first administrator consultation feature. It includes authentication and the consultation of registered olive oil samples grouped by collector.

| ID | User Story | Tasks | Duration |
|---|---|---|---:|
| 1 | As a user, I can authenticate using my email and password in order to access the interface and functionalities related to my role. | 1.1 Create the login interface with the required authentication fields.<br>1.2 Develop the backend authentication process and session management.<br>1.3 Redirect each authenticated user to the interface corresponding to their role.<br>1.4 Test the authentication workflow for the different roles. | 4 Days |
| 4 | As an administrator, I can consult all registered olive oil samples grouped by collector, as well as the olive oil samples added internally, in order to follow the samples brought during the day. | 4.1 Create the administrator sample consultation interface.<br>4.2 Develop the backend for retrieving and organizing sample information.<br>4.3 Display the samples grouped by collector and include internally added samples.<br>4.4 Verify the consultation workflow and displayed information. | 5 Days |

**Total Sprint 1 Duration:** 9 Days

---

## 4. Sprint 2 Backlog

The second sprint focuses on the olive oil evaluation workflow and the sample management features used by Panel Members and the Panel Evaluation Supervisor.

| ID | User Story | Tasks | Duration |
|---|---|---|---:|
| 2 | 2.1 As a Panel Member / Panel Evaluation Supervisor, I can evaluate olive oil samples by filling in organoleptic evaluation forms, saving drafts, editing them, and submitting final evaluations. | 2.1 Create the organoleptic evaluation interface and form.<br>2.2 Develop the backend for saving drafts and submitted evaluations.<br>2.3 Allow evaluations to be completed later and submitted as final results.<br>2.4 Verify the evaluation workflow and the saved results. | 7 Days |
| 3 | 3.1 As a Panel Member / Panel Evaluation Supervisor, I can manage olive oil samples by adding, viewing, editing, deleting, and confirming physical reception when allowed.<br><br>3.2 As a Panel Member / Panel Evaluation Supervisor, I can use AI-assisted OCR to extract information from handwritten bottle labels. | 3.1 Create the sample management interface for panel roles.<br>3.2 Develop the backend for managing sample information and workflow restrictions.<br>3.3 Confirm the physical reception of eligible samples.<br>3.4 Integrate bottle-label OCR and allow the user to verify the extracted information.<br>3.5 Test the sample management and reception workflow. | 12 Days |

**Total Sprint 2 Duration:** 19 Days

---

## 5. Sprint 3 Backlog

The third sprint focuses on the decision workflow after organoleptic evaluation. It includes administrator decisions, collector follow-up, and confirmed purchase consultation.

| ID | User Story | Tasks | Duration |
|---|---|---|---:|
| 6 | As an administrator, I can consult organoleptic evaluations submitted by Panel Members and Panel Evaluation Supervisors, then approve or refuse olive oil samples based on the results.<br><br>As a Panel Evaluation Supervisor, I can supervise submitted evaluations and compare panel results. | 6.1 Create the administrator consultation interface for organoleptic evaluations.<br>6.2 Develop the backend for retrieving evaluations and storing administrator decisions.<br>6.3 Implement administrator approval and refusal decisions with the required decision information.<br>6.4 Create the supervisor view for comparing submitted panel evaluations. | 7 Days |
| 5 | As a collector, I can manage collected olive oil samples by adding, viewing, editing, and deleting them.<br><br>As a collector, I can use AI-assisted OCR to extract information from handwritten bottle labels.<br><br>As a collector, I can follow the negotiation state of my olive oil samples and consult purchase confirmation information when a purchase is approved. | 5.1 Create the collector olive oil sample management interface with search and filters.<br>5.2 Develop the backend for collector olive oil sample management and purchase follow-up.<br>5.3 Integrate bottle-label OCR with verification of the extracted information.<br>5.4 Display negotiation and purchase information when an olive oil sample advances in the process.<br>5.5 Implement purchase proposal submission by the collector. | 10 Days |
| 7 | As an administrator, I can consult confirmed purchases and follow stock delivery information. | 7.1 Create the confirmed purchases consultation interface.<br>7.2 Develop the backend for confirmed purchase consultation and stock delivery follow-up.<br>7.3 Display confirmed purchases with the olive oil sample, collector, quantity, price, and delivery information.<br>7.4 Allow the administrator to follow stock in transit and received stock.<br>7.5 Verify the confirmed purchases consultation workflow. | 6 Days |

**Total Sprint 3 Duration:** 23 Days

---

## 6. Sprint 4 Backlog

The fourth sprint focuses on laboratory analysis and tasting session management. It also includes the consultation of laboratory results by the concerned roles.

| ID | User Story | Tasks | Duration |
|---|---|---|---:|
| 9 | 9.1 As a laboratory technician, I can manage laboratory analyses of olive oil samples by adding, viewing, editing, deleting, and submitting results. | 9.1 Create the laboratory analysis management interface.<br>9.2 Develop the backend for managing draft and submitted laboratory analyses.<br>9.3 Submit final laboratory analyses and make them read-only after submission.<br>9.4 Verify the laboratory analysis workflow and displayed states. | 7 Days |
| 8 | 8.1 As a Panel Member / Panel Evaluation Supervisor, I can consult laboratory analyses related to olive oil samples and request urgent laboratory analysis when needed.<br><br>8.2 As an administrator, I can consult laboratory analyses in order to follow the evaluation process. | 8.1 Create the laboratory analysis consultation views for panel roles and administrator.<br>8.2 Develop the backend for laboratory analysis consultation and urgent requests.<br>8.3 Display laboratory analysis states and submitted report details.<br>8.4 Verify that each role sees the appropriate laboratory information. | 6 Days |
| 10 | 10.1 As a Panel Member / Panel Evaluation Supervisor, I can manage tasting sessions by adding, viewing, editing, deleting, and confirming attendance.<br><br>10.2 As a Panel Evaluation Supervisor, I can approve or refuse proposed sessions. | 10.1 Create the tasting session management interface.<br>10.2 Develop the backend for session management, attendance, and supervisor decisions.<br>10.3 Manage session information and participants.<br>10.4 Update and verify the session state throughout the workflow. | 8 Days |

**Total Sprint 4 Duration:** 21 Days

---

## 7. Sprint 5 Backlog

The fifth sprint focuses on support features related to users, profiles, and panel member information.

| ID | User Story | Tasks | Duration |
|---|---|---|---:|
| 11 | 11.1 As an administrator, I can manage user accounts by adding, viewing, editing, activating/deactivating, and deleting users. | 11.1 Create the administrator user management interface.<br>11.2 Develop the backend for user account management and activation status.<br>11.3 Apply the administrator permissions for user actions.<br>11.4 Test the user management workflow. | 5 Days |
| 12 | 12.1 As a user, I can manage my profile by viewing and updating my personal information. | 12.1 Create the profile management interface.<br>12.2 Develop the backend for profile consultation and update.<br>12.3 Allow password update with the required validation.<br>12.4 Verify the profile update workflow. | 3 Days |
| 13 | 13.1 As a Panel Member / Panel Evaluation Supervisor, I can consult the list and information of panel members. | 13.1 Create the panel members consultation interface.<br>13.2 Develop the backend for retrieving panel member information.<br>13.3 Display panel members with search and empty-state handling. | 2 Days |

**Total Sprint 5 Duration:** 10 Days

---

## 8. Sprint 6 Backlog

The sixth sprint focuses on global monitoring features: the administrator dashboard and the collector geographic coverage map.

| ID | User Story | Tasks | Duration |
|---|---|---|---:|
| 14 | 14.1 As an administrator, I can consult the dashboard in order to have an overview of the olive oil evaluation and purchase process. | 14.1 Create the administrator dashboard interface.<br>14.2 Develop the backend for calculating dashboard indicators.<br>14.3 Display the main indicators of the evaluation, purchase, stock, and supplier workflow.<br>14.4 Verify that dashboard statistics match the available data. | 7 Days |
| 15 | 15.1 As a collector, I can consult the geographic map of olive oil samples in order to follow visited and unvisited collection areas. | 15.1 Create the geographic coverage map interface.<br>15.2 Develop the backend for retrieving geographic coverage data.<br>15.3 Display visited and unvisited Tunisian delegations with filters.<br>15.4 Verify the map consultation workflow. | 4 Days |

**Total Sprint 6 Duration:** 11 Days
