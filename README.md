# README

Architecture:
# Job Tracker Application Architecture

This Markdown document describes the **monolithic architecture** and flow of the job tracker application.

---

## 1. Overall Architecture

```
+----------------------+        +----------------------+        +--------------------+
|                      |        |                      |        |                    |
|  Web Browser / UI    | <----> |  Rails Controllers   | <----> |  Views / Templating |
|  (HTML/CSS/JS)       |        |  (Jobs, Users, Auth) |        |  ERB/Haml Templates |
+----------------------+        +----------------------+        +--------------------+
            |                               |
            |                               |
            v                               v
+----------------------+        +----------------------+
|                      |        |                      |
| Models (ActiveRecord)|        |  Background Jobs     |
|  User, Job, Reminder,|        |  (Notifications, CSV)|
|    etc.              |        |                      |
+----------------------+        +----------------------+
            |
            |
            v
+----------------------+        +----------------------+
|                      |        |                      |
|  Database (PostgreSQL)|       |  External Services   |
|                      |        |  (Email/Slack API)  |
+----------------------+        +----------------------+
```

---

## 2. Components

### 2.1 Frontend
- HTML/CSS/JS using Rails templating (ERB or Haml).
- Pages:
  - Landing Page
  - Sign Up / Login
  - User Profile
  - Job List / Status Board
  - Job Detail / Create/Edit
  - Reminders / Notifications
  - Import/Export Jobs
- Responsive design (desktop + mobile).

### 2.2 Backend
- **Controllers** handle HTTP requests and coordinate with models.
- **Models** manage database interactions (ActiveRecord): User, Job, Reminder, Company.
- **Background Jobs** handle:
  - Sending Email notifications
  - Sending Slack messages
  - CSV import/export
- **Services / Helpers** for parsing external job posts and integrations.

### 2.3 Database
- PostgreSQL (or MySQL) for storing:
  - Users
  - Jobs
  - Reminders
  - Notifications
  - Activity logs

### 2.4 External Integrations
- Email service (SMTP or SendGrid)
- Slack webhooks
- Optional external APIs for job import/export

### 2.5 CI/CD
- GitHub Actions for:
  - Running RSpec, Cucumber, Jasmine tests
  - Linting and code style checks
  - Automatic deployment to Heroku on `main` branch merge

### 2.6 Testing
- **RSpec** for unit and controller tests
- **Cucumber** for feature tests (behavior-driven)
- **Jasmine** for frontend JS tests
- All tests integrated into CI pipeline

---

## 3. User Request Flow

```
User (Browser)
    |
    v
HTTP Request -> Rails Router -> Controller -> Model -> DB
    |
    v
Controller returns data -> View renders -> Response to User
    |
    v
Background Jobs handle async tasks (Notifications / CSV Import)
``` 

---

## 4. Notes
- Monolithic structure keeps frontend, backend, and DB tightly integrated.
- Use partials and layouts for reusable UI components.
- Background jobs allow async processing for notifications.
- CI/CD ensures consistent builds and automatic deployments.
- The architecture supports incremental development (3 increments).

------------------------------------------------------------------------------------------

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
