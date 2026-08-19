///|
/// A recurrence that a cron expression can be generated for.
pub(all) enum Schedule {
  Daily
} derive(Show, Eq)

///|
/// Parses a schedule word such as `"daily"` into a `Schedule`.
///
/// Returns `None` when the word names no known schedule.
pub fn parse_schedule(word : String) -> Schedule? {
  match word {
    "daily" => Some(Daily)
    _ => None
  }
}
