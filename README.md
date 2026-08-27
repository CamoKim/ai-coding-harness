# AI Coding Harness

Personal AI Coding Harness v0.2 is a small, versioned foundation for Codex work across repositories. It owns durable safety instructions and change-aware verification routing contracts. It does not own project build recipes, user-level lifecycle tooling, or external runtime state.

## v0.2 scope

| Area | Status | Source of truth |
| --- | --- | --- |
| E2 Change-aware Verification Routing | Complete | [verification contract](docs/verification-contract.md) and repository template |

The Global source is [`templates/global/AGENTS.md`](templates/global/AGENTS.md). It is a normal user-level file, not a managed lifecycle artifact.

## Basic flow

Validate the Harness source first:

```text
./scripts/validate
```

## Not in v0.2

- project-specific verification recipes, verify-auto frameworks, or runtime orchestration
- user-level installers, manifests, hooks, telemetry, or operational lifecycle tools
- CI, worktree orchestration, new agent framework, or external-service automation

See [CHANGELOG.md](CHANGELOG.md) for the release summary.
