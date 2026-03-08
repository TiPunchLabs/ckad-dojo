# ADR-0001: Standard Library Only for Web Server

**Status**: Accepted
**Date**: 2025-12-04
**Authors**: @xgueret

## Context

The ckad-dojo web server needs to serve static files, expose a REST API for the frontend, manage an exam timer, and execute scoring/cleanup via subprocess calls. A web framework (Flask, FastAPI, etc.) could simplify routing and request handling.

However, ckad-dojo targets users preparing for the CKAD exam on personal machines or lab environments. These setups vary widely and may have limited or restricted internet access. Adding Python dependencies increases setup friction and introduces potential compatibility issues.

## Decision

Use only the Python standard library (`http.server`, `json`, `subprocess`, `threading`) for the web server. No external Python packages are required at runtime for the server component.

## Alternatives Considered

- **Flask**: Lightweight but adds a dependency (plus Werkzeug). Overkill for a handful of routes.
- **FastAPI**: Powerful but brings uvicorn, pydantic, and other transitive dependencies. Far too heavy for this use case.
- **Node.js/Express**: Would add a second runtime to the stack and fragment the codebase.

## Consequences

- **Positive**: Zero-dependency server. Works on any machine with Python 3.8+. No `pip install` step, no virtualenv needed for the server. `uv run` handles everything.
- **Positive**: Reduced attack surface — no third-party code in the server.
- **Negative**: Manual routing via `do_GET`/`do_POST` with path matching. More boilerplate than a framework.
- **Negative**: No built-in request validation, middleware, or content negotiation. Must be implemented manually when needed.
