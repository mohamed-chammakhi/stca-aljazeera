# Chapter 4 - Study and Realization of Sprint 2

## Introduction

Sprint 2 is structured around the panel sample and evaluation workflow.

- Sample Evaluation
- Sample Management for Panel Roles

## 1. Sprint 2 Backlog

This section presents the backlog of the second sprint, detailing the user stories and their associated tasks with the estimated duration.

**Table 4.1 - Sprint 2 Backlog**

| ID | User Story | Tasks | Duration (Days) |
|---|---|---|---|
| 2 | As a Panel Member / Panel Evaluation Supervisor, I can evaluate samples by filling in organoleptic evaluation forms, saving drafts, editing them, and submitting final evaluations. | 2.1 Design the organoleptic evaluation interface.<br>2.2 Display samples with their evaluation states.<br>2.3 Allow the user to fill in and save an evaluation draft.<br>2.4 Allow the user to edit a draft before final submission.<br>2.5 Submit the final evaluation and lock it in read-only mode. | 7 |
| 3 | As a Panel Member / Panel Evaluation Supervisor, I can manage samples by viewing sample details, editing information when allowed, confirming physical reception, and using AI-assisted OCR for handwritten labels. | 3.1 Design the sample management interface for panel roles.<br>3.2 Display sample details and current status.<br>3.3 Allow authorized edits while respecting workflow restrictions.<br>3.4 Confirm physical reception of a sample.<br>3.5 Integrate AI-assisted OCR for handwritten bottle labels. | 12 |

## 2. User Story 1: Organoleptic Evaluation of Olive Oil Samples

Panel members and the panel evaluation supervisor evaluate olive oil samples by completing organoleptic evaluation forms. An evaluation can be saved as a draft, edited before submission, and submitted as a final evaluation.

### 2.1 Design

**Textual Description of the "Organoleptic Evaluation of Olive Oil Samples" Use Case**

**Table 4.2 - Textual description of the "Organoleptic Evaluation of Olive Oil Samples" use case**

| Use Case | Organoleptic Evaluation of Olive Oil Samples |
|---|---|
| Actors | Panel Member, Panel Evaluation Supervisor |
| Description | This use case allows a panel member or the panel evaluation supervisor to evaluate an olive oil sample by completing an organoleptic evaluation form. The evaluation can be saved as a draft, modified before submission, and then submitted as the final evaluation. |
| Pre-condition | The user is authenticated and has access to olive oil samples assigned or available for organoleptic evaluation. |
| Main Scenario | 1. The user opens the organoleptic evaluation page.<br>2. The system displays the olive oil samples available for evaluation with their evaluation states: "Non évaluée", "En cours", and "Soumis".<br>3. The user selects an olive oil sample to evaluate.<br>4. The system displays the organoleptic evaluation form.<br>5. The user fills in the evaluation fields.<br>6. If the evaluation is not finished yet, the user saves it as a draft.<br>7. If the evaluation is finished, the user submits the final evaluation.<br>8. The system records the evaluation and updates its state according to the action performed. |
| Post-condition | The evaluation is saved in the system. If it is submitted, it becomes final and can no longer be modified by the user. |
| Exception Scenarios | 2. If no olive oil sample is available for evaluation, the system displays the message "Aucun échantillon disponible". Return to step 2. |

## 3. User Story 2: Management of Olive Oil Samples for Panel Roles

Panel members and the panel evaluation supervisor manage olive oil samples by consulting their details, editing information when allowed, confirming physical reception, and using AI-assisted OCR to extract information from handwritten bottle labels.

### 3.1 Design

**Textual Description of the "Add an Olive Oil Sample" Use Case**

**Table 4.3 - Textual description of the "Add an Olive Oil Sample" use case**

| Use Case | Add an Olive Oil Sample |
|---|---|
| Actors | Panel Member, Panel Evaluation Supervisor |
| Description | This use case allows a panel member or the panel evaluation supervisor to add a new olive oil sample to the system by filling in the olive oil sample registration form. |
| Pre-condition | The user is authenticated and has access to the olive oil samples management page. |
| Main Scenario | 1. The user opens the olive oil samples management page.<br>2. The system displays the list of registered olive oil samples.<br>3. The user clicks the button to add a new olive oil sample.<br>4. The system displays the olive oil sample registration form.<br>5. The user enters the required olive oil sample information.<br>6. The user validates the form.<br>7. The system checks the entered information.<br>8. The system registers the new olive oil sample.<br>9. The system displays the confirmation message "Échantillon ajouté avec succès". |
| Post-condition | A new olive oil sample is registered in the system and displayed in the samples list. |
| Exception Scenarios | 7. If the bottle reference, supplier, or quantity is missing, the system displays the message "Veuillez vérifier les champs obligatoires". Return to step 5. |

**Textual Description of the "AI-Assisted Extraction from Bottle Label" Use Case**

**Table 4.4 - Textual description of the "AI-Assisted Extraction from Bottle Label" use case**

| Use Case | AI-Assisted Extraction from Bottle Label |
|---|---|
| Actors | Panel Member, Panel Evaluation Supervisor |
| Description | This use case allows a panel member or the panel evaluation supervisor to use AI-assisted OCR to extract information from a handwritten olive oil bottle label and complete the sample form faster. |
| Pre-condition | The user is authenticated and is filling in or editing an olive oil sample form. A bottle label image is available. |
| Main Scenario | 1. The user opens the olive oil sample form while registering a new olive oil sample or editing an existing olive oil sample.<br>2. The user taps the photo button.<br>3. The system displays two choices: "Prendre une photo" and "Choisir depuis la galerie".<br>4. The user takes a new picture or selects an existing image of the bottle label.<br>5. The system launches OCR extraction on the selected image.<br>6. The system analyzes the image and extracts available information, such as supplier, quantity, and sealing information.<br>7. The system fills the corresponding form fields with the extracted values.<br>8. The user verifies and corrects the extracted values if needed, then completes the remaining fields manually.<br>9. The user validates the form. |
| Post-condition | The extracted information is inserted into the sample form and can be corrected by the user before saving. |
| Exception Scenarios | 6. If the image cannot be analyzed, the system displays the message "Impossible d'extraire les informations". Return to step 2. |
