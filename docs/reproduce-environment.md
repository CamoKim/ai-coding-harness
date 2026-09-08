# Reproduce the Environment

## Scope

This guide recreates the portable Harness baseline on Linux, macOS, or Windows. It does not transfer a Codex account, credentials, plugin authorization, connector authorization, trust decisions, project paths, `AGENTS.md`, or `config.toml`.

The reproduction utilities inspect portable prerequisites and help reconstruct the documented environment. They are explicit, user-invoked aids, not runtime management, self-healing doctor tooling, or unattended installation.

## Core Preflight

Clone this repository, then run the platform entry point without an apply flag:

```text
Linux or macOS: ./reproduction/bootstrap.sh --component core
Windows:        .\reproduction\bootstrap.ps1 -Component core
```

Preflight is read-only. `READY` means an automatable component is present, `MISSING` means it must be installed, `MANUAL` names a user-owned action, and `UNSUPPORTED` means the platform or request is outside this release. Exit `0` means selected automatable checks are ready, `1` means a required check is missing, and `2` means unsupported.

## Install and Authenticate Codex

Use the official Codex CLI installation path for your platform. The official macOS/Linux standalone installer is:

```text
curl -fsSL https://chatgpt.com/codex/install.sh | sh
```

On Windows, use the official Codex installation instructions for the supported Windows route. After installation, open a project directory and run `codex`; complete the account sign-in method shown by Codex yourself. Never place account material in this repository.

Rerun doctor after login:

```text
Linux or macOS: ./reproduction/doctor.sh --component core
Windows:        .\reproduction\doctor.ps1 -Component core
```

Doctor intentionally leaves login as `MANUAL`; it proves tool presence, not account authorization.

## Superpowers

In Codex CLI, enter `/plugins`, install Superpowers from an approved marketplace, and begin a new Codex session before using its skills. Review any plugin hook or connector authorization before enabling it. Plugin availability and authorization remain account-owned.

## Harness Adoption

After core doctor output is satisfactory, use the [Portable Adoption Kit](portable-adoption-kit.md) for each target repository. It merges instructions rather than overwriting them and leaves project build and verification commands under the project owner.

## Deferred Optional Capability

Graphify and its watcher are deliberately separate from the core baseline. Add them only to a repository with a proven broad-exploration need. Its project-specific watcher setup is not part of core bootstrap and must not be inferred from a repository path.

### Project-Scoped Graphify Watchers

The watcher adapters are deliberately not run by bootstrap or doctor. `enable` is stateful: it writes one named platform-service configuration and starts or schedules that named watcher. Use one only after Graphify is installed and only with an explicit Git repository path:

```text
Linux:   ./reproduction/graphify-watch/linux.sh enable <project-id> <repository-path>
         ./reproduction/graphify-watch/linux.sh status <project-id>
         ./reproduction/graphify-watch/linux.sh remove <project-id>

macOS:   ./reproduction/graphify-watch/macos.sh enable <project-id> <repository-path>
         ./reproduction/graphify-watch/macos.sh status <project-id>
         ./reproduction/graphify-watch/macos.sh remove <project-id>

Windows: .\reproduction\graphify-watch\windows.ps1 enable <project-id> <repository-path>
         .\reproduction\graphify-watch\windows.ps1 status <project-id>
         .\reproduction\graphify-watch\windows.ps1 remove <project-id>
```

`project-id` must contain only letters, numbers, `_`, and `-`. It identifies exactly one platform object: `graphify-watch@<project-id>.service` (Linux), `com.graphify.watch.<project-id>.plist` (macOS), or `Graphify-Watch-<project-id>` (Windows). `remove` affects only that named object and its matching project configuration; it never discovers, changes, or removes other watcher registrations. The first real `enable` is a human acceptance checkpoint because it registers a persistent service or scheduled task for a chosen repository.

The adapters resolve and store the installed Graphify executable path when they enable a watcher, so the service does not depend on an interactive shell `PATH` after a reboot. A watcher is the recommended one-per-repository default when graph output should follow ordinary file saves: it rebuilds code changes after a short debounce. Document, image, and other semantic inputs still set `graphify-out/needs_update`; they require an explicit semantic update because that work can use an LLM.

The project-scoped watcher is the only supported automatic Graphify refresh path. Do not install Graphify Git hooks: Codex commonly makes several uncommitted edits before a commit, and the watcher keeps the graph current throughout that workflow.

## Fresh-Machine Acceptance

For each operating system, a human must verify a fresh environment: run preflight, install Codex through its official route, complete login, install Superpowers, run doctor, and adopt the Harness in a disposable Git repository. On Windows, run `tests/reproduction/test_powershell_core.ps1` in PowerShell 7. Record only command outcomes; never record account identifiers or authorization data.
