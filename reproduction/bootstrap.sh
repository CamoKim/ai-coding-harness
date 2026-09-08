#!/usr/bin/env sh

set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HARNESS_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
. "$SCRIPT_DIR/lib/common.sh"

apply=false
parse_component "$@" || exit $?
case "$(uname -s)" in
    Linux|Darwin) ;;
    *) emit UNSUPPORTED platform "$(uname -s)"; exit 2 ;;
esac

"$SCRIPT_DIR/doctor.sh" --component "$component" || exit $?
if [ "$apply" = true ]; then
    emit MANUAL installation 'core installation adapters are not yet configured'
else
    emit READY preflight 'no changes made; pass --apply only after reviewing an adapter'
fi
