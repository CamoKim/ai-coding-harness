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

codex-headroom ─> Headroom on 127.0.0.1 only ─> OpenAI
```

Install Headroom in a user-level isolated `uv` tool environment. Prefer its
supported Codex wrapper/entrypoint over a custom request-rewriting proxy
configuration. `codex-headroom` invokes `headroom wrap codex --code-memory
none --` for one terminal session; it must not alter the environment of a
normal `codex` session.

The proxy is on-demand for the first rollout rather than a persistent user
service. It binds only to loopback, and its lifecycle ends with the wrapper
session unless the supported Headroom entrypoint requires a short-lived child
process.

The wrapper owns the configuration-restoration boundary. Before it starts the
supported Headroom child process, it creates a private, byte-for-byte backup of
`~/.codex/config.toml`. It does not `exec` Headroom: it retains the direct child
PID and traps `EXIT`, `HUP`, `INT`, and `TERM`. Cleanup terminates and waits for
that child when needed, restores the original configuration if it differs,
proves identity with `cmp` and matching checksums, and only then removes the
backup. An unprovable restoration retains the backup and exits nonzero.

## Security and Privacy Defaults

- Bind only to `127.0.0.1`; never expose a listening port on the LAN.
- Do not configure a new API key or copy either Codex account's credentials.
  The current Codex authentication flow must pass through unchanged.
- Disable Headroom memory, traffic learning, telemetry, and request/response
  content logging for the trial.
- Pass `--code-memory none` on every wrapped launch so Headroom does not
  register the default Serena code-memory MCP server.
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
