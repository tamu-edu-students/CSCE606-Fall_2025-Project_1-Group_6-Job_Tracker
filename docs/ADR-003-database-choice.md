# ADR 003 – Database Choice: PostgreSQL (Prod) + SQLite (Dev/Test)

**Status:** Accepted  

## Context
Rails supports multiple adapters, and Heroku uses PostgreSQL natively.  
Developers need a simple local setup.

## Decision
Use **SQLite3** for development/testing and **PostgreSQL** for production.

## Alternatives Considered
- PostgreSQL in all environments  
- MySQL  
- SQLite only

## Rationale
- SQLite requires no setup for local development.  
- PostgreSQL is robust and Heroku-compatible.  
- Rails 8 supports environment-specific database configuration.

## Consequences
- Different DB engines across environments.  
- Minor SQL syntax differences.  
- Low friction for local and production deployment.
