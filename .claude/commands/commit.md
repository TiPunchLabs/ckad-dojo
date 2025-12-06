# Commit Changes

Create a professional git commit for the current changes.

## Instructions

1. **Analyze changes**: Run `git status` and `git diff --staged` (or `git diff` if nothing staged) to understand what has been modified.

2. **Check commit style**: Run `git log --oneline -5` to see recent commit messages and follow the same style/convention.

3. **Stage changes**: If files are not staged, ask the user which files to stage, or stage all with `git add -A` if the changes are coherent.

4. **Create commit message** following Conventional Commits format:
   - **Type**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`, `build`
   - **Scope** (optional): component or area affected
   - **Subject**: concise description in imperative mood
   - **Body**: detailed explanation of what and why (not how)
   - **Footer**: co-authored-by attribution

5. **Commit format**:
```
<type>(<scope>): <subject>

<body>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Rules

- Use imperative mood ("add" not "added", "fix" not "fixed")
- Subject line max 72 characters
- Body lines max 100 characters
- Be specific about what changed and why
- Group related changes logically
- Never commit secrets, credentials, or sensitive data
- Always verify staged files before committing

## Optional argument

If the user provides a message hint (e.g., `/commit fix login bug`), use it to guide the commit message.

$ARGUMENTS
