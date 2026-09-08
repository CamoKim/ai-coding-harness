# Portable Adoption Kit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give another person one safe, complete manual path for adopting the Harness in a compatible repository.

**Architecture:** Add one external-user guide that routes to existing templates and detailed documents without duplicating them. Expose it from the README and make the source validator require it, so the portable path cannot silently disappear.

**Tech Stack:** Markdown, POSIX shell, Git.

**Spec:** `docs/superpowers/specs/2026-09-08-portable-adoption-kit-design.md`

## Global Constraints

- Preserve the manual reviewed-merge model; do not add an installer, uninstaller, doctor command, or configuration manager.
- Never overwrite a target repository's existing `AGENTS.md` or invent its build and verification commands.
- Keep accounts, plugins, credentials, connector authorization, trust, Graphify installation, and user service-manager state outside portable artifacts.
- Keep Graphify optional and scoped to each repository that explicitly adopts it.
- Keep machine paths, usernames, credentials, and target-project-specific commands out of the kit.

---

### Task 1: Write the external-user Portable Adoption Kit

**Files:**

- Create: `docs/portable-adoption-kit.md`
- Modify: `README.md`

**Interfaces:**

- Consumes: the adoption, verification, configuration, reference-environment, and re-entry guides plus all three `templates/*/AGENTS.md` files.
- Produces: one linked document that an external user follows before detailed references.

- [x] **Step 1: Create the guide headings and fit criterion**

Create `docs/portable-adoption-kit.md` with these exact headings:

```markdown
# Portable Adoption Kit

## Is This a Fit?
## What You Will and Will Not Get
## Safe Adoption Path
## Define the Project Verification Contract
## Optional Graphify Path
## Completion Checklist
## Undo or Update an Adoption
## When to Stop and Ask
```

Under `## Is This a Fit?`, require an existing Git repository whose owner can review instruction changes and identify safe project verification. State that it is not for blindly modifying an unknown, production-only, or unowned repository.

- [x] **Step 2: Add the manual adoption sequence**

Under `## Safe Adoption Path`, add this order and link the adoption guide and each template:

```text
Read existing project instructions and source-of-truth docs.
Merge templates/global/AGENTS.md into normal global guidance.
Merge templates/repository/AGENTS.md into <repository>/AGENTS.md.
Add templates/subsystem/AGENTS.md only for a subtree with distinct facts or risks.
Review the diff with the repository owner or sources of truth.
Run safe project verification.
Commit only reviewed project-owned changes.
```

State that merging preserves true existing instructions rather than replacing them.

- [x] **Step 3: Add verification, optional Graphify, completion, and exit criteria**

Require the target project to define or document:

```text
./scripts/verify <scope> <level>
```

Link `verification-contract.md`; say unavailable environments must be reported honestly rather than replaced with invented generic commands. Link the Graphify design and plan; state that Graphify is installed only for a distinct broad-exploration need and that its guidance, artifacts, and watcher remain project-scoped.

The completion checklist must require reviewed instructions, a documented verification route, no committed secrets or paths, safe verification evidence, and adoption-diff review. The undo/update section must require reverting only exact adopted hunks after checking dependencies; never delete an entire existing `AGENTS.md` by default. Route recurring questions to the narrowest owner from `reference-environment.md`.

- [x] **Step 4: Expose the kit from README**

Add this section immediately after `## Adopt it in a repository`:

```markdown
## Share It With Another Engineer

For a complete manual adoption path, start with the [Portable Adoption Kit](docs/portable-adoption-kit.md). It preserves existing project instructions and deliberately leaves accounts, credentials, plugins, local trust, and optional project tools under their owners' control.
```

Add `Portable Adoption Kit` to the `## Read deeper` links.

- [x] **Step 5: Verify links and portable content**

Run:

```text
rg -n 'Portable Adoption Kit|templates/global/AGENTS.md|templates/repository/AGENTS.md|templates/subsystem/AGENTS.md|./scripts/verify <scope> <level>|Graphify' README.md docs/portable-adoption-kit.md
./scripts/validate
```

Expected: the first command names the entry point, three templates, verification contract, and optional Graphify; source validation confirms the kit has no managed-artifact paths or obvious secret patterns.

### Task 2: Make the kit a required Harness contract

**Files:**

- Modify: `scripts/validate`
- Test: temporary Harness copy under `/tmp`

**Interfaces:**

- Consumes: the `required_files` list in `scripts/validate`.
- Produces: a precise validation failure when an otherwise identical source copy lacks `docs/portable-adoption-kit.md`.

- [x] **Step 1: Write and run the failing validation expectation**

Before changing `scripts/validate`, run:

```sh
temp_dir=$(mktemp -d /tmp/harness-portable-kit-red-XXXXXX)
cp -a . "$temp_dir/harness"
rm -f "$temp_dir/harness/docs/portable-adoption-kit.md"
if "$temp_dir/harness/scripts/validate" >/tmp/harness-portable-kit-red.log 2>&1; then
    rm -rf "$temp_dir"
    printf '%s\n' 'TEST FAILURE: validator accepts a missing portable adoption kit' >&2
    exit 1
fi
rm -rf "$temp_dir"
```

Expected: failure with `TEST FAILURE`, because the existing validator accepts a missing kit.

- [x] **Step 2: Add the smallest requirement**

Add this line immediately after `docs/adoption.md` in `required_files`:

```text
docs/portable-adoption-kit.md
```

Do not add a script, dependency, or path-specific rule.

- [x] **Step 3: Verify the green state and removal failure**

Run:

```sh
./scripts/validate
temp_dir=$(mktemp -d /tmp/harness-portable-kit-XXXXXX)
cp -a . "$temp_dir/harness"
rm -f "$temp_dir/harness/docs/portable-adoption-kit.md"
if "$temp_dir/harness/scripts/validate" >/tmp/harness-portable-kit-negative.log 2>&1; then
    rm -rf "$temp_dir"
    printf '%s\n' 'TEST FAILURE: validator accepted a missing portable adoption kit' >&2
    exit 1
fi
rg -n 'missing required file: docs/portable-adoption-kit.md' /tmp/harness-portable-kit-negative.log
rm -rf "$temp_dir"
```

Expected: source validation passes; copied source missing only the kit fails and names that exact file.

- [x] **Step 4: Final verification and commit**

Run:

```text
git diff --check
./scripts/validate
git status --short
```

Expected: no whitespace errors, successful Harness validation, and only intended kit files changed. Commit with:

```text
git add README.md docs/portable-adoption-kit.md scripts/validate
git commit -m "docs: add portable adoption kit"
```

## Plan Self-Review

- Spec coverage: Task 1 implements the external guide, merge boundary, verification contract, optional Graphify, completion criteria, and rollback/update handling. Task 2 makes the guide durable.
- Placeholder scan: no deferred files, commands, or validation behavior remain.
- Interface consistency: Task 1 creates the exact path Task 2 requires; README and the negative test use that same path.
