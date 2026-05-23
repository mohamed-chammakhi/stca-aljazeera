# Chapter 7 - Study and Realization of Sprint 5

## Introduction

Sprint 5 is structured around user support and panel consultation.

- User Management
- Profile Management
- Panel Members Consultation

## 1. Sprint 5 Backlog

This section presents the backlog of the fifth sprint, detailing the user stories and their associated tasks with the estimated duration.

**Table 7.1 - Sprint 5 Backlog**

| ID | User Story | Tasks | Duration (Days) |
|---|---|---|---|
| 11 | As an administrator, I can manage user accounts by adding, viewing, editing, activating/deactivating, and deleting users. | 11.1 Design the user management interface.<br>11.2 Display the list of user accounts and their roles.<br>11.3 Allow the administrator to add and edit users.<br>11.4 Allow the administrator to activate or deactivate accounts.<br>11.5 Allow the administrator to delete user accounts when allowed. | 5 |
| 12 | As a user, I can manage my profile by viewing and updating personal information, password, and profile picture. | 12.1 Design the profile management interface.<br>12.2 Display personal information of the authenticated user.<br>12.3 Allow the user to update personal information.<br>12.4 Allow the user to update the password.<br>12.5 Allow the user to update the profile picture. | 3 |
| 13 | As a Panel Member / Panel Evaluation Supervisor, I can consult the list and information of panel members. | 13.1 Design the panel members consultation interface.<br>13.2 Display the list of panel members.<br>13.3 Display details about a selected panel member.<br>13.4 Add search or filtering when needed. | 2 |

## 2. User Story 1: User Management

The administrator manages user accounts used by the application. This includes creating accounts, consulting user details, updating information, activating or deactivating accounts, and deleting accounts when the system allows it.

### 2.1 Design

**Textual Description of the "Add a User" Use Case**

**Table 7.2 - Textual description of the "Add a User" use case**

| Use Case | Add a User |
|---|---|
| Actors | Administrator |
| Description | This use case allows the administrator to add a new user account to the system. |
| Pre-condition | The administrator is authenticated and has access to the user management page. |
| Main Scenario | 1. The administrator opens the user management page.<br>2. The system displays the list of users.<br>3. The administrator clicks on the button "Ajouter".<br>4. The system displays the user creation form.<br>5. The administrator enters the user information, including name, email, role, phone number, and password.<br>6. The administrator clicks on the button "Enregistrer".<br>7. The system records the new user account and displays the confirmation message "Utilisateur ajouté avec succès". |
| Post-condition | A new user account is created and displayed in the users list. |
| Exception Scenarios | 6. If required information is missing, the system displays the message "Veuillez remplir les champs obligatoires". Return to step 5.<br>6. If the email is already used, the system displays the message "Cette adresse e-mail est déjà utilisée". Return to step 5.<br>6. If the password does not contain at least 6 characters, one number, and one special character, the system displays the message "Veuillez saisir un mot de passe valide". Return to step 5. |

## 3. User Story 2: Profile Management

Each authenticated user can consult and update their personal profile. This allows the user to keep their personal information, password, and profile picture up to date.

### 3.1 Design

**Textual Description of the "Update Profile" Use Case**

**Table 7.3 - Textual description of the "Update Profile" use case**

| Use Case | Update Profile |
|---|---|
| Actors | Administrator, Collector, Panel Member, Panel Evaluation Supervisor, Laboratory Technician |
| Description | This use case allows an authenticated user to update their personal profile information. |
| Pre-condition | The user is authenticated and has access to the profile page. |
| Main Scenario | 1. The user opens the profile page.<br>2. The system displays the user's personal information.<br>3. The user clicks on the edit button of the concerned field.<br>4. The user updates the selected field.<br>5. The user confirms the modification of that field.<br>6. The system saves the modification and displays the confirmation message "Information mise à jour avec succès". |
| Post-condition | The user profile is updated with the confirmed modification. |
| Exception Scenarios | 5. If the modified field is empty, the system displays the message "Veuillez remplir ce champ". Return to step 4.<br>5. If the user tries to modify the email address, the system prevents the modification because the email is used for authentication. Return to step 3.<br>5. If the current password is incorrect during password update, the system displays the message "Mot de passe actuel incorrect". Return to step 4.<br>5. If the new password does not contain at least 6 characters, one number, and one special character, the system displays the message "Veuillez saisir un mot de passe valide". Return to step 4. |

## 4. User Story 3: Panel Members Consultation

Panel members and the panel evaluation supervisor can consult information about the members of the panel. This helps them identify the members involved in the tasting and evaluation process.

### 4.1 Design

**Textual Description of the "Panel Members Consultation" Use Case**

**Table 7.4 - Textual description of the "Panel Members Consultation" use case**

| Use Case | Panel Members Consultation |
|---|---|
| Actors | Panel Member, Panel Evaluation Supervisor |
| Description | This use case allows panel roles to consult the list of panel members. |
| Pre-condition | The user is authenticated and has access to the panel members consultation page. |
| Main Scenario | 1. The user opens the panel members page.<br>2. The system displays the list of panel members with their names and membership dates.<br>3. The user searches for a panel member if needed.<br>4. The system updates the displayed list according to the search. |
| Post-condition | The user has viewed the panel members list. |
| Exception Scenarios | 2. If no panel member is available, the system displays the message "Aucun membre trouvé". Return to step 2.<br>3. If no member matches the search, the system displays the message "Aucun membre trouvé". Return to step 3. |
