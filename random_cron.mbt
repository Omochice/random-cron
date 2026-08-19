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
  match schedule {
    Daily => "\{minute} \{hour} * * *"
    Weekly => "\{minute} \{hour} * * \{pick(7)}"
  }
}
