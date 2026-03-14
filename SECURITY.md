# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| Latest (main branch) | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in ckad-dojo, please report it responsibly:

1. **Do not** open a public GitHub issue
2. Use [GitHub Security Advisories](https://github.com/TiPunchLabs/ckad-dojo/security/advisories/new) to report privately
3. Include the following details:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### Response Timeline

- **Acknowledgment**: within 48 hours
- **Triage and assessment**: within 7 days
- **Fix and disclosure**: within 90 days

## Scope

This project is an educational CKAD exam simulator designed for **local use only**. It:

- Runs a local web server on `localhost:9090`
- Uses `ttyd` for embedded terminal access on `localhost:7681`
- Creates Kubernetes resources in your local cluster
- Does not transmit data externally

### In-Scope Vulnerabilities

- Supply chain integrity (dependencies, CI/CD pipelines)
- Secrets or credentials in configuration files or manifests
- Script injection in bash automation (command injection, path traversal)
- Cross-site scripting (XSS) in the web interface

### Out of Scope

- Issues requiring physical access to the host machine
- Denial of service on a local-only service
- Vulnerabilities in upstream dependencies (report to the upstream project)

## Security Best Practices

- Run only on trusted local Kubernetes clusters
- Do not expose the web interface to public networks
- Review exam questions before running in shared environments

## Acknowledgments

We appreciate responsible disclosure of security vulnerabilities. Contributors who report valid security issues will be acknowledged (with permission) in release notes.
