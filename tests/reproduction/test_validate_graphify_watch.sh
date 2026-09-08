#!/usr/bin/env sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }

temp_dir=$(mktemp -d /tmp/harness-validate-graphify-watch-XXXXXX)
trap 'rm -rf "$temp_dir"' EXIT HUP INT TERM
copy_root=$temp_dir/harness
mkdir -p "$copy_root"
(cd "$ROOT" && tar --exclude=.git -cf - .) | (cd "$copy_root" && tar -xf -)
rm -f "$copy_root/reproduction/graphify-watch/windows.ps1"

if "$copy_root/scripts/validate" > "$temp_dir/validate.out" 2>&1; then
    fail 'validation accepted a missing Graphify watcher adapter'
fi
grep -F -q 'missing required file: reproduction/graphify-watch/windows.ps1' "$temp_dir/validate.out" || fail 'validation did not identify the missing watcher adapter'

printf '%s\n' 'PASS: validation rejects a missing Graphify watcher adapter'
