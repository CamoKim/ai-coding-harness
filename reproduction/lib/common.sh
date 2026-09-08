#!/usr/bin/env sh

set -eu

ROOT=${HARNESS_ROOT:?HARNESS_ROOT must be set by the entry point}
MANIFEST=$ROOT/reproduction/manifest.env

emit() {
    printf '%s %s %s\n' "$1" "$2" "$3"
}

parse_component() {
    component=core
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --component)
                [ "$#" -ge 2 ] || { emit MISSING component 'value required'; return 1; }
                component=$2
                shift 2
                ;;
            --apply) apply=true; shift ;;
            *) emit UNSUPPORTED argument "$1"; return 2 ;;
        esac
    done
    case "$component" in core) ;; *) emit UNSUPPORTED component "$component"; return 2 ;; esac
}

command_state() {
    name=$1
    if command -v "$name" >/dev/null 2>&1; then
        emit READY "$name" 'available'
        return 0
    fi
    emit MISSING "$name" 'not found'
    return 1
}
