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
