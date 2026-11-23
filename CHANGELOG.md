# Changelog

## [Unreleased]

- Build with Ziran 8133bd41 and Kryon d97c19e8, the Kryon source Breeze, Apps, Entity, Plot, Game2D and CSS share.
- `Game2D/Sdl` queues shapes and pictures that share a texture and blend mode and sends each run to SDL as one geometry call: Kasaival's frames went from about 4,500 SDL calls to a few dozen.
- `Game2D/Sdl` no longer spins waiting for the target frame rate when vsync already presents at that rate.

- `Game2D/Sdl` runs on Android under SDL2's activity (`PLATFORM_ANDROID`): `InitWindow(0, 0)` fills the display, pictures decode as PNG in Ziran and text draws with FreeType.

- `Game2D/Sdl` draws its text with FreeType on Windows and Android (`sdl_text_freetype`), in the system's sans-serif face or the font file `GAME2D_FONT` names, so a static Windows build needs no Pango or Cairo.

- `Game2D/Sdl` builds for the browser (`PLATFORM_WEB` with Emscripten's SDL2 port and Ziran's `web/ziran_web.js`): PNG pictures decode in Ziran, text draws on the page's canvas (`sdl_text_web`), the browser paces frames, and WebAudio starts with the first key or button press. The desktop text moved to `sdl_text_pango`. `malloc` and `memcpy` take `size_t`, so wasm32 builds no longer trap on their first allocation. A page linked with `--use-preload-plugins` reads the pictures the browser decoded before `main`, so large sprite sets load without blocking the page.

- `Game2D/Sdl` draws its text with Pango and Cairo itself (`sdl_text`) instead of importing Kryon's Cairo window raster, so a game that paints Kryon widgets through its own `Raster*` calls links without duplicate symbols, and games no longer carry Kryon's window raster.

- `Game2D/Sdl` reads gamepads (`IsGamepadAvailable`, `IsGamepadButtonDown`, `IsGamepadButtonPressed`, `GetGamepadAxisMovement`), toggles a fullscreen that scales the game at its own size, sets the window icon and its resizable state (`SetWindowState`), and loads pictures (`LoadImage`, PNG bytes with `LoadImageFromMemory`, `GenImageColor`) and music from bytes (`LoadMusicStreamFromMemory`).

- `Game2D/Sdl` replaces `Raylib` and `RaylibNull`: games open an SDL2 window drawn by SDL's renderer, with the same window, drawing, texture, render-target, text, input, timing and audio calls, on Kryon's picture decoding and text and Ziran's core audio. `SetFixedFrameTime` steps headless runs deterministically. Games that ship Ogg Vorbis or MP3 import `std/audio_decode_vorbis` or `std/audio_decode_mp3` and link that codec.

- Use Kryon's public widget modules in shared controls so export-enforced native and portable consumers build cleanly.

- Built on Kryon b9aed758, the Kryon the CSS style package installs into.

- Preserve the surrounding game theme when nested controls finish drawing.

- Swipe steering exposes accepted-step and tap events separately from retained direction.

- A floating touch stick steers in any direction and shows a high-contrast anchor, finger and heading while held.
- Games can share title, pause, settings and movement-control navigation across native and portable hosts.
- A reusable swipe/direction-pad chooser supports continuous touch steering and changing controls during a paused game.
