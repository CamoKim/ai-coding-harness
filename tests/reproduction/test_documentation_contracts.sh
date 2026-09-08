#!/usr/bin/env sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
require_text() {
    path=$1
    expected=$2
    normalized=$(tr '\n' ' ' < "$ROOT/$path" | tr -s ' ')
    printf '%s\n' "$normalized" | grep -F -q -- "$expected" || fail "missing expected text in $path: $expected"
}
forbid_text() {
    path=$1
    forbidden=$2
    if grep -F -q -- "$forbidden" "$ROOT/$path"; then
        fail "forbidden text present in $path: $forbidden"
    fi
}

require_text README.md 'runtime management, self-healing doctor tooling, or automatic installers'
require_text docs/adoption.md 'does not provide a runtime manager, self-healing doctor, or automatic installer'
require_text docs/reference-environment.md 'Portable reproduction utilities are included only as explicit, user-invoked environment-reconstruction aids'
require_text docs/reproduce-environment.md 'The reproduction utilities inspect portable prerequisites and help reconstruct the documented environment.'
require_text docs/reproduce-environment.md 'The project-scoped watcher is the only supported automatic Graphify refresh path.'
require_text docs/verification-contract.md 'A project may invoke its own verifier from CI, but workflow definitions, credentials, required checks, and runtime setup remain project-owned.'
forbid_text docs/reproduce-environment.md 'graphify hook install'

printf '%s\n' 'PASS: documentation boundaries are aligned'
