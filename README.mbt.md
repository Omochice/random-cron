# Omochice/random_cron

`random-cron` prints a cron expression whose fields are drawn at random within
the ranges a given schedule leaves free. It exists to spread periodic jobs over
the period they belong to, instead of having every machine fire on the hour.

## Usage

The command takes one positional argument naming the schedule. A `daily`
schedule fixes nothing but the minute and the hour, while a `weekly` schedule
also fixes the day of the week.

```console
$ random-cron daily
37 4 * * *

$ random-cron weekly
37 4 * * 3
```

An invocation naming no schedule, or naming one the program does not know, is
reported and exits with status 2. The report goes to standard output rather than
standard error, because the core library offers no way to write to standard
error, so redirecting the output of a failed invocation into a crontab would
place the message in that file.

## Building

The program is built for the native backend, which the module pins, so no
target has to be named on the command line.

```console
moon build
./_build/native/release/build/cmd/main/main.exe daily
```

The flake builds the same binary through a MoonBit toolchain taken from
[moonbit-overlay](https://github.com/moonbit-community/moonbit-overlay), so no
toolchain has to be installed beforehand.

```console
nix build
./result/bin/random-cron daily
```

That toolchain is distributed as binaries for `x86_64-linux`, `x86_64-darwin`
and `aarch64-darwin` only, so the package is exposed on those systems alone.

## Library

The `Omochice/random_cron` package holds every decision the program makes, and
the entry point only reads arguments, seeds the generator and prints. The source
of randomness is passed to `generate` as a function drawing from `0 ..< limit`,
which is what lets the tests state expected expressions exactly rather than
asserting ranges.
