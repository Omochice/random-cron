///|
test "\"daily\" parses to the daily schedule" {
  assert_eq(@random_cron.parse_schedule("daily"), Some(@random_cron.Daily))
}

///|
test "\"weekly\" parses to the weekly schedule" {
  assert_eq(@random_cron.parse_schedule("weekly"), Some(@random_cron.Weekly))
}

///|
test "\"monthly\" parses to the monthly schedule" {
  assert_eq(@random_cron.parse_schedule("monthly"), Some(@random_cron.Monthly))
}

///|
test "an unknown word fails to parse" {
  assert_eq(@random_cron.parse_schedule("yearly"), None)
}

///|
/// A random source pinned to the lowest value any range can produce.
fn lowest(_limit : Int) -> Int {
  0
}

///|
test "a daily schedule at the lowest random values" {
  assert_eq(@random_cron.generate(@random_cron.Daily, lowest), "0 0 * * *")
}

///|
/// A random source pinned to the highest value any range can produce.
fn highest(limit : Int) -> Int {
  limit - 1
}

///|
test "a daily schedule at the highest random values" {
  assert_eq(@random_cron.generate(@random_cron.Daily, highest), "59 23 * * *")
}

///|
test "a weekly schedule at the lowest random values" {
  assert_eq(@random_cron.generate(@random_cron.Weekly, lowest), "0 0 * * 0")
}

///|
test "a weekly schedule at the highest random values" {
  assert_eq(@random_cron.generate(@random_cron.Weekly, highest), "59 23 * * 6")
}

///|
test "a monthly schedule at the lowest random values" {
  assert_eq(@random_cron.generate(@random_cron.Monthly, lowest), "0 0 1 * *")
}

///|
test "a monthly schedule at the highest random values" {
  assert_eq(
    @random_cron.generate(@random_cron.Monthly, highest),
    "59 23 28 * *",
  )
}

///|
test "the adapter never returns a value outside the requested bound" {
  let pick = @random_cron.picker(@random.Rand::new())
  for _ in 0..<200 {
    let day_of_week = pick(7)
    assert_true(day_of_week >= 0 && day_of_week < 7)
  }
}

///|
test "two different moments produce two different seeds" {
  assert_not_eq(@random_cron.seed(1, 0), @random_cron.seed(2, 0))
}

///|
test "a seed is 32 bytes long, as ChaCha8 requires" {
  assert_eq(@random_cron.seed(0, 0).length(), 32)
}

///|
test "an invocation with no schedule argument is rejected" {
  try @random_cron.command().parse(argv=[]) catch {
    _ => ()
  } noraise {
    _ => fail("expected the invocation to be rejected")
  }
}

///|
test "an invocation naming a schedule yields that word" {
  let matches = @random_cron.command().parse(argv=["weekly"])
  assert_eq(matches.values.get("schedule"), Some(["weekly"]))
}

///|
test "two runs starting within the same moment produce different seeds" {
  assert_not_eq(@random_cron.seed(1, 1), @random_cron.seed(1, 2))
}
