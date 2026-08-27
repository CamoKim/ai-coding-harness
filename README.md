# AI Coding Harness

Personal AI Coding Harness v0.2 is a small, versioned foundation for Codex work across repositories. It owns durable safety instructions, change-aware verification routing contracts, optional privacy-safe telemetry hooks, and safe local operational commands. It does not own project build recipes or external runtime state.

## v0.2 scope

| Area | Status | Source of truth |
| --- | --- | --- |
| E2 Change-aware Verification Routing | Complete | [verification contract](docs/verification-contract.md) and repository template |
| E3 turn-level opt-in telemetry | Complete | [telemetry contract](docs/telemetry-contract.md) |
| H1–H3 operational commands | Complete | doctor, safe install/update, and safe uninstall contracts |
| H4 Behavioral Lab | Complete | [Behavioral Lab contract](docs/behavioral-lab-contract.md) |

The managed Global source is [`templates/global/AGENTS.md`](templates/global/AGENTS.md). Local installed files and telemetry data are never committed.

## Basic flow

Validate the Harness source first:

```text
./scripts/validate
```

Inspect the managed local installation, review the result, then apply only when explicitly intended:

```text
./scripts/harness-install --check
./scripts/harness-install --apply
./scripts/doctor
```

`--apply` changes only the three managed user-level artifacts after safe preflight. It never manages `config.toml`, hooks trust, telemetry consent, records, or transient telemetry state. See the [install contract](docs/install-contract.md) for states and exit codes.

Use the Behavioral Lab only for manual or semi-automated policy regression evidence; it never launches Codex itself:

```text
./scripts/behavioral-lab prepare shared-impact
# Run the printed prompt manually in the isolated workspace.
./scripts/behavioral-lab check <workspace>
```

The lab evaluates diff allowlists, fixture audit events, forbidden-event absence, and required manual attestation—not natural-language response strings. Synthetic lab evidence stays in its temporary workspace and must not enter E3 telemetry.

## Uninstall and telemetry

`./scripts/harness-uninstall --check` shows only manifest-proven artifacts that are removable. `--apply` is explicit and preserves `config.toml`, hooks trust, telemetry marker, records, transient state, and Harness directories. See the [uninstall contract](docs/uninstall-contract.md).

Telemetry is optional and turn-level. Only an explicit telemetry opt-in may create or repair `~/.codex/harness/telemetry/enabled`; only explicit opt-out may remove it. Neither install, uninstall, doctor, validation, nor Behavioral Lab changes telemetry consent or records. The [telemetry contract](docs/telemetry-contract.md) defines the privacy boundary.

`scripts/install-telemetry-hooks` is deprecated, makes no changes, and exits with guidance to use `./scripts/harness-install --check|--apply`.

## Not in v0.2

- E4 analysis based on accumulated real-work telemetry
- model or subagent routing, model-driven telemetry collection, and automatic Codex behavioral execution
- project-specific verification recipes, verify-auto frameworks, or runtime orchestration
- telemetry daemon, dashboard, database, or purge-data function
- CI, worktree orchestration, new agent framework, or external-service automation

See [CHANGELOG.md](CHANGELOG.md) for the release summary.
