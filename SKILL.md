---
name: jac-portfolio-app
description: Build or evolve a creative, animated, full-stack resume and portfolio web application with Jac/Jaseci where practical. Use when work includes the public portfolio, projects, contact experience, responsive design, or authenticated administration; do not use for unrelated static sites or generic Jac tutorials.
metadata:
  short-description: Build a Jac/Jaseci portfolio application
---

# Jac Portfolio Application

Build the user's product. This skill is for delivering a portfolio application, not primarily for teaching Jac or Jaseci. Keep the result credible, editable, responsive, and straightforward to run.

## Activate when

Use this skill for a resume/portfolio web application that needs one or more of:

- a creative animated public experience;
- resume, biography, skills, and project content;
- contact form and social links;
- a responsive layout;
- an authenticated admin experience for portfolio content; or
- Jac/Jaseci across frontend and backend where the installed ecosystem supports it.

Do not use it for an unrelated landing page, a documentation-only task, or a request that is solely a Jac language lesson.

## Core outcome

Deliver a maintainable portfolio application with these user-facing capabilities:

- Public pages or sections for an introduction, resume, selected projects, contact details, and provided social links.
- A contact flow that validates input and has an explicit, truthful delivery status (for example, saved for review, emailed, or unavailable in a local demo).
- An admin area protected by authentication, used to create, update, publish, reorder, or remove portfolio content as the chosen data model supports.
- A layout that works with keyboard navigation and on narrow, medium, and wide screens.
- Motion that supports the design without blocking reading, input, or reduced-motion preferences.

Use Jac for frontend and backend responsibilities wherever practical in the **currently installed and documented** Jac/Jaseci setup. Do not force Jac into a responsibility that the verified toolchain cannot support well; use the smallest compatible supporting layer and record that boundary.

## Start with discovery, then make a plan

Before implementation, inspect the repository and local environment. Establish facts rather than assuming a particular Jac version, CLI command, web framework, frontend compiler, ORM, authentication pattern, deployment target, or API syntax.

1. Read existing project instructions, manifests, lockfiles, Jac source, tests, and environment examples.
2. Identify installed Jac/Jaseci versions and available commands from the project's own configuration and locally installed help/documentation.
3. Trace the actual application entry points, build/run/test commands, data storage, routing, and current authentication approach.
4. If a required capability is uncertain, consult the authoritative documentation for the detected version before selecting an integration. Prefer a tiny proof of capability over inventing an API.
5. State a short plan before broad edits: goals, proposed architecture, affected files, verification approach, and any decision that needs user input.

If no implementation exists, choose a simple monolithic structure with a clear public surface, admin surface, content/data layer, and tests. Avoid microservices unless the user specifically asks for them.

## Architecture decisions

Keep the architecture proportional to a personal portfolio:

- Treat public portfolio content, admin commands, contact submissions, and authentication as separate responsibilities even when they share one application.
- Define a small, explicit content model. Typical entities are profile, resume entry, project, social link, site setting, administrator, and contact submission.
- Store content in a durable, migration-friendly form appropriate to the verified stack. Do not place passwords, tokens, or private contact messages in browser-accessible assets.
- Prefer server-side authorization for every administrative mutation. Hiding an admin button is not access control.
- Use external services only where they clearly improve a required feature, and make local development workable without production credentials when possible.

When a choice matters, explain it briefly in terms of the verified Jac/Jaseci capabilities, maintenance cost, user experience, and security.

## Design and frontend conventions

Create an original visual direction rather than copying a template. Use a restrained design system: named color, spacing, type, elevation, motion, and breakpoint tokens; reusable components; and semantic HTML or the semantic output supported by the verified frontend path.

- Make the first screen quickly communicate identity, role, and a clear next action.
- Give projects meaningful screenshots, summaries, roles, technologies, links, and outcomes when that information is available. Do not fabricate credentials, metrics, employers, or project links.
- Use animations purposefully: entrance hierarchy, hover/focus feedback, transitions, and optional decorative movement. Honor `prefers-reduced-motion`, avoid continual expensive animation, and never rely on motion alone to convey information.
- Build mobile-first. Test navigation, project grids, forms, text scale, and administration at narrow and wide viewports.
- Maintain visible focus, logical heading levels, labelled controls, keyboard-operable dialogs/menus, sufficient contrast, meaningful alternative text, and useful validation errors.
- Optimize images and fonts, avoid unnecessary client JavaScript, and check that loading states and layout shifts remain reasonable.

## Coding conventions

- Follow existing repository formatting, naming, module boundaries, and package manager conventions. Add tools only when their value is clear and compatible with the discovered stack.
- Keep Jac modules, supporting server code, UI components, and data access narrowly responsible. Prefer explicit types, validation, and error handling at boundaries.
- Centralize configuration through documented environment variables and checked-in safe examples. Never hard-code secrets, private keys, tokens, or production URLs that contain credentials.
- Keep generated files, local databases, logs, dependency caches, and environment files out of version control unless the repository deliberately tracks them.
- Make database and content changes repeatable through the ecosystem's verified migration or seed mechanism. Provide safe sample content only when requested or useful for local review.

## Contact, authentication, and security

Treat all form data and admin input as untrusted.

- Validate and normalize contact data on the server; return safe, user-friendly errors; and prevent duplicate accidental submissions where practical.
- Use the verified framework's protections for authentication, session handling, password hashing, CSRF or equivalent request protection, authorization, rate limiting, and output encoding. Do not invent security APIs.
- Limit admin accounts and capabilities to the minimum needed. Verify that unauthenticated users cannot read or change admin data through direct requests.
- Keep secrets in environment configuration, provide an `.env.example` only with placeholders, and rotate any credential accidentally exposed during development.
- For email or third-party contact delivery, use secret-managed credentials and handle provider failure without falsely claiming delivery.

## Testing and verification

Run the repository's canonical checks discovered during setup. Add focused tests for changed behavior, using tools already supported by the stack where possible.

At minimum, verify:

- public resume and project content renders from the intended source;
- responsive navigation and primary content work at mobile and desktop widths;
- contact validation, submission handling, error state, and stated delivery behavior;
- authentication and authorization boundaries for the admin area;
- admin create/update/delete or publish operations and their validation;
- accessibility basics: keyboard path, focus, labels, headings, contrast review, and reduced-motion behavior;
- relevant server/data tests, plus a small end-to-end or browser check when the local environment supports it.

Report commands run and outcomes. Distinguish automated checks from manual visual checks, and name anything not verified rather than implying it passed.

## Git and GitHub workflow

Inspect the working tree before editing and preserve unrelated changes. Work in focused commits when commits are requested or customary; use descriptive commit messages that describe the user-visible or technical change.

- Do not commit secrets, generated local artifacts, or unrelated formatting churn.
- Keep README setup instructions accurate: prerequisites, environment variables, local run steps, test commands, and deployment assumptions.
- Before a pull request or publish action, summarize the changed behavior, tests, screenshots or visual checks when available, and remaining limits.
- Do not push, open a pull request, change repository visibility, or alter deployment settings without the user's authorization.

## Definition of done

Consider a requested implementation complete only when the agreed scope is present and verified:

- The portfolio has polished, original, responsive public presentation with usable motion and accessible interaction.
- Resume, projects, contact/social links, and required admin workflows are implemented from real or explicitly marked sample data.
- Jac/Jaseci use reflects the discovered, supported environment; any supporting technology has a stated reason.
- Sensitive operations are server-authorized and secrets remain outside tracked source.
- Relevant automated checks pass, and manual/browser checks have been recorded when feasible.
- Setup and key architectural decisions are documented concisely, including known limits or unverified integrations.

## Implementation phases

Adapt the order to the existing project, but keep each phase reviewable:

1. **Discover and plan** — verify the Jac/Jaseci ecosystem and current project state; agree scope and acceptance checks.
2. **Foundation** — establish the content model, configuration, routing, and authentication boundary using supported patterns.
3. **Public portfolio** — build the responsive, accessible visual system and resume/project/contact/social experiences.
4. **Administration** — implement protected content management and validate authorization directly.
5. **Polish and performance** — refine animation, reduced-motion behavior, loading, image/font handling, and mobile interaction.
6. **Test and handoff** — run checks, inspect the result, update honest setup notes, and explain key decisions plus any remaining boundary.

At the end of each meaningful phase, summarize what changed, what was verified, and the next decision or limitation. Do not silently expand the product beyond the requested scope.
