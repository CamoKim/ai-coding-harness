# Local Repository Graph Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a local CLI that creates and queries a bounded repository graph for `obigo-data-pipeline`, reducing Codex discovery context without weakening source inspection or verification.

**Architecture:** Create a standalone Python CLI in `local-repository-graph`. It parses configured tracked Python files with `ast`, joins those facts with reviewed YAML contract/routing declarations, stores a local ignored JSON index keyed by Git state and content hashes, and emits capped JSON candidate sets from explicit seed paths or symbols.

**Tech Stack:** Python 3.11+, standard-library `ast`, `argparse`, `json`, `hashlib`, `subprocess`, `pathlib`; PyYAML; pytest; Ruff.

**Spec:** `docs/superpowers/specs/2026-09-01-local-repository-graph-design.md`

## Global Constraints

- Create the standalone repository at `/home/obigo/바탕화면/github/local-repository-graph`; do not add executable graph code to `ai-coding-harness`.
- Keep analysis local: no network clients, embeddings, vector stores, source upload, CI mutation, runtime orchestration, or stateful target-project commands.
- Support only Python source edges in the first release; represent non-code relationships as reviewed YAML declarations and uncertainties.
- Never analyze ignored runtime data, `.env` files, credentials, certificates, volumes, generated artifacts, or untracked operational data.
- Index output is untracked and disposable. A fresh Git SHA plus matching tracked-input hashes is required to report `fresh`.
- Graph output is advisory and capped; it must never assert that a missing edge proves no impact.
- Use test-first development. Each task runs the stated focused tests before its commit.

---

### Task 1: Create the standalone CLI project and test harness

**Files:**

- Create: `/home/obigo/바탕화면/github/local-repository-graph/pyproject.toml`
- Create: `/home/obigo/바탕화면/github/local-repository-graph/README.md`
- Create: `/home/obigo/바탕화면/github/local-repository-graph/.gitignore`
- Create: `/home/obigo/바탕화면/github/local-repository-graph/src/repository_graph/__init__.py`
- Create: `/home/obigo/바탕화면/github/local-repository-graph/src/repository_graph/cli.py`
- Test: `/home/obigo/바탕화면/github/local-repository-graph/tests/test_cli.py`

**Interfaces:**

- Produces: console command `repository-graph` with `build` and `query` subcommands.

- [ ] **Step 1: Write the failing command-dispatch test**

```python
from repository_graph.cli import main

def test_main_requires_a_subcommand(capsys):
    assert main([]) == 2
    assert "usage:" in capsys.readouterr().err
```

- [ ] **Step 2: Run the focused test**

Run: `cd /home/obigo/바탕화면/github/local-repository-graph && pytest tests/test_cli.py::test_main_requires_a_subcommand -q`

Expected: FAIL because the package and `main` do not exist.

- [ ] **Step 3: Implement the minimal project**

Use a `src/` layout, `requires-python = ">=3.11"`, PyYAML runtime dependency, pytest/Ruff dev dependencies, and:

```toml
[project.scripts]
repository-graph = "repository_graph.cli:main"
```

Implement `main(argv: list[str] | None = None) -> int` with `argparse`, required subcommands, and temporary zero-return handlers.

- [ ] **Step 4: Run focused validation**

Run: `cd /home/obigo/바탕화면/github/local-repository-graph && pytest tests/test_cli.py -q && ruff check src tests`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add pyproject.toml README.md .gitignore src tests
git commit -m "feat: scaffold local repository graph CLI"
```

### Task 2: Define and validate tracked graph configuration

**Files:**

- Create: `src/repository_graph/config.py`
- Create: `src/repository_graph/model.py`
- Test: `tests/test_config.py`
- Create: `/home/obigo/바탕화면/github/obigo-data-pipeline/.codex/repo-graph.yml`
- Modify: `/home/obigo/바탕화면/github/obigo-data-pipeline/.gitignore`

**Interfaces:**

- Consumes: `/home/obigo/바탕화면/github/obigo-data-pipeline/.codex/repo-graph.yml`.
- Produces: immutable `GraphConfig`, `Contract`, `VerifierRoute`, `GraphNode`, and `GraphEdge` dataclasses.

- [ ] **Step 1: Write failing configuration tests**

```python
from repository_graph.config import load_config

def test_load_config_rejects_source_outside_repository(tmp_path):
    (tmp_path / ".codex").mkdir()
    (tmp_path / ".codex/repo-graph.yml").write_text(
        "version: 1\npython_sources: ['../secret.py']\n"
    )
    with pytest.raises(ValueError, match="inside repository"):
        load_config(tmp_path)
```

Also reject missing version, absolute paths, unknown node/edge types, and verifier routes with unsupported levels.

- [ ] **Step 2: Run tests to prove failure**

Run: `cd /home/obigo/바탕화면/github/local-repository-graph && pytest tests/test_config.py -q`

Expected: FAIL because `load_config` does not exist.

- [ ] **Step 3: Implement configuration and target declarations**

The schema declares version `1`, permitted Python roots, excluded path segments, subsystem path ownership, contracts, consumers, verifier routes, and CI job/path-group relationships. Every declared path must resolve inside the repository.

For `obigo-data-pipeline`, declare `onprem`, `road-platform`, `aws`, `libs`; shared-library consumer relations; TripInfo/VSS, SQL, HTTP, MQTT, environment, storage, and Compose contracts; local verifier scopes; and `onprem-ci.yml` relationships. Ignore only `.codex/repo-graph/index.json` and temporary index files.

- [ ] **Step 4: Run focused validation**

Run: `cd /home/obigo/바탕화면/github/local-repository-graph && pytest tests/test_config.py -q && ruff check src tests`

Expected: PASS.

- [ ] **Step 5: Commit independently**

```bash
cd /home/obigo/바탕화면/github/local-repository-graph
git add src/repository_graph/config.py src/repository_graph/model.py tests/test_config.py
git commit -m "feat: validate repository graph configuration"

cd /home/obigo/바탕화면/github/obigo-data-pipeline
git add .codex/repo-graph.yml .gitignore
git commit -m "chore: add repository graph configuration"
```

### Task 3: Extract safe Python facts

**Files:**

- Create: `src/repository_graph/analyze_python.py`
- Test: `tests/test_analyze_python.py`

**Interfaces:**

- Consumes: repository-relative Python path and source text.
- Produces: `PythonFacts(path, module, definitions, imports, parse_error)` without importing or executing target code.

- [ ] **Step 1: Write failing AST extraction tests**

```python
from repository_graph.analyze_python import analyze_python

def test_collects_imports_and_top_level_definitions():
    facts = analyze_python(
        "src/pkg/service.py",
        "from pkg.db import Session\nclass Service: pass\ndef run(): pass\n",
    )
    assert facts.module == "pkg.service"
    assert facts.imports == {"pkg.db"}
    assert facts.definitions == {"Service", "run"}
```

Add cases for direct and relative imports, async functions, syntax errors, and paths outside configured roots.

- [ ] **Step 2: Run test to prove failure**

Run: `cd /home/obigo/바탕화면/github/local-repository-graph && pytest tests/test_analyze_python.py -q`

Expected: FAIL because `analyze_python` does not exist.

- [ ] **Step 3: Implement AST-only analysis**

Use `ast.parse`; collect module-level class/function/async-function definitions and import targets. Convert paths to modules with configured Python roots. Persist a parse-error uncertainty instead of failing the full index.

- [ ] **Step 4: Run focused validation and commit**

Run: `cd /home/obigo/바탕화면/github/local-repository-graph && pytest tests/test_analyze_python.py -q && ruff check src tests`

Expected: PASS.

```bash
git add src/repository_graph/analyze_python.py tests/test_analyze_python.py
git commit -m "feat: extract Python graph facts safely"
```

### Task 4: Build and freshness-check the local index

**Files:**

- Create: `src/repository_graph/index.py`
- Create: `src/repository_graph/git_state.py`
- Test: `tests/test_index.py`
- Modify: `src/repository_graph/cli.py`

**Interfaces:**

- Consumes: `GraphConfig`, tracked target files, Git SHA, and SHA-256 file hashes.
- Produces: `.codex/repo-graph/index.json` and `IndexStatus(fresh|stale|missing, reasons)`.

- [ ] **Step 1: Write failing index/freshness tests**

```python
def test_index_is_stale_when_tracked_input_hash_changes(repo):
    build_index(repo)
    (repo / "src/pkg/service.py").write_text("def changed(): pass\n")
    assert inspect_index(repo).status == "stale"
```

Also test atomic writes, recorded HEAD/dirty state, fresh unchanged checkout, missing index, and serialized parse-error uncertainty.

- [ ] **Step 2: Run test to prove failure**

Run: `cd /home/obigo/바탕화면/github/local-repository-graph && pytest tests/test_index.py -q`

Expected: FAIL because index APIs do not exist.

- [ ] **Step 3: Implement build and incremental reuse**

Use `git rev-parse HEAD`, `git status --porcelain`, and `git ls-files` without shell interpolation. Hash configured tracked sources, reuse unchanged serialized facts, recompute changed facts and dependent import edges, then write a temporary file followed by `Path.replace`. Never read ignored or untracked source inputs. `repository-graph build --repo /home/obigo/바탕화면/github/obigo-data-pipeline` emits status and node/edge counts as JSON.

- [ ] **Step 4: Run focused validation and commit**

Run: `cd /home/obigo/바탕화면/github/local-repository-graph && pytest tests/test_index.py -q && ruff check src tests`

Expected: PASS.

```bash
git add src/repository_graph/index.py src/repository_graph/git_state.py src/repository_graph/cli.py tests/test_index.py
git commit -m "feat: build and freshness-check local graph indexes"
```

### Task 5: Implement bounded impact queries

**Files:**

- Create: `src/repository_graph/query.py`
- Test: `tests/test_query.py`
- Modify: `src/repository_graph/cli.py`

**Interfaces:**

- Consumes: `repository-graph query --repo /home/obigo/바탕화면/github/obigo-data-pipeline --path libs/obigo_road_match_core/src/obigo_road_match_core/matcher.py` or a fully qualified configured symbol.
- Produces: `index_status`, `starting_files`, `related_files`, `related_contracts`, `affected_consumers`, `verification_candidates`, and `uncertainties`.

- [ ] **Step 1: Write failing bounded-query tests**

```python
def test_query_expands_shared_library_to_consumers_and_verifier(index):
    result = query_index(index, paths=["libs/obigo_road_match_core/src/matcher.py"])
    assert result["affected_consumers"] == ["onprem", "road-platform"]
    assert result["verification_candidates"] == ["./scripts/verify all fast"]
```

Also test caps of three starting files, twelve related files, and five contracts/consumers/verifiers; stale output without expansion; and dynamic-wiring uncertainty.

- [ ] **Step 2: Run test to prove failure**

Run: `cd /home/obigo/바탕화면/github/local-repository-graph && pytest tests/test_query.py -q`

Expected: FAIL because `query_index` does not exist.

- [ ] **Step 3: Implement deterministic traversal**

Resolve explicit paths/symbols, traverse direct import, reverse-import, contract, consumer, test, and verifier edges to depth two, rank direct paths first, deduplicate, and sort deterministically. Reject absolute/out-of-repository paths. A stale/missing index returns only status and reasons.

- [ ] **Step 4: Run focused validation and commit**

Run: `cd /home/obigo/바탕화면/github/local-repository-graph && pytest tests/test_query.py -q && ruff check src tests`

Expected: PASS.

```bash
git add src/repository_graph/query.py src/repository_graph/cli.py tests/test_query.py
git commit -m "feat: query bounded repository impact graphs"
```

### Task 6: Add Codex guidance and evaluation fixtures

**Files:**

- Create: `docs/obigo-data-pipeline-evaluation.md`
- Modify: `README.md`
- Modify: `/home/obigo/바탕화면/github/obigo-data-pipeline/AGENTS.md`
- Create: `/home/obigo/바탕화면/github/obigo-data-pipeline/.codex/repo-graph-evaluation.yml`
- Create: `tests/test_evaluation.py`

**Interfaces:**

- Produces: a ten-to-twenty case, manually reviewed baseline-versus-graph evaluation protocol.

- [ ] **Step 1: Write failing evaluation fixture test**

```python
import pathlib
import yaml

FIXTURE = pathlib.Path(
    "/home/obigo/바탕화면/github/obigo-data-pipeline/.codex/repo-graph-evaluation.yml"
)

def load_cases():
    return yaml.safe_load(FIXTURE.read_text())["cases"]

def test_evaluation_has_required_task_classes():
    cases = load_cases()
    assert {case["kind"] for case in cases} >= {
        "single-domain", "shared-library", "schema", "mqtt-or-sql", "flow", "ci",
    }
    assert len(cases) >= 10
```

- [ ] **Step 2: Run test to prove failure**

Run: `cd /home/obigo/바탕화면/github/local-repository-graph && pytest tests/test_evaluation.py -q`

Expected: FAIL because fixture loading does not exist.

- [ ] **Step 3: Add protocol and integration guidance**

Document two runs per case: baseline targeted search and graph-assisted seed expansion. Record elapsed time, input tokens if available, files/lines read, selected verifier, verification outcome, review findings, and missed impacts. Preserve unavailable token data as `null`.

Add concise target `AGENTS.md` guidance: query only for ambiguous/cross-cutting work after locating one to three seeds; rebuild stale index; treat output as candidates; use targeted search on fallback; skip graph for known one-file work.

- [ ] **Step 4: Run full tool validation**

Run: `cd /home/obigo/바탕화면/github/local-repository-graph && pytest -q && ruff check src tests`

Expected: PASS.

- [ ] **Step 5: Run the read-only target smoke check**

Run: `repository-graph build --repo /home/obigo/바탕화면/github/obigo-data-pipeline && repository-graph query --repo /home/obigo/바탕화면/github/obigo-data-pipeline --path libs/obigo_road_match_core/src/obigo_road_match_core/matcher.py`

Expected: fresh bounded output with the declared consumer and verifier candidates. Do not run project tests, Compose, migrations, or runtime commands.

- [ ] **Step 6: Commit documentation and target integration**

```bash
cd /home/obigo/바탕화면/github/local-repository-graph
git add README.md docs tests
git commit -m "docs: add graph evaluation guidance"

cd /home/obigo/바탕화면/github/obigo-data-pipeline
git add AGENTS.md .codex/repo-graph-evaluation.yml
git commit -m "docs: document graph-assisted discovery"
```

### Task 7: Decide adoption from measured evidence

**Files:**

- Create: `/home/obigo/바탕화면/github/obigo-data-pipeline/docs/repository-graph-evaluation.md`

**Interfaces:**

- Consumes: completed results for at least ten declared tasks.
- Produces: one of `adopt`, `narrow`, or `stop`.

- [ ] **Step 1: Record both flows for each fixture task**

```yaml
- id: shared-road-core-change
  kind: shared-library
  baseline: {elapsed_seconds: null, input_tokens: null, files_read: null, lines_read: null}
  graph_assisted: {elapsed_seconds: null, input_tokens: null, files_read: null, lines_read: null}
  quality: {verifier: null, result: null, missed_impacts: []}
```

- [ ] **Step 2: Write the evidence-based decision**

Report medians/ranges for time, tokens where available, files/lines read, verifier results, review findings, and missed impacts. Adopt only if quality is at least baseline and time or context reduction is meaningful; narrow if only some task classes benefit; stop if quality regresses or gains are negligible.

- [ ] **Step 3: Commit the evidence report**

```bash
cd /home/obigo/바탕화면/github/obigo-data-pipeline
git add docs/repository-graph-evaluation.md .codex/repo-graph-evaluation.yml
git commit -m "docs: record repository graph evaluation"
```
