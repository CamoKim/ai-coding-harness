# Efficiency Telemetry Contract

## Purpose

Efficiency telemetry measures Codex turn duration and selected runtime events without collecting task content. It is optional, turn-scoped, local-only, and does not infer unavailable metrics.

The Harness repository contains this contract only. It must not contain telemetry records, a collector, a daemon, a dashboard, or a database.

## Opt-in and Storage

Telemetry is enabled only when the local regular-file marker `~/.codex/harness/telemetry/enabled` contains exactly `enabled` followed by a newline. General tasks may inspect the marker read-only only. An explicit telemetry opt-in request may create or repair the marker; an explicit telemetry opt-out request may delete it. No other action may mutate the marker.

Do not create the marker or telemetry directory as an implicit setup action. If the marker is absent, malformed, or unavailable at task start, do not record telemetry and continue the task normally. A valid marker at task start makes that task telemetry-eligible. Removing or changing the marker disables future tasks; it does not alter existing local records or the eligibility already established for a running task.

## Turn Boundary and Collection

One record represents one Codex turn. `UserPromptSubmit` starts it, `PermissionRequest` increments `approval_request_count`, `SubagentStart` increments `subagent_count`, and `Stop` finalizes exactly one JSONL record in the canonical path `~/.codex/harness/telemetry/turns.jsonl`. Hooks read their event JSON but extract only `hook_event_name`, `turn_id`, and active `model`; prompt, transcript, cwd, tool input/output, and assistant text are discarded. A SHA-256 turn-id key is transient state only and is never recorded.

If the marker is absent at `UserPromptSubmit`, no state or record is created. Hook errors are advisory and must not fail the primary task.

No Harness component parses Codex sessions, histories, prompts, tool logs, source code, or repository history to produce records.

## Schema

Each JSONL line uses this schema:

```json
{
  "schema_version": 2,
  "record_unit": "turn",
  "record_id": "opaque-local-uuid",
  "model": "gpt-5.6-terra",
  "reasoning_effort": null,
  "duration_s": 420,
  "user_followup_count": null,
  "approval_request_count": 0,
  "verification_retry_count": null,
  "runtime_e2e_retry_count": null,
  "subagent_count": 0,
  "verification_route": null,
  "runtime_e2e": null,
  "outcome": null
}
```

Fields unavailable from stable hook input are `null`, never guessed or represented as zero.

### Field Rules

- `record_id` is random and not derived from a prompt, repository, source file, or session identifier.
- `model` is the active hook model. `reasoning_effort`, classification, follow-ups, verification routing/retries, runtime E2E, and outcome are `null` because hooks do not expose them reliably.
- `approval_request_count` counts permission requests, not approvals. `subagent_count` counts `SubagentStart` events.

## Data Minimization

Never store user prompt text, source code, file paths, repository URLs, diffs, commands, tool inputs or outputs, Codex session/history content, secrets, credentials, environment values, or approval text. Do not derive telemetry by copying or parsing those artifacts.

The schema deliberately stores only counts, enums, duration, optional model metadata, and an opaque random task identifier. A user may use local aggregation later, but records must remain outside repositories and must not be committed.

## Runtime Helper Installation

`scripts/telemetry-record` is the canonical hook handler. `scripts/harness-install --check|--apply` owns its safe adoption together with Global `AGENTS.md` and the user-level hooks file. The deprecated `scripts/install-telemetry-hooks` makes no changes. Trust review remains a Codex requirement. Installation never creates telemetry marker or records.

Global policy does not invoke telemetry. Hooks invoke only the installed runtime path; no repository-local fallback exists.

## Helper Boundary

`scripts/telemetry-record` is a local deterministic helper for eligibility checking, JSONL append, duplicate prevention, and schema/privacy validation only. It is not a collector, daemon, dashboard, database, or session parser. It does not create local telemetry configuration and is not run unless a task uses the opt-in completion flow.

## Relationship to Existing Policies

Telemetry does not alter E1 autonomy, E2 verification routing, or any approval boundary. It observes the task's selected classification and evidence after the fact. Runtime E2E approval, verification execution, and subagent use continue to follow their existing contracts.
