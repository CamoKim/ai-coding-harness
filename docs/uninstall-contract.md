# Harness Uninstall Contract

`./scripts/harness-uninstall --check|--apply` removes only the Global `AGENTS.md`, telemetry handler, and `hooks.json` proven by the valid local `managed-artifacts.json` baseline. It does not consult current Harness source files.

Each artifact line is `ARTIFACT<TAB>STATE<TAB>DETAIL`, followed by explicit hooks-trust and telemetry-data preservation lines plus `SUMMARY`. `--check` is read-only. `--apply` requires every artifact to be `REMOVABLE` or `ALREADY_ABSENT` before changing anything.

Without a manifest, all three absent targets are `NOT_INSTALLED`; both commands are successful no-ops. Any existing target without provenance is `UNMANAGED` and blocks removal. A present manifest must be a private regular schema-v1 file with complete SHA-256 and mode fingerprints; only corruption or incompleteness is `ERROR`.

With a valid manifest, matching regular targets are `REMOVABLE`, absent targets are `ALREADY_ABSENT`, changed targets are `UNMANAGED_DRIFT`, and symlinks or non-regular targets are `CONFLICT`. Apply detaches in hooks-json, telemetry-handler, Global AGENTS order by atomic rename to a same-filesystem private quarantine. It rolls back a partial detach and reports `recovery-required` only when rollback fails. It removes the manifest last.

`config.toml`, hooks trust metadata, telemetry consent, `turns.jsonl`, legacy records, transient state, and Harness directories are never deleted or modified. Exit `0` means not installed or successful apply; `1` means removal is eligible; `2` means manifest or operational error; `3` means unmanaged state, drift, or conflict; `64` means invalid invocation.
