# Workflow agent — objectif → Claude Code → review Codex → rapport

**Langue :** [English (par défaut)](agent-workflow.md) | Français

> ⚠️ **Traduction de référence** : ce document traduit [`agent-workflow.md`](agent-workflow.md) pour les lecteurs francophones. Il ne fait pas autorité : Claude Code et Codex suivent uniquement la version anglaise, qui prévaut en cas de divergence.

Déroulement d'une mission dans ce dépôt lorsque le propriétaire confie un
objectif à Claude Code (implémenteur et orchestrateur) et que Codex CLI fait une
review indépendante du résultat, Herdr servant de lien entre les deux. Claude
Code part de [`CLAUDE.fr.md`](../CLAUDE.fr.md), Codex de
[`AGENTS.fr.md`](../AGENTS.fr.md) ; ce fichier est la référence commune aux deux.

Vérifié le 2026-11-10 avec Claude Code 2.1.322, herdr 0.9.1 et codex-cli 0.166.0.
Les binaires installés font autorité : quand une version change, consultez
`herdr agent --help`, `herdr pane --help` et `codex --help` avant de réutiliser
les commandes ci-dessous.

```text
 propriétaire ── objectif ──► Claude Code ── inspecter · planifier · implémenter · vérifier
                                  │   ▲
                 review-brief-N   │   │  review-N   (via Herdr, 3 reviews au maximum)
                                  ▼   │
                                Codex  (review en lecture seule dans un worktree détaché)
                                  │
 propriétaire ◄── report.md + PR ─┘   décide : merge, cycles supplémentaires, tests sur cluster
```

Sommaire :

- [1. Rôles](#1-rôles)
- [2. Répertoire et fichiers de mission](#2-répertoire-et-fichiers-de-mission)
- [3. Cycle de vie](#3-cycle-de-vie)
- [4. Vérifications et preuves](#4-vérifications-et-preuves)
- [5. Review Codex via Herdr](#5-review-codex-via-herdr)
- [6. Cycles de correction](#6-cycles-de-correction)
- [7. Pull request et rapport](#7-pull-request-et-rapport)
- [8. Démarrer ou reprendre une mission](#8-démarrer-ou-reprendre-une-mission)
- [9. Clôture](#9-clôture)
- [10. Modèles](#10-modèles)

## 1. Rôles

| Rôle | Fait | Ne fait jamais |
|---|---|---|
| Propriétaire | Donne l'objectif et toute autorisation supplémentaire, répond aux décisions et à chaque prompt de confiance, de permission ou de sandbox, merge, déploie, exécute ou autorise le travail sur cluster | — |
| Claude Code | Seul orchestrateur et implémenteur : inspecte, écrit `prompt.md` et `mission.md`, travaille dans un worktree, lance les vérifications, briefe Codex, corrige les constats, ouvre la PR quand c'est autorisé, écrit `report.md` | Merger, toucher à `main`, répondre au prompt d'un agent, lire des secrets, utiliser un cluster sans autorisation explicite |
| Codex | Review indépendante du commit candidat et des preuves au regard des critères d'acceptation ; peut relancer des vérifications en lecture seule et hors ligne | Modifier quoi que ce soit d'autre que son `review-N.md`, écrire dans Git, utiliser le réseau ou un cluster |

Claude Code ne s'arrête pas pour les choix courants. Il s'arrête et demande dans
ces cas : une décision structurelle que l'objectif ne couvre pas, une action qui
dépasse les autorisations de `prompt.md`, tout prompt de confiance ou de
permission, toute opération sur un cluster, et tout conflit avec le travail local
du propriétaire.

## 2. Répertoire et fichiers de mission

Ce dépôt est public. Les artefacts de mission ne vont jamais dans Git ; ils sont
rangés dans un répertoire par mission :

```bash
MD="${XDG_DATA_HOME:-$HOME/.local/share}/ckad-dojo-agent/<mission-id>"   # <mission-id> = YYYY-MM-DD-<slug>
mkdir -p "$MD/evidence" "$MD/reviews" && chmod 700 "${MD%/*}"
```

```text
$MD/
├── prompt.md            objectif tel que reçu, périmètre, critères d'acceptation, actions autorisées
├── mission.md           plan, base Git, branche et worktrees, vérifications, état, blocage, prochaine action
├── review-brief-N.md    ce que Codex doit examiner (écrit par Claude Code)
├── reviews/review-N.md  verdict de Codex (le seul répertoire où Codex peut écrire)
├── report.md            rapport final au propriétaire
├── evidence/            journaux bruts des commandes, instantanés, sommes de contrôle (Claude Code uniquement)
└── review-wt/           worktree de review détaché au SHA candidat
```

| Fichier | Contenu minimal |
|---|---|
| `prompt.md` | L'objectif tel que reçu (mot pour mot), périmètre inclus/exclu, critères d'acceptation, actions autorisées, décisions du propriétaire prises pendant la mission |
| `mission.md` | Plan succinct, SHA de base Git, branche, chemins des worktrees, résultats des vérifications avec codes de sortie, état courant, blocage éventuel, prochaine action, journal |
| `review-brief-N.md` | Critères, SHA de base et du candidat, plage à examiner, preuves expurgées, limites du reviewer, réponses aux constats antérieurs, chemin de sortie du verdict |
| `reviews/review-N.md` | Verdict, constats par gravité avec `file:line`, couverture des critères d'acceptation, commandes et codes de sortie, éléments non vérifiés, réserves |
| `report.md` | Résultat, PR et SHA, périmètre livré, vérifications et preuves, verdict, réserves, état final, décision restante |

Les modèles se trouvent au [§10](#10-modèles).

Règles applicables à chaque artefact, y compris les artefacts locaux :

- Aucun secret, token, contenu de kubeconfig ni donnée de `Secret` Kubernetes.
  Citez le nom d'une variable ou d'un objet, jamais sa valeur. Si un secret est
  un jour affiché, arrêtez-vous, ne le répétez pas, et indiquez quel identifiant
  doit être renouvelé.
- Les journaux bruts, les chemins personnels et les détails d'environnement
  restent dans `$MD`. Seul un résumé expurgé va dans la PR.
- Quand la mission est liée à une issue GitHub, consignez son numéro dans
  `prompt.md` et référencez-la dans la PR (`Fixes #<n>`), comme le décrit le
  [guide de contribution](../CONTRIBUTING.fr.md).

## 3. Cycle de vie

1. **Inspecter.** Consignez dans `mission.md` : `git remote -v`, la branche
   courante, `git rev-parse origin/main` après `git fetch origin`,
   `git status --short`, `git worktree list`, `git stash list`, et toute branche
   ou PR ouverte couvrant le même objectif
   (`gh pr list --state all --search "<keywords>"`). Prenez l'instantané du
   checkout principal (ci-dessous) avant de toucher à quoi que ce soit.
2. **Planifier.** Écrivez les critères d'acceptation et un plan succinct dans
   `prompt.md` et `mission.md`. Chaque résultat attendu reçoit un critère assorti
   d'une méthode de vérification ; chaque mission reçoit aussi `AC-SAFE` (travail
   local préservé, aucun secret lu ni écrit, hooks actifs, rien sur `main`, aucun
   accès cluster sauf autorisation). Poursuivez sans attendre, sauf si le
   [§1](#1-rôles) exige une décision.
3. **Implémenter** dans un worktree dédié créé à partir de `origin/main`, afin que
   le checkout principal, ses fichiers non suivis et ignorés, et ses stashes
   restent intacts :

   ```bash
   git fetch origin
   git worktree add -b <type>/<slug> ../ckad-dojo-worktrees/<slug> origin/main
   git -C ../ckad-dojo-worktrees/<slug> branch --unset-upstream   # un `git push` nu ne peut plus cibler main
   ```

   Les types de branche suivent les Conventional Commits (`feat/`, `fix/`,
   `docs/`, `chore/`). Les hooks pre-commit installés dans le checkout principal
   s'appliquent à chaque worktree.
4. **Vérifier** ([§4](#4-vérifications-et-preuves)) et consigner chaque commande
   avec son code de sortie.
5. **Commiter le candidat** (quand les commits sont autorisés) et en **faire la
   review** ([§5](#5-review-codex-via-herdr)).
6. **Corriger et refaire la review** ([§6](#6-cycles-de-correction)).
7. **Livrer** : PR si elle est autorisée, puis `report.md`
   ([§7](#7-pull-request-et-rapport)).

### Instantané du checkout principal

Un SHA-256 unique calculé sur le HEAD du checkout principal, les changements
indexés et non indexés, les fichiers non suivis, les fichiers locaux ignorés que
les agents pourraient vraisemblablement endommager (`.claude/`, `CLAUDE.md` tant
qu'un checkout l'ignore encore, `CLAUDE.local.md`, `exam/`, examens ignorés) et la
liste des stashes.
Seul le hash est affiché. Chaque extrait de ce fichier est écrit pour un seul
appel Bash.

```bash
snap() {  # snap <checkout>
  local s h
  s=$(set -o pipefail; cd "$1" && git rev-parse HEAD \
      && echo '#staged' && git diff --cached --binary \
      && echo '#unstaged' && git diff --binary \
      && echo '#untracked' && git ls-files -o --exclude-standard -z | xargs -0r sha256sum \
      && echo '#ignored' && git ls-files -o -i --exclude-standard -z -- .claude CLAUDE.md CLAUDE.local.md exam exams | xargs -0r sha256sum \
      && echo '#stash' && git stash list --format=%H) || return 1
  h=$(printf '%s\n' "$s" | sha256sum | cut -d' ' -f1)
  [[ $h =~ ^[0-9a-f]{64}$ ]] || return 1
  printf '%s\n' "$h"
}
snap "$MAIN" > "$MD/evidence/main-snap-baseline.txt" || { echo "STOP: snapshot failed" >&2; exit 1; }
```

`MAIN` désigne le checkout principal. Comparez avant le rapport et à chaque
reprise :

```bash
now=$(snap "$MAIN") || exit 1
[ "$now" = "$(cat "$MD/evidence/main-snap-baseline.txt")" ] && echo unchanged || echo "CHANGED: stop and ask the owner"
```

## 4. Vérifications et preuves

### 4.1 Vérifications par type de changement

La CI (`.github/workflows/ci.yml`) exécute `uv sync --group dev`,
`uv run pre-commit run --all-files`, `./tests/run-tests.sh`,
`uv run pytest --cov --cov-report=term-missing` sous Python 3.12 et 3.15,
`pip-audit`, `gitleaks` et `uv build`. Aucune de ces étapes ne nécessite de
cluster.

| Changement | Vérifications locales |
|---|---|
| Tout changement | `git add` des fichiers modifiés, puis `uv run pre-commit run --files <files>` (gitleaks analyse le contenu indexé) ; `git diff --check` avant le commit et `git diff --check <base>...HEAD` après |
| Documentation | ce qui précède ; chaque lien relatif et chaque ancre se résolvent ; chaque commande citée existe (`--help`) ; les versions anglaise et française (`*.fr.md`) changent ensemble ([langues de la documentation](../CONTRIBUTING.fr.md#langues-de-la-documentation)) |
| Bash (`scripts/`, `exams/*/scoring-functions.sh`) | `./tests/run-tests.sh` |
| Python (`ckad_dojo.py`, `web/`, `scripts/bump-version.py`) | `uv run pytest --cov --cov-report=term-missing` |
| Configuration de la CI ou des hooks | `uv run pre-commit run --all-files` ; l'exécution de la CI sur la PR fait office de preuve |
| Comportement d'examen, setup, scoring sur de vraies ressources | Intégration Kubernetes : uniquement avec une autorisation explicite, voir [`CLAUDE.fr.md`](../CLAUDE.fr.md#règles-kubernetes) |

Ne jamais sauter ni affaiblir un hook (`--no-verify`, `SKIP=`) pour obtenir un
résultat vert.

### 4.2 Statuts

Rapportez séparément les vérifications de documentation, les tests Bash, les
tests Python et l'intégration Kubernetes. Chaque critère d'acceptation et chaque
vérification reçoit un statut :

- `VERIFIED` : la vérification a été exécutée et sa sortie confirme le critère
  (citez la commande, le code de sortie et les lignes pertinentes).
- `NOT_VERIFIED` : non exécutée, échec de l'exécution ou résultat non concluant ;
  dites pourquoi et ce qui permettrait de trancher.
- `NOT_APPLICABLE` : ne s'applique pas à ce changement ; dites pourquoi.

Une vérification non exécutée est rapportée comme non exécutée, jamais déduite
d'une vérification voisine. Une CI verte prouve le lint et les tests, pas le
comportement sur un cluster.

## 5. Review Codex via Herdr

À exécuter depuis le pane Herdr de Claude Code lui-même
(`test "$HERDR_ENV" = 1`). Variables : `W` worktree d'implémentation, `MD`
répertoire de mission, `RW="$MD/review-wt"`, `N` numéro de review, `R` nom de
l'agent reviewer (`ckad-review`).

### 5.1 Candidat et worktree de review

Le worktree d'implémentation doit être commité et propre. Codex examine un
commit, jamais des fichiers non commités.

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

Le worktree de review n'a pas de `.venv` et n'est pas autorisé par direnv, donc
`.envrc` ne s'y exécute jamais.

### 5.2 Brief

Écrivez `$MD/review-brief-$N.md` à partir du [modèle](#review-brief-nmd). Le
brief et les preuves qu'il cite restent dans `$MD`, hors du worktree de review :
Codex peut les lire mais pas les modifier. Ne citez que des extraits expurgés.

### 5.3 Lancer Codex

Le pane remplace son shell par un shell propre qui ne conserve qu'une liste
explicite de variables autorisées (aucun identifiant, `KUBECONFIG=/dev/null`)
avant le démarrage de Codex ; les options de lancement appliquent ensuite les
mêmes règles à chaque commande exécutée par Codex. Le réglage par défaut de
Codex lui-même (`ignore_default_excludes = true`) ne filtre **pas** les variables
`*KEY*`, `*SECRET*` ou `*TOKEN*`, d'où les surcharges explicites.

```bash
R=ckad-review
herdr agent list | grep -q "$R" && { echo "STOP: an agent named $R already exists" >&2; exit 1; }
P=$(set -o pipefail; herdr pane split --current --direction right --cwd "$RW" --no-focus \
      | jq -er .result.pane.pane_id) && [ -n "$P" ] || { echo "STOP: pane not created" >&2; exit 1; }
stop() { herdr pane close "$P"; echo "STOP: $1; pane $P closed" >&2; exit 1; }
herdr pane run "$P" 'a=(); for v in HOME USER LOGNAME PATH TERM COLORTERM LANG $(compgen -e | grep "^HERDR_"); do a+=("$v=${!v}"); done; exec env -i "${a[@]}" SHELL=/bin/bash KUBECONFIG=/dev/null bash --noprofile --norc' \
  || stop "clean shell not started"
herdr pane run "$P" 'echo "env_extra=$(compgen -e | grep -cvxE "HOME|USER|LOGNAME|PATH|TERM|COLORTERM|LANG|SHELL|KUBECONFIG|HERDR_[A-Z_]+|PWD|OLDPWD|SHLVL|_") kubeconfig=$KUBECONFIG"' \
  || stop "env check not sent"
herdr pane wait-output "$P" --regex 'env_extra=[0-9]+ kubeconfig=\S+' --source recent-unwrapped --timeout 15000 >/dev/null \
  || stop "env check not seen"
out=$(herdr pane read "$P" --source recent-unwrapped --lines 50) || stop "pane read failed"
grep -qx 'env_extra=0 kubeconfig=/dev/null' <<<"$out" || stop "environment not clean"
herdr agent start "$R" --kind codex --pane "$P" -- \
  -C "$RW" --add-dir "$MD/reviews" \
  --sandbox workspace-write --ask-for-approval never \
  -c sandbox_workspace_write.network_access=false \
  -c check_for_update_on_startup=false \
  -c shell_environment_policy.inherit=core \
  -c shell_environment_policy.ignore_default_excludes=false \
  -c 'shell_environment_policy.set.KUBECONFIG="/dev/null"' \
  -c plugins._default.enabled=false \
  -c skills.include_instructions=false \
  >/dev/null || stop "agent start failed"
echo "pane=$P"
```

Effet de chaque option :

| Option | Effet |
|---|---|
| `-C "$RW"` | La racine de travail de Codex est le worktree de review détaché, jamais `$W` |
| `--sandbox workspace-write` + `--add-dir "$MD/reviews"` | Accessibles en écriture : `$RW`, `$MD/reviews`, `/tmp`. `.git` reste en lecture seule, Codex ne peut donc ni indexer ni commiter |
| `--ask-for-approval never` | Aucune demande d'élévation n'est possible ; une commande refusée échoue et passe sous « Not verified » |
| `network_access=false` | Pas de réseau pour les commandes de Codex (prévaut sur un `true` global) |
| `shell_environment_policy.*` | Les commandes ne reçoivent que les variables de base, sans les noms KEY/SECRET/TOKEN, avec `KUBECONFIG=/dev/null` |
| `plugins._default.enabled=false`, `skills.include_instructions=false` | Aucun plugin (Superpowers compris) et aucun catalogue de skills dans la session du reviewer |

Le système de fichiers hors des racines accessibles en écriture reste **lisible**
dans cette sandbox : les limites du reviewer dans
[`AGENTS.fr.md`](../AGENTS.fr.md#limites) interdisent de lire des identifiants, et
le `KUBECONFIG` vidé ainsi que le réseau désactivé empêchent `kubectl` et `helm`
d'atteindre un cluster. Les restrictions d'écriture et de réseau sont imposées
par la sandbox de Codex ; personne ne les sonde en tentant une écriture ou une
connexion interdite.

Avant le premier prompt :

```bash
herdr agent get "$R"                         # attendu : idle, interactive_ready true
herdr agent read "$R" --source visible       # chercher une boîte de dialogue "Trust this folder?"
```

Herdr peut signaler une boîte de dialogue de confiance comme `idle`. Toute
question de confiance, d'approbation ou de sandbox est transmise au
propriétaire ; n'y répondez jamais. Si une option est rejetée, retirez-la,
consignez-le, et n'élargissez jamais les permissions à la place.

Après le premier prompt, lisez la politique effective que Codex a enregistrée
pour la session (fichier le plus récent sous `~/.codex/sessions/`, entrée
`turn_context`) et conservez-la comme preuve :

```bash
f=$(ls -t ~/.codex/sessions/*/*/*/rollout-*.jsonl | head -1)
jq -c 'select(.type=="turn_context") | .payload | {cwd, approval_policy, sandbox_policy}' "$f" | head -1
# attendu : cwd = $RW, approval_policy "never", type "workspace-write",
# writable_roots = ["$MD/reviews"], network_access false
```

### 5.4 Prompt

```bash
herdr agent prompt "$R" "Read AGENTS.md, then $MD/review-brief-$N.md, and do the review it describes. Write the review to $MD/reviews/review-$N.md and nothing else." \
  --wait --timeout 900000
```

Un timeout n'est pas un échec et jamais une raison de renvoyer le prompt :
vérifiez `herdr agent get "$R"` et
`herdr agent read "$R" --source recent-unwrapped --lines 80`, puis
`herdr agent wait "$R" --timeout 600000` tant que l'agent est `working`.

| État Herdr | Action |
|---|---|
| `working` | attendre ; ne rien envoyer |
| `blocked` | `herdr agent explain "$R" --format text`, `herdr agent read "$R" --source detection` ; demander au propriétaire |
| `unknown` | ne rien envoyer ; encore un `herdr agent wait "$R" --timeout 60000`, puis faire un rapport |
| `idle` / `done` | ce n'est pas un verdict en soi ; passer au §5.5 |

### 5.5 Après la review

Toutes les vérifications doivent réussir avant d'utiliser le verdict ; le premier
échec arrête tout.

```bash
F="$MD/reviews/review-$N.md"
fail() { echo "STOP: $1" >&2; exit 1; }
[ -f "$F" ] && [ "$F" -nt "$MD/review-brief-$N.md" ] || fail "review missing or older than its brief"
[ "$(grep -cE '^VERDICT:' "$F")" = 1 ] || fail "not exactly one VERDICT line"
V=$(grep -xE 'VERDICT: (PASS|PASS_WITH_RESERVATIONS|CHANGES_REQUESTED|BLOCKED)' "$F") || fail "malformed verdict"
grep -qx "Brief: review-brief-$N.md" "$F" || fail "wrong brief"
grep -qx "Candidate: $CAND" "$F" || fail "wrong candidate SHA"
[ "$(git -C "$RW" rev-parse HEAD)" = "$CAND" ] || fail "review worktree moved"
[ -z "$(git -C "$RW" status --porcelain)" ] || fail "review worktree changed"
sha256sum "$F" >> "$MD/evidence/reviews.sha256" || fail "checksum not recorded"
echo "$V"
```

Ensuite, confrontez vous-même au code au moins un constat ou une affirmation sur
un critère d'acceptation. Si le fichier de review est absent alors que l'agent
est `idle`, lisez la réponse
(`herdr agent read "$R" --source recent-unwrapped --lines 200`) et demandez une
seule fois à Codex d'écrire le fichier.

| Verdict | Étape suivante |
|---|---|
| `PASS` | PR et rapport |
| `PASS_WITH_RESERVATIONS` | PR et rapport ; chaque réserve figure dans les deux |
| `CHANGES_REQUESTED` | §6 |
| `BLOCKED` | résoudre la cause ou rapporter `BLOCKED` |

## 6. Cycles de correction

- Au maximum **trois reviews par mission** par défaut, la première comprise.
  Seul le propriétaire peut relever cette limite ; citez son autorisation dans
  `mission.md`.
- Corrigez les constats dans `$W`, jamais dans `$RW`. Relancez les
  vérifications, commitez un nouveau candidat, déplacez le worktree de review
  vers celui-ci (§5.1) et écrivez `review-brief-<N+1>.md`. Le nouveau brief
  répond à chaque constat ouvert : corrigé (où) ou rejeté (pourquoi).
- Réutilisez l'agent Codex en cours d'exécution ; sa sandbox pointe toujours vers
  `$RW`. Démarrez-en un nouveau (§5.3) si le pane a disparu ou si la procédure de
  lancement elle-même a changé (fermez d'abord l'ancien pane).
- Tout commit postérieur à un verdict l'invalide : la nouvelle tête a besoin de
  sa propre review avant que la PR ou le rapport puisse lui attribuer un verdict.
- S'il reste des constats après la dernière review autorisée, arrêtez-vous et
  rapportez `BLOCKED` ou `PARTIAL` avec les constats ouverts.
- Si Herdr ou Codex ne peut pas mener une review à terme, consignez le blocage et
  les preuves dans `mission.md`. Faute de verdict émis, la review est **en
  attente** : une PR draft, s'il y en a une, doit le mentionner.

## 7. Pull request et rapport

Quand l'objectif l'autorise :

```bash
[ "$(git -C "$W" rev-parse HEAD)" = "$CAND" ] || { echo "STOP: head is not the reviewed SHA" >&2; exit 1; }
git -C "$W" push -u origin HEAD:refs/heads/<type>/<slug>
gh pr create --draft --base main --head <type>/<slug> --title "<conventional title>" --body-file "$MD/pr-body.md"
gh pr view --json url,baseRefName,headRefOid,isDraft
gh pr checks <number>
```

- Toujours en **draft**, toujours ciblant `main`. Le merge est la décision du
  propriétaire.
- La description de la PR est le résumé partageable : remplissez la section
  « Agent-assisted PR » du [template de PR](../.github/PULL_REQUEST_TEMPLATE.md)
  avec le SHA examiné, le verdict, les vérifications et les réserves. Aucun
  chemin personnel, aucun journal brut.
- `report.md` reste dans `$MD` et n'est jamais commité : un commit du rapport
  changerait la tête et invaliderait le SHA examiné.
- Consignez le résultat de la CI de la PR séparément des vérifications locales.

Verdicts de `report.md` : `PASS` (tous les critères `VERIFIED`, dernière review
`PASS` ou `PASS_WITH_RESERVATIONS`), `PARTIAL`, `BLOCKED`, `FAIL` ou
`NOT_VERIFIED`, avec la justification de tout verdict autre que `PASS`. Claude
Code répond ensuite au propriétaire avec le chemin du rapport, le verdict et la
décision qui reste à prendre.

## 8. Démarrer ou reprendre une mission

### 8.1 Démarrage

Ouvrez Claude Code dans un pane Herdr au niveau du checkout principal et donnez,
par exemple :

```text
Objective: <what you want, or "issue #<n>">.
Follow docs/agent-workflow.md. Mission id: <YYYY-MM-DD>-<slug>.
Authorizations: <none | commit | commit + push + draft PR>. Cluster: <none | context <name>, disposable>.
```

Claude Code crée `$MD`, copie l'objectif mot pour mot dans `prompt.md`, puis
déroule le [§3](#3-cycle-de-vie).

### 8.2 Reprise

1. Lisez `$MD/prompt.md`, puis `$MD/mission.md` (**State**, **Next action**,
   **Log**).
2. Revérifiez ce qu'affirme `mission.md` : `git worktree list`,
   `git -C "$W" status --short`, `git -C "$W" log --oneline origin/main..HEAD`,
   l'instantané du checkout principal, `herdr agent list`.
3. Reprenez à partir de **Next action** :
   - `reviews/review-N.md` existe et est plus récent que son brief → traitez-le
     (§5.5).
   - Reviewer actif et `working` → attendez ; ne renvoyez rien.
   - Reviewer disparu et aucun fichier de review → relancez Codex (§5.3) et
     envoyez le même brief.
   - La réalité contredit `mission.md` (commits inconnus, worktree modifié ou
     absent, instantané changé) → arrêtez-vous et demandez au propriétaire.
4. Ajoutez une ligne `resumed` au journal.

## 9. Clôture

1. Comparaison finale de l'instantané du checkout principal
   ([§3](#instantané-du-checkout-principal)).
2. Fermez les panes créés par cette mission, et uniquement ceux-là :
   `herdr pane close "$P"`.
3. Le worktree de review et `$MD` restent en place jusqu'à ce que le propriétaire
   approuve leur suppression (`git worktree remove "$RW"` supprime des fichiers).
4. Passez `mission.md` à `done` (ou `blocked`) avec l'état final, puis remettez
   `report.md` et la décision restante au propriétaire.

## 10. Modèles

Les modèles ci-dessous restent en anglais : ce sont les agents qui les
remplissent, et un script analyse certaines de leurs lignes.

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
## Environment probes (read-only, first brief of a Codex session)
- `echo "KUBECONFIG=${KUBECONFIG-unset}"` → expect /dev/null
- `env | grep -ciE 'token|secret|passw|key|credential'` → expect 0 (names counted, values never printed)
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
