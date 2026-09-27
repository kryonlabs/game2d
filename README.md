# Game2D

Game2D is an optional Ziran package for 2D games that use Kryon. The `Game2D`
module holds backend-independent 2D values and collision helpers. The `Raylib`
module provides the existing raylib game API as a separate adapter. Kryon keeps
its UI geometry, drawing primitives, widgets, and raylib UI host.

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
