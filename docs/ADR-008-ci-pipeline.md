# ADR 008 – Continuous Integration Pipeline

**Status:** Accepted  
**Date:** 2025-09-29  

## Context
Automated quality checks are required for every commit and pull request.

## Decision
Use **GitHub Actions** for continuous integration with RSpec, Cucumber, and Brakeman.

## Alternatives Considered
- CircleCI  
- Travis CI  
- Manual testing

## Rationale
- Native integration with GitHub repo.  
- Simple YAML workflow syntax.  
- Supports caching and artifact reporting.

## Consequences
- Requires YAML workflow maintenance.  
- Free-tier build minutes may be limited.  
- Immediate feedback for commits and PRs.