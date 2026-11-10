# Agent workflow — objective → Claude Code → Codex review → report

How a mission runs in this repository when the owner hands an objective to
Claude Code (implementer and orchestrator) and Codex CLI reviews the result
independently, with Herdr as the link between the two. Claude Code starts from
[`CLAUDE.md`](../CLAUDE.md), Codex from [`AGENTS.md`](../AGENTS.md); this file is
the shared reference for both.

Verified on 2026-11-10 with Claude Code 2.1.322, herdr 0.9.1 and codex-cli 0.166.0.
The installed binaries are the authority: when a version changes, check
`herdr agent --help`, `herdr pane --help` and `codex --help` before reusing the
commands below.

```text
 owner ── objective ──► Claude Code ── inspect · plan · implement · check
                            │   ▲
           review-brief-N   │   │  review-N   (via Herdr, at most 3 reviews)
                            ▼   │
                          Codex  (read-only review in a detached worktree)
                            │
 owner ◄── report.md + PR ──┘   decides: merge, more cycles, cluster tests
```

Contents:

- [1. Roles](#1-roles)
- [2. Mission directory and files](#2-mission-directory-and-files)
- [3. Lifecycle](#3-lifecycle)
- [4. Checks and evidence](#4-checks-and-evidence)
- [5. Codex review through Herdr](#5-codex-review-through-herdr)
- [6. Correction cycles](#6-correction-cycles)
- [7. Pull request and report](#7-pull-request-and-report)
- [8. Starting or resuming a mission](#8-starting-or-resuming-a-mission)
- [9. Closing out](#9-closing-out)
- [10. Templates](#10-templates)

## 1. Roles

| Role | Does | Never does |
|---|---|---|
| Owner | Gives the objective and any extra authorization, answers decisions and every trust, permission or sandbox prompt, merges, deploys, runs or authorizes cluster work | — |
| Claude Code | Sole orchestrator and implementer: inspects, writes `prompt.md` and `mission.md`, works in a worktree, runs checks, briefs Codex, fixes findings, opens the PR when authorized, writes `report.md` | Merges, touches `main`, answers an agent's prompt, reads secrets, uses a cluster without explicit authorization |
| Codex | Independent review of the candidate commit and the evidence against the acceptance criteria; may rerun read-only, offline checks | Edits anything except its `review-N.md`, writes to Git, uses the network or a cluster |

Claude Code does not stop for routine choices. It stops and asks for: a
structural decision the objective does not cover, an action above the
authorizations in `prompt.md`, any trust or permission prompt, any cluster
operation, and any conflict with the owner's local work.

## 2. Mission directory and files

This repository is public. Mission artifacts never go into Git; they live in one
directory per mission:

```bash
MD="${XDG_DATA_HOME:-$HOME/.local/share}/ckad-dojo-agent/<mission-id>"   # <mission-id> = YYYY-MM-DD-<slug>
mkdir -p "$MD/evidence" "$MD/reviews" && chmod 700 "${MD%/*}"
```

```text
$MD/
├── prompt.md            objective as received, scope, acceptance criteria, authorized actions
├── mission.md           plan, Git base, branch and worktrees, checks, state, blocker, next action
├── review-brief-N.md    what Codex must review (Claude Code writes it)
├── reviews/review-N.md  Codex's verdict (the only directory Codex can write to)
├── report.md            final report to the owner
├── evidence/            raw command logs, snapshots, checksums (Claude Code only)
└── review-wt/           detached review worktree at the candidate SHA
```

| File | Minimum content |
|---|---|
| `prompt.md` | The objective as received (verbatim), scope in/out, acceptance criteria, authorized actions, owner decisions taken during the mission |
| `mission.md` | Short plan, Git base SHA, branch, worktree paths, check results with exit codes, current state, blocker if any, next action, log |
| `review-brief-N.md` | Criteria, base and candidate SHAs, range to review, sanitized evidence, reviewer limits, responses to earlier findings, verdict output path |
| `reviews/review-N.md` | Verdict, findings by severity with `file:line`, acceptance criteria coverage, commands and exit codes, items left unverified, reservations |
| `report.md` | Outcome, PR and SHA, delivered scope, checks and evidence, verdict, reservations, final state, remaining decision |

Templates are in [§10](#10-templates).

Rules for every artifact, local ones included:

- No secrets, tokens, kubeconfig content, or Kubernetes `Secret` data. Quote the
  name of a variable or object, never its value. If a secret is ever printed,
  stop, do not repeat it, and report which credential to rotate.
- Raw logs, personal paths and environment details stay in `$MD`. Only a
  sanitized summary goes into the PR.
- When the mission has a linked GitHub issue, record its number in `prompt.md`
  and reference it in the PR (`Fixes #<n>`), as the
  [contribution guide](../CONTRIBUTING.md) describes.

## 3. Lifecycle

1. **Inspect.** Record in `mission.md`: `git remote -v`, the current branch,
   `git rev-parse origin/main` after `git fetch origin`, `git status --short`,
   `git worktree list`, `git stash list`, and any open branch or PR covering the
   same objective (`gh pr list --state all --search "<keywords>"`). Snapshot the
   primary checkout (below) before touching anything.
2. **Plan.** Write the acceptance criteria and a short plan in `prompt.md` and
   `mission.md`. Each expected outcome gets a criterion with a verification
   method; every mission also gets `AC-SAFE` (local work preserved, no secret
   read or written, hooks active, nothing on `main`, no cluster access unless
   authorized). Continue without waiting unless [§1](#1-roles) requires a decision.
3. **Implement** in a dedicated worktree from `origin/main`, so the primary
   checkout, its untracked and ignored files, and its stashes stay untouched:

   ```bash
   git fetch origin
   git worktree add -b <type>/<slug> ../ckad-dojo-worktrees/<slug> origin/main
   git -C ../ckad-dojo-worktrees/<slug> branch --unset-upstream   # a bare `git push` can no longer target main
   ```

   Branch types follow Conventional Commits (`feat/`, `fix/`, `docs/`, `chore/`).
   The pre-commit hooks installed in the primary checkout apply to every worktree.
4. **Check** ([§4](#4-checks-and-evidence)) and record each command with its exit code.
5. **Commit the candidate** (when commits are authorized) and **review** it
   ([§5](#5-codex-review-through-herdr)).
6. **Fix and re-review** ([§6](#6-correction-cycles)).
7. **Deliver**: PR if authorized, then `report.md` ([§7](#7-pull-request-and-report)).

### Primary checkout snapshot

One SHA-256 over the primary checkout's HEAD, staged and unstaged changes,
untracked files, the ignored local files agents could plausibly damage
(`.claude/`, `CLAUDE.local.md`, `exam/`, ignored exams) and the stash list.
Prints only the hash. Each snippet in this file is written for a single Bash call.

```bash
snap() {  # snap <checkout>
  local s h
  s=$(set -o pipefail; cd "$1" && git rev-parse HEAD \
      && echo '#staged' && git diff --cached --binary \
      && echo '#unstaged' && git diff --binary \
      && echo '#untracked' && git ls-files -o --exclude-standard -z | xargs -0r sha256sum \
      && echo '#ignored' && git ls-files -o -i --exclude-standard -z -- .claude CLAUDE.local.md exam exams | xargs -0r sha256sum \
      && echo '#stash' && git stash list --format=%H) || return 1
  h=$(printf '%s\n' "$s" | sha256sum | cut -d' ' -f1)
  [[ $h =~ ^[0-9a-f]{64}$ ]] || return 1
  printf '%s\n' "$h"
}
snap "$MAIN" > "$MD/evidence/main-snap-baseline.txt" || { echo "STOP: snapshot failed" >&2; exit 1; }
```

`MAIN` is the primary checkout. Compare before the report and on every resume:

```bash
now=$(snap "$MAIN") || exit 1
[ "$now" = "$(cat "$MD/evidence/main-snap-baseline.txt")" ] && echo unchanged || echo "CHANGED: stop and ask the owner"
```

## 4. Checks and evidence

### 4.1 Checks by change type

CI (`.github/workflows/ci.yml`) runs `uv sync --group dev`,
`uv run pre-commit run --all-files`, `./tests/run-tests.sh`,
`uv run pytest --cov --cov-report=term-missing` on Python 3.12 and 3.15,
`pip-audit`, `gitleaks` and `uv build`. None of these needs a cluster.

| Change | Local checks |
|---|---|
| Any | `git add` the changed files, then `uv run pre-commit run --files <files>` (gitleaks scans staged content); `git diff --check` before the commit and `git diff --check <base>...HEAD` after it |
| Documentation | the above; every relative link and anchor resolves; every command quoted exists (`--help`) |
| Bash (`scripts/`, `exams/*/scoring-functions.sh`) | `./tests/run-tests.sh` |
| Python (`ckad_dojo.py`, `web/`, `scripts/bump-version.py`) | `uv run pytest --cov --cov-report=term-missing` |
| CI or hooks configuration | `uv run pre-commit run --all-files`; the PR's CI run is the evidence |
| Exam behaviour, setup, scoring against real resources | Kubernetes integration: only with explicit authorization, see [`CLAUDE.md`](../CLAUDE.md#kubernetes-rules) |

Never skip or weaken a hook (`--no-verify`, `SKIP=`) to get a green result.

### 4.2 Statuses

Report documentation checks, Bash tests, Python tests and Kubernetes integration
separately. Each acceptance criterion and each check gets one status:

- `VERIFIED`: the check ran and its output confirms the criterion (quote the
  command, the exit code and the relevant lines).
- `NOT_VERIFIED`: not run, failed to run, or inconclusive; say why and what would settle it.
- `NOT_APPLICABLE`: does not apply to this change; say why.

A check that was not executed is reported as not executed, never inferred from a
neighbouring one. A green CI proves lint and tests, not behaviour on a cluster.

## 5. Codex review through Herdr

Run from Claude Code's own Herdr pane (`test "$HERDR_ENV" = 1`). Variables:
`W` implementation worktree, `MD` mission directory, `RW="$MD/review-wt"`,
`N` review number, `R` reviewer agent name (`ckad-review`).

### 5.1 Candidate and review worktree

The implementation worktree must be committed and clean. Codex reviews a commit,
never uncommitted files.

```bash
BASE=$(git -C "$W" merge-base origin/main HEAD) && CAND=$(git -C "$W" rev-parse HEAD) \
  && [ -z "$(git -C "$W" status --porcelain)" ] || { echo "STOP: no clean candidate" >&2; exit 1; }
if [ -e "$RW" ]; then
  [ -z "$(git -C "$RW" status --porcelain)" ] || { echo "STOP: review worktree dirty" >&2; exit 1; }
  git -C "$RW" switch --detach "$CAND"
else
  git -C "$W" worktree add --detach "$RW" "$CAND"
fi
[ "$(git -C "$RW" rev-parse HEAD)" = "$CAND" ] && [ -z "$(git -C "$RW" status --porcelain)" ] \
  && echo "review worktree clean at $CAND; range $BASE...$CAND"
```

The review worktree has no `.venv` and is not direnv-allowed, so `.envrc` never
runs there.

### 5.2 Brief

Write `$MD/review-brief-$N.md` from the [template](#review-brief-nmd). The brief
and the evidence it quotes stay in `$MD`, outside the review worktree: Codex can
read them but not change them. Quote only sanitized excerpts.

### 5.3 Start Codex (first review of a session)

The pane drops credential-like variables and points `KUBECONFIG` at `/dev/null`
before Codex starts, and the launch flags repeat both for every command Codex
runs. Codex's own default (`ignore_default_excludes = true`) does **not** filter
`*KEY*`, `*SECRET*` or `*TOKEN*` variables, hence the explicit overrides.

```bash
R=ckad-review
herdr agent list | grep -q "$R" && { echo "STOP: an agent named $R already exists" >&2; exit 1; }
P=$(set -o pipefail; herdr pane split --current --direction right --cwd "$RW" --no-focus \
      | jq -er .result.pane.pane_id) && [ -n "$P" ] || { echo "STOP: pane not created" >&2; exit 1; }
stop() { herdr pane close "$P"; echo "STOP: $1; pane $P closed" >&2; exit 1; }
herdr pane run "$P" 'for v in $(compgen -e | grep -iE "token|secret|passw|api_?key|credential|^ssh_auth_sock$|^kubeconfig$"); do unset "$v"; done; export KUBECONFIG=/dev/null; echo "env_dirty=$(compgen -e | grep -ciE "token|secret|passw|api_?key|credential|^ssh_auth_sock$") kubeconfig=$KUBECONFIG"' \
  || stop "env cleanup not sent"
herdr pane wait-output "$P" --regex 'env_dirty=[0-9]+ kubeconfig=\S+' --source recent-unwrapped --timeout 15000 \
  || stop "env check not seen"
out=$(herdr pane read "$P" --source recent-unwrapped --lines 50) || stop "pane read failed"
grep -qx 'env_dirty=0 kubeconfig=/dev/null' <<<"$out" || stop "environment not clean"
herdr agent start "$R" --kind codex --pane "$P" -- \
  -C "$RW" --add-dir "$MD/reviews" \
  --sandbox workspace-write --ask-for-approval never \
  -c sandbox_workspace_write.network_access=false \
  -c check_for_update_on_startup=false \
  -c shell_environment_policy.inherit=core \
  -c shell_environment_policy.ignore_default_excludes=false \
  -c 'shell_environment_policy.set.KUBECONFIG="/dev/null"' \
  || stop "agent start failed"
echo "pane=$P"
```

Effect, per flag:

| Flag | Effect |
|---|---|
| `-C "$RW"` | Codex's working root is the detached review worktree, never `$W` |
| `--sandbox workspace-write` + `--add-dir "$MD/reviews"` | Writable: `$RW`, `$MD/reviews`, `/tmp`. `.git` stays read-only, so Codex cannot stage or commit |
| `--ask-for-approval never` | No escalation request is possible; a denied command fails and goes under "Not checked" |
| `network_access=false` | No network for Codex's commands (overrides a global `true`) |
| `shell_environment_policy.*` | Commands get only core variables, minus KEY/SECRET/TOKEN names, with `KUBECONFIG=/dev/null` |

The filesystem outside the writable roots stays **readable** in this sandbox:
the reviewer's limits in [`AGENTS.md`](../AGENTS.md#limits) forbid reading
credentials, and the cleared `KUBECONFIG` plus disabled network keep `kubectl`
and `helm` from reaching a cluster.

Before the first prompt:

```bash
herdr agent get "$R"                         # expect idle, no pending launch
herdr agent read "$R" --source visible       # look for a "Trust this folder?" dialog
```

Herdr may report a trust dialog as `idle`. Any trust, approval or sandbox
question goes to the owner; never answer it. If a flag is rejected, drop it,
record it, and never widen permissions instead. The first brief of every Codex
session includes the permission probes of the template; confirm their results
in the review, and check the session's effective policy in Codex's newest
rollout file (`~/.codex/sessions/…/rollout-*.jsonl`, `turn_context` entry:
`sandbox_policy`, `approval_policy`, `network_access`).

### 5.4 Prompt

```bash
herdr agent prompt "$R" "Read AGENTS.md, then $MD/review-brief-$N.md, and do the review it describes. Write the review to $MD/reviews/review-$N.md and nothing else." \
  --wait --timeout 900000
```

A timeout is not a failure and never a reason to resend: check
`herdr agent get "$R"` and `herdr agent read "$R" --source recent-unwrapped --lines 80`,
then `herdr agent wait "$R" --timeout 600000` while it is `working`.

| Herdr state | Action |
|---|---|
| `working` | wait; do not send anything |
| `blocked` | `herdr agent explain "$R" --format text`, `herdr agent read "$R" --source detection`; ask the owner |
| `unknown` | send nothing; one more `herdr agent wait "$R" --timeout 60000`, then report |
| `idle` / `done` | not a verdict on its own; go to §5.5 |

### 5.5 After the review

```bash
F="$MD/reviews/review-$N.md"
test "$F" -nt "$MD/review-brief-$N.md" || echo "STALE or missing review"
grep -xE 'VERDICT: (PASS|PASS_WITH_RESERVATIONS|CHANGES_REQUESTED|BLOCKED)' "$F"
grep -x "Brief: review-brief-$N.md" "$F" && grep -x "Candidate: $CAND" "$F"
[ "$(git -C "$RW" rev-parse HEAD)" = "$CAND" ] && [ -z "$(git -C "$RW" status --porcelain)" ] && echo "review worktree intact"
sha256sum "$F" >> "$MD/evidence/reviews.sha256"
```

Then cross-check at least one finding or one acceptance-criterion claim against
the code yourself. If the review file is missing while the agent is `idle`, read
the answer (`herdr agent read "$R" --source recent-unwrapped --lines 200`) and ask
Codex once to write the file.

| Verdict | Next step |
|---|---|
| `PASS` | PR and report |
| `PASS_WITH_RESERVATIONS` | PR and report; every reservation goes into both |
| `CHANGES_REQUESTED` | §6 |
| `BLOCKED` | resolve the cause or report `BLOCKED` |

## 6. Correction cycles

- At most **three reviews per mission** by default, the first included. Only the
  owner can extend the limit; quote the authorization in `mission.md`.
- Fix findings in `$W`, never in `$RW`. Rerun the checks, commit a new candidate,
  move the review worktree to it (§5.1), and write `review-brief-<N+1>.md`. The
  new brief answers every open finding: fixed (where) or rejected (why).
- Reuse the running Codex agent; its sandbox still points at `$RW`. Start a new
  one (§5.3) only if the pane is gone.
- Any commit after a verdict invalidates it: the new head needs its own review
  before the PR or the report can claim a verdict for it.
- If findings remain after the last allowed review, stop and report `BLOCKED` or
  `PARTIAL` with the open findings.
- If Herdr or Codex cannot complete a review, record the blocker and evidence in
  `mission.md`. With no verdict issued, the review is **pending**: a draft PR, if
  any, must say so.

## 7. Pull request and report

When the objective authorizes it:

```bash
[ "$(git -C "$W" rev-parse HEAD)" = "$CAND" ] || { echo "STOP: head is not the reviewed SHA" >&2; exit 1; }
git -C "$W" push -u origin HEAD:refs/heads/<type>/<slug>
gh pr create --draft --base main --head <type>/<slug> --title "<conventional title>" --body-file "$MD/pr-body.md"
gh pr view --json url,baseRefName,headRefOid,isDraft
gh pr checks <number>
```

- Always a **draft**, always against `main`. Merging is the owner's decision.
- The PR body is the shareable summary: fill the "Agent-assisted PR" section of
  the [PR template](../.github/PULL_REQUEST_TEMPLATE.md) with the reviewed SHA,
  the verdict, the checks and the reservations. No personal paths, no raw logs.
- `report.md` stays in `$MD` and is never committed: a report commit would
  change the head and invalidate the reviewed SHA.
- Record the PR's CI result separately from the local checks.

`report.md` verdicts: `PASS` (all criteria `VERIFIED`, last review `PASS` or
`PASS_WITH_RESERVATIONS`), `PARTIAL`, `BLOCKED`, `FAIL`, or `NOT_VERIFIED`, with
the reason for anything other than `PASS`. Claude Code then replies to the owner
with the report path, the verdict and the decision left to take.

## 8. Starting or resuming a mission

### 8.1 Start

Open Claude Code in a Herdr pane at the primary checkout and give, for example:

```text
Objective: <what you want, or "issue #<n>">.
Follow docs/agent-workflow.md. Mission id: <YYYY-MM-DD>-<slug>.
Authorizations: <none | commit | commit + push + draft PR>. Cluster: <none | context <name>, disposable>.
```

Claude Code creates `$MD`, copies the objective verbatim into `prompt.md`, then
works through [§3](#3-lifecycle).

### 8.2 Resume

1. Read `$MD/prompt.md`, then `$MD/mission.md` (**State**, **Next action**, **Log**).
2. Re-check what `mission.md` claims: `git worktree list`,
   `git -C "$W" status --short`, `git -C "$W" log --oneline origin/main..HEAD`,
   the primary checkout snapshot, `herdr agent list`.
3. Continue from **Next action**:
   - `reviews/review-N.md` exists and is newer than its brief → process it (§5.5).
   - Reviewer alive and `working` → wait; do not resend.
   - Reviewer gone and no review file → start Codex again (§5.3), send the same brief.
   - Reality contradicts `mission.md` (unknown commits, dirty or missing worktree,
     changed snapshot) → stop and ask the owner.
4. Append a `resumed` line to the log.

## 9. Closing out

1. Final snapshot comparison of the primary checkout ([§3](#primary-checkout-snapshot)).
2. Close the panes this mission created, and only those: `herdr pane close "$P"`.
3. The review worktree and `$MD` stay until the owner approves their removal
   (`git worktree remove "$RW"` deletes files).
4. Set `mission.md` to `done` (or `blocked`) with the final state, then deliver
   `report.md` and the remaining decision to the owner.

## 10. Templates

### `prompt.md`

```markdown
# Prompt — <mission-id>
## Objective as received
<verbatim>
## Linked issue
#<n> | none
## Scope
In: … / Out: …
## Acceptance criteria
- AC1 <criterion> — verification: <command or inspection>
- AC-SAFE local work preserved; no secret read or written; hooks active; nothing on main; no cluster access unless authorized
## Authorized actions
<branch + worktree | commit | push | draft PR | cluster context …>; not authorized: …
## Owner decisions
- <date> D<n>: <question> → <answer>
```

### `mission.md`

```markdown
# Mission <mission-id>
## Plan
1. …
## Git
- Base: origin/main @ <sha>
- Branch / worktree: <type>/<slug> / <W>
- Review worktree: <RW> @ <candidate sha>
- Primary checkout snapshot: evidence/main-snap-baseline.txt
## Checks
| Check | Command | Exit | Status |
|---|---|---|---|
## State
- Phase: inspect | plan | implement | check | review-N | fix-N | deliver | done | blocked
- Review cycle: N of 3; reviewer: <agent name>, pane <id>
- Blocker: none | …
- Next action: …
## Log
- <date time> <phase>: <one line>
```

### `review-brief-N.md`

```markdown
# Review brief N — <mission-id>
## Target
- Base: <sha>   Candidate: <sha>   Range: <base>...<candidate>
- Review worktree: <RW> (detached at the candidate, clean)
- Output: <MD>/reviews/review-N.md — the only file you may write
## Objective and scope
<short, with a pointer to prompt.md>
## Acceptance criteria
| ID | Criterion | Claude Code status | Evidence |
## Checks run by Claude Code
- `<command>` → exit <n>, <one line>
## Checks not run
- … (why)
## Earlier findings (N > 1)
- F<k>.<j>: fixed in <file:line> | rejected because …
## Permission probes (first brief of a Codex session)
- `echo "KUBECONFIG=${KUBECONFIG-unset}"` → expect /dev/null
- `env | grep -ciE 'token|secret|passw|api_?key|credential'` → expect 0
- `touch "$HOME/.ckad-review-probe"` → expect permission denied
- `touch "$(git rev-parse --git-common-dir)/ckad-review-probe"` → expect permission denied
- `curl -sS -m 5 -o /dev/null https://example.com` → expect failure
## Limits
AGENTS.md "Limits" applies. <mission-specific limits>
```

### `review-N.md`

```markdown
# Review N — <mission-id>
Brief: review-brief-N.md
Candidate: <full sha>
VERDICT: PASS | PASS_WITH_RESERVATIONS | CHANGES_REQUESTED | BLOCKED
## Rationale
<two to five lines>
## Findings
- F<N>.<k> [blocker|major|minor] <file:line> — problem — expected fix
## Acceptance criteria
| ID | Reviewer status | Basis |
## Commands run
- `<command>` → exit <n>, <one-line result>
## Not verified
- … (why)
## Reservations
- …
```

### `report.md`

```markdown
# Report — <mission-id>
## Outcome
Verdict: PASS | PARTIAL | BLOCKED | FAIL | NOT_VERIFIED — <one line>
## PR and SHAs
<URL>, base <sha>, reviewed head <sha>, remote head <sha>, CI <status>
## Delivered scope
<files created / modified>
## Checks and evidence
Documentation / Bash tests / Python tests / Kubernetes integration — each with status and evidence
## Reviews
| N | Candidate | Verdict | Findings and resolution |
## Reservations and limits
## Final state
Branch, worktrees, panes, primary checkout snapshot, what remains on disk
## Decision for the owner
<merge or not, further cycles, cleanup approvals>
```
