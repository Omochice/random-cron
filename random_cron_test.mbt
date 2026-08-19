///|
test "\"daily\" parses to the daily schedule" {
  inspect(@random_cron.parse_schedule("daily"), content="Some(Daily)")
}

///|
test "\"weekly\" parses to the weekly schedule" {
  inspect(@random_cron.parse_schedule("weekly"), content="Some(Weekly)")
}

///|
test "an unknown word fails to parse" {
  inspect(@random_cron.parse_schedule("yearly"), content="None")
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
test "the adapter never returns a value outside the requested bound" {
  let pick = @random_cron.picker(@random.Rand::new())
  for _ in 0..<200 {
    let day_of_week = pick(7)
    assert_true(day_of_week >= 0 && day_of_week < 7)
  }
}

///|
test "two different moments produce two different seeds" {
  assert_not_eq(@random_cron.seed(1), @random_cron.seed(2))
}
