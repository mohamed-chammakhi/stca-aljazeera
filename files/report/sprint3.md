# Chapter 5 - Study and Realization of Sprint 3

## Introduction

Sprint 3 is structured around the decision, collection, and purchase workflow.

- Organoleptic Analysis Consultation
- Collector Sample Management
- Confirmed Purchases

## 1. Sprint 3 Backlog

This section presents the backlog of the third sprint, detailing the user stories and their associated tasks with the estimated duration.

**Table 5.1 - Sprint 3 Backlog**

| ID | User Story | Tasks | Duration (Days) |
|---|---|---|---|
| 6 | As an administrator, I can consult organoleptic evaluations submitted by Panel Members and Panel Evaluation Supervisors, then approve or refuse samples based on the results. As a Panel Evaluation Supervisor, I can supervise submitted evaluations and compare panel results. | 6.1 Design the organoleptic analysis consultation interface.<br>6.2 Display submitted evaluations for each olive oil sample.<br>6.3 Allow the administrator to approve or refuse an olive oil sample.<br>6.4 Allow the panel evaluation supervisor to compare submitted evaluations.<br>6.5 Highlight divergent evaluation results when needed. | 7 |
| 5 | 5.1 As a collector, I can manage collected samples by adding, viewing, editing, and deleting them.<br>5.2 As a collector, I can use AI-assisted OCR to extract information from handwritten bottle labels.<br>5.3 As a collector, I can follow the negotiation state of my samples and consult purchase confirmation information when a purchase is approved. | 5.1 Design the collector olive oil sample management interface.<br>5.2 Allow the collector to add, view, edit, and delete authorized olive oil samples.<br>5.3 Integrate AI-assisted OCR for handwritten bottle labels.<br>5.4 Display negotiation and purchase confirmation states. | 10 |
| 7 | As an administrator, I can consult confirmed purchases and follow stock delivery information. | 7.1 Design the confirmed purchases consultation interface.<br>7.2 Develop the backend for confirmed purchase consultation and stock delivery follow-up.<br>7.3 Display confirmed purchases with the olive oil sample, collector, quantity, price, and delivery information.<br>7.4 Allow the administrator to follow stock in transit and received stock. | 6 |

## 2. User Story 1: Organoleptic Analysis Consultation

This user story is divided into two textual descriptions because the administrator and the panel evaluation supervisor do not perform exactly the same actions. The administrator consults submitted organoleptic evaluations in order to make a decision about an olive oil sample.

### 2.1 Design

**Textual Description of the "Administrator Organoleptic Analysis Consultation" Use Case**

**Table 5.2 - Textual description of the "Administrator Organoleptic Analysis Consultation" use case**

| Use Case | Administrator Organoleptic Analysis Consultation |
|---|---|
| Actors | Administrator |
| Description | This use case allows the administrator to consult the organoleptic evaluations submitted by the panel members. The administrator studies the evaluations, then approves or refuses the olive oil sample according to the observations. If the olive oil sample is approved, the administrator provides the first purchase instructions for the collector. |
| Pre-condition | The administrator is authenticated and has access to the organoleptic analysis consultation page. |
| Main Scenario | 1. The administrator opens the organoleptic analysis consultation page.<br>2. The system displays all olive oil samples.<br>3. The administrator selects an olive oil sample.<br>4. The system displays the list of panel members who submitted evaluations, with the classification assigned to the olive oil sample and an option to consult each evaluation in detail.<br>5. The administrator consults the evaluation details if needed.<br>6. The administrator chooses to approve or refuse the olive oil sample.<br>7. If the olive oil sample is approved, the system displays the purchase instruction form.<br>8. The administrator enters the negotiation budget, the desired stock delivery date, and any additional notes for the collector.<br>9. The system records the decision and displays the confirmation message "Decision enregistree avec succes". |
| Post-condition | If the olive oil sample is approved, the negotiation instructions become available to the collector. Otherwise, the olive oil sample is refused. |
| Exception Scenarios | 2. If no submitted evaluation is available for an olive oil sample, the system displays the message "Aucune evaluation soumise disponible". Return to step 2.<br>8. If the required purchase instructions are missing, the system displays the message "Veuillez verifier les champs obligatoires". Return to step 8. |

## 3. User Story 2: Collector Sample Management

The collector manages their collected olive oil samples. The collector can add, consult, modify, and delete samples when the workflow allows it, use OCR to help extract handwritten label information, negotiate with the supplier, and submit a purchase proposal.

### 3.1 Design

**Textual Description of the "Modify an Olive Oil Sample" Use Case**

**Table 5.3 - Textual description of the "Modify an Olive Oil Sample" use case**

| Use Case | Modify an Olive Oil Sample |
|---|---|
| Actors | Collector |
| Description | This use case allows the collector to modify the information of one of their registered olive oil samples. The modification is possible only before a panel member confirms the sample's physical reception from inside the company. |
| Pre-condition | The collector is authenticated and has access to the collector olive oil samples management page. The olive oil sample has not yet been marked in the application as physically received by a panel member inside the company, so the collector is still allowed to modify it. |
| Main Scenario | 1. The collector opens the olive oil samples management page.<br>2. The system displays the collector's registered olive oil samples with their current states.<br>3. The collector selects the olive oil sample to modify.<br>4. The system displays the details of the selected olive oil sample.<br>5. The collector clicks the edit button.<br>6. The system displays the olive oil sample modification form.<br>7. The collector modifies the information that needs to be corrected.<br>8. The collector validates the form.<br>9. The system checks the entered information.<br>10. The system saves the modifications and displays the confirmation message "Echantillon modifie avec succes". |
| Post-condition | The olive oil sample information is modified in the system. |
| Exception Scenarios | 5. If a panel member has already confirmed the physical reception of the olive oil sample inside the company, the edit button is not available and the collector cannot modify the sample. Return to step 4.<br>9. If the bottle reference, supplier, or quantity is missing, the system displays the message "Veuillez verifier les champs obligatoires". Return to step 7. |

**Textual Description of the "Submit a Purchase Proposal" Use Case**

**Table 5.4 - Textual description of the "Submit a Purchase Proposal" use case**

| Use Case | Submit a Purchase Proposal |
|---|---|
| Actors | Collector |
| Description | This use case allows the collector to handle an olive oil sample that has been approved for negotiation. The collector negotiates with the supplier, enters the purchase information, and makes it available for administrator follow-up. |
| Pre-condition | The collector is authenticated and has access to the collector olive oil samples management page. |
| Main Scenario | 1. The collector opens the olive oil samples management page.<br>2. The system displays the collector's olive oil samples with their current states: "Receptionne", "En negociation", and "Achat confirme".<br>3. The collector selects an olive oil sample marked as "En negociation".<br>4. The system displays the details of the selected olive oil sample and the purchase instructions entered by the administrator.<br>5. If the negotiation with the supplier succeeds, the collector clicks on "Confirmer achat".<br>6. The system displays the purchase information form.<br>7. The collector enters the purchase information, including the price, sealing information, truck used, and expected stock arrival date.<br>8. The collector validates the form.<br>9. The system records the purchase information and displays the confirmation message "Achat confirme avec succes". |
| Post-condition | The purchase information is registered in the system and becomes visible to the administrator in the confirmed purchases follow-up. |
| Exception Scenarios | 8. If the required purchase information, such as the price or expected stock arrival date, is missing, the system displays the message "Veuillez remplir les champs obligatoires". Return to step 7. |

## 4. User Story 3: Confirmed Purchases

The administrator consults confirmed purchases and follows the delivery information related to stock. This makes it possible to know which purchased olive oil samples are still in transit and which ones have already been received.

### 4.1 Design

**Textual Description of the "Confirmed Purchases Consultation" Use Case**

**Table 5.5 - Textual description of the "Confirmed Purchases Consultation" use case**

| Use Case | Confirmed Purchases Consultation |
|---|---|
| Actors | Administrator |
| Description | This use case allows the administrator to consult confirmed purchases and follow stock delivery information, including expected delivery dates and delivery state. |
| Pre-condition | The administrator is authenticated and at least one purchase has been confirmed. |
| Main Scenario | 1. The administrator opens the confirmed purchases page.<br>2. The system displays the list of confirmed purchases.<br>3. The administrator consults the purchase details and related olive oil sample information.<br>4. The system displays the stock delivery information.<br>5. The administrator follows whether the stock is still in transit or already received.<br>6. The administrator uses filters or search if needed to find a specific purchase. |
| Post-condition | The administrator has consulted the confirmed purchases and stock delivery state without modifying the original olive oil sample data. |
| Exception Scenarios | 6. If no purchase matches the selected filters, the system displays the message "Aucun resultat trouve". Return to step 6. |
