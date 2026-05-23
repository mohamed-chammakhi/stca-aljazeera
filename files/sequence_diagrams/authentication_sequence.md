# Sequence Diagram - Authentication

This sequence diagram presents the main authentication steps. The user enters an email and password, the system verifies the information, then redirects the user to the interface that corresponds to their role if the authentication is accepted.

```mermaid
sequenceDiagram
    actor User
    participant Interface as Authentication Interface
    participant Controller as Authentication Controller
    participant Model as User Model

    User->>Interface: Request the login page
    Interface-->>User: Display the login form
    User->>Interface: Enter email and password
    Interface->>Interface: Verify the entered data

    alt Incorrect data
        Interface-->>User: Display an error message
    else Correct data
        Interface->>Controller: Send authentication request
        Controller->>Model: Verify user credentials

        alt Authentication refused
            Model-->>Controller: Invalid credentials
            Controller-->>Interface: Refuse access
            Interface-->>User: Display an authentication error
        else Authentication accepted
            Model-->>Controller: User authenticated with role
            Controller-->>Interface: Confirm authentication
            Interface-->>User: Redirect to the role-specific interface
        end
    end
```

**Figure: Authentication sequence diagram.**

The authentication process starts when the user opens the login page and enters their email and password. The system checks the entered data, verifies the user credentials, and either displays an error message or opens the interface corresponding to the authenticated user role.
