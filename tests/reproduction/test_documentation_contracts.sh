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

require_text README.md 'explicit, user-invoked checks'
require_text docs/architecture.md '| Native Codex |'
require_text docs/architecture.md '| Superpowers |'
require_text docs/architecture.md '| This Harness |'
require_text docs/reference-environment.md 'read-only prerequisite checks'
require_text docs/reproduce-environment.md 'project-scoped watcher'
require_text docs/verification-contract.md 'project-owned verifier'
forbid_text docs/reproduce-environment.md 'graphify hook install'

printf '%s\n' 'PASS: documentation boundaries are aligned'
