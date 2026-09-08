#!/usr/bin/env sh

set -eu

config_root=${XDG_CONFIG_HOME:-$HOME/Library/Application Support}/graphify-watch
agent_root=$HOME/Library/LaunchAgents

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
valid_id() { printf '%s' "$1" | grep -E -q '^[A-Za-z0-9][A-Za-z0-9_-]*$'; }
label() { printf 'com.graphify.watch.%s' "$1"; }
plist_path() { printf '%s/%s.plist' "$agent_root" "$(label "$1")"; }
xml_escape() {
    printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g' -e "s/'/\&apos;/g"
}
resolve_graphify() {
    raw=$(command -v graphify 2>/dev/null || :)
    [ -n "$raw" ] && [ -f "$raw" ] && [ -x "$raw" ] || return 1
    directory=$(CDPATH= cd -- "$(dirname -- "$raw")" && pwd -P)
    printf '%s/%s' "$directory" "$(basename -- "$raw")"
}

require_id() {
    valid_id "$1" || fail 'project identifier must contain only letters, numbers, underscores, or hyphens'
}

resolve_repository() {
    repo=$1
    [ -d "$repo" ] || return 1
    git -C "$repo" rev-parse --is-inside-work-tree 2>/dev/null | grep -F -x -q true || return 1
    CDPATH= cd -- "$repo" && pwd -P
}

user_domain() { printf 'gui/%s' "$(id -u)"; }

enable() {
    id=$1
    repo=$2
    require_id "$id"
    repo=$(resolve_repository "$repo") || fail 'repository is not a Git repository'
    graphify=$(resolve_graphify) || fail 'graphify is not available as an executable'
    plist=$(plist_path "$id")
    mkdir -p "$config_root/projects" "$agent_root"
    printf 'GRAPHIFY_PROJECT=%s\n' "$repo" > "$config_root/projects/$id.env"
    cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$(label "$id")</string>
  <key>ProgramArguments</key>
  <array>
    <string>$(xml_escape "$graphify")</string>
    <string>watch</string>
    <string>$(xml_escape "$repo")</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>
EOF
    launchctl bootout "$(user_domain)" "$plist" >/dev/null 2>&1 || :
    launchctl bootstrap "$(user_domain)" "$plist"
}

status() { require_id "$1"; launchctl print "$(user_domain)/$(label "$1")"; }

remove() {
    id=$1
    require_id "$id"
    plist=$(plist_path "$id")
    launchctl bootout "$(user_domain)" "$plist" >/dev/null 2>&1 || :
    rm -f "$plist" "$config_root/projects/$id.env"
}

[ "$#" -ge 2 ] || fail 'usage: macos.sh enable <id> <repository> | status <id> | remove <id>'
case "$1" in
    enable) [ "$#" -eq 3 ] || fail 'enable requires an identifier and repository'; enable "$2" "$3" ;;
    status) [ "$#" -eq 2 ] || fail 'status requires an identifier'; status "$2" ;;
    remove) [ "$#" -eq 2 ] || fail 'remove requires an identifier'; remove "$2" ;;
    *) fail 'unknown command' ;;
esac
