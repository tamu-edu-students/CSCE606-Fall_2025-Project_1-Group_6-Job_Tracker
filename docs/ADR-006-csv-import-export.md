# ADR 006 – Implement CSV Import/Export for Jobs

**Status:** Accepted  
**Date:** 2025-09-25  

## Context
Users need to back up and import job data easily, especially when switching devices.

## Decision
Use Ruby’s built-in **CSV** library for import/export features.

## Alternatives Considered
- JSON import/export  
- API-based sync  
- ActiveStorage attachments

## Rationale
- CSV is human-readable and compatible with Excel/Sheets.  
- No external libraries required.  
- Simple validation and parsing.

## Consequences
- CSV limited to flat data (no nested associations).  
- Must handle validation and duplicates manually.  
- Lightweight and reliable for project scale.
