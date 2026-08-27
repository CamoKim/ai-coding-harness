# Configuration Ownership

## Principle

The Harness does not manage a user's Codex configuration. The Global `AGENTS.md` template is a normal user-level file; `config.toml`, hooks, trust, plugins, and connectors remain user-owned.

## Portable Configuration

The Harness provides no managed configuration format or lifecycle tooling.

## Local Configuration

The following remain local unless a later design explicitly provides a safe representation:

- machine-specific paths and environment details;
- project trust entries and repository locations;
- enabled plugin state and connector authorization;
- MCP server endpoints, credentials, and authentication state;
- API keys, tokens, certificates, and other secrets;
- account-, organization-, or machine-specific overrides.

Project-scoped `.codex/config.toml` files belong to their trusted projects, not to the Personal Harness. A project is responsible for documenting and reviewing any configuration it commits.

## Secrets and Paths

Secrets must never be committed to Harness templates or documentation. Templates may name an environment variable but must not contain its value. Portable artifacts must not embed home-directory paths, usernames, worktree locations, or paths to adopted repositories.

Examples should use neutral placeholders such as `<repository>` and `<subsystem>`.
