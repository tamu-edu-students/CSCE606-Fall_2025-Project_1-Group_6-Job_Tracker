# ADR 002 – Authentication with Devise

**Status:** Accepted  

## Context
User registration, login, logout, and password reset are required.  
Security and maintainability are priorities.

## Decision
Adopt **Devise** for authentication.

## Alternatives Considered
- Custom authentication logic  

## Rationale
- Devise is a proven and secure Rails library.  
- Built-in mailer and password recovery features.  
- Minimal setup effort and strong documentation.

## Consequences
- Adds dependency on Devise/Warden.  
- Requires SMTP configuration (SendGrid) for production.  
- Simplifies authentication flow and user management.