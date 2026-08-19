# random-cron

`random-cron` prints a cron expression whose fields are drawn at random within the ranges a given schedule leaves free.
It exists to spread periodic jobs over the period they belong to, instead of having every machine fire on the hour.

## Usage

The command takes one positional argument naming the schedule.
A `daily` schedule fixes nothing but the minute and the hour, a `weekly` schedule also fixes the day of the week, and a `monthly` schedule fixes the day of the month instead.

```console
$ random-cron daily
37 4 * * *

$ random-cron weekly
37 4 * * 3

$ random-cron monthly
37 4 12 * *
```

The day of the month is drawn from 1 to 28, never later, so that a monthly job fires in every month rather than skipping the short ones.

An invocation naming no schedule, or naming one the program does not know, is reported and exits with status 2.
The report goes to standard output rather than standard error, because the core library offers no way to write to standard error, so redirecting the output of a failed invocation into a crontab would place the message in that file.

## Building

Building from source, running the tests and running the checks are described in [CONTRIBUTING.md](./CONTRIBUTING.md).

## Library

The `Omochice/random_cron` package holds every decision the program makes, and the entry point only reads arguments, seeds the generator and prints.
The source of randomness is passed to `generate` as a function drawing from `0 ..< limit`, which is what lets the tests state expected expressions exactly rather than asserting ranges.
