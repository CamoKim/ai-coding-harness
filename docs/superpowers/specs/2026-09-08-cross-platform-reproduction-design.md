# Cross-Platform Reproduction Design

## Goal

Let another engineer reproduce the supported Harness baseline on Linux, macOS,
or Windows: common tooling, documented optional capabilities, and an
evidence-producing readiness check. Authentication, authorization, trust, and
project-specific adoption remain explicit user actions.

## Scope

The reproducible baseline includes Git, Codex CLI, the Superpowers plugin,
this Harness checkout, and an optional Graphify capability. It supplies a
common manifest, OS-specific bootstrap adapters, and a doctor command that
reports ready, missing, unsupported, or manual-action-required components.

Linux uses Bash and systemd user services; macOS uses Bash and launchd; Windows
uses PowerShell and Task Scheduler for the optional Graphify watcher. The
watcher is never enabled unless a user explicitly requests the optional
Graphify project setup.

## Explicit Non-Goals

The reproduction workflow must not copy or modify another person's Codex
account, credentials, API keys, plugin authorization, connector authorization,
trust entries, project paths, existing `AGENTS.md`, or `config.toml`. It does
not install Graphify by default, configure a target repository, or create a
watcher without an explicit project-scoped request.

The workflow does not claim that a successful doctor result proves a user is
authenticated. It reports login and authorization as manual checks because
their proof must remain user-controlled.

## Components

| Component | Responsibility |
| --- | --- |
| `reproduction/manifest.*` | Versioned, portable declaration of required and optional components, supported platforms, and minimum verification expectations. It contains no secrets or local paths. |
| `reproduction/bootstrap.sh` | Dispatches Linux or macOS read-only preflight by default; with `--apply`, invokes the matching installer adapter after confirmation. |
| `reproduction/bootstrap.ps1` | Windows equivalent with the same modes and component names. |
| OS installer adapters | Install only a missing, manifest-declared prerequisite through the OS's standard package manager or official installer route. They never overwrite Codex configuration. |
| `reproduction/doctor.sh` and `reproduction/doctor.ps1` | Check component presence, version commands, Harness source validation, and optional Graphify project state. They only inspect. |
| `reproduction/graphify-watch/` adapters | Explicit, project-scoped Linux systemd, macOS launchd, and Windows Task Scheduler setup/status/remove helpers. |
| `docs/reproduce-environment.md` | Human path for prerequisites, command use, manual login/authorization, failure interpretation, and safe cleanup. |

## Shared Command Contract

Every bootstrap and doctor entry point accepts the same component names:

```text
core       Git, Codex CLI, Superpowers plugin, Harness checkout validation
graphify   optional Graphify CLI and one project-scoped watcher
all        core plus only explicitly selected optional components
```

Default bootstrap mode is preflight and makes no changes. `--apply` is required
for an installation. `--component core` is the default; Graphify additionally
requires a user-supplied repository path and project identifier. A command must
fail rather than infer a package manager, repository path, account, or project
identifier it cannot verify.

Each doctor result is line-oriented and has one of four states: `READY`,
`MISSING`, `MANUAL`, or `UNSUPPORTED`. Exit code `0` means all selected
automatable checks are ready; `1` means missing or failed checks; `2` means an
unsupported platform, package manager, or request. A `MANUAL` line does not
automatically make the command fail; it identifies a required human action.

## Installation and Data Flow

```text
User chooses platform, components, and --apply
    ↓
platform bootstrap validates OS and package manager
    ↓
adapter installs only missing declared prerequisites
    ↓
doctor inspects commands, plugin availability, and Harness validation
    ↓
user completes Codex login, account selection, trust, and connector authorization
    ↓
optional Graphify helper configures one named project watcher
```

An adapter must prefer an already installed compatible tool. It prints the
planned command before any installation, stops on a failed command, and never
stores authentication material. Re-running an adapter must be idempotent: it
does not duplicate a plugin or a service registration.

## OS-Specific Boundaries

| Capability | Linux | macOS | Windows |
| --- | --- | --- | --- |
| Core bootstrap | Bash, supported package-manager adapter | Bash, supported package-manager adapter | PowerShell, supported package-manager adapter |
| Optional watcher owner | systemd user service | launchd user agent | Task Scheduler task |
| Watcher identity | project identifier | project identifier | project identifier |
| Local account/config | untouched | untouched | untouched |

Each OS adapter must reject unsupported package managers rather than attempt a
generic or privileged installation. Service registration must name only the
given project identifier and support a matching status and removal operation.

## Error Handling and Safety

- A missing tool reports `MISSING` and an actionable official setup link or
  package-manager instruction; it is installed only under `--apply`.
- An unsupported operating system or package manager reports `UNSUPPORTED` and
  exits `2` without changes.
- A partially completed installation stops at the failing component and leaves
  prior independent installations intact; rerun is safe.
- A user must complete Codex login, account selection, plugin authorization,
  trust, and connector authorization separately. The scripts never inspect or
  export secrets to determine them.
- Graphify watcher setup validates a Git repository and a safe project
  identifier before creating a platform service entry. Removal targets only the
  exact named project entry.

## Verification

Unit-level shell and PowerShell tests use fake package-manager, Codex, Git,
Graphify, and service-manager commands to prove dry-run behavior, `--apply`
gating, component selection, idempotence, and exact service targeting. A
portable validation script checks manifest shape, executable syntax, required
documentation, and absence of paths or secret-like values.

Platform acceptance uses a fresh Linux, macOS, and Windows environment. For
each platform, run core preflight, apply core installation with user approval,
complete manual Codex login, run doctor, and perform a normal Harness
adoption in a disposable Git repository. Separately verify Graphify only on a
user-selected project and confirm that watcher status and removal affect no
other project.

## Success Criteria

On each supported OS, a new user can follow one documented path, apply only
the core baseline they approve, complete manual authentication without sharing
credentials, and receive a doctor result that distinguishes installed tooling
from required human actions. Optional Graphify can then be added and removed
for exactly one project without changing other repositories or global Codex
configuration.
