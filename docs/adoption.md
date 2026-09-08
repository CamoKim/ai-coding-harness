# Adopt the Harness in a Real Repository

## Safe Manual Adoption

This Harness does not provide a runtime manager, self-healing doctor, or automatic installer. Its separate, explicit reproduction utilities inspect portable prerequisites; they do not replace manual, reviewed adoption. Adopt the Harness by reviewing and merging its small templates into the places you already own.

1. Read the target repository’s existing `AGENTS.md` files and nearby project documentation first. Treat them as the current source of truth.
2. Review `templates/global/AGENTS.md`, then merge its durable personal engineering rules into `~/.codex/AGENTS.md` (or your configured Codex-home equivalent). Read the existing file first; append or reconcile only non-duplicated rules, and keep unrelated personal instructions unchanged. Review the resulting diff before saving.
3. At the repository root, create or extend `AGENTS.md` from `templates/repository/AGENTS.md`. Replace bracketed prompts only with facts you can verify from the project. Keep existing repository-specific guidance that remains true.
4. Add `<subsystem>/AGENTS.md` from `templates/subsystem/AGENTS.md` only when that subtree needs different instructions from its parent—for example, a separate service, schema source, generated-code boundary, or stateful operational area.
5. Run the project’s own checks after editing its instructions. The Harness source itself is checked with `./scripts/validate`.

Before and after a manual global merge, inspect the difference without changing either file:

```sh
diff -u templates/global/AGENTS.md ~/.codex/AGENTS.md
```

An empty result means the files match. A nonempty result is review input; preserve intentional user-only guidance rather than overwriting it.

The instruction hierarchy is global guidance, then repository guidance, then the nearest subsystem guidance. Each lower layer adds local facts; it should not repeat the higher layers or generic engineering method.

## Fill the Repository Guide with Facts

Record a short repository map, shared dependencies, compatibility contracts, generated-data boundaries, and a Verification Routing map. Link to sources of truth instead of copying specifications. A useful entry tells Codex what changes affect, which consumers are implicated, and which project-owned verification scopes must run.

Before adding a statement, answer: is it true for this repository today, is it durable enough to guide future work, and is this the narrowest instruction scope that needs it? If not, leave it out or put it nearer to the code it describes.

## Add Subsystem Guides Only When Useful

Use a subsystem `AGENTS.md` when the subtree has a distinct execution path, dependencies, compatibility boundary, environment limitation, generated artifact policy, or stateful-operation risk. Do not create one merely to restate the repository guide. Keep it close to the affected files and point it to detailed project documentation where that is the real source of truth.

## Decide Where Information Belongs

| Put it in | When it is | Example |
| --- | --- | --- |
| `AGENTS.md` | durable context Codex needs to choose safe work and verification | a schema’s consumers, a migration approval boundary, a subsystem’s supported verifier scopes |
| Project code or project documentation | the implementation or detailed source of truth | API schemas, architecture diagrams, build configuration, operational runbooks |
| `./scripts/verify` | executable, repeatable, project-owned validation | selecting and running the service’s test, lint, typecheck, or integration checks |

Do not encode project commands in this Harness. Do not turn `AGENTS.md` into a copy of source code, a tutorial on generic methodology, or a replacement for executable checks.

## Define Project Verification

When a repository benefits from one predictable entry point, define:

```text
./scripts/verify <scope> <level>
```

The repository chooses its scopes. `fast` is the normal low-cost evidence for an affected scope; `full` adds only meaningful higher-cost evidence. A project may map the interface directly to existing commands or use a small local wrapper; it does not need a root dispatcher, per-subsystem scripts, or an `all` scope. Keep changed-file and consumer knowledge in the repository’s Verification Routing table, not in a generic inference framework.

Document unsupported environments honestly with the contract’s exit code `2`. Default verification must not install dependencies, migrate data, deploy, publish, or mutate shared state. Document any runtime evidence separately, and obtain approval before a stateful action.

See [the verification contract](verification-contract.md) and the [repository template](../templates/repository/AGENTS.md) for the full interface.

## Preserve Existing Instructions

Adoption is a merge, not a reset. Retain verified, useful project instructions; reconcile conflicts with the closest project owner; remove stale or duplicate rules only after confirming they are no longer needed. Do not silently change a public API, schema, configuration format, data contract, production state, or security boundary while performing this documentation work.
