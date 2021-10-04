Fractal README
=============

[![.github/workflows/build-and-publish-sdl.yml](https://github.com/fractal/SDL/actions/workflows/build-and-publish-sdl.yml/badge.svg)](https://github.com/fractal/SDL/actions/workflows/build-and-publish-sdl.yml)

This repository is Fractal's fork of SDL, with a few modifications. We forked SDL so that we can control and optimize it for better integration with the Fractal streaming protocol. For instructions on how to build the Fractal version SDL for development on your platform, consult [the SDL wiki](https://wiki.libsdl.org/Installation) or the [Building](#Building) section below. Note that we will be using the CMake build tools instead of `./configure`.

## Fractal Changelog

- Copy `README.txt` to `README.md` so that GitHub will render it nicely, and update it with our continuous integration workflow

- Enable precision scrolling events

- Allow `Command+W` to passthrough to the application on macOS, instead of being captured by the "Close Window" shortcut

- Enable capturing macOS pinch gestures using Cocoa, to enable pinch-to-zoom on macOS trackpad devices

- Reduce the SDL Metal implementation of updateYUVtexture from two data copies when combining with FFmpeg (FFmpeg &rarr; Staging Texture &rarr; Actual Texture) to one copy (FFmpeg &rarr; Actual Texture). This feature requires FFmpeg `av_malloc` to be pagesize-aligned, which is a modification we made on our own internal FFmpeg fork. This feature also modifies SDL to create one command encoder rather than three

- Added SDL events for detection window occlusion on macOS

- Created a GitHub Actions workflows, `build-and-publish-sdl.yml`, to build, test and publish on Windows, macOS and Linux Ubuntu

- Modified METAL_UpdateTextureNV to take VideoToolbox frames, wrap Metal textures around them, and directly GPU copy those Metal textures to the SDL texture to be rendered. We determine whether to use this hardware transfer or a software copy by checking the arguments to that function - if the Y and UV planes are the same, it's a VideoToolbox frame, and if not, it's a CPU frame.

## Development

Before building or modifying the code, you should pull the latest changes from the public [`libsdl-org/SDL`](https://github.com/libsdl-org/SDL) repository that this repository is forked from. To set up your repository, follow these steps:

1. Clone and enter the repository

```
git clone https://github.com/fractal/SDL && cd SDL
```

2. Add the upstream repository as a remote

```
git remote add upstream https://github.com/libsdl-org/SDL
```

3. Disable pushing to upstream SDL (ensures that git will push to `fractal/SDL` instead of erroring out)

```
git remote set-url --push upstream DISABLE
```

After this, you should be able to list your remotes with `git remote -v` if you ever need to debug.

Since SDL is quite an active project, we will eventually need to work with the latest code. Meanwhile, we need to make sure that our own repository has a sane commit history -- we cannot simply periodically merge the latest SDL on top of our own modifications.

Instead, perform the following steps to incorporate changes from upstream:

1. Fetch the latest changes to the `upstream` remote

```
git fetch upstream
```

2. Rebase on top of your current work

```
git rebase upstream/main
# git rebase upstream/<desired branch> for other upstream branches
```

3. Resolve merge conflicts, if any arise, and push to the Fractal SDL repository

```
git push origin <current branch>
```

## Building

For most purposes, we need only build the `SDL2-Static` target. As with our other C projects, we prefer to build this using CMake as it is a tool we understand well, rather than the `./configure` script that is also included.

We derive the CMake flags as follows. CMake requires an out-of-tree build, meaning we must create a folder `mkdir build` and specify that folder via `-B build`. Unless you need debugging symbols, we should build an optimized release build via `-D CMAKE_BUILD_TYPE=Release`. Our deployment pipeline will always build an optimized release build.

On Windows, SDL2 assumes that we have no access to standard functions like `memcpy`, and tries to define them for us. This is an issue since the Fractal Protocol already does the same, leading to multiple defines. To avoid this, we specify `-D HAVE_LIBC=ON`. To streamline the build, we also specify `-D DIRECTX=OFF` since we don't need it for SDL2. Also, on Windows we must generate NMake Makefiles via `-G "NMake Makefiles"`.

Putting it all together, we build as follows:

```
mkdir build
cmake -S . -B build -D HAVE_LIBC=ON -D DIRECTX=OFF -D CMAKE_BUILD_TYPE=Release # -G "NMake Makefiles" on Windows
cd build
make SDL2-Static # nmake on Windows
```

When configuring this way, the non-static targets may fail, so make sure to only make `SDL2-Static`! Once built, the static binary will be in `build/libSDL2.a`, or `build\SDL2-static.lib` on Windows.

For more complete instructions on how to build the Fractal SDL for a wider variety of platforms and with far more granular settings, consult [the SDL wiki](https://wiki.libsdl.org/Installation). Whenever possible, we prefer to use the CMake setup instead of `./configure`.

## Publishing

For every push to `main`, for instance when we pull the latest changes from upstream or if we make changes to SDL and merge to `main`, the static version of SDL on Windows, macOS and Linux Ubuntu will be built and published to AWS S3, via the GitHub Actions workflow `.github/workflows/build-and-publish-sdl.yml`, from where the Fractal protocol retrieves its libraries. The newly-uploaded SDL libraries will be automatically deployed with the next `fractal/fractal` update. **Only stable changes should make it to `main`.**

See the [Changelog](#Changelog) above for the list of changes on top of the public version of SDL that are incorporated in our internal Fractal version of SDL.

---

SDL README
=============

                         Simple DirectMedia Layer

                                  (SDL)

                                Version 2.0

---

https://www.libsdl.org/

Simple DirectMedia Layer is a cross-platform development library designed
to provide low level access to audio, keyboard, mouse, joystick, and graphics
hardware via OpenGL and Direct3D. It is used by video playback software,
emulators, and popular games including Valve's award winning catalog
and many Humble Bundle games.

More extensive documentation is available in the docs directory, starting
with README.md

Enjoy!

Sam Lantinga (slouken@libsdl.org)
