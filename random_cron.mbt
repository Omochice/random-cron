///|
/// A recurrence that a cron expression can be generated for.
pub(all) enum Schedule {
  Daily
  Weekly
} derive(Debug, Eq)

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
/// Derives a ChaCha8 seed from `moment`, a point in time, and `nonce`, a value
/// that separates two runs starting within the same moment.
///
/// ChaCha8 falls back to a constant seed, which would make every run of the
/// program produce the same expression, so the seed is varied by the moment the
/// program starts. A moment alone is not enough: the native clock resolves to
/// whole seconds, so two runs in the same second would still agree.
///
/// The octets of `moment` and `nonce` occupy the front of the seed and the rest
/// is left zeroed, since ChaCha8 only requires the seed to be 32 bytes.
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
/// The released version of the program.
///
/// release-please rewrites this line when it prepares a release, which is what
/// the trailing annotation marks; the number is not maintained by hand.
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
        about="One of: daily, weekly",
        num_args=@argparse.ValueRange::single(),
      ),
    ],
  )
}
