# ADR 007 – Reminder System Design

**Status:** Accepted  

## Context
Each job requires time-based reminders for deadlines and interviews, with auto-disable rules.

## Decision
Implement a **Reminder model** linked to `Job` and `User`, with model validations and callbacks.

## Alternatives Considered
- Background scheduler (Sidekiq, Resque)  
- External notification service  
- Inline mailer-only reminders

## Rationale
- Keeps reminders relationally consistent.  
- Easier to test within the same monolith.  
- Fulfills functional and data integrity requirements.

## Consequences
- No background scheduling (future enhancement).  
- Auto-disable logic triggered on `job.status` updates.  
- Simple and maintainable within current scope.
