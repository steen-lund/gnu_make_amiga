# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

GNU Make 4.4.1 with the Amiga port restored (upstream removed all Amiga support right after this version). It targets AmigaOS/m68k, natively with SAS/C 6.51 (no ixemul). The current branch (`steen/build-w-gcc`) is about also building it with a cross GCC (`m68k-amigaos-gcc`, installed at `/opt/amiga/bin` on this machine). The `v4.4.1` branch is the main branch. Amiga-specific user docs are in `README.Amiga`.

Almost everything outside `src/amiga.*`, `src/config.ami`, `mk/Amiga.mk` and `SCOPTIONS` is untouched upstream GNU Make, so keep Amiga changes small and guarded by `#ifdef _AMIGA` (the macro used throughout; a few spots use `AMIGA`).

## Building

### Cross-build with GCC (works, from macOS/Linux)

```
PATH=/opt/amiga/bin:$PATH make -f Basic.mk MAKE_HOST=m68k-amigaos OUTDIR=/some/out/dir/
```

`OUTDIR` must end in a slash; keep it outside the repo. `MAKE_HOST=m68k-amigaos` makes `Basic.mk` load `mk/amigaos.mk` (GCC: `m68k-amigaos-gcc -noixemul`, `-lm`), while the SAS/C build uses `mk/Amiga.mk`. This yields an AmigaOS hunk executable; it has only been linked, never run (no emulator checked). GCC-specific code is guarded by `AMIGA_GCC` (defined in `src/mkcustom.h` when `_AMIGA` and `__GNUC__` are both set) and `__GNUC__` blocks in `src/config.ami`. The default Amiga shell stack is too small for make; `__stack` in `src/main.c` only takes effect because `mk/amigaos.mk` links libnix's `swapstack.o` with `-Wl,-u,___stkinit`. Typical issues are libnix clashing with make's own declarations (`concat` is renamed `make_concat` in `makeint.h`; `stpcpy`, `mempcpy`, `strcasecmp`, `umask`, `getenv`, `getopt` are taken from libnix).

### SAS/C and other

There is no working Amiga-hosted bootstrap beyond the upstream "Basic.mk" flow, and none of it has been tested end-to-end (see `README.Amiga`):

- `make -f Basic.mk` — non-autotools build. `Basic.mk` includes `mk/<last word of MAKE_HOST>.mk` (here `mk/Amiga.mk`) for overrides: `CC = sc`, SAS/C-style flags (`IDir`, `To`, `DEF`), and copying `src/config.ami` to `$(OUTDIR)src/config.h`.
- `SCOPTIONS` holds the SAS/C compiler options (`HAVE_CONFIG_H`, `NO_ALLOCA`, `NO_ARCHIVES`, `STARTUP=cres`, ...).
- `build.sh` / `configure` are the upstream Unix paths and don't produce an Amiga build.
- Tests: `make -f Basic.mk check` runs `tests/run_make_tests` (Perl, needs a host able to run the built `make`). Run one category or test with `cd tests && ./run_make_tests -make <path-to-make> <category>[/<test>]` (categories are directories under `tests/scripts`: `features`, `functions`, `misc`, `options`, `targets`, `variables`). Native Amiga runs of the suite aren't realistic.

## Architecture

- `src/amiga.c` / `src/amiga.h`: the port itself — command execution via `SystemTags()` (replaces fork/exec), multi-line command support (`@@` becomes newline), and device-name handling in target names (`c:make : make.o` vs `make:make.o` is decided by surrounding spaces).
- `src/config.ami`: hand-written `config.h` for Amiga (stands in for autoconf output).
- Hooks into core code are `_AMIGA` blocks in `job.c` (job spawning/waiting — the largest), `dir.c`, `function.c` (`$(wildcard)` with Amiga wildcards, shell function), `default.c`, `file.c`, `commands.c`, `expand.c`, `read.c`, `main.c`, `misc.c`, `makeint.h`, `mkcustom.h`.
- `lib/` holds the gnulib bits (alloca, glob, fnmatch, getloadavg) that `mk/Amiga.mk` adds to the source list; `Basic.mk` generates `alloca.h`, `fnmatch.h`, `glob.h` from the `.in.h` files.
- Other-platform files (`src/w32`, `vms*`, `README.W32`/`DOS`/`OS2`/`VMS`, `mk/*.mk` for other OSes, `configh.dos`) are upstream and irrelevant to Amiga work.
