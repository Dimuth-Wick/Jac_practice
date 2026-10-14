# Jac Portfolio

A Jac-only resume and portfolio application. The public page includes a hero,
about, resume, skills, projects, contact form, and social links. The admin area
supports profile/resume editing, project management, and a private contact
inbox.

All application source and tests are Jac (`.jac`). The interface uses Jac
Client JSX and CSS embedded in the Jac client component.

## Requirements

Install the Jac CLI for this environment and use the versions declared in
`jac.toml`:

- Jac 0.16.7
- Jac Client 0.3.25
- Jac Scale 0.2.31
- Bun 1.3.11

## Install and run (PowerShell)

From the repository root:

```powershell
jac install

# Set these in the current PowerShell session; never commit real values.
$env:JAC_ADMIN_PASSWORD = "replace-with-a-strong-unique-password"
$env:JAC_JWT_SECRET = "replace-with-a-long-random-secret"

jac start main.jac --dev --port 8765 --no-scale
```

Open <http://localhost:8765/>. Stop the local server with `Ctrl+C`. The app
requires both environment variables at startup; it does not contain fallback
credentials.

Jac Scale provisions the configured `admin` account using
`JAC_ADMIN_PASSWORD`. Admin login and authorization are handled by Jac Scale
and server-side checks that verify the configured administrator identity and
root before exposing or changing private portfolio data. The local Jac Scale
user database persists under `.jac/`; use the account-management tools for
credential changes rather than assuming a changed environment variable resets
an existing account.

## Content and storage

The initial portfolio is clearly marked as sample content. Replace it in the
admin editor before presenting the site as a real resume. Projects, profile
content, and contact messages are stored locally in the Jac graph data under
`.jac/`. Contact submissions are not emailed or sent to an external service;
they appear in the administrator inbox. Project and social links must use
HTTPS.

## Checks and tests

```powershell
jac check main.jac portfolio.cl.jac portfolio_api.jac tests\portfolio_tests.jac
jac test tests\portfolio_tests.jac -v
```

The Jac tests cover malformed contact input and refusal to read private admin
data from a caller outside the configured administrator root. In addition,
the app was manually exercised in the browser for contact submission,
administrator login and authorization, profile editing, project create/edit/
delete, inbox deletion, invalid project URL rejection, and layouts at 375,
768, and 1280 pixels. Keyboard navigation showed a visible focus outline, and
the reduced-motion setting reduced the hero animation duration.

## Accessibility

The UI includes a skip link, labelled navigation and form fields, keyboard
focus indicators, responsive layouts, and a `prefers-reduced-motion` override.

## Scope and deployment

This project is configured for local development. No deployment, production
build, external email delivery, or production security review has been
performed. Configure production secrets and persistence, review the
deployment-specific authentication and hosting setup, and run a production
build and end-to-end checks before exposing it publicly. Jac reports nonfatal
analyzer warnings for the embedded style element and some event parameters;
the browser also logs a React missing-key warning that has not yet been traced.
Non-admin requests are denied, but this Jac Scale RPC version wraps the guard's
403 as a 500 response; this is an error-status mismatch, not authorized access.
