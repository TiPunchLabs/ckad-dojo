# ADR-0003: Vanilla JS Frontend

**Status**: Accepted
**Date**: 2025-12-04
**Authors**: @xgueret

## Context

The web interface needs to display exam questions (Markdown with code blocks), provide question navigation, manage a countdown timer, and show scoring results. A JavaScript framework (React, Vue, Svelte) could accelerate development and provide better state management.

However, the frontend is served directly by the Python HTTP server with no build pipeline. Adding a framework would require a build step (webpack, vite), a `node_modules` directory, and a CI pipeline for the frontend — all for an interface that is fundamentally a single-page document viewer.

## Decision

Use vanilla JavaScript (ES6+) with no framework and no build step. External libraries are limited to CDN-loaded utilities: `marked.js` for Markdown rendering, `highlight.js` for syntax highlighting, and `Lucide` for icons.

## Alternatives Considered

- **React**: Component model would help organize the UI. But requires JSX compilation, a bundler, and `node_modules`. Overkill for a single-page app.
- **Vue (CDN mode)**: Viable without a build step. But adds framework concepts (reactivity, directives) that complicate contributions for non-Vue developers.
- **Svelte**: Great DX but requires a compiler. Non-starter without a build pipeline.
- **htmx**: Interesting for server-rendered apps. But the exam UI needs client-side state (timer, flags, navigation) that htmx doesn't handle well.

## Consequences

- **Positive**: No build step. Edit `app.js`, refresh the browser. Instant feedback loop.
- **Positive**: No `node_modules`, no `package.json`, no bundler configuration.
- **Positive**: Anyone who knows JavaScript can contribute — no framework-specific knowledge required.
- **Negative**: Manual DOM manipulation. State management is ad-hoc (module-level variables, DOM attributes).
- **Negative**: As the UI grows, the single `app.js` file becomes harder to maintain.
- **Mitigated**: The UI scope is intentionally limited — it's an exam viewer, not a full application.
