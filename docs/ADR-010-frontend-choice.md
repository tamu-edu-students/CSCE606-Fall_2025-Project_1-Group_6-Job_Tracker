# ADR 010 – Frontend Implementation: ERB + Importmap

**Status:** Accepted  
**Date:** 2025-10-02  

## Context
The application requires minimal interactivity and fast page loads.

## Decision
Use Rails 8’s default **ERB templating** and **Importmap** for JS management.

## Alternatives Considered
- React SPA  
- Vue.js with Webpacker  
- StimulusReflex or Hotwire Turbo Streams

## Rationale
- ERB and Importmap are default and require no build tools.  
- Simpler asset pipeline for Heroku deployment.  
- Matches the academic and functional scope of the project.

## Consequences
- Limited client-side interactivity.  
- Lightweight, fast-loading pages.  
- Easier debugging and simpler stack.
