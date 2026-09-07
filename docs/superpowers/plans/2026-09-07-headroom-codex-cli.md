# Headroom for Codex CLI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add and evaluate an opt-in `codex-headroom` command for terminal Codex CLI without changing normal `codex`, the VS Code extension, repository files, or Codex credentials.

**Architecture:** Install Headroom once in a user-level `uv` tool environment. A small `codex-headroom` wrapper delegates to `headroom wrap codex --code-memory none --`, retains Headroom as a direct child, and owns interruption-safe Codex configuration backup/restoration. The supported command starts a loopback-only proxy for that one Codex session. The compatibility trial is performed once per user-selected Codex account and stops on the first routing, authentication, or fidelity failure.

**Tech Stack:** `uv`, `headroom-ai[proxy]`, Bash, Codex CLI, loopback HTTP.

**Spec:** `docs/superpowers/specs/2026-09-07-headroom-codex-cli-design.md`

## Global Constraints

- Do not modify the VS Code extension, existing `codex` executable, repository files, Git hooks, Graphify, or systemd services.
- Bind Headroom only to `127.0.0.1`; do not use `0.0.0.0` or a LAN address.
- Do not create, copy, print, or replace Codex/OpenAI credentials.
- Do not enable Headroom memory, learning, telemetry, request/response content logs, or an aggressive token mode in this trial.
- Use Headroom's documented `headroom wrap codex` integration; do not hand-write an OpenAI request-rewriting proxy configuration.
- Preserve and compare the pre-trial `~/.codex/config.toml` checksum. If Headroom changes it and does not restore it, stop and restore the exact backup before further work.
- Treat the active upstream reports of Codex wrapper model and WebSocket failures as a mandatory go/no-go gate, not as a reason to alter normal Codex routing.

## File Structure

- Create: `/home/obigo/.local/bin/codex-headroom` — opt-in Bash command that delegates to Headroom with code memory disabled and restores `config.toml` safely on normal exit or interruption.
- Create temporarily: `/tmp/headroom-codex-wrapper-test.sh` — hermetic wrapper contract test; remove after it passes.
- Create temporarily per wrapper invocation: a private `mktemp` backup matching `/tmp/headroom-codex-config.toml.XXXXXX`; remove only after the wrapper proves byte-identical restoration.
- Modify only through the supported tool during an active wrapper session: `/home/obigo/.codex/config.toml`, if the installed Headroom version uses temporary Codex provider injection. It must match the pre-trial backup after session exit.

## Task 1: Establish Headroom/Codex compatibility prerequisites

**Files:** User-level `uv` tool environment only.

**Interfaces:** Produces a known Headroom version and records whether its installed CLI exposes the supported Codex wrapper.

- [ ] **Step 1: Record the untouched Codex baseline**

Run:

```bash
command -v codex
codex --version
sha256sum /home/obigo/.codex/config.toml
ss -ltnp '( sport = :8787 )' || true
```

Expected: record the existing Codex executable/version and configuration digest; port 8787 is either unused or its listener is identified before continuing.

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

The command must invoke `headroom wrap codex --code-memory none --` and pass every user argument unchanged. It must create its own private configuration backup before starting Headroom and must not `exec` the Headroom command. Its normal target is `/home/obigo/.codex/config.toml`; `CODEX_HEADROOM_CONFIG` is a test-only override that permits the hermetic test to use a copied configuration.

- [ ] **Step 1: Write the failing hermetic wrapper test**

Create `/tmp/headroom-codex-wrapper-test.sh` with a temporary `PATH` containing a fake `headroom` executable that records its arguments. The test must run a copied `codex-headroom -- --version`, then assert the recording is exactly:

```text
wrap
codex
--code-memory
none
--
--version
```

The test must also assert `codex-headroom -- 'read only'` records the literal final argument `read only` without shell splitting. Its complete second recording must be:

```text
wrap
codex
--code-memory
none
--
read only
```

The hermetic test must additionally use `CODEX_HEADROOM_CONFIG` to point the
copied wrapper at a copied configuration, never the real user configuration.
Its fake Headroom child must record its PID, mutate that copied configuration,
and remain alive until the test signals the wrapper. Deliver `TERM` to the
wrapper while that direct child is live; assert the wrapper terminates and
waits for the child, the child PID is no longer live, and `cmp --silent` proves
the copied configuration equals its pre-launch copy. Finally, simulate a
restore failure (for example, with a fake `install` that permits the initial
backup but rejects backup-to-configuration restoration), assert the wrapper
exits nonzero, and assert the controlled private backup path remains. This
failure case must not delete the retained backup.

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

config=${CODEX_HEADROOM_CONFIG:-/home/obigo/.codex/config.toml}
[[ -f "$config" ]] || {
  printf '%s\n' "codex-headroom: missing config: $config" >&2
  exit 2
}
backup="$(mktemp /tmp/headroom-codex-config.toml.XXXXXX)"
child_pid=

chmod 600 "$backup"
install -m 600 "$config" "$backup"

cleanup() {
  local status=$?
  trap - EXIT
  trap '' HUP INT TERM

  if [[ -n "$child_pid" ]] && kill -0 "$child_pid" 2>/dev/null; then
    kill -TERM "$child_pid" 2>/dev/null || true
    wait "$child_pid" 2>/dev/null || true
  fi

  if ! cmp --silent "$config" "$backup"; then
    install -m 600 "$backup" "$config" || {
      printf '%s\n' "codex-headroom: restoration failed; retaining $backup" >&2
      exit 1
    }
  fi

  if ! cmp --silent "$config" "$backup"; then
    printf '%s\n' "codex-headroom: restoration could not be proven; retaining $backup" >&2
    exit 1
  fi
  sha256sum "$config" "$backup" || {
    printf '%s\n' "codex-headroom: checksum proof failed; retaining $backup" >&2
    exit 1
  }
  rm -f "$backup" || {
    printf '%s\n' "codex-headroom: could not remove proven backup: $backup" >&2
    exit 1
  }
  exit "$status"
}

trap cleanup EXIT
# Ignore catchable termination signals until the direct-child PID is captured.
trap '' HUP INT TERM
headroom wrap codex --code-memory none -- "$@" &
child_pid=$!
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
set +e
wait "$child_pid"
child_status=$?
set -e
exit "$child_status"
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

Expected: both argument cases pass, including `--code-memory none` before the argument separator. The signal test proves the fake child is stopped and the copied configuration is restored byte-for-byte. The failed-restoration test exits nonzero and retains its controlled private backup. The temporary test file and only the success-case backup are removed.

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

Expected: it returns `HEADROOM_SKILL_LOADED`; before launch, the wrapper creates its private backup, then starts only a loopback proxy and exits after restoring and proving the original Codex configuration. If the wrapper exits nonzero or retains a backup, stop; do not manually rewrite routing settings.

- [ ] **Step 3: Verify routing and wrapper restoration evidence**

Run after the proxied process exits:

```bash
ss -ltnp '( sport = :8787 )' || true
```

Expected: there is no non-loopback Headroom listener. The wrapper's cleanup must already have emitted both configuration checksums after a successful `cmp --silent` proof and removed its private backup. If it exits nonzero or retained its backup, stop; the wrapper—not Task 3—owns restoration and must be corrected before another trial.

## Task 4: Repeat the compatibility spike for the second account

**Interfaces:** Requires the user to switch the terminal Codex session to the second account before the probe.

- [ ] **Step 1: Pause for an explicit account-switch confirmation**

Ask the user to log the terminal Codex CLI into the second account and confirm that normal `codex --version` succeeds. Do not inspect account identities, credentials, or tokens.

- [ ] **Step 2: Repeat Tasks 3.1 through 3.3 exactly**

Run the same normal baseline, proxied `HEADROOM_SKILL_LOADED` probe, loopback check, and wrapper-owned byte-for-byte restoration proof.

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

Report the Headroom version, each account's pass/fail result, whether `config.toml` restoration was byte-identical, listener binding evidence, elapsed times, and any aggregate metric exposed without enabling content logs. Do not infer token savings when no aggregate metric is available.

- [ ] **Step 3: Do not promote the default command**

Leave `codex` and the VS Code extension unchanged. A future request may separately evaluate enabling local-only aggregate telemetry or promoting `codex-headroom` to a default alias after repeated successful real tasks.
