# Cross-Platform Core Baseline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reproduce and verify the safe Harness core on Linux, macOS, and Windows without copying user-owned Codex state.

**Architecture:** Keep the component contract in one portable manifest. Provide Bash adapters for Linux/macOS and PowerShell adapters for Windows; all default to read-only preflight and require `--apply` for any installation. Separate doctor commands report automatable state and manual account/authorization actions.

**Tech Stack:** POSIX shell, PowerShell, Git, Markdown.

**Spec:** `docs/superpowers/specs/2026-09-08-cross-platform-reproduction-design.md`

## Global Constraints

- Support Linux, macOS, and Windows, but never infer an unsupported package manager.
- Default mode is read-only; `--apply` is the only installation mode.
- Never read, copy, overwrite, export, or commit accounts, credentials, trust, existing `AGENTS.md`, `config.toml`, paths, or connector state.
- `core` is the default component; Graphify watcher setup is outside this plan.
- Doctor output uses only `READY`, `MISSING`, `MANUAL`, and `UNSUPPORTED`; exit codes are `0`, `1`, and `2` as specified.

---

### Task 1: Add the portable component contract and structural validation

**Files:**

- Create: `reproduction/manifest.env`
- Create: `tests/reproduction/test_manifest.sh`
- Modify: `scripts/validate`

**Interfaces:**

- Produces variables `HARNESS_CORE_COMMANDS`, `HARNESS_OPTIONAL_COMPONENTS`, and `HARNESS_SUPPORTED_PLATFORMS` for every adapter.
- The manifest contains only `KEY=value` lines with no executable substitutions, secrets, or local paths.

- [ ] Write `tests/reproduction/test_manifest.sh` so a malformed key or a missing required key fails.
- [ ] Run `tests/reproduction/test_manifest.sh` before creating the manifest and confirm it fails because the file is missing.
- [ ] Create `manifest.env` with `HARNESS_CORE_COMMANDS=git,codex`, `HARNESS_OPTIONAL_COMPONENTS=graphify`, and `HARNESS_SUPPORTED_PLATFORMS=linux,macos,windows`.
- [ ] Make `scripts/validate` require the manifest, reproduction documentation, Bash scripts, and PowerShell scripts; check shell syntax and reject unsafe manifest characters.
- [ ] Run the manifest test and `./scripts/validate`; expect both to pass.

### Task 2: Implement the Linux and macOS Bash bootstrap and doctor contract

**Files:**

- Create: `reproduction/lib/common.sh`
- Create: `reproduction/bootstrap.sh`
- Create: `reproduction/doctor.sh`
- Create: `reproduction/lib/linux.sh`
- Create: `reproduction/lib/macos.sh`
- Create: `tests/reproduction/test_bash_core.sh`

**Interfaces:**

- `bootstrap.sh [--apply] [--component core]` prints preflight state and exits `0`, `1`, or `2`.
- `doctor.sh [--component core]` prints `STATE component detail` lines and never changes state.
- `common.sh` provides `emit`, `command_state`, `parse_component`, and `require_apply`.

- [ ] Write fake-command tests proving preflight does not invoke an installer, a missing command is `MISSING`, unsupported OS/package-manager is `UNSUPPORTED` with exit `2`, and `--apply` is required before an installer adapter runs.
- [ ] Run the Bash tests and confirm they fail because the entry points do not exist.
- [ ] Implement manifest loading with strict keys, component parsing, state emission, OS detection, and no interactive side effects in default mode.
- [ ] Add Linux and macOS adapters that recognize only explicitly supported package managers and print planned installation commands before `--apply` invokes them.
- [ ] Implement doctor checks for Git, Codex, Harness validation, Superpowers plugin presence when queryable, and manual Codex login/authorization guidance without inspecting credentials.
- [ ] Re-run Bash tests and `sh -n` on every Bash source; expect pass.

### Task 3: Implement the Windows PowerShell bootstrap and doctor contract

**Files:**

- Create: `reproduction/lib/common.ps1`
- Create: `reproduction/bootstrap.ps1`
- Create: `reproduction/doctor.ps1`
- Create: `reproduction/lib/windows.ps1`
- Create: `tests/reproduction/test_powershell_core.ps1`

**Interfaces:**

- `bootstrap.ps1 [-Apply] [-Component core]` is behaviorally equivalent to Bash bootstrap.
- `doctor.ps1 [-Component core]` emits the same states and exit-code meanings as Bash doctor.

- [ ] Write PowerShell tests with fake `git`, `codex`, and package-manager commands proving no installation occurs without `-Apply` and unsupported package managers return exit `2`.
- [ ] Run the tests and confirm they fail because the entry points do not exist.
- [ ] Implement strict manifest parsing, component validation, state emission, and command discovery in `common.ps1`.
- [ ] Add the Windows adapter for explicitly supported package managers only; print planned commands and invoke them only under `-Apply`.
- [ ] Implement doctor checks matching Task 2, including manual login/authorization status without inspecting credentials.
- [ ] Run the PowerShell tests in PowerShell 7 and static syntax checks where available; expect pass.

### Task 4: Document and prove the user journey

**Files:**

- Create: `docs/reproduce-environment.md`
- Modify: `README.md`
- Modify: `docs/reference-environment.md`
- Test: `tests/reproduction/test_documentation.sh`

**Interfaces:**

- The documentation names the same `core`, `graphify`, `all`, `READY`, `MISSING`, `MANUAL`, and `UNSUPPORTED` contract as the scripts.
- It directs users to official Codex setup for login and plugins rather than encoding credentials.

- [ ] Write a documentation test that fails if the reproduction guide, all three supported platforms, default preflight, `--apply`, doctor states, or the manual-authentication boundary is absent.
- [ ] Run it and confirm it fails before the guide exists.
- [ ] Write the guide with platform prerequisites, preflight/apply/doctor commands, interpretation of every state, manual login/plugin/trust steps, safe cleanup, Graphify deferral, and fresh-machine acceptance procedure.
- [ ] Link the guide from README and reference environment, preserving the distinction between portable workflow and user-owned local state.
- [ ] Run documentation, manifest, Bash, PowerShell where available, and Harness validation; expect pass or clearly report platform-unavailable checks.

### Task 5: Final contract verification

**Files:**

- Modify: `docs/superpowers/plans/2026-09-08-cross-platform-core-baseline.md`

- [ ] Run `git diff --check`, `./scripts/validate`, manifest and Bash tests, and available PowerShell tests.
- [ ] In a temporary copy, remove `manifest.env` and confirm source validation names it as missing.
- [ ] In a temporary copy, add an unsafe manifest value and confirm validation rejects it.
- [ ] Mark completed steps, review the final diff for paths, credentials, account names, and unintended configuration writes.
- [ ] Commit the Core Baseline with `feat: add cross-platform reproduction core`.

## Plan Self-Review

- Spec coverage: Tasks 1-3 implement the manifest, OS adapters, read-only default, apply gate, doctor states, and no-secret boundaries. Task 4 implements the user path and manual-action boundary. Task 5 verifies both positive and negative contracts.
- Scope boundary: Graphify watcher adapters are intentionally excluded and require a separate plan after Core Baseline verification.
- Interface consistency: every task uses the same component names, states, exit meanings, and manifest keys.
