# Game2D

Game2D is an optional Ziran package for 2D games that use Kryon. Kryon provides
the shared `Rectangle` and `Circle` values. The `Game2D` module adds collision
helpers. The `Sdl` module is a game's window: SDL2 draws it with its
accelerated renderer (or SDL's software renderer where there is no GPU), and
the game reads keyboard, mouse, touch and gamepad input, loads pictures,
textures and render targets, draws shapes and text, and plays sounds and music with the call names
games already use (`InitWindow`, `BeginDrawing`, `DrawTexturePro`,
`PlaySound`...). Pictures decode through Kryon's `image_pixels`, text draws
with Pango and Cairo, and audio mixes in Ziran's `std/audio`. Kryon keeps
its UI geometry, drawing primitives and widgets.

`game2d/navigation` owns the portable title/play/pause/settings/control-choice
state machine. `game2d/controls` supplies `GameControlsChoice` and re-anchored
`GameSwipeDirection` steering. The chooser uses Kryon's standard
DirectionPad and buttons. Callers supply translated labels, persist their
chosen mode, and retain their own game rules, title artwork and account actions.
Neither module depends on a publisher, account service or game catalog.

`Sdl` links SDL2, zlib for PNG bytes and, for text, Pango and Cairo
(`pkg-config --libs sdl2 zlib cairo pangocairo glib-2.0`). It does not bring in
Kryon's Cairo window raster, so a game that draws Kryon widgets supplies the
`Raster*` functions they paint through, drawing with these same calls. It reads WAV; a game that
ships Ogg Vorbis or MP3 also imports `std/audio_decode_vorbis` or
`std/audio_decode_mp3` and links that codec, so a game carries only the decoders
it uses. Render textures draw upright with a negative source height, as games
already draw them. `SetFixedFrameTime(seconds)` makes every frame last exactly
that long for `GetFrameTime` and `GetTime`, for deterministic headless and
replayed runs (SDL's `offscreen` or `dummy` video driver needs no display).
Gamepads use raylib's button and axis numbering (`GAMEPAD_BUTTON_*`,
`GAMEPAD_AXIS_*`) over SDL's game controllers. `ToggleFullscreen` scales the
game to the screen at its own size, so `GetScreenWidth` and mouse positions
keep the window's coordinates. `SetWindowState(FLAG_WINDOW_RESIZABLE)` makes an
open window resizable.

The same module builds for the browser with Emscripten: compile the game's
generated C with `--define PLATFORM_WEB` and link with `-sUSE_SDL=2
-sUSE_ZLIB=1` (plus `-sUSE_OGG=1 -sUSE_VORBIS=1` for Ogg music) and
`--js-library` Ziran's `web/ziran_web.js`. There pictures are PNG files (link
with `--use-preload-plugins` so the browser decodes preloaded ones), text
draws on the page's canvas, the browser paces frames, and audio plays through
WebAudio once the player has pressed a key or button.

On Windows and Android the text draws with FreeType (link `-lfreetype`) in
the system's sans-serif face, or the font file `GAME2D_FONT` names. `LoadImageFromMemory` reads PNG bytes; other
formats load from files with `LoadImage`.
Run `ziran update` to refresh all packages, or `ziran update Game2D` to refresh
Game2D and its transitive Kryon dependency.

```toml
[dependencies.Game2D]
git = "https://github.com/kryonlabs/game2d.git"
ref = "master"
```

Import the shared module with `using Game :: #import "Game2D";`, and the window
with `using Window :: #import "Game2D/Sdl";`.

For local development, add an ignored `ziran.local.toml` with overrides for
`Game2D`, `Kryon`, and `ziran` in the application. Commit `ziran.lock` for
reproducible builds.

`GameSwipeDirection(*state, down, x, y, minimum = 6.0) -> s32` keeps its
retained-direction return: `0` left, `1` up, `2` right, `3` down, `-1` idle.
Sample once per input frame with a `GameSwipe` state. Initial down anchors
without moving. Each displacement reaching the threshold on either axis
sets `state.step = true` and reanchors, including another crossing in the
same direction. The dominant axis wins; ties choose horizontal. A nonpositive
minimum uses 6. Below threshold, the return retains direction but `step` is
false; it must not trigger another discrete move.

`state.moved` records any accepted crossing during the press. On release,
`state.tapped` is true only if the press never crossed the threshold; direction
returns to -1 and `active`, `step`, and `moved` clear. Both `step` and `tapped`
are per-sample events. For cancellation or leaving play, discard the gesture
with `state = GameSwipe.{}` instead of feeding a release, then sample the new
press normally. Navigation does not own input state. Read direction from the
function return, or from `state.direction` after sampling.

For Wurm adoption, map `ifx state.step then direction else -1` to its existing one-event
turn input; never compare with the previous direction to detect a turn. Its
simulation and timed turns remain game-owned. Shovey's tap-to-step,
tap-to-fire, held-repeat timing and board-coordinate mapping remain game-owned;
consume `step` only for accepted swipe movement and route taps separately.
Kryon retains DirectionPad, SwipeArea and pointer capture. Choano uses
`GameStickSteer` for continuous headings and needs no swipe API migration.

Run `env -u DISPLAY -u WAYLAND_DISPLAY sh tests/swipe_result_test.sh` for the
navigation/control/floating-stick suite through native C and portable `.zx`
from source and saved IR, plus an external public-import consumer. `make -j1 test`
includes this suite, the geometry tests and `tests/sdl_surface_test.sh`, which
draws, reads input and plays audio through `Sdl` from source and saved IR on a
private Xvfb with SDL's software renderer and dummy audio.
