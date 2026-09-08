#!/usr/bin/env sh

set -eu

config_root=${XDG_CONFIG_HOME:-$HOME/.config}/graphify-watch
unit_root=${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
valid_id() { printf '%s' "$1" | grep -E -q '^[A-Za-z0-9][A-Za-z0-9_-]*$'; }
service_name() { printf 'graphify-watch@%s.service' "$1"; }
resolve_graphify() {
    raw=$(command -v graphify 2>/dev/null || :)
    [ -n "$raw" ] && [ -f "$raw" ] && [ -x "$raw" ] || return 1
    directory=$(CDPATH= cd -- "$(dirname -- "$raw")" && pwd -P)
    printf '%s/%s' "$directory" "$(basename -- "$raw")"
}

require_id() {
    valid_id "$1" || fail 'project identifier must contain only letters, numbers, underscores, or hyphens'
}

enable() {
    id=$1
    repo=$2
    require_id "$id"
    [ -d "$repo/.git" ] || fail 'repository is not a Git repository'
    graphify=$(resolve_graphify) || fail 'graphify is not available as an executable'
    repo=$(CDPATH= cd -- "$repo" && pwd -P)
    mkdir -p "$config_root/projects" "$unit_root"
    printf 'GRAPHIFY_PROJECT=%s\n' "$repo" > "$config_root/projects/$id.env"
    cat > "$unit_root/graphify-watch@.service" <<EOF
[Unit]
Description=Graphify watcher for %i

[Service]
EnvironmentFile=%h/.config/graphify-watch/projects/%i.env
ExecStart="$graphify" watch \${GRAPHIFY_PROJECT}
Restart=on-failure
EOF
    systemctl --user daemon-reload
    systemctl --user enable --now "$(service_name "$id")"
}

status() { require_id "$1"; systemctl --user status --no-pager "$(service_name "$1")"; }

remove() {
    id=$1
    require_id "$id"
    systemctl --user disable --now "$(service_name "$id")"
    rm -f "$config_root/projects/$id.env"
    systemctl --user daemon-reload
}

[ "$#" -ge 2 ] || fail 'usage: linux.sh enable <id> <repository> | status <id> | remove <id>'
case "$1" in
    enable) [ "$#" -eq 3 ] || fail 'enable requires an identifier and repository'; enable "$2" "$3" ;;
    status) [ "$#" -eq 2 ] || fail 'status requires an identifier'; status "$2" ;;
    remove) [ "$#" -eq 2 ] || fail 'remove requires an identifier'; remove "$2" ;;
    *) fail 'unknown command' ;;
esac
