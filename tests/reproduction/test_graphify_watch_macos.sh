#!/usr/bin/env sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
adapter=$ROOT/reproduction/graphify-watch/macos.sh

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
[ -x "$adapter" ] || fail 'macOS Graphify watcher adapter is missing'

temp_dir=$(mktemp -d /tmp/harness-graphify-watch-macos-XXXXXX)
trap 'rm -rf "$temp_dir"' EXIT HUP INT TERM
fake_bin=$temp_dir/bin
repo=$temp_dir/repo\ \&\ graph
mkdir -p "$fake_bin" "$repo/.git"
printf '#!/usr/bin/env sh\nprintf "%%s\\n" "$*" >> "$HARNESS_SERVICE_LOG"\n' > "$fake_bin/launchctl"
printf '#!/usr/bin/env sh\nexit 0\n' > "$fake_bin/graphify"
printf '#!/usr/bin/env sh\nprintf "501\\n"\n' > "$fake_bin/id"
chmod 700 "$fake_bin/launchctl" "$fake_bin/graphify" "$fake_bin/id"

if HARNESS_SERVICE_LOG=$temp_dir/services HOME=$temp_dir/home PATH=$fake_bin:$PATH "$adapter" enable 'bad/id' "$repo" >/dev/null 2>&1; then
    fail 'invalid identifier was accepted'
fi
[ ! -e "$temp_dir/services" ] || fail 'invalid identifier invoked launchctl'

HARNESS_SERVICE_LOG=$temp_dir/services HOME=$temp_dir/home PATH=$fake_bin:$PATH "$adapter" enable demo "$repo"
grep -F -q 'bootstrap gui/501' "$temp_dir/services" || fail 'enable does not bootstrap the current user domain'
grep -F -q 'com.graphify.watch.demo.plist' "$temp_dir/services" || fail 'enable does not target exact plist'
grep -F -q "<string>$fake_bin/graphify</string>" "$temp_dir/home/Library/LaunchAgents/com.graphify.watch.demo.plist" || fail 'plist does not use the resolved Graphify executable'
grep -F -q '<string>'"$temp_dir"'/repo &amp; graph</string>' "$temp_dir/home/Library/LaunchAgents/com.graphify.watch.demo.plist" || fail 'plist does not escape repository path XML'
HARNESS_SERVICE_LOG=$temp_dir/services HOME=$temp_dir/home PATH=$fake_bin:$PATH "$adapter" remove demo
grep -F -q 'bootout gui/501' "$temp_dir/services" || fail 'remove does not boot out the current user domain'
grep -F -q 'com.graphify.watch.demo.plist' "$temp_dir/services" || fail 'remove does not target exact plist'

printf '%s\n' 'PASS: macOS Graphify watcher adapter'
