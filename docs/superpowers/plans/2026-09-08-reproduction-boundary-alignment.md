# Reproduction Boundary Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align the Harness documentation with its portable reproduction utilities and watcher-only Graphify policy, then release the result as 0.4.0.

**Architecture:** Runtime management, self-healing doctor behavior, and automatic installation remain outside the Harness. The `reproduction/` utilities are explicitly scoped, user-invoked environment reconstruction aids; Graphify automatic refresh uses only project-scoped watchers.

**Tech Stack:** Markdown, POSIX shell, existing `scripts/validate` contract.

**Spec:** User-requested documentation corrections from 2026-09-08.

## Global Constraints

- Preserve the distinction between user-owned configuration and portable repository artifacts.
- Do not present Graphify Git hooks as a supported automatic-refresh path.
- Keep verification static and non-mutating except for disposable test copies.

---

### Task 1: Align documents, release metadata, and source validation

**Files:**
- Create: `tests/reproduction/test_documentation_contracts.sh`
- Modify: `README.md`, `docs/adoption.md`, `docs/reference-environment.md`, `docs/reproduce-environment.md`, `scripts/validate`, `VERSION`, `CHANGELOG.md`

**Interfaces:**
- Consumes: `scripts/validate` `require_text` contract checks.
- Produces: a reproducible documentation contract checked by `./scripts/validate`.

- [x] **Step 1: Write the failing test**

Create `tests/reproduction/test_documentation_contracts.sh` to require the portable-reproduction wording and forbid `graphify hook install`.

- [x] **Step 2: Run the test to verify it fails**

Run: `tests/reproduction/test_documentation_contracts.sh`

Expected: failure because the current documents still describe all doctor commands and installers as excluded and offer the Git-hook workflow.

- [x] **Step 3: Write the minimal documentation and validation changes**

Describe user-invoked reproduction checks as distinct from runtime management, delete the Git-hook alternative, add the contract test to `scripts/validate`, and publish `0.4.0` metadata.

- [x] **Step 4: Run green verification**

Run: `tests/reproduction/test_documentation_contracts.sh && ./scripts/validate && git diff --check`

Expected: all checks pass.

- [ ] **Step 5: Commit and push**

Run: `git add` for only task files, `git commit -m "docs: align reproduction boundary"`, then `git push origin main`.
