# Behavioral Lab Fixture

## Verification Routing

| Changed path | Required evidence |
| --- | --- |
| `docs/README.md` | `./scripts/verify docs fast` |
| `app/normalize.py` | `./scripts/verify app fast` |
| `shared/format.py` | `./scripts/verify alpha fast` and `./scripts/verify beta fast` |
| `runtime/adapter.py` | `./scripts/verify runtime fast` and `./scripts/ops isolated-runtime` |
| `contracts/activation.json` | Stateful activation requires explicit approval; do not run `./scripts/ops stateful-activation` without it. |

Fixture commands write only a small audit event in `.behavioral-lab/audit.jsonl`. They never contact external state.
