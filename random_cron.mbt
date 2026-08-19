///|
/// A recurrence that a cron expression can be generated for.
pub(all) enum Schedule {
  Daily
  Weekly
  Monthly
} derive(Debug, Eq)

///|
/// Parses a schedule word such as `"daily"` into a `Schedule`.
///
/// Returns `None` when the word names no known schedule.
pub fn parse_schedule(word : String) -> Schedule? {
  match word {
    "daily" => Some(Daily)
    "weekly" => Some(Weekly)
    "monthly" => Some(Monthly)
    _ => None
  }
}

///|
/// Generates a cron expression for `schedule`, drawing each random field with
/// `pick`, which returns a value in `0 ..< limit`.
pub fn generate(schedule : Schedule, pick : (Int) -> Int) -> String {
  let minute = pick(60)
  let hour = pick(24)
  let day_of_month = match schedule {
    Daily | Weekly => "*"
    // Not the full 1 to 31 the field allows: a job past the 28th would skip
    // February, and past the 30th the short months as well.
    Monthly => (pick(28) + 1).to_string()
  }
  let day_of_week = match schedule {
    Daily | Monthly => "*"
    Weekly => pick(7).to_string()
  }
  "\{minute} \{hour} \{day_of_month} * \{day_of_week}"
}

///|
/// Adapts `rand` into the drawing function `generate` expects, returning values
/// in `0 ..< limit`.
pub fn picker(rand : @random.Rand) -> (Int) -> Int {
  fn(limit) { rand.int(limit~) }
}

///|
/// Derives a 32 byte ChaCha8 seed from `moment`, a point in time, and `nonce`.
///
/// Not `moment` alone: the native clock resolves to whole seconds, so two runs
/// within one second would seed alike.
pub fn seed(moment : UInt64, nonce : UInt64) -> Bytes {
  Bytes::makei(32, fn(i) {
    if i < 8 {
      (moment >> (i * 8)).to_byte()
    } else if i < 16 {
      (nonce >> ((i - 8) * 8)).to_byte()
    } else {
      b'\x00'
    }
  })
}

///|
/// Rewritten by release-please through the trailing annotation, not by hand.
let version : String = "0.1.0" // x-release-please-version

///|
/// The command line specification of the program.
pub fn command() -> @argparse.Command {
  @argparse.Command(
    "random-cron",
    about="Generate a random cron expression for a schedule",
    version~,
    positionals=[
      @argparse.PositionArg(
        "schedule",
        about="One of: daily, weekly, monthly",
        num_args=@argparse.ValueRange::single(),
      ),
    ],
  )
}
