# Configuration Ownership

## Principle

The Harness manages only portable, explicitly adopted configuration. It does not own or replace a user's complete `~/.codex/config.toml`.

Global `AGENTS.md` is the v0.1 priority because it is a stable, portable statement of personal engineering rules. A managed-key strategy for `config.toml` may be added later after the portable keys and update behavior are proven.

## Portable Configuration

A setting is eligible for Harness management only when it:

- is useful across repositories and machines;
- contains no secret, credential, account identifier, or private endpoint;
- contains no machine-specific absolute path;
- can be updated without replacing unrelated user configuration;
- has an explicit owner and documented default.

Examples may include deliberately chosen personal defaults for approval, sandbox, or supported features. No such keys are managed by Build Batch 1.

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

## Future Managed-Key Contract

A future configuration tool should operate in this order:

1. identify an explicit allowlist of Harness-owned keys;
2. compare desired and installed values without exposing secrets;
3. show a dry-run diff;
4. back up the existing file;
5. update only the allowlisted keys;
6. parse and validate the result;
7. preserve a clear recovery path.

It must not replace the complete user configuration, infer ownership from key names, or copy project trust and plugin state into this repository.

Build Batch 1 intentionally documents this boundary without creating a `config.toml` template or merge implementation.
