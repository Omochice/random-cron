///|
test "\"daily\" parses to the daily schedule" {
  inspect(@random_cron.parse_schedule("daily"), content="Some(Daily)")
}
