///|
/// Ends the process with `code`.
///
/// The core library exposes no exit, so the C one is taken directly, the same
/// way `moonbitlang/core/argparse` reaches for it.
#cfg(any(target="native", target="llvm"))
extern "c" fn exit(code : Int) -> Unit = "exit"

///|
/// Reports `message` and ends the process with a failure code.
///
/// The trailing `panic` is never reached; it only gives the function a return
/// type that fits wherever a value is expected.
fn[T] die(message : String) -> T {
  println(message)
  exit(2)
  panic()
}

///|
/// Prints a random cron expression for the schedule named on the command line.
fn main {
  let matches = @lib.command().parse() catch { error => die(error.to_string()) }
  let word = matches.values.get("schedule").unwrap()[0]
  match @lib.parse_schedule(word) {
    Some(schedule) => {
      let generator = @random.Rand::chacha8(seed=@lib.seed(@env.now()))
      println(@lib.generate(schedule, @lib.picker(generator)))
    }
    None => die("unknown schedule: \{word}")
  }
}
