# Harness Simplification and Verification Design

## Goal

Make the Harness smaller and more trustworthy by running its existing isolated behavior tests, removing a broken installer path, fixing Graphify watcher portability, and reducing duplicated guidance without expanding the Harness into an orchestration framework.

## Scope and Boundaries

This change covers the Harness repository's source validation, reproduction bootstrap, Graphify watcher adapters, documentation contracts, and instruction templates. It preserves the current ownership boundary: Native Codex owns execution, Superpowers owns generic engineering methodology, and adopted repositories own project facts and verification recipes.

The change will not install tools automatically, manage `~/.codex`, add a benchmark framework, add changed-file inference, run real platform services during tests, or introduce a new managed configuration format.

## Validation

`./scripts/validate` remains the single source-repository validation command. It will run all safe, isolated tests supported by the current host instead of checking most test files for syntax only.

On Unix hosts, validation will run the manifest, Bash core, documentation-contract, Graphify watcher, and validation-regression tests. PowerShell tests will run when `pwsh` is available; otherwise validation will report them as skipped with the reason. Platform service commands remain faked in temporary directories, so validation does not register or start real services.

The final output will distinguish executed behavior tests from syntax checks and permitted platform skips. Any executed test failure fails validation.

## Read-only Bootstrap

The reproduction bootstrap becomes a read-only wrapper around doctor on every platform. The Linux/macOS `--apply` option and Windows `-Apply` switch will be removed from the supported interface, and passing either will return the existing unsupported/invocation outcome rather than downloading or installing Codex.

Documentation will direct users to the official Codex installation instructions. Tests will assert that bootstrap performs only preflight checks and rejects the removed apply option. This resolves the current contradiction where bootstrap requires Codex to exist before attempting to install it.

## Graphify Watchers

The Linux service file will reference the exact environment file created beneath the resolved configuration root. Paths written into systemd configuration will use systemd-compatible escaping so spaces and special characters do not silently change the value.

Linux and macOS repository validation will use Git itself to accept both normal checkouts and linked worktrees, rather than requiring `.git` to be a directory. The Windows adapter will be checked for the same assumption and aligned if needed.

Tests will cover a non-default configuration root and a linked-worktree-style `.git` file without invoking a real service manager. Existing exact-target removal guarantees remain intact.

## Documentation Contracts

Documentation tests will retain only durable boundary assertions whose accidental removal would materially change the Harness. Long prose fragments will be replaced with shorter stable markers, headings, or behavior checks. Secret and machine-path scans remain because they validate objective repository properties.

`docs/architecture.md` will be the canonical ownership-boundary explanation. `docs/daily-usage.md` will be the canonical user-facing tool-selection guide. README and other guides will summarize their local purpose and link to those canonical pages instead of repeating detailed ownership and OMX guidance.

## Instruction Templates

The repository template will combine repeated consumer-impact guidance from Shared Dependencies, Verification Routing, and Cross-subsystem Impact into one verification-routing table and concise supporting prompts. The separate Cross-subsystem Impact section will be removed if all of its information is represented by the routing table.

The templates will explicitly tell adopters to delete unused optional sections and prompts. Generic methodology stays out of repository and subsystem files.

The global template keeps the approved subagent model-selection policy. Its existing uncommitted wording changes are preserved and will be validated as part of the final implementation.

## Global Template Synchronization

The adoption guide will include a short, read-only comparison procedure using `diff` between `templates/global/AGENTS.md` and `~/.codex/AGENTS.md`. The Harness will not overwrite or automatically validate the user-owned global file. During this implementation, the actual global file will be updated deliberately after the template is stable, preserving unrelated user content.

## Verification and Acceptance

The implementation is complete when:

- `./scripts/validate` executes all safe host-supported behavior tests and passes;
- missing or failing behavior tests cause validation to fail;
- bootstrap performs no installation or download and rejects apply flags;
- watcher tests cover custom configuration roots and linked worktrees;
- documentation contract tests no longer depend on long prose sentences;
- repository and documentation templates contain no duplicated ownership or cross-subsystem guidance identified in this design;
- the global template and the active global `AGENTS.md` match after deliberate synchronization; and
- `git diff --check` reports no whitespace errors.

No real service registration, tool installation, account access, or other stateful runtime evidence is part of acceptance.
