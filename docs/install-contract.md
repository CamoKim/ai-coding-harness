# Harness Install Contract

`./scripts/harness-install --check|--apply` manages only the adopted Global `AGENTS.md`, telemetry hook handler, and `hooks.json`. It never manages `config.toml`, hook trust, telemetry consent, records, or transient state.

Each artifact line is `ARTIFACT<TAB>STATE<TAB>DETAIL`, followed by a `hooks-trust` boundary line and one `SUMMARY` line. `--check` is read-only. `--apply` performs an all-artifact preflight and makes no change when any artifact has `UNMANAGED_DRIFT`, `CONFLICT`, or `ERROR`.

The local-only `~/.codex/harness/managed-artifacts.json` manifest uses schema version 1 and stores only each managed artifact's SHA-256 content fingerprint and installed mode. It is written last, after all target parity checks pass. A target matching source with no or stale manifest is `ADOPTABLE`: apply updates provenance only. A missing target with a previous managed baseline is `UNMANAGED_DRIFT`, never automatic recovery.

States are `MISSING`, `EXACT`, `ADOPTABLE`, `SAFE_UPGRADE`, `UNMANAGED_DRIFT`, `CONFLICT`, and `ERROR`. `SAFE_UPGRADE` requires the current target to match the previous managed content and mode. Targets that are symlinks or non-regular files, and real inline `[hooks]` or `[[hooks]]` definitions, are conflicts.

Exit `0` means exact parity or successful apply; `1` means an apply-eligible change exists; `2` means an operational, manifest, parity, or rollback error; `3` means drift or conflict blocked apply; `64` means invalid invocation. Apply stages files, rechecks parity, rolls back a partial replacement, and reports `recovery-required` if rollback cannot complete. Codex hook trust review remains outside this command.
