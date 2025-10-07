# ADR 009 – Mailers: SendGrid (Prod) + Letter Opener (Dev)

**Status:** Accepted  

## Context
The system must support password reset and reminder notifications.

## Decision
Use **SendGrid** for production emails and **Letter Opener** for local preview.

## Alternatives Considered
- Custom SMTP setup  
- Gmail SMTP relay  
- Third-party APIs (Mailgun)

## Rationale
- SendGrid offers a free Heroku add-on.  
- Devise integrates easily with Action Mailer.  
- Letter Opener allows local testing without sending real emails.

## Consequences
- External dependency for production mail delivery.  
- Environment-specific configuration required.  
- Seamless local/production transition.
