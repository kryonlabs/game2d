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
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM

"$ziran" check --project src/Game2D/module.zi
"$ziran" check --project src/Raylib/module.zi
"$ziran" build --project --target=c \
    -o "$work/c" tests/game2d_behavior.zi
"${CC:-cc}" -std=c99 -I"$compiler/include" -I"$work/c" \
    "$work/c"/*.c -lm -o "$work/game2d-behavior"
"$work/game2d-behavior"

"$ziran" bundle --project --entry game2d_behavior:main \
    -o build/game2d-behavior.zib tests/game2d_behavior.zi
"$ziran" run build/game2d-behavior.zib

"$ziran" build --project --target=c -o build/raylib-c src/Raylib/module.zi
"$ziran" build --project --target=cpp -o build/raylib-cpp src/Raylib/module.zi
"${CC:-cc}" -std=c11 -I"$compiler/include" -Ibuild/raylib-c \
    -c build/raylib-c/Raylib.c -o build/Raylib.o
"${CXX:-c++}" -std=c++17 -I"$compiler/include" -Ibuild/raylib-cpp \
    -c build/raylib-cpp/Raylib.cpp -o build/Raylib-cpp.o

raylib_header=${RAYLIB_HEADER_DIR:-$("$ziran" pkg path raylib $lock_flags --submodules)/src}
if test -f "$raylib_header/raylib.h"; then
    "${CC:-cc}" -std=c11 -DGENERATED -ffunction-sections \
        -Wl,--gc-sections -I"$compiler/include" -Ibuild/raylib-c \
        tests/raylib_wave_abi.c -o build/generated-abi
    "${CC:-cc}" -std=c11 -I"$raylib_header" \
        tests/raylib_wave_abi.c -o build/raylib-abi
    test "$(build/generated-abi)" = "$(build/raylib-abi)"
fi

echo "Game2D source, native, portable, and raylib ABI checks passed"
