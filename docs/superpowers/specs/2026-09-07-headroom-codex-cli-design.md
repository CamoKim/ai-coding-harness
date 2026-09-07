# Headroom for Codex CLI — Design

## Goal

Add an opt-in Headroom route for terminal-launched Codex CLI sessions, so the
user can measure context optimization without changing the default `codex`
path or the VS Code extension.

## Scope

The first rollout covers the current Linux user, terminal Codex CLI, and both
of the user's Codex accounts. It is an observability-and-compatibility trial,
not a default replacement.

It does not change:

- the VS Code Codex extension;
- repository files or Git hooks;
- the existing `codex` command;
- Graphify's watcher, service, or artifacts; or
- Codex authentication material.

## Architecture

```text
VS Code Codex extension ────────────────────────────────> existing route

codex ──────────────────────────────────────────────────> existing route

codex-headroom ─> temporary config snapshot ─> Headroom on 127.0.0.1 only ─> OpenAI
```

Install Headroom in a user-level isolated `uv` tool environment. Prefer its
supported Codex wrapper/entrypoint over a custom request-rewriting proxy
configuration. `codex-headroom` invokes `headroom wrap codex --no-mcp
--code-memory none --` for one terminal session. The wrapper snapshots the
active `config.toml` before launch and restores it byte-for-byte after the
Headroom child exits. This is necessary because Headroom 0.37.0 still invokes
legacy Headroom-MCP cleanup even with those two flags. It must not alter the
environment of a normal `codex` session.

The proxy is on-demand for the first rollout rather than a persistent user
service. It binds only to loopback, and its lifecycle ends with the wrapper
session unless the supported Headroom entrypoint requires a short-lived child
process.

The wrapper refuses to launch without an existing active `config.toml`. It
keeps the snapshot in a private temporary directory and restores it after
normal exit, `SIGHUP`, `SIGINT`, or `SIGTERM`; it then deletes the snapshot.
It cannot restore state after `SIGKILL` or power loss, so the trial must not
run while another Codex client, including the VS Code extension, can update
the same configuration.

## Security and Privacy Defaults

- Bind only to `127.0.0.1`; never expose a listening port on the LAN.
- Do not configure a new API key or copy either Codex account's credentials.
  The current Codex authentication flow must pass through unchanged.
- Disable Headroom memory, traffic learning, telemetry, and request/response
  content logging for the trial.
- Pass `--no-mcp --code-memory none` on every wrapped launch. `--no-mcp`
  prevents retrieve-MCP registration and `--code-memory none` disables code
  memory. Neither alone guarantees no transient config mutation in the
  installed Headroom version, which is why the wrapper snapshot is required.
- Record only aggregate compatibility and measurement data: command outcome,
  elapsed time, request count, and any Headroom token/compression counters.
- Do not enable an aggressive token-reduction profile initially. Start with
  Headroom's cache-oriented coding behavior to protect recent context and
  provider prefix-cache stability.

## Compatibility Trial

The trial proves the actual ChatGPT-login Codex CLI path rather than assuming
that generic OpenAI-compatible proxy support covers it.

For each Codex account:

1. Record a small read-only baseline using normal `codex`.
2. Run the same narrowly scoped read-only request with `codex-headroom`.
3. Verify authentication, response completion, repository instruction loading,
   Graphify skill availability, and tool behavior.
4. Compare aggregate counters and elapsed time, without retaining prompt or
   response content.

Use a short, fixed task only. A failed probe must stop the trial before any
default-command, shell, service, or repository change.

## Success Criteria

- `codex-headroom` is available while `codex` remains byte-for-byte normal in
  intent and invocation path.
- Both accounts pass a read-only compatibility probe.
- The proxy does not require a credential migration or change the VS Code
  extension.
- Graphify and existing project instructions remain available in a proxied
  Obigo session.
- Headroom exposes useful aggregate optimization data without content logging.
- The user can bypass Headroom immediately by running `codex`.

## Failure and Rollback

Authentication failure, missing tool/skill behavior, material response
degradation, or inability to prove loopback-only binding ends the trial. Stop
the wrapper/proxy and use normal `codex`; no repository rollback is necessary.

Do not promote the wrapper to the default `codex` command during this work.
That is a separate decision after measured, repeated successful sessions.

## Expected Benefit and Limits

Graphify reduces unnecessary repository discovery. Headroom may additionally
reduce or stabilize the context sent for long terminal Codex sessions. It does
not replace Graphify, automatically commit generated graph artifacts, or
perform document semantic extraction.
