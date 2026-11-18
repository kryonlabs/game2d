#!/bin/sh
# Game2D's SDL2 surface from source and saved IR on a private Xvfb, with
# SDL's software renderer and dummy audio; never the live desktop.
set -eu
repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo"
ziran=${ZIRAN:-ziran}
lock_flags=
if test ! -f ziran.local.toml; then lock_flags=--locked; fi
picture=$("$ziran" pkg path kryon $lock_flags)/assets/brand/mascot-dragon.png
mkdir -p work
work=$(mktemp -d "$repo/work/sdl.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
unset DISPLAY WAYLAND_DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS SESSION_MANAGER
unset DESKTOP_SESSION XDG_SESSION_ID XDG_SESSION_TYPE SDL_WINDOWID WAYLAND_SOCKET
mkdir -p "$work/runtime"
export YUE_DESKTOP_RECOVERY=0 HARMONY_DESKTOP_RECOVERY=0 XDG_RUNTIME_DIR="$work/runtime"
export SDL_VIDEODRIVER=x11 SDL_RENDER_DRIVER=software SDL_AUDIODRIVER=dummy
libs="$(pkg-config --libs sdl2 cairo freetype2 pangocairo fontconfig glib-2.0) -lm -ldl -lpthread"
LDLIBS="$libs" "$ziran" build --project --target=c --exe --entry sdl_surface_test:main \
    -o "$work/source" tests/sdl_surface_test.zi
xvfb-run -a -s "-noreset -screen 0 640x480x24" "$work/source/sdl_surface_test" "$picture" "$work"
"$ziran" ir --project -o "$work/ir" tests/sdl_surface_test.zi
LDLIBS="$libs" "$ziran" build --target=c --root "$work/ir" --entry sdl_surface_test:main --exe \
    -o "$work/saved" "$work/ir/sdl_surface_test.zir"
xvfb-run -a -s "-noreset -screen 0 640x480x24" "$work/saved/sdl_surface_test" "$picture" "$work"
echo "Game2D SDL surface: shapes, camera, scissor, blending, render targets, textures, text, input, timing and audio passed from source and saved IR"
