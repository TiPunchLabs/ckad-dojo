# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in ckad-dojo, please:

1. **Do not** open a public issue
2. Email the maintainer directly at the contact provided in the repository
3. Include the following details:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)
4. Allow reasonable time for a fix before public disclosure (typically 90 days)

## Security Considerations

This project is designed for **local educational use only**. It:

- Runs a local web server on `localhost:9090`
- Uses `ttyd` for embedded terminal access on `localhost:7681`
- Creates Kubernetes resources in your local cluster
- Does not transmit data externally

### Best Practices

- Run only on trusted local Kubernetes clusters
- Do not expose the web interface to public networks
- Review exam questions before running in shared environments

## Acknowledgments

We appreciate responsible disclosure of security vulnerabilities. Contributors who report valid security issues will be acknowledged (with permission) in release notes.
