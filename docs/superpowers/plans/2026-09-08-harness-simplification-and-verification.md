# Harness Simplification and Verification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make source validation exercise existing isolated behavior tests, remove the unusable automatic installer path, fix watcher portability, and reduce duplicated Harness guidance.

**Architecture:** Keep `./scripts/validate` as the single source-repository check and make it orchestrate safe host-supported tests. Keep reproduction utilities explicit and read-only except for separately invoked watcher adapters, and keep durable facts in one canonical documentation location.

**Tech Stack:** POSIX shell, PowerShell 7, Git, Markdown

**Spec:** `docs/superpowers/specs/2026-09-08-harness-simplification-and-verification-design.md`

## Global Constraints

- Do not install tools, manage user configuration, register real services, or run other stateful runtime evidence during verification.
- Preserve Native Codex, Superpowers, Harness, project, and optional OMX ownership boundaries.
- Run PowerShell behavior tests only when `pwsh` is available and report an explicit permitted skip otherwise.
- Preserve the existing uncommitted global model-selection policy and synchronize it deliberately only after the template is stable.

---

### Task 1: Make bootstrap read-only

**Files:**
- Modify: `tests/reproduction/test_bash_core.sh`
- Modify: `tests/reproduction/test_powershell_core.ps1`
- Modify: `reproduction/bootstrap.sh`
- Modify: `reproduction/bootstrap.ps1`
- Modify: `reproduction/lib/common.sh`
- Modify: `docs/reproduce-environment.md`

**Interfaces:**
- Consumes: existing `doctor.sh --component core` and `doctor.ps1 -Component core`
- Produces: read-only bootstrap commands that reject `--apply` and `-Apply`

- [ ] **Step 1: Change the Bash test to require read-only behavior**

Remove the fake `curl` setup and installer assertions. Add an assertion that `bootstrap.sh --component core --apply` exits nonzero, prints `UNSUPPORTED argument --apply`, and never prints an installer marker.

- [ ] **Step 2: Run the Bash core test and verify the old implementation fails**

Run: `sh tests/reproduction/test_bash_core.sh`

Expected: FAIL because the current bootstrap accepts `--apply` and invokes the fake installer.

- [ ] **Step 3: Remove apply support from the Unix bootstrap parser and entry point**

Delete `apply=false`, remove the `--apply` parser case from `reproduction/lib/common.sh`, and replace the installer branch in `reproduction/bootstrap.sh` with one successful preflight message after doctor passes:

```sh
emit READY preflight 'no changes made; install missing tools through their official instructions'
```

- [ ] **Step 4: Align PowerShell bootstrap and its test**

Remove `[switch]$Apply` from `reproduction/bootstrap.ps1`; leave only the validated `Component` parameter and the read-only preflight message. Update `test_powershell_core.ps1` to invoke `-Apply` in a child PowerShell process and require a nonzero result without any installation action.

- [ ] **Step 5: Update reproduction documentation**

Remove instructions suggesting an apply flag and state that bootstrap performs preflight only. Keep the official installation command as a manual, user-invoked step.

- [ ] **Step 6: Verify bootstrap behavior**

Run: `sh tests/reproduction/test_bash_core.sh`

Expected: PASS with `PASS: bash core contract`.

When `pwsh` is available, run: `pwsh -NoProfile -File tests/reproduction/test_powershell_core.ps1`

Expected: PASS with the PowerShell core contract message.

---

### Task 2: Fix Graphify watcher paths and worktree support

**Files:**
- Modify: `tests/reproduction/test_graphify_watch_linux.sh`
- Modify: `tests/reproduction/test_graphify_watch_macos.sh`
- Modify: `tests/reproduction/test_graphify_watch_windows.ps1`
- Modify: `reproduction/graphify-watch/linux.sh`
- Modify: `reproduction/graphify-watch/macos.sh`
- Modify: `reproduction/graphify-watch/windows.ps1`

**Interfaces:**
- Consumes: `enable <project-id> <repository>`, platform service managers, and Git repository metadata
- Produces: exact watcher configuration paths and acceptance of normal checkouts or linked worktrees

- [ ] **Step 1: Extend Linux and macOS tests with real linked worktrees**

Create a temporary repository with:

```sh
git -C "$temp_dir/source" init
git -C "$temp_dir/source" -c user.name=Harness -c user.email=harness@example.invalid commit --allow-empty -m initial
git -C "$temp_dir/source" worktree add "$temp_dir/linked"
```

Require `enable linked "$temp_dir/linked"` to succeed. In the Linux test, set a custom `XDG_CONFIG_HOME` containing a space and require the generated unit's `EnvironmentFile` to reference that exact configuration file rather than `%h/.config`.

- [ ] **Step 2: Extend the Windows test with a `.git` file repository shape**

Replace the temporary `.git` directory with a file containing `gitdir: <temporary metadata path>` and require the adapter to proceed to the mocked `schtasks` call.

- [ ] **Step 3: Run watcher tests and verify current assumptions fail**

Run:

```sh
sh tests/reproduction/test_graphify_watch_linux.sh
sh tests/reproduction/test_graphify_watch_macos.sh
```

Expected: FAIL because the adapters currently require `.git` to be a directory and Linux hard-codes `%h/.config`.

- [ ] **Step 4: Validate repositories through Git metadata shape**

For Unix adapters, accept a repository when `.git` is either a directory or a file and resolve the repository with `pwd -P`. For Windows, change `Assert-Repository` to accept either `PathType Container` or `PathType Leaf`. Keep rejection of paths with no `.git` entry.

- [ ] **Step 5: Write the exact Linux environment-file path**

Add a small unit-value escaping helper for backslashes, double quotes, and percent signs. Generate:

```text
EnvironmentFile="<escaped absolute config path>/projects/<id>.env"
```

Keep `ExecStart` bound to the resolved Graphify executable.

- [ ] **Step 6: Verify watcher behavior**

Run the Linux and macOS shell tests. When `pwsh` is available, run the Windows watcher test. Require every executed test to pass.

---

### Task 3: Execute behavior tests from source validation

**Files:**
- Modify: `scripts/validate`
- Modify: `tests/reproduction/test_validate_graphify_watch.sh`

**Interfaces:**
- Consumes: all `tests/reproduction/test_*.sh` files and PowerShell equivalents
- Produces: one validation result that reports executed tests and permitted platform skips

- [ ] **Step 1: Strengthen the validation-regression test**

Invoke the copied validator with `HARNESS_VALIDATION_CHILD=1` so it can test static validation without recursively launching itself. Add a second temporary copy containing a deliberately failing host behavior test and require normal `scripts/validate` to fail with the test name in its output.

- [ ] **Step 2: Run the regression test and verify behavior tests are not yet enforced**

Run: `sh tests/reproduction/test_validate_graphify_watch.sh`

Expected: FAIL on the new deliberately failing behavior-test case.

- [ ] **Step 3: Add a behavior-test runner to `scripts/validate`**

After static checks, run these shell tests when `HARNESS_VALIDATION_CHILD` is not `1`:

```text
tests/reproduction/test_manifest.sh
tests/reproduction/test_bash_core.sh
tests/reproduction/test_graphify_watch_linux.sh
tests/reproduction/test_graphify_watch_macos.sh
tests/reproduction/test_validate_graphify_watch.sh
tests/reproduction/test_documentation_contracts.sh
```

Record a pass or failure for each. If `pwsh` exists, run all three PowerShell tests; otherwise print one explicit permitted-skip line naming the missing executable.

- [ ] **Step 4: Avoid duplicate documentation execution**

Remove the existing standalone documentation-contract invocation once it is owned by the behavior-test loop. Retain shell syntax checks and static content checks.

- [ ] **Step 5: Verify validation propagation**

Run: `sh tests/reproduction/test_validate_graphify_watch.sh`

Expected: PASS, proving missing artifacts and failing behavior tests both fail source validation.

Run: `./scripts/validate`

Expected: all host-supported tests pass, with an explicit PowerShell skip only when `pwsh` is unavailable.

---

### Task 4: Reduce documentation and template duplication

**Files:**
- Modify: `tests/reproduction/test_documentation_contracts.sh`
- Modify: `README.md`
- Modify: `docs/architecture.md`
- Modify: `docs/daily-usage.md`
- Modify: `docs/adoption.md`
- Modify: `docs/reference-environment.md`
- Modify: `docs/returning-to-the-harness.md`
- Modify: `templates/repository/AGENTS.md`
- Modify: `templates/global/AGENTS.md`
- Modify outside repository after template stabilization: `~/.codex/AGENTS.md`

**Interfaces:**
- Consumes: architecture as canonical ownership documentation and daily usage as canonical user workflow documentation
- Produces: concise linked guidance, one cross-subsystem verification map, and an explicit read-only global-template comparison step

- [ ] **Step 1: Replace brittle prose assertions**

Change `test_documentation_contracts.sh` to assert stable headings and short boundary phrases such as `Native Codex`, `Superpowers`, `This Harness`, `explicit, user-invoked`, and `project-scoped watcher`. Keep the prohibition on `graphify hook install`.

- [ ] **Step 2: Consolidate ownership and usage prose**

Keep the full owner table only in `docs/architecture.md` and detailed tool-selection guidance only in `docs/daily-usage.md`. In README, reference-environment, returning, and adoption documents, remove repeated explanations and link to those canonical pages while retaining instructions unique to each document.

- [ ] **Step 3: Consolidate repository-template impact routing**

Remove `## Shared Dependencies` and `## Cross-subsystem Impact` as separate sections. Expand the Verification Routing table's first column and supporting bullets so each shared dependency or contract source names all affected direct and transitive consumers in one place. Add an instruction to delete unused optional sections and bracketed prompts.

- [ ] **Step 4: Add the global-template comparison procedure**

In `docs/adoption.md`, add:

```sh
diff -u templates/global/AGENTS.md ~/.codex/AGENTS.md
```

Describe it as a read-only review step and retain manual merge ownership. Do not add automatic copying or validation of the user-owned file.

- [ ] **Step 5: Synchronize the active global file deliberately**

Review the final template diff, then apply only the corresponding template changes to `~/.codex/AGENTS.md`. Confirm byte-for-byte equality only when the active file contains no unrelated user-only guidance; otherwise confirm that the managed section matches without overwriting unrelated content.

- [ ] **Step 6: Update static validation expectations**

Adjust `scripts/validate` required headings and stable text checks to match the consolidated repository template and canonical documentation layout.

- [ ] **Step 7: Run final verification**

Run:

```sh
git diff --check
./scripts/validate
```

Expected: no whitespace errors and a successful full Harness validation with every host-supported behavior test executed.
