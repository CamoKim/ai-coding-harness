# Headroom for Codex CLI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add and evaluate an opt-in `codex-headroom` command for terminal Codex CLI without changing normal `codex`, the VS Code extension, repository files, or Codex credentials.

**Architecture:** Install Headroom once in a user-level `uv` tool environment. A small `codex-headroom` wrapper delegates to `headroom wrap codex --no-mcp --code-memory none --`. `--no-mcp` prevents Headroom from registering its retrieve MCP and therefore leaves Codex configuration untouched. The supported command starts a loopback-only proxy for that one Codex session.

**Tech Stack:** `uv`, `headroom-ai[proxy]`, Bash, Codex CLI, loopback HTTP.

**Spec:** `docs/superpowers/specs/2026-09-07-headroom-codex-cli-design.md`

## Global Constraints

- Do not modify the VS Code extension, existing `codex` executable, repository files, Git hooks, Graphify, or systemd services.
- Bind Headroom only to `127.0.0.1`; do not use `0.0.0.0` or a LAN address.
- Do not create, copy, print, or replace Codex/OpenAI credentials.
- Do not enable Headroom memory, learning, telemetry, request/response content logs, or an aggressive token mode in this trial.
- Use Headroom's documented `headroom wrap codex` integration; do not hand-write an OpenAI request-rewriting proxy configuration.
- Require `--no-mcp` on every wrapped launch; do not read, modify, or back up `~/.codex/config.toml` in this trial.
- Treat the active upstream reports of Codex wrapper model and WebSocket failures as a mandatory go/no-go gate, not as a reason to alter normal Codex routing.

## File Structure

- Create: `/home/obigo/.local/bin/codex-headroom` — opt-in Bash command that delegates to Headroom with MCP registration and code memory disabled.
- Create temporarily: `/tmp/headroom-codex-wrapper-test.sh` — hermetic wrapper contract test; remove after it passes.

## Task 1: Establish Headroom/Codex compatibility prerequisites

**Files:** User-level `uv` tool environment only.

**Interfaces:** Produces a known Headroom version and records whether its installed CLI exposes the supported Codex wrapper.

- [ ] **Step 1: Record the untouched Codex baseline**

Run:

```bash
command -v codex
codex --version
ss -ltnp '( sport = :8787 )' || true
```

Expected: record the existing Codex executable/version; port 8787 is either unused or its listener is identified before continuing.

- [ ] **Step 2: Install Headroom in an isolated tool environment**

Run:

```bash
uv tool install "headroom-ai[proxy]"
headroom --version
headroom wrap codex --help
```

Expected: `headroom` is executable and its help names Codex as a supported `wrap` target. If installation fails, stop; do not alter Codex configuration manually.

- [ ] **Step 3: Verify the safe defaults before any Codex request**

Run:

```bash
headroom proxy --help
headroom wrap codex --help
```

Expected: confirm that the wrapper has no `--learn` argument supplied and the proxy default bind address is loopback. The implementer attests that this Task 1 run did not invoke a persistent installation command or start a proxy; these observations do not establish that no earlier session ever did so. Do not start `headroom proxy` manually in this task.

- [ ] **Step 4: Commit the design and plan only**

Run:

```bash
git add docs/superpowers/specs/2026-09-07-headroom-codex-cli-design.md docs/superpowers/plans/2026-09-07-headroom-codex-cli.md
git commit -m "docs: plan Headroom Codex CLI trial"
```

Expected: only Harness documentation is committed. The user-level tool installation is intentionally outside Git.

## Task 2: Provide an opt-in wrapper and prove its argument boundary

**Files:**
- Create: `/home/obigo/.local/bin/codex-headroom`
- Test: `/tmp/headroom-codex-wrapper-test.sh`

**Interfaces:**

```text
codex-headroom [codex arguments...]
```

The command must invoke `headroom wrap codex --no-mcp --code-memory none --` and pass every user argument unchanged. It must not read, write, back up, or restore Codex configuration.

- [ ] **Step 1: Write the failing hermetic wrapper test**

Create `/tmp/headroom-codex-wrapper-test.sh` with a temporary `PATH` containing a fake `headroom` executable that records its arguments. The test must run a copied `codex-headroom --version`, then assert the recording is exactly:

```text
wrap
codex
--no-mcp
--code-memory
none
--
--version
```

The test must also assert `codex-headroom -- 'read only'` records the literal final argument `read only` without shell splitting. Its complete second recording must be:

```text
wrap
codex
--no-mcp
--code-memory
none
--
read only
```

The hermetic test may pass `CODEX_HEADROOM_CONFIG` only as a sentinel copied
configuration. Its fake Headroom must not modify that file; `cmp --silent` must
prove the wrapper leaves it unchanged. The test must fail if `--no-mcp` is
missing, reordered after `--code-memory`, or user arguments are split.

- [ ] **Step 2: Prove the test fails before the wrapper exists**

Run:

```bash
bash /tmp/headroom-codex-wrapper-test.sh
```

Expected: failure because `/home/obigo/.local/bin/codex-headroom` does not exist.

- [ ] **Step 3: Implement the minimal wrapper**

Write `/home/obigo/.local/bin/codex-headroom`:

```bash
#!/usr/bin/env bash
set -euo pipefail

exec headroom wrap codex --no-mcp --code-memory none -- "$@"
```

Run:

```bash
chmod 700 /home/obigo/.local/bin/codex-headroom
```

- [ ] **Step 4: Verify the wrapper and remove its temporary test**

Run:

```bash
bash /tmp/headroom-codex-wrapper-test.sh
rm -f /tmp/headroom-codex-wrapper-test.sh
```

Expected: both argument cases pass, including `--no-mcp --code-memory none` before the argument separator, and the copied configuration sentinel is byte-identical. The temporary test file is removed.

## Task 3: Run the first-account read-only compatibility spike

**Interfaces:** Consumes `codex-headroom`; produces a pass/fail record only, not a persistent routing change.

- [ ] **Step 1: Capture the normal baseline**

Run from the Obigo repository root:

```bash
codex exec --ephemeral -s read-only --color never '$graphify. Do not inspect files or call tools. Reply with exactly: BASELINE_SKILL_LOADED if this skill is available; otherwise reply exactly: BASELINE_SKILL_UNAVAILABLE.'
```

Expected: the normal Codex invocation returns `BASELINE_SKILL_LOADED`. If the baseline fails, stop; Headroom cannot be evaluated against a broken baseline.

- [ ] **Step 2: Start the opt-in proxied probe**

Run from the same repository root:

```bash
codex-headroom exec --ephemeral -s read-only --color never '$graphify. Do not inspect files or call tools. Reply with exactly: HEADROOM_SKILL_LOADED if this skill is available; otherwise reply exactly: HEADROOM_SKILL_UNAVAILABLE.'
```

Expected: it returns `HEADROOM_SKILL_LOADED`; `--no-mcp` keeps Codex configuration untouched while the wrapper starts only a loopback proxy. If it exits nonzero, stop; do not manually rewrite routing settings.

- [ ] **Step 3: Verify routing evidence**

Run after the proxied process exits:

```bash
ss -ltnp '( sport = :8787 )' || true
```

Expected: there is no non-loopback Headroom listener. If the wrapper exits nonzero, stop before another trial.

## Task 4: Repeat the compatibility spike for the second account

**Interfaces:** Requires the user to switch the terminal Codex session to the second account before the probe.

- [ ] **Step 1: Pause for an explicit account-switch confirmation**

Ask the user to log the terminal Codex CLI into the second account and confirm that normal `codex --version` succeeds. Do not inspect account identities, credentials, or tokens.

- [ ] **Step 2: Repeat Tasks 3.1 through 3.3 exactly**

Run the same normal baseline, proxied `HEADROOM_SKILL_LOADED` probe, and loopback check.

Expected: the second account passes independently. A failure leaves normal `codex` usable and ends the rollout without promotion.

## Task 5: Report evidence and keep the route opt-in

**Files:** Modify: `docs/superpowers/specs/2026-09-07-headroom-codex-cli-design.md` only if measured results require an explicit factual addendum.

**Interfaces:** Keeps `codex` and the VS Code extension unchanged; `codex-headroom` remains the only Headroom entrypoint.

- [ ] **Step 1: Verify the final boundaries**

Run:

```bash
command -v codex
command -v codex-headroom
headroom --version
ss -ltnp '( sport = :8787 )' || true
git -C /home/obigo/바탕화면/ai-coding-harness status --short
git -C /home/obigo/바탕화면/github/obigo-data-pipeline status --short
```

Expected: normal `codex` still resolves independently of the wrapper, no Headroom listener remains after a wrapper session, and neither repository contains Headroom-induced changes.

- [ ] **Step 2: Report only verified trial evidence**

Report the Headroom version, each account's pass/fail result, listener binding evidence, elapsed times, and any aggregate metric exposed without enabling content logs. Do not infer token savings when no aggregate metric is available.

- [ ] **Step 3: Do not promote the default command**

Leave `codex` and the VS Code extension unchanged. A future request may separately evaluate enabling local-only aggregate telemetry or promoting `codex-headroom` to a default alias after repeated successful real tasks.
