# Graphify Adoption Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Graphify the sole repository graph for `obigo-data-pipeline`, automatically refresh its code graph, and retire the bespoke graph after a verified cutover.

**Architecture:** One user-level `uv` Graphify installation serves all repositories. Each opted-in repository receives a project-scoped Codex integration and a separate `systemd --user` watcher. Team-useful graph artifacts are committed; caches and machine state are ignored.

**Tech Stack:** `uv`, `graphifyy`, Codex, Bash, `systemd --user`, Git.

**Spec:** `docs/superpowers/specs/2026-09-07-graphify-adoption-design.md`

## Global Constraints

- Install with `uv tool install "graphifyy[sql,watch]"`; do not use `pip`.
- Use a watcher, not Graphify Git hooks.
- Commit `graphify-out/graph.json`, `GRAPH_REPORT.md`, and `graph.html` when produced.
- Ignore `graphify-out/cache/`, `manifest.json`, `cost.json`, and `needs_update`.
- Project contracts and verification routing stay in `AGENTS.md`.
- No background semantic extraction may call a model or API unattended.
- Show exact targets and confirm Git state before destructive cleanup.

## Task 1: Install and audit Graphify

**Files:** User-level `uv` tool installation only.

**Interfaces:** Produces a `graphify` executable without project integration or hooks.

- [ ] **Step 1: Record the baseline**

Run:

```bash
git -C <target-repository> status --short
git -C <retired-graph-repository> status --short
```

Expected: no unrelated changes. If output exists, preserve those paths and exclude them from all staging and deletion.

- [ ] **Step 2: Install Graphify in an isolated tool environment**

Run:

```bash
uv tool install "graphifyy[sql,watch]"
uv tool update-shell
graphify --version
uv tool list
```

Expected: a Graphify version and `graphifyy` in the `uv` tool list. Use a new shell if the current shell has not reloaded its path.

- [ ] **Step 3: Confirm no hooks are installed**

Run:

```bash
graphify --help
graphify hook status
```

Expected: Graphify lists a watcher command and reports no installed Graphify hooks. Never run `graphify hook install`.

## Task 2: Build reusable watcher management

**Files:**
- Create: `<user-local-bin>/graphify-project`
- Create: `<user-config>/systemd/user/graphify-watch@.service`
- Test: `/tmp/graphify-project-test.sh`

**Interfaces:**

```text
graphify-project enable <project-id> <absolute-repository-path>
graphify-project disable <project-id>
graphify-project status <project-id>
```

- [ ] **Step 1: Write the failing hermetic contract test**

Create `/tmp/graphify-project-test.sh` with a temporary `HOME`, fake `graphify`, and fake `systemctl` placed first on `PATH`. Copy the helper under test there. Call `enable obigo-data-pipeline "$TEMP_REPO"`; assert that the environment file contains exactly `GRAPHIFY_PROJECT=$TEMP_REPO`, and logged systemctl calls are `--user daemon-reload` and `--user enable --now graphify-watch@obigo-data-pipeline.service`. Also assert that `../bad` fails without writing a file, `status` names the exact service, and `disable` deletes only this project's environment file and calls `disable --now` for it.

- [ ] **Step 2: Prove the test fails**

Run `bash /tmp/graphify-project-test.sh`.

Expected: failure because the helper does not exist.

- [ ] **Step 3: Create the service template**

Write `<user-config>/systemd/user/graphify-watch@.service`:

```ini
[Unit]
Description=Graphify watcher for %i
[Service]
Type=simple
EnvironmentFile=%h/.config/graphify/projects/%i.env
ExecStart=%h/.local/bin/graphify-project run %i
Restart=on-failure
RestartSec=5
[Install]
WantedBy=default.target
```

- [ ] **Step 4: Implement the helper**

Use Bash with `set -euo pipefail`, `CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/graphify/projects"`, and project ID validation `^[A-Za-z0-9][A-Za-z0-9_-]*$`.

`enable` resolves `cd -- "$path" && pwd -P`, requires `$repo/.git` and `command -v graphify`, atomically writes a mode-`0600` file containing only `GRAPHIFY_PROJECT=<resolved-path>`, then runs:

```bash
systemctl --user daemon-reload
systemctl --user enable --now "graphify-watch@$id.service"
```

`run` sources only its matching environment file, validates the target Git repository, and runs `exec graphify watch "$GRAPHIFY_PROJECT"`. `disable` runs `systemctl --user disable --now "graphify-watch@$id.service"`, removes only its matching environment file, then daemon-reloads. `status` runs `systemctl --user status --no-pager "graphify-watch@$id.service"`.

- [ ] **Step 5: Verify and clean the test**

Run:

```bash
chmod 700 <user-local-bin>/graphify-project
bash /tmp/graphify-project-test.sh
systemd-analyze --user verify <user-config>/systemd/user/graphify-watch@.service
rm -f /tmp/graphify-project-test.sh
```

Expected: the test passes, the unit parses, and the temporary test is removed.

## Task 3: Adopt Graphify in Obigo

**Files:**
- Modify: `AGENTS.md`, `.gitignore`
- Create: `graphify-out/graph.json`, `graphify-out/GRAPH_REPORT.md`, and `graphify-out/graph.html` if emitted.

**Interfaces:** Project-scoped Codex integration; committed shared graph artifacts; ignored local Graphify state.

- [ ] **Step 1: Register the Codex integration**

From the Obigo repository root, run:

```bash
graphify codex install --project
git diff -- AGENTS.md .codex .agents .gitignore
```

Expected: only Graphify-related guidance or metadata is new. Preserve existing instructions and remove only installer-created unrelated hunks if any occur.

- [ ] **Step 2: Replace bespoke graph guidance**

Replace `## Local Repository Graph` in `AGENTS.md` with:

```markdown
## Graphify Repository Graph

- For ambiguous or cross-cutting work, query Graphify before broad raw-file search; skip it for known one-file work.
- Treat `EXTRACTED` edges as source-derived and `INFERRED` or `AMBIGUOUS` edges as candidates requiring source inspection.
- Graphify does not replace existing compatibility, consumer-review, or `./scripts/verify <scope> <level>` routing rules.
- If `graphify-out/needs_update` exists and the task relies on changed docs, PDFs, or images, refresh it before relying on those graph facts; never start unattended semantic extraction.
```

- [ ] **Step 3: Apply the shared artifact policy**

Remove `.codex/repo-graph/index.json` and `.codex/repo-graph/.index.json.*.tmp` from `.gitignore`. Add:

```text
# Local Graphify cache and machine-specific state
graphify-out/cache/
graphify-out/manifest.json
graphify-out/cost.json
graphify-out/needs_update
graphify-out/.graphify_root
graphify-out/.graphify_python
graphify-out/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/
```

- [ ] **Step 4: Build and query the initial graph**

In a new Codex thread at the project root, submit `$graphify .`. Then run:

```bash
graphify query "Which consumers and verification paths are relevant to libs/obigo_road_match_core?" --graph graphify-out/graph.json
git status --short
```

Expected: `graph.json` and `GRAPH_REPORT.md` exist; `graph.html` is included only if generated; the query returns cited scoped data; ignored local state does not appear in Git status.

- [ ] **Step 5: Commit reviewed portable changes**

Stage `AGENTS.md`, `.gitignore`, the two required Graphify artifacts, optional `graph.html`, and reviewed Graphify integration files under `.codex` or `.agents`. Run `git diff --cached --check`, then commit:

```text
feat: adopt Graphify repository graph
```

Expected: cache, manifest, cost, and marker files are not staged.

## Task 4: Enable automatic code-graph refresh

**Files:** Create `<user-config>/graphify/projects/obigo-data-pipeline.env` through the helper.

- [ ] **Step 1: Enable and inspect the watcher**

Run:

```bash
graphify-project enable obigo-data-pipeline <target-repository>
graphify-project status obigo-data-pipeline
```

Expected: service status is `active (running)`; the environment file mode is `0600`.

- [ ] **Step 2: Verify isolation and absence of hooks**

Run:

```bash
systemctl --user cat graphify-watch@obigo-data-pipeline.service
graphify hook status
git config --global --get core.hooksPath || true
```

Expected: only this repository has a watcher and Graphify has no hooks.

- [ ] **Step 3: Run a controlled watcher probe**

Run:

```bash
probe=onprem/src/obigo_onprem/graphify_watcher_probe.py
printf 'def graphify_watcher_probe() -> None:\n    pass\n' > "$probe"
sleep 5  # debounce only; allow the rebuild itself to finish before inspecting logs
journalctl --user -u graphify-watch@obigo-data-pipeline.service --since '10 minutes ago' --no-pager
rm -f "$probe"
sleep 5  # debounce only; wait for the removal rebuild to complete
```

Expected: logs show rebuilds after creation and removal; Git status does not list the removed probe. The probe must be non-hidden and not ignored because Graphify's watcher skips hidden and Git-ignored paths. Restart once with `systemctl --user restart graphify-watch@obigo-data-pipeline.service` and confirm it returns active.

- [ ] **Step 4: Commit watcher changes only when nonempty**

Stage only changed shared graph artifacts. If `git diff --cached --quiet` is false, commit `chore: refresh Graphify repository graph`; otherwise create no commit.

## Task 5: Retire bespoke graph implementation

**Files:**
- Delete in Obigo: `scripts/repository-graph`, `.codex/repo-graph.yml`, `.codex/repo-graph-evaluation.yml`, `tests/repository_graph/test_repository_graph_cli.sh`, `docs/repository-graph-evaluation.md`, and the 2026-09-01 wrapper design/plan.
- Retire: `<retired-graph-repository>`.
- Delete in Harness: the 2026-09-01 bespoke graph design and plan.

- [ ] **Step 1: Reconfirm exact targets and obtain deletion approval**

Run Git status in both repositories and list only the declared targets with `find`. Show those paths to the user. Do not delete if either repository has unrelated changes.

- [ ] **Step 2: Delete only confirmed Obigo paths**

After approval, remove only listed paths, run `test -f road-platform/sql/011_link_graph.sql`, stage with `git add -u`, run `git diff --cached --check`, and commit `refactor: retire bespoke repository graph`.

Expected: the domain SQL file remains; staging contains only approved deletions.

- [ ] **Step 3: Archive the standalone graph repository**

After approval, run:

```bash
mv <retired-graph-repository> <retired-graph-repository>.retired-2026-09-07
```

Expected: Graphify has no active sibling dependency; reverse the move to recover it. Retain the archive until one ordinary Graphify-supported task completes.

- [ ] **Step 4: Delete obsolete Harness documents**

After approval, delete the 2026-09-01 bespoke graph spec and plan, stage with `git add -u docs/superpowers`, run `git diff --cached --check`, and commit `docs: retire bespoke repository graph plan`.

Expected: this Graphify design and plan remain.

## Task 6: Final verification and future-project setup

- [ ] **Step 1: Verify active Graphify state**

Run `graphify --version`, `graphify-project status obigo-data-pipeline`, `git ls-files graphify-out/graph.json graphify-out/GRAPH_REPORT.md graphify-out/graph.html`, and `git check-ignore -v graphify-out/cache/probe graphify-out/manifest.json graphify-out/cost.json graphify-out/needs_update` from Obigo.

Expected: Graphify and watcher are active, shared artifacts are tracked, and all local-state probes are ignored.

- [ ] **Step 2: Verify obsolete active paths are gone**

Run `test ! -e scripts/repository-graph`, `test ! -e .codex/repo-graph.yml`, and `test ! -e <retired-graph-repository>`.

Expected: Graphify is the sole active graph route.

- [ ] **Step 3: Set up a future repository**

Run `graphify codex install --project` in its root; create the graph with `$graphify .` in a new Codex thread; then run `graphify-project enable <project-id> "$(pwd -P)"`.

Expected: each future repository gets its own Codex guidance and watcher without altering Obigo configuration.
