#!/usr/bin/env sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
manifest=$ROOT/reproduction/manifest.env

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

[ -f "$manifest" ] || fail 'manifest is missing'
grep -F -x -q 'HARNESS_CORE_COMMANDS=git,codex' "$manifest" || fail 'missing core commands'
grep -F -x -q 'HARNESS_OPTIONAL_COMPONENTS=graphify' "$manifest" || fail 'missing optional components'
grep -F -x -q 'HARNESS_SUPPORTED_PLATFORMS=linux,macos,windows' "$manifest" || fail 'missing supported platforms'
grep -E -q '[`$]|[[:space:]]' "$manifest" && fail 'manifest contains unsafe characters'

printf '%s\n' 'PASS: reproduction manifest'
