# AI Coding Harness

Personal AI Coding Harness is a small, versioned foundation for using Codex in real repositories. It makes project facts, safety boundaries, instruction hierarchy, and verification contracts explicit without replacing the tools that already do the work.

## What it owns

The Harness owns only durable, project-specific guidance:

- personal engineering rules in the Global `AGENTS.md` template;
- repository and subsystem `AGENTS.md` templates for architecture, constraints, risks, and compatibility facts;
- the project-owned `./scripts/verify <scope> <level>` contract and verification-routing rules; and
- source validation for this repository.

The full division of responsibility among Native Codex, Superpowers, this Harness, projects, and optional OMX is defined in [the architecture guide](docs/architecture.md). Reproduction utilities are explicit, user-invoked checks; they do not manage user configuration or install tools.

## Adopt it in a repository

1. Read [the adoption guide](docs/adoption.md), then copy or merge [`templates/global/AGENTS.md`](templates/global/AGENTS.md) into your normal global Codex guidance. It is a normal user-owned file, not managed by this repository.
2. In the target repository, create or carefully extend `AGENTS.md` from [`templates/repository/AGENTS.md`](templates/repository/AGENTS.md). Record verified facts; preserve useful existing instructions instead of replacing them.
3. Add a nearer `AGENTS.md` from [`templates/subsystem/AGENTS.md`](templates/subsystem/AGENTS.md) only where a subtree has distinct execution paths, contracts, or safety constraints.
4. Have the project define `./scripts/verify <scope> <level>` and its Verification Routing map. The project owns the implementation and actual checks.
5. Use normal, short Codex prompts in that repository. Codex reads the nearest applicable instructions and selects the project’s verification route.

Start by validating this source repository:

```text
./scripts/validate
```

## Share It With Another Engineer

For a complete manual adoption path, start with the [Portable Adoption Kit](docs/portable-adoption-kit.md). It preserves existing project instructions and deliberately leaves accounts, credentials, plugins, local trust, and optional project tools under their owners' control.

For a fresh Linux, macOS, or Windows workstation, use [the environment reproduction guide](docs/reproduce-environment.md) before adopting any target repository.

## Daily use

Most work starts with a natural-language request, such as “Add pagination to the orders endpoint and verify affected consumers.” Superpowers methodology is normally applied by Codex when it is useful; it is not another Harness command to memorize. Use [the daily usage guide](docs/daily-usage.md) for `/goal`, subagents, worktrees, review, `codex exec`, hooks, project verification, and optional OMX.

Returning after a pause or on a new machine? Start with [the re-entry guide](docs/returning-to-the-harness.md) before changing local configuration or copying templates.

## Read deeper

- [Adoption workflow](docs/adoption.md)
- [Portable Adoption Kit](docs/portable-adoption-kit.md)
- [Daily usage guide](docs/daily-usage.md)
- [Returning to the Harness](docs/returning-to-the-harness.md)
- [Reference environment and deliberate boundaries](docs/reference-environment.md)
- [Architecture and ownership boundary](docs/architecture.md)
- [Verification contract](docs/verification-contract.md)
- [Configuration ownership](docs/configuration.md)
- [Changelog](CHANGELOG.md)

The Harness stays intentionally small. Add shared artifacts only for durable gaps that its existing owners do not cover.
