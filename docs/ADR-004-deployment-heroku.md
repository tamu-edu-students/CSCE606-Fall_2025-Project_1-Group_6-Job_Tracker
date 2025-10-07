# ADR 004 – Deployment via Heroku with GitHub Actions CI/CD

**Status:** Accepted  

## Context
The project needs continuous deployment and an easy demonstration environment.

## Decision
Deploy the app on **Heroku**, using GitHub Actions for CI/CD automation.

## Alternatives Considered
- AWS Elastic Beanstalk  
- Render  
- Manual deployment on EC2

## Rationale
- Heroku provides simple, free-tier hosting with PostgreSQL.  
- GitHub Actions integrates directly for push/merge automation.  
- No manual DevOps overhead for student projects.

## Consequences
- Vendor lock-in to Heroku.  
- Limited horizontal scaling.  
- Very easy setup and maintenance.
