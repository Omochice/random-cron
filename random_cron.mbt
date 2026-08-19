///|
/// A recurrence that a cron expression can be generated for.
pub(all) enum Schedule {
  Daily
  Weekly
} derive(Show, Eq)

///|
/// Parses a schedule word such as `"daily"` into a `Schedule`.
///
/// Returns `None` when the word names no known schedule.
pub fn parse_schedule(word : String) -> Schedule? {
  match word {
    "daily" => Some(Daily)
    "weekly" => Some(Weekly)
    _ => None
  }
}

///|
/// Generates a cron expression for `schedule`.
///
/// `pick` draws a random integer in `0 ..< limit`. It is injected so that the
/// caller owns the source of randomness and callers under test can pin it.
pub fn generate(schedule : Schedule, pick : (Int) -> Int) -> String {
  let minute = pick(60)
  let hour = pick(24)
  let day_of_week = match schedule {
    Daily => "*"
    Weekly => pick(7).to_string()
  }
  "\{minute} \{hour} * * \{day_of_week}"
}

///|
/// Adapts `rand` into the drawing function `generate` expects.
///
/// The returned function draws a value in `0 ..< limit`.
pub fn picker(rand : @random.Rand) -> (Int) -> Int {
  fn(limit) { rand.int(limit~) }
}

///|
/// Derives a ChaCha8 seed from `moment`, a point in time.
///
/// ChaCha8 falls back to a constant seed, which would make every run of the
/// program produce the same expression, so the seed is varied by the moment the
/// program starts. The eight octets of `moment` occupy the front of the seed and
/// the rest is left zeroed, since ChaCha8 only requires the seed to be 32 bytes.
pub fn seed(moment : UInt64) -> Bytes {
  Bytes::makei(32, fn(i) {
    if i < 8 {
      (moment >> (i * 8)).to_byte()
    } else {
      b'\x00'
    }
  })
}

///|
/// The command line specification of the program.
pub fn command() -> @argparse.Command {
  @argparse.Command::new(
    "random-cron",
    about="Generate a random cron expression for a schedule",
    positionals=[
      @argparse.PositionArg::new(
        "schedule",
        about="One of: daily, weekly",
        num_args=@argparse.ValueRange::single(),
      ),
    ],
  )
}
