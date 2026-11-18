# Changelog

## [Unreleased]

- `Game2D/Sdl` replaces `Raylib` and `RaylibNull`: games open an SDL2 window drawn by SDL's renderer, with the same window, drawing, texture, render-target, text, input, timing and audio calls, on Kryon's picture decoding and text and Ziran's core audio. `SetFixedFrameTime` steps headless runs deterministically. Games that ship Ogg Vorbis or MP3 import `std/audio_decode_vorbis` or `std/audio_decode_mp3` and link that codec.

- Built on Kryon b9aed758, the Kryon the CSS style package installs into.

- Preserve the surrounding game theme when nested controls finish drawing.

- Swipe steering exposes accepted-step and tap events separately from retained direction.

- A floating touch stick steers in any direction and shows a high-contrast anchor, finger and heading while held.
- Games can share title, pause, settings and movement-control navigation across native and portable hosts.
- A reusable swipe/direction-pad chooser supports continuous touch steering and changing controls during a paused game.
