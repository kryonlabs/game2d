# game2d

An optional Ziran package for 2D games that use Kryon. The `Game2D` module adds
collision helpers on Kryon geometry; `Game2D/Sdl` is a game's window with
raylib-style calls (`InitWindow`, `BeginDrawing`, `DrawTexturePro`) over SDL2,
and `game2d/navigation` and `game2d/controls` supply the portable menu state
machine and native control implementations. Screens compose components from
`Game2D/tsx/controls`; native composition functions are package-private.
README.md is the API reference.

## Layout

| Path | Contents |
| --- | --- |
| `src/` | Package modules; lowercase names are implementation modules |
| `tests/` | Package tests |
| `Makefile` | `make test` runs the test suite |

## Commands

```sh
make test    # package tests
```

## Pins and links

- Ziran toolchain: `dc3ecf0aabd1630881c13783a660ca8b298eff88`
- Kryon: `e2b0fbd89167f9bf599efed1865f198ba715786e`
- `Sdl` links `sdl2 zlib cairo pangocairo glib-2.0`; games add only the audio
decoders they ship (`std/audio_decode_vorbis`, `std/audio_decode_mp3`).

Commit as Waozi <waozi@proton.me>; ordinary changes stay in CHANGELOG's
`Unreleased` section.
