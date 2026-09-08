#!/usr/bin/env sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
bootstrap=$ROOT/reproduction/bootstrap.sh
doctor=$ROOT/reproduction/doctor.sh

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

[ -x "$bootstrap" ] || fail 'bootstrap is missing or not executable'
[ -x "$doctor" ] || fail 'doctor is missing or not executable'

temp_dir=$(mktemp -d /tmp/harness-bash-core-XXXXXX)
trap 'rm -rf "$temp_dir"' EXIT HUP INT TERM
fake_bin=$temp_dir/bin
mkdir -p "$fake_bin"
printf '#!/usr/bin/env sh\nexit 0\n' > "$fake_bin/git"
printf '#!/usr/bin/env sh\nexit 0\n' > "$fake_bin/codex"
chmod 700 "$fake_bin/git" "$fake_bin/codex"

HARNESS_VALIDATION_CHILD=1 PATH=$fake_bin:$PATH "$doctor" --component core > "$temp_dir/doctor.out"
grep -F -q 'READY git' "$temp_dir/doctor.out" || fail 'doctor does not report Git ready'
grep -F -q 'READY codex' "$temp_dir/doctor.out" || fail 'doctor does not report Codex ready'
grep -F -q 'MANUAL codex-login' "$temp_dir/doctor.out" || fail 'doctor does not preserve manual login boundary'

HARNESS_VALIDATION_CHILD=1 PATH=$fake_bin:$PATH "$bootstrap" --component core > "$temp_dir/bootstrap.out"
grep -F -q 'READY preflight' "$temp_dir/bootstrap.out" || fail 'bootstrap does not perform read-only preflight'

if HARNESS_VALIDATION_CHILD=1 PATH=$fake_bin:$PATH "$bootstrap" --component core --apply > "$temp_dir/apply.out" 2>&1; then
    fail 'bootstrap accepted the removed --apply option'
fi
grep -F -q 'UNSUPPORTED argument --apply' "$temp_dir/apply.out" || fail 'bootstrap does not identify the removed --apply option'
if grep -F -q 'INSTALLER_RAN' "$temp_dir/apply.out"; then
    fail 'bootstrap invoked an installer'
fi

printf '%s\n' 'PASS: bash core contract'
