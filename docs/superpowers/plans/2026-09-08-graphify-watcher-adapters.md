# Graphify Watcher Adapters Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add project-scoped, removable Graphify watcher adapters for Linux, macOS, and Windows without configuring any repository by default.

**Architecture:** A single argument contract validates an explicit project identifier and Git repository path. Platform adapters create only their matching systemd user unit, launchd user agent, or Task Scheduler task; status and remove target that same identifier only.

**Tech Stack:** Bash, PowerShell, systemd, launchd, Task Scheduler.

**Spec:** `docs/superpowers/specs/2026-09-08-cross-platform-reproduction-design.md`

## Global Constraints

- Never enable a watcher unless the caller provides both a repository path and a safe project identifier.
- Accept only identifiers matching `^[A-Za-z0-9][A-Za-z0-9_-]*$`.
- Validate that the path is a Git repository and that Graphify is available before registration.
- `status` and `remove` operate on exactly one named watcher; no wildcard deletion.
- Linux uses a systemd user service, macOS a launchd user agent, and Windows a Task Scheduler task.

---

### Task 1: Shared validation and Linux adapter

**Files:**

- Create: `reproduction/graphify-watch/linux.sh`
- Create: `tests/reproduction/test_graphify_watch_linux.sh`

- [ ] Write a fake `systemctl`, `graphify`, and Git repository test proving an invalid identifier, a non-Git path, or missing Graphify creates no service entry.
- [ ] Run the test before implementation and confirm it fails because `linux.sh` is absent.
- [ ] Implement `enable <id> <repository>`, `status <id>`, and `remove <id>`; create an exact per-id environment file and user unit, call only `systemctl --user` for that unit, and remove only its files.
- [ ] Run fake-command tests for enable/status/remove and confirm exact service targeting.

### Task 2: macOS and Windows adapters

**Files:**

- Create: `reproduction/graphify-watch/macos.sh`
- Create: `reproduction/graphify-watch/windows.ps1`
- Create: `tests/reproduction/test_graphify_watch_windows.ps1`

- [ ] Add macOS launchd enable/status/remove with the same identifier and Git validation contract.
- [ ] Add Windows Task Scheduler enable/status/remove with the same contract and no broad task deletion.
- [ ] Write fake-command tests for each adapter's exact service/task name and removal target.
- [ ] Run macOS and Windows tests on their native platforms; record unavailable native execution as a human acceptance checkpoint.

### Task 3: Documentation and contract verification

**Files:**

- Modify: `docs/reproduce-environment.md`
- Modify: `scripts/validate`
- Modify: `tests/reproduction/test_bash_core.sh`

- [ ] Document that Graphify watcher activation is a project-specific, stateful operation requiring an explicit user command and repository path.
- [ ] Add every adapter to source validation and test that a missing adapter is rejected.
- [ ] Run Bash tests, Harness validation, diff checks, and native-platform tests where available.
- [ ] Commit with `feat: add Graphify watcher adapters`.

## Plan Self-Review

- The plan covers creation, status, removal, exact targeting, and platform-specific service ownership.
- It deliberately defers actual activation until a human supplies a project and approves the stateful service registration.
