# Game2D

Game2D is an optional Ziran package for 2D games that use Kryon. Kryon provides
the shared `Rectangle` and `Circle` values. The `Game2D` module adds collision
helpers. The `Raylib`
module provides the existing raylib game API as a separate adapter. Kryon keeps
its UI geometry, drawing primitives, widgets, and raylib UI host.

`game2d/navigation` owns the portable title/play/pause/settings/control-choice
state machine. `game2d/controls` supplies `GameControlsChoice` and continuous,
re-anchored `GameSwipeDirection` steering. The chooser uses Kryon's standard
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
