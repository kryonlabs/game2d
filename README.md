# Game2D

Game2D is an optional Ziran package for 2D games that use Kryon. Kryon provides
the shared `Rectangle` and `Circle` values. The `Game2D` module adds collision
helpers. The `Raylib`
module provides the existing raylib game API as a separate adapter. Kryon keeps
its UI geometry, drawing primitives, widgets, and raylib UI host.

`game2d/navigation` owns the portable title/play/pause/settings/control-choice
state machine. `game2d/controls` supplies `GameControlsChoice` and re-anchored
`GameSwipeDirection` steering. The chooser uses Kryon's standard
DirectionPad and buttons. Callers supply translated labels, persist their
chosen mode, and retain their own game rules, title artwork and account actions.
Neither module depends on a publisher, account service, game catalog or raylib.

Kryon owns the raylib backend and its version. Game2D neither vendors nor
builds raylib: its `Raylib` module binds to the C ABI of the raylib version
selected by the Kryon dependency. Platform builds can obtain that exact source
with `ziran pkg path kryon --locked --submodules`. Run `ziran update` to refresh
all packages, or `ziran update Game2D` to refresh Game2D and its transitive
Kryon dependency.

```toml
[dependencies.Game2D]
git = "https://github.com/kryonlabs/game2d.git"
ref = "master"
```

Import the shared module with `using Game :: #import "Game2D";`. A native C or
C++ game that uses raylib can additionally import `Raylib`. The raylib adapter
uses raylib's C ABI and does not support native Go. Select and link a platform
host in the application; a Ziran package does not install a renderer by itself.

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
includes this suite and the existing geometry and raylib ABI local tests.
