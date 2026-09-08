#!/usr/bin/env sh

set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HARNESS_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
. "$SCRIPT_DIR/lib/common.sh"

parse_component "$@" || exit $?
case "$(uname -s)" in
    Linux|Darwin) ;;
    *) emit UNSUPPORTED platform "$(uname -s)"; exit 2 ;;
esac

"$SCRIPT_DIR/doctor.sh" --component "$component" || exit $?
emit READY preflight 'no changes made; install missing tools through their official instructions'
