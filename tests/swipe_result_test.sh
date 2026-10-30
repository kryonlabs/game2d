#!/bin/sh
# Shared swipe events, navigation and floating-stick behavior, without a UI host.
set -eu
unset DISPLAY WAYLAND_DISPLAY
repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo"
export ZIRAN_TEST_ALLOW_LOCAL_GIT=1
ziran=${ZIRAN:-ziran}
lock_flags=
if test ! -f ziran.local.toml; then lock_flags=--locked; fi
mkdir -p work
work="$repo/work/swipe-result"
mkdir -p "$work"
# Prevent two invocations from sharing generated outputs.
mkdir "$work/.running"
trap 'rmdir "$work/.running"' EXIT HUP INT TERM

# The portable runner prints main's result; assert it as well as process status.
run_portable() {
    "$ziran" run --project "$1" > "$work/portable.log"
    tail -n 10 "$work/portable.log"
    test "$(tail -n 1 "$work/portable.log")" = 0
}

"$ziran" build --project --target=c --exe --entry navigation_test:main \
    -o "$work/native" tests/navigation_test.zi
"$work/native/navigation_test"
# The stick paint test commits Box paint; raster stubs stand in for a host.
set -- --bind kryon/raster_shape:RasterRoundedRectangle=navigation_test:RasterRoundedRectangle \
    --bind kryon/raster_shape:RasterRoundedRectangleOutline=navigation_test:RasterRoundedRectangleOutline
"$ziran" bundle --project "$@" --entry navigation_test:main \
    -o "$work/navigation-test.zx" tests/navigation_test.zi
run_portable "$work/navigation-test.zx"
"$ziran" ir --project --entry navigation_test:main -o "$work/ir" tests/navigation_test.zi
"$ziran" bundle --project "$@" --entry navigation_test:main \
    -o "$work/navigation-ir.zx" "$work/ir/navigation_test.zir"
run_portable "$work/navigation-ir.zx"

# Exercise the maintained suite from an external project's public imports.
# This is a consumer fixture, not a dependency checkout or copied library.
compiler=$("$ziran" pkg path ziran $lock_flags)
kryon=$("$ziran" pkg path kryon $lock_flags)
python3 - "$repo" "$work/consumer" "$compiler" "$kryon" <<'PY'
import json
from pathlib import Path
import sys
repo, consumer, compiler, kryon = map(Path, sys.argv[1:])
(consumer / 'src').mkdir(parents=True, exist_ok=True)
source = (repo / 'tests/navigation_test.zi').read_text()
for module in ('controls', 'navigation'):
    source = source.replace(f'#import "{module}"', f'#import "Game2D/{module}"')
(consumer / 'src/navigation_test.zi').write_text(source)
(consumer / 'ziran.toml').write_text('''[package]
name = "swipe_consumer"
module_roots = ["src"]
[toolchain]
git = "https://github.com/ziranlang/ziran.git"
ref = "master"
[dependencies.Game2D]
git = "https://github.com/kryonlabs/game2d.git"
ref = "master"
[dependencies.kryon]
git = "https://github.com/kryonlabs/kryon.git"
ref = "master"
''')
(consumer / 'ziran.local.toml').write_text('[overrides]\n' + ''.join(
    f'{name} = {json.dumps(str(path))}\n' for name, path in
    (('Game2D', repo), ('kryon', kryon), ('ziran', compiler))))
PY
cd "$work/consumer"
"$ziran" lock --offline
"$ziran" build --project --offline --target=c --exe --entry navigation_test:main \
    -o "$work/consumer-native" src/navigation_test.zi
"$work/consumer-native/navigation_test"
"$ziran" bundle --project --offline "$@" --entry navigation_test:main \
    -o "$work/consumer.zx" src/navigation_test.zi
run_portable "$work/consumer.zx"
echo "Game2D local swipe events, navigation, floating-stick and public-import consumer tests passed"
