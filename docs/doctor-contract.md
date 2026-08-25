# Harness Doctor Contract

`./scripts/doctor` is a read-only operational check with no arguments. Any argument returns exit `64`.

Each result line is `CHECK<TAB>STATUS<TAB>DETAIL`, followed by one `SUMMARY` line. It checks Global and handler parity, hooks parity or inline-hooks conflict, telemetry marker validity, Harness validation, and the Harness working tree.

`DISABLED` telemetry, a `DIRTY` worktree, and `NOT_INSTALLED` when the manifest and all managed targets are absent are observations, not failures by themselves. Exit `0` means healthy, `1` means action is required, and `2` means doctor could not complete a check.

Doctor never installs, updates, reconciles, trusts hooks, or creates, repairs, deletes, or reads telemetry records or transient state. Its validation invocation sets `PYTHONDONTWRITEBYTECODE=1` and `HARNESS_DOCTOR_RUNNING=1`; the latter prevents doctor-test recursion.
