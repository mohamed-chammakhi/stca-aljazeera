# Chapter 6 - Study and Realization of Sprint 4

## Introduction

Sprint 4 is structured around the laboratory and tasting workflow.

- Laboratory Analysis Consultation
- Samples for Analysis
- Tasting Session Management

## 1. Sprint 4 Backlog

This section presents the backlog of the fourth sprint, detailing the user stories and their associated tasks with the estimated duration.

**Table 6.1 - Sprint 4 Backlog**

| ID | User Story | Tasks | Duration (Days) |
|---|---|---|---|
| 8 | As a Panel Member / Panel Evaluation Supervisor, I can consult laboratory analyses related to samples and request urgent laboratory analysis when needed. As an administrator, I can consult laboratory analyses in order to follow the evaluation process. | 8.1 Design the laboratory analysis consultation interface.<br>8.2 Display laboratory results linked to samples.<br>8.3 Allow authorized users to consult analysis details.<br>8.4 Allow panel roles to request urgent laboratory analysis.<br>8.5 Notify the laboratory technician about urgent requests. | 6 |
| 9 | As a laboratory technician, I can manage laboratory analyses by adding, viewing, editing, deleting, submitting results, and using AI-assisted OCR for paper reports. | 9.1 Design the samples for analysis interface.<br>9.2 Display physically received samples that require analysis.<br>9.3 Allow the technician to add, view, edit, and delete authorized analysis reports.<br>9.4 Integrate AI-assisted OCR for paper laboratory reports.<br>9.5 Submit final laboratory analysis results in read-only mode. | 10 |
| 10 | As a Panel Member / Panel Evaluation Supervisor, I can manage tasting sessions by adding, viewing, editing, deleting, and confirming attendance. As a Panel Evaluation Supervisor, I can approve or refuse proposed sessions. | 10.1 Design the tasting session management interface.<br>10.2 Allow panel roles to create and consult tasting sessions.<br>10.3 Allow authorized edits and deletions according to session state.<br>10.4 Allow members to confirm attendance.<br>10.5 Allow the panel evaluation supervisor to approve or refuse proposed sessions. | 8 |

## 2. User Story 1: Laboratory Analysis Consultation

Panel roles and the administrator consult laboratory analyses related to samples. Panel roles can also request an urgent laboratory analysis when they need laboratory results to continue the evaluation process.

### 2.1 Design

**Textual Description of the "Laboratory Analysis Consultation" Use Case**

**Table 6.2 - Textual description of the "Laboratory Analysis Consultation" use case**

| Use Case | Laboratory Analysis Consultation |
|---|---|
| Actors | Panel Member, Panel Evaluation Supervisor |
| Description | This use case allows a panel member or the panel evaluation supervisor to consult laboratory analysis results related to olive oil samples. If the analysis is needed urgently, the user can send an urgent request to the laboratory technician. |
| Pre-condition | The user is authenticated and has access to the laboratory analysis consultation page. |
| Main Scenario | 1. The user opens the laboratory analysis consultation page.<br>2. The system displays the olive oil samples with their laboratory analysis states: "En attente" and "Soumis".<br>3. The user selects an olive oil sample.<br>4. The system displays the available laboratory analysis details for the selected olive oil sample.<br>5. If the analysis is needed urgently, the user sends an urgent laboratory analysis request.<br>6. The system records the request, notifies the laboratory technician, and displays the confirmation message "Demande urgente envoyée avec succès". |
| Post-condition | The user has consulted the laboratory analysis details. If an urgent request is sent, it becomes visible to the laboratory technician. |
| Exception Scenarios | 2. If no laboratory analysis is available for an olive oil sample, the system displays the message "Aucune analyse laboratoire disponible". Return to step 2. |

## 3. User Story 2: Samples for Analysis

The laboratory technician manages laboratory analyses for physically received samples. The technician can create and update reports, use OCR to help extract results from a paper report, and submit final results when the analysis is complete.

### 3.1 Design

**Textual Description of the "Add a Laboratory Analysis" Use Case**

**Table 6.3 - Textual description of the "Add a Laboratory Analysis" use case**

| Use Case | Add a Laboratory Analysis |
|---|---|
| Actors | Laboratory Technician |
| Description | This use case allows the laboratory technician to add a laboratory analysis for an olive oil sample that has been physically received inside the company. The technician enters the analysis values and saves the analysis in the system. |
| Pre-condition | The laboratory technician is authenticated and has access to the samples for analysis page. The olive oil sample is physically received and available for laboratory analysis. |
| Main Scenario | 1. The laboratory technician opens the samples for analysis page.<br>2. The system displays the physically received olive oil samples with their analysis states: "En attente", "En cours", and "Soumis".<br>3. The technician selects an olive oil sample marked as "En attente".<br>4. The system displays the laboratory analysis form.<br>5. The technician fills in the laboratory analysis values manually or uses OCR to extract them from a paper laboratory report.<br>6. The technician verifies the entered values.<br>7. The technician validates the form.<br>8. The system records the laboratory analysis and displays the confirmation message "Analyse enregistrée avec succès". |
| Post-condition | A laboratory analysis is added to the selected olive oil sample and saved in the system. |
| Exception Scenarios | 2. If no physically received olive oil sample is available, the system displays the message "Aucun échantillon reçu physiquement". Return to step 2.<br>7. If required analysis values are missing, the system displays the message "Veuillez remplir les champs obligatoires". Return to step 5. |

**Textual Description of the "AI-Assisted Extraction from Laboratory Report" Use Case**

**Table 6.4 - Textual description of the "AI-Assisted Extraction from Laboratory Report" use case**

| Use Case | AI-Assisted Extraction from Laboratory Report |
|---|---|
| Actors | Laboratory Technician |
| Description | This use case allows the laboratory technician to use AI-assisted OCR to extract analysis values from a paper laboratory report and fill the laboratory analysis form faster. |
| Pre-condition | The laboratory technician is authenticated and is filling in or editing a laboratory analysis form. |
| Main Scenario | 1. The technician opens the laboratory analysis form.<br>2. The technician chooses to scan a paper laboratory report.<br>3. The system displays two choices: "Prendre une photo" and "Choisir depuis la galerie".<br>4. The technician takes a new picture or selects an existing image of the report.<br>5. The system launches OCR extraction on the selected image.<br>6. The system fills the corresponding analysis fields with the extracted values.<br>7. The technician verifies and corrects the extracted values if needed.<br>8. The technician completes the remaining fields manually. |
| Post-condition | The extracted values are inserted into the laboratory analysis form and can be corrected before saving. |
| Exception Scenarios | 5. If the image cannot be analyzed, the system displays the message "Impossible d'extraire les informations". Return to step 3. |

## 4. User Story 3: Tasting Session Management

Panel members and the panel evaluation supervisor manage tasting sessions. Members can create and consult sessions and confirm attendance, while the supervisor can approve or refuse proposed sessions.

### 4.1 Design

**Textual Description of the "Add a Tasting Session" Use Case**

**Table 6.5 - Textual description of the "Add a Tasting Session" use case**

| Use Case | Add a Tasting Session |
|---|---|
| Actors | Panel Member, Panel Evaluation Supervisor |
| Description | This use case allows a panel member or the Panel Evaluation Supervisor to add a new tasting session. |
| Pre-condition | The user is authenticated and has access to the tasting session management page. |
| Main Scenario | 1. The user opens the tasting session page.<br>2. The system displays the list of tasting sessions with their states: "En attente", "Planifiée", and "Terminée".<br>3. The user clicks on the button "Nouvelle session".<br>4. The system displays the tasting session creation form.<br>5. The user enters the session information, including title, date, time, location, notes, and selected participants.<br>6. The user clicks on the button "Créer la session".<br>7. The system records the tasting session and displays the confirmation message "Session créée et planifiée". |
| Post-condition | The tasting session is saved in the system with the state "En attente" until it is approved by the Panel Evaluation Supervisor. |
| Exception Scenarios | 6. If required session information is missing, the system displays the message "Veuillez remplir les informations obligatoires". Return to step 5. |

**Textual Description of the "Tasting Session Approval" Use Case**

**Table 6.6 - Textual description of the "Tasting Session Approval" use case**

| Use Case | Tasting Session Approval |
|---|---|
| Actors | Panel Evaluation Supervisor |
| Description | This use case allows the Panel Evaluation Supervisor to approve or refuse a tasting session proposed by a panel member. |
| Pre-condition | The Panel Evaluation Supervisor is authenticated and has access to the tasting session management page. |
| Main Scenario | 1. The Panel Evaluation Supervisor opens the tasting session page.<br>2. The system displays the list of tasting sessions with their states: "En attente", "Planifiée", and "Terminée".<br>3. For a session that has not been approved or refused yet, the system displays the buttons "Approuver" and "Refuser".<br>4. The Panel Evaluation Supervisor selects the proposed session to consult its details and see who proposed it.<br>5. The Panel Evaluation Supervisor clicks on the button "Approuver" or "Refuser".<br>6. The system records the decision and displays the confirmation message "Décision enregistrée avec succès". |
| Post-condition | If the session is approved, it becomes "Planifiée" and remains visible in the tasting sessions list. If it is refused, the proposed session is marked as refused. In both cases, a notification is sent to the panel member who created the session and to the concerned members. |
