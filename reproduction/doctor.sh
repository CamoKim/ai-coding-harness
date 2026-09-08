#!/usr/bin/env sh

set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HARNESS_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
. "$SCRIPT_DIR/lib/common.sh"

apply=false
parse_component "$@" || exit $?

failures=0
command_state git || failures=$((failures + 1))
command_state codex || failures=$((failures + 1))
if "$ROOT/scripts/validate" >/dev/null 2>&1; then
    emit READY harness 'source validation passed'
else
    emit MISSING harness 'source validation failed'
    failures=$((failures + 1))
fi
emit MANUAL codex-login 'complete account login and authorization yourself'
emit MANUAL superpowers-plugin 'install or authorize the plugin through Codex'

[ "$failures" -eq 0 ] || exit 1
