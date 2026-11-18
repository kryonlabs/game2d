#!/bin/sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo"
export ZIRAN_TEST_ALLOW_LOCAL_GIT=1
unset DISPLAY WAYLAND_DISPLAY

ziran=${ZIRAN:-ziran}
lock_flags=
if test ! -f ziran.local.toml; then lock_flags=--locked; fi
compiler=$("$ziran" pkg path ziran $lock_flags)
mkdir -p work
work=$(mktemp -d "$repo/work/test.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM

"$ziran" check --project src/Game2D/module.zi
"$ziran" check --project src/Sdl/module.zi
"$ziran" build --project --target=c \
    -o "$work/c" tests/game2d_behavior.zi
"${CC:-cc}" -std=c99 -I"$compiler/include" -I"$work/c" \
    "$work/c"/*.c -lm -o "$work/game2d-behavior"
"$work/game2d-behavior"

"$ziran" bundle --project --entry game2d_behavior:main \
    -o build/game2d-behavior.zx tests/game2d_behavior.zi
"$ziran" run --project build/game2d-behavior.zx

sh tests/sdl_surface_test.sh
LDLIBS="$(pkg-config --libs freetype2)" "$ziran" build --project $lock_flags --target=c --exe \
    --entry sdl_text_freetype_test:main -o "$work/freetype" tests/sdl_text_freetype_test.zi
"$work/freetype/sdl_text_freetype_test"
sh tests/swipe_result_test.sh
echo "Game2D local source, native, portable and SDL surface tests passed"
