# ADR 001 – Adopt Monolithic Rails 8 Architecture

**Status:** Accepted  
## Context
The Job Tracker app is a relatively small-scale academic project for managing user accounts, job postings, and reminders.  
It is maintained by a single student team and requires minimal service isolation.

## Decision
Use a **monolithic Ruby on Rails 8** architecture with MVC, avoiding microservices or external modularization.

## Alternatives Considered
- Microservices-based architecture  
- Modular Rails engines  
- Monolithic Rails app

## Rationale
- Simpler setup and deployment for Heroku and academic use.  
- Rails 8 conventions provide natural modularity (controllers, concerns, namespaces).  
- Easier for a single team to maintain and test.

## Consequences
- Single codebase for all features.  
- Simpler CI/CD and environment management.  
- Horizontal scaling limited but sufficient for coursework.
