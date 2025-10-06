# README

Architecture:
# Job Tracker Application Architecture

This Markdown document describes the **monolithic architecture** and flow of the job tracker application.

---

## 1. Overall Architecture

```
+----------------------+     +----------------------+     +--------------------+
|  Web Browser / UI    | <-> |  Rails Controllers   | <-> |  Views / Templating |
|  (HTML/CSS/JS,       |     |  (Jobs, Users, Auth) |     |  (ERB/Haml, JS)     |
|  Stimulus)           |     |                      |     |                    |
+----------------------+     +----------+-----------+     +--------------------+
             |                          |
             | HTTP requests / Fetch/XHR
             v                          v
+----------------------+     +----------------------+
| Frontend Assets / JS | --> | Rails Controllers    |
| (Stimulus controllers,|     | (HTML endpoints,     |
|  packs, CSS, images)  |     |  JSON/API endpoints) |
+----------------------+     +----------+-----------+
             |                          |
             | client-side DOM updates  | reads / writes
             | or API calls to          v
             | controllers         +----------------------+
             +-------------------> | Models (ActiveRecord)|
                                | User, Job, Company   |
                                | Reminders, etc.      |
                                +----------------------+ 
                                         |
                                         v
                                +----------------------+
                                |  Database            |
                                |  (PostgreSQL)        |
                                +----------------------+
                                         |
                                         v
                                +----------------------+
                                | Background Jobs      |
                                | (ActiveJob — adapter)|
                                | -> External Services |
                                |    (Email, Slack API)|
                                +----------------------+
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

---

## Jobs & Companies — Features and Tests

This project provides a small Job Tracker with the following user-facing features and routes (concise):

- Jobs CRUD: create, read, update, delete job applications.
  - Routes: GET /jobs (index), GET /jobs/:id (show), GET /jobs/new, POST /jobs, GET /jobs/:id/edit, PATCH /jobs/:id, DELETE /jobs/:id
  - Redirects: creating a job currently redirects to the dashboard so users see new entries in context; editing/deleting will return to the dashboard if the action was initiated from the dashboard (tracked via params[:from] or referer), otherwise it returns to the jobs list (`jobs_path`).
- Search bar: the jobs list (`/jobs`) contains the search input (client-side filtering with Stimulus for live UI filtering). The search input is present for non-JS clients as well.
- Search bar: the jobs list (`/jobs`) contains the search input. By default the page uses client-side filtering (Stimulus) for instant, in-browser filtering. A non-JS fallback is provided: the search is also implemented as a GET form that submits a `q` query parameter to `GET /jobs` and the controller filters results server-side using `params[:q]` (case-insensitive, uses a left join on companies so jobs without a company are included).
- Company CRUD: create and list companies. Companies created from the job form return the user to the new-job form (uses `return_to: 'jobs_new'` or referer detection).

What lives where (important files):
- Jobs controller and views: `app/controllers/jobs_controller.rb`, `app/views/jobs/*`.
- Stimulus search controller: `app/javascript/controllers/job_search_controller.js` (client-side filtering of `#jobs-table`).
 - Stimulus search controller: `app/javascript/controllers/job_search_controller.js` (client-side filtering of `#jobs-table`). The Stimulus controller now prevents the GET form from performing a full-page submit when JavaScript is enabled (so JS clients get instant filtering while non-JS clients use the server-side `q` fallback).
- Companies controller and views: `app/controllers/companies_controller.rb`, `app/views/companies/*`.

Test coverage (what we ran locally)
- RSpec (job-focused)
  - `spec/models/job_spec.rb` — model validations for presence of title, user, company.
    - Acceptance: invalid without title/user/company; valid with all required attributes.
  - `spec/requests/jobs_crud_spec.rb` — request tests covering index/show/new/create/update/delete and error cases.
    - Key cases: create with valid attrs redirects and persists; create with nil title or company or malformed deadline returns 422 and does not persist; update/delete when `from: 'dashboard'` redirect to dashboard.
    - Acceptance: response status and database state match expectations (redirects, 422 error pages, persisted records).
  - `spec/controllers/jobs_controller_spec.rb` (controller → request smoke tests) — basic sanity checks for REST endpoints.
    - `spec/requests/jobs_request_spec.rb` — server-side search request specs (new): verifies `GET /jobs?q=...` filters results by job title and by company (and includes jobs when matching title even if company absent behavior is supported by left_joins).
  - `spec/system/*_back_spec.rb` — system specs that verify the Back navigation behavior from the jobs/new/edit/show flows (Back now returns to jobs list when opened from jobs list; when opened from dashboard the behavior still returns to dashboard). These tests drive the UI via Capybara rack_test.

    - Cucumber: new scenario `features/search.feature` — "Search form submits and filters results (non-JS)" which exercises the GET form submit behavior (non-JS) and asserts filtered results.

- RSpec (company-focused)
  - `spec/models/company_spec.rb` — validation tests for presence of name and website.
  - `spec/requests/companies_request_spec.rb` — request-level coverage for companies (index, show scoped to current user jobs, new, create, create-with-return-to-job-flow, invalid-create showing validation errors). Acceptance: HTTP status checks, DB changes, and correct redirect destinations.
  - `spec/system/company_from_job_spec.rb` — system test that creates a company from the job form and ensures the user returns to the job form and the new company appears in the select.

- Cucumber (feature tests)
  - `features/jobs.feature` — high-level create/edit/delete flows executed as a signed-in user.
  - `features/dashboard_navigation.feature` — verifies opening a job from the jobs list and that Back returns to the jobs list (adjusted because the dashboard no longer contains the jobs table).
  - `features/search.feature` — verifies the search input is present on the jobs list. (Live client filtering is exercised in system/JS tests; Cucumber checks non-JS presence/behavior.)
  - `features/company_from_job.feature` — verifies the create-company-from-job flow and return-to-job behavior.

Brief acceptance criteria (concise bullets)
- Job create: POST /jobs with valid params creates a Job record and redirects (see route-level redirect behaviour). Invalid params (blank title, blank company, malformed deadline) return 422 and show errors.
- Job update: PATCH /jobs/:id with valid params updates the record; when `from: 'dashboard'` or referer is dashboard, redirect to dashboard, otherwise to jobs list.
- Job delete: DELETE /jobs/:id removes the record and redirects back to the source (dashboard or jobs list).
- Search bar: Input exists on jobs list; client-side filtering hides non-matching rows in JS-enabled clients. Non-JS clients can still see the input and use server-side filtering if implemented.
- Company create from job: creating a company via the Add New Company link returns to the job form and the new company is present in the company select.

Commands to run tests (copyable)
```bash
# Run all RSpec tests (slow)
bundle exec rspec

# Run job-related RSpec tests (focused)
bundle exec rspec spec/models/job_spec.rb spec/requests/jobs_crud_spec.rb spec/controllers/jobs_controller_spec.rb spec/system/new_job_back_spec.rb spec/system/job_show_back_from_dashboard_spec.rb spec/system/dashboard_edit_back_spec.rb

# Run company-related RSpec tests
bundle exec rspec spec/models/company_spec.rb spec/requests/companies_request_spec.rb spec/system/company_from_job_spec.rb

# Run the Cucumber feature suite
bundle exec cucumber --format pretty

# Run a single RSpec file for quick feedback
bundle exec rspec spec/requests/jobs_crud_spec.rb
```

Notes and suggested additional tests (small list)
- Add authorization tests ensuring users cannot access or modify other users' jobs (request specs). This is high-priority for data safety.
- Add `update_status` request specs to validate permitted enum values and behavior.
- Add deadline boundary tests (e.g., '2035-12-31' accepted) and status enum negative tests.

If you'd like, I can add the high-priority missing specs now (ownership + update_status + user_id tamper protection) and run the suite.


## Jobs & Search

- Location: the search bar is available on the Jobs list page (`/jobs`) and on the main Dashboard (`/dashboard`).

- User behavior: the search performs real-time, client-side filtering of the visible jobs table as you type. It matches job title and company name (case-insensitive, partial matches supported). Results update instantly without reloading the page.

- Notes for developers:
  - The client-side search is implemented with a Stimulus controller at `app/javascript/controllers/job_search_controller.js` (importmap-style). It filters table rows in the browser for small-to-moderate datasets.
  - A server-side search endpoint also exists (`GET /jobs/search` -> `JobsController#search`) as a possible fallback for large datasets or when you need pagination/search on the server. If you enable server-side search, prefer `left_joins(:company)` or equivalent to avoid errors when jobs have no associated company.
    - Server-side fallback: there is no separate `#search` action — instead `JobsController#index` accepts `params[:q]` (GET /jobs?q=...) and performs the server-side filtering. If you later add server-side paging or heavy full-text search, consider using a dedicated search service (Postgres full-text, ElasticSearch, or Algolia).

- Quick user tip: visit the Dashboard, start typing in the search box (top-right of the jobs table) and watch the rows filter live. There is no delay and no network traffic for the filtering itself.

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
