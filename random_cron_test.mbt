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
