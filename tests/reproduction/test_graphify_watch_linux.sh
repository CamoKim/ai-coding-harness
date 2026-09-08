#!/usr/bin/env sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
adapter=$ROOT/reproduction/graphify-watch/linux.sh

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
[ -x "$adapter" ] || fail 'Linux Graphify watcher adapter is missing'

temp_dir=$(mktemp -d /tmp/harness-graphify-watch-XXXXXX)
trap 'rm -rf "$temp_dir"' EXIT HUP INT TERM
fake_bin=$temp_dir/bin
config_root=$temp_dir/config\ root
mkdir -p "$fake_bin" "$temp_dir/repo" "$config_root"
git -C "$temp_dir/repo" init -q
printf '#!/usr/bin/env sh\nprintf "%%s\\n" "$*" >> "$HARNESS_SERVICE_LOG"\n' > "$fake_bin/systemctl"
printf '#!/usr/bin/env sh\nexit 0\n' > "$fake_bin/graphify"
chmod 700 "$fake_bin/systemctl" "$fake_bin/graphify"

if HARNESS_SERVICE_LOG=$temp_dir/services XDG_CONFIG_HOME=$temp_dir/config PATH=$fake_bin:$PATH "$adapter" enable 'bad/id' "$temp_dir/repo" >/dev/null 2>&1; then
    fail 'invalid identifier was accepted'
fi
[ ! -e "$temp_dir/services" ] || fail 'invalid identifier invoked systemctl'

mkdir -p "$temp_dir/bogus/.git"
if HARNESS_SERVICE_LOG=$temp_dir/services XDG_CONFIG_HOME="$config_root" PATH=$fake_bin:$PATH "$adapter" enable bogus "$temp_dir/bogus" >/dev/null 2>&1; then
    fail 'repository validation accepted fake Git metadata'
fi

HARNESS_SERVICE_LOG=$temp_dir/services XDG_CONFIG_HOME="$config_root" PATH=$fake_bin:$PATH "$adapter" enable demo "$temp_dir/repo"
grep -F -q 'enable --now graphify-watch@demo.service' "$temp_dir/services" || fail 'enable does not target exact service'
unit=$config_root/systemd/user/graphify-watch@.service
grep -F -q "ExecStart=\"$fake_bin/graphify\" watch" "$unit" || fail 'service does not use the resolved Graphify executable'
grep -F -q "EnvironmentFile=\"$config_root/graphify-watch/projects/%i.env\"" "$unit" || fail 'service does not use the exact configured environment root'

mkdir -p "$temp_dir/source"
git -C "$temp_dir/source" init -q
git -C "$temp_dir/source" -c user.name=Harness -c user.email=harness@example.invalid commit --allow-empty -q -m initial
git -C "$temp_dir/source" worktree add -q "$temp_dir/linked"
HARNESS_SERVICE_LOG=$temp_dir/services XDG_CONFIG_HOME="$config_root" PATH=$fake_bin:$PATH "$adapter" enable linked "$temp_dir/linked"
grep -F -q 'enable --now graphify-watch@linked.service' "$temp_dir/services" || fail 'linked worktree was not enabled'

HARNESS_SERVICE_LOG=$temp_dir/services XDG_CONFIG_HOME="$config_root" PATH=$fake_bin:$PATH "$adapter" remove demo
grep -F -q 'disable --now graphify-watch@demo.service' "$temp_dir/services" || fail 'remove does not target exact service'

printf '%s\n' 'PASS: Linux Graphify watcher adapter'
