# ckad-dojo — instructions for Claude Code

**Language:** English (default) | [Français](CLAUDE.fr.md)

Entry point for a Claude Code session in this repository. Human-facing
documentation: [`README.md`](README.md), [`CONTRIBUTING.md`](CONTRIBUTING.md),
[`docs/architecture.md`](docs/architecture.md), ADRs in [`docs/adr/`](docs/adr/).
When this file and the code disagree, the code wins: fix both.

## Your role

For an objective from the owner, Claude Code is the **sole orchestrator and
implementer**: it inspects, scopes, works in a worktree, runs the checks, gets an
independent review from Codex through Herdr, fixes the findings, and delivers a
report. The owner decides on merge, deployment, and every trust or permission
prompt.

Read [`docs/agent-workflow.md`](docs/agent-workflow.md) at the start of every
mission: it holds the mission files, the verified Herdr and Codex commands, the
correction cycles and how to resume. Codex's instructions are in
[`AGENTS.md`](AGENTS.md).

## Repository layout

```text
ckad_dojo.py              CLI (uv run ckad-dojo): list, info, exam start|stop, setup, score, cleanup, status, completion
web/                      exam web UI: server.py (Python standard library only) + vanilla JS/CSS
scripts/                  Bash business logic: ckad-setup.sh, ckad-exam.sh, ckad-score.sh, ckad-cleanup.sh
scripts/lib/              shared Bash: common, setup-functions, scoring-functions, timer, banner
exams/<exam-id>/          self-contained exams: exam.conf, questions.md, solutions.md, scoring-functions.sh, manifests/, templates/
manifests/setup/, templates/   shared setup manifests and templates
tests/                    Bash suites (run-tests.sh, test-*.sh) and tests/python/ (pytest)
docs/                     architecture, ADRs, CKAD curriculum, agent workflow
specs/                    historical feature specs (read-only reference)
.github/                  CI, issue and PR templates, Dependabot, Scorecard
```

Design decisions are recorded as ADRs (stdlib-only web server, Bash for business
logic, vanilla JS, self-contained exams, Python CLI orchestrator, in-memory timer).
Read the matching ADR before changing one of these areas.

Exams ignored by `.gitignore` are local-only: never name them or copy their
content into a tracked file, a commit message, a PR or an issue.

## Checks

| Change | Checks |
|---|---|
| Any | `git add` the files, then `uv run pre-commit run --files <files>`; `git diff --check`, then `git diff --check <base>...HEAD` after the commit |
| Documentation | the above, plus every relative link, anchor and quoted command verified; the English and French (`*.fr.md`) versions updated together ([documentation languages](CONTRIBUTING.md#documentation-languages)) |
| Bash | `./tests/run-tests.sh` |
| Python | `uv run pytest --cov --cov-report=term-missing` |
| CI parity | `uv sync --group dev && uv run pre-commit run --all-files` |

Hooks: ruff, mypy, shellcheck, shfmt, yamllint, actionlint, markdownlint,
codespell, gitleaks and commitizen (commit message). They are installed in the
primary checkout and run in every worktree. Never bypass or weaken them
(`--no-verify`, `SKIP=`, config edits) to pass.

Report documentation checks, Bash tests, Python tests and Kubernetes integration
separately, each `VERIFIED`, `NOT_VERIFIED` or `NOT_APPLICABLE` with its evidence
or reason. The CI's Bash and Python suites run without a cluster; they do not
prove behaviour on one.

## Git rules

- GitHub Flow: one branch per change from `origin/main`, in a worktree under
  `../ckad-dojo-worktrees/<slug>`. Never commit on `main`, never push to `main`.
- Conventional Commits (enforced by commitizen). Use `git switch`, not `git checkout`.
- Commit, push and PR only when the objective authorizes them. PRs are drafts
  against `main`. Merging is always the owner's decision; no automation merges
  or publishes.
- The primary checkout may hold the owner's work: uncommitted or untracked files,
  ignored local files and stashes. Never edit, stage, stash, reset, clean or switch
  it. No `git reset --hard`, `git clean`, `git checkout -- <path>`, `rm -rf`.
- Mission artifacts stay out of Git, in `$XDG_DATA_HOME/ckad-dojo-agent/<mission-id>/`
  (default `~/.local/share/...`). This repository is public.
- No secrets, tokens, kubeconfig content or Kubernetes `Secret` data in any file,
  commit, PR, issue or local artifact.
- Do not edit machine-wide configuration (`~/.codex`, `~/.claude`, shell profiles)
  as part of a mission.

## Kubernetes rules

Every command that reaches a cluster is out of bounds unless the objective
explicitly authorizes it:

- `kubectl`, `helm`, and any `ckad-dojo` subcommand other than `list`, `info` and
  `completion` (the interactive menu included);
- `scripts/ckad-setup.sh`, `ckad-exam.sh`, `ckad-score.sh`, `ckad-cleanup.sh` and
  any exam setup, reset or cleanup. Some cleanup paths delete resources in
  `default` or at cluster scope.

When a mission is authorized to change a cluster:

1. The owner names the kube context and confirms it is a **dedicated, disposable**
   cluster. Record both in `prompt.md`.
2. Check the context before any command (`kubectl config get-contexts`, the
   cluster's nodes) and stop if it does not match.
3. Pass the context explicitly on every command (`kubectl --context <ctx>`,
   `helm --kube-context <ctx>`); never rely on the current context.
4. A dedicated namespace is not enough: cluster-scoped objects (namespaces,
   ClusterRoles, CRDs, PersistentVolumes) and the `default` namespace are shared.
5. If the target is uncertain at any point, stop all cluster operations and record
   the blocker in `mission.md`.

Read-only access (`status`, `score`, `kubectl get`) is still cluster access and
follows the same rules. Codex never has cluster access.
