# game2d

An optional Ziran package for 2D games that use Kryon. The `Game2D` module adds
collision helpers on Kryon geometry; `Game2D/Sdl` is a game's window with
raylib-style calls (`InitWindow`, `BeginDrawing`, `DrawTexturePro`) over SDL2,
and `game2d/navigation` and `game2d/controls` supply the portable menu state
machine and control chooser. README.md is the API reference.

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

- Ziran toolchain: `ba28d7c0a3f5583958a126a30006d92b506e96fb`
- Kryon: `ad43e92a582786c592c3c205a4141c901a385e8c`
- `Sdl` links `sdl2 zlib cairo pangocairo glib-2.0`; games add only the audio
decoders they ship (`std/audio_decode_vorbis`, `std/audio_decode_mp3`).

Commit as Waozi <waozi@proton.me>; ordinary changes stay in CHANGELOG's
`Unreleased` section.
