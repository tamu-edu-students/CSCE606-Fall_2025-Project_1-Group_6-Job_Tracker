# ADR 005 – Testing Frameworks: RSpec + Cucumber

**Status:** Accepted  

## Context
The project requires both developer-level unit testing and user-story-based acceptance testing.

## Decision
Use **RSpec** for model, controller, and request specs, and **Cucumber** for BDD-style acceptance tests.

## Alternatives Considered
- MiniTest only (Rails default)  
- RSpec only  
- Cucumber only

## Rationale
- RSpec offers expressive syntax and shared contexts.  
- Cucumber allows natural-language scenarios for acceptance testing.  
- Both integrate with Capybara and Devise helpers.

## Consequences
- Slightly longer setup but improved test coverage and clarity.  
- Clear separation of unit and integration testing.  
