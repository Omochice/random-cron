# CONTRIBUTING

This project welcomes contributions.

When raising a problem, we recommend that you first create an issue and then create a PR.

## Setup

This project uses [nix](https://nixos.org).

The module manifest uses the format recent MoonBit toolchains expect, which older ones do not recognise at all, so the toolchain to work with is the one the development shell supplies rather than whatever happens to be installed.

```console
nix develop
```

The following steps assume that shell.

### Build

The program is built for the native backend, which the module pins, so no target has to be named on the command line.

```console
moon build
./_build/native/release/build/cmd/main/main.exe daily
```

The flake builds the same binary without the shell, taking the toolchain from [moonbit-overlay](https://github.com/moonbit-community/moonbit-overlay).

```console
nix build
./result/bin/random-cron daily
```

That toolchain is distributed as binaries for a few platforms only, so the package is exposed on `x86_64-linux` and `aarch64-darwin` alone.

### Test

```console
moon test
```

### Check

```console
nix flake check
```

This is what the CI workflow runs, and it is the gate a change has to pass.
It covers the formatting, the hooks, the workflow linters and the package build, which runs the tests in turn.

### Format

```console
nix fmt
```
