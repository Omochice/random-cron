///|
/// Taken from C because the core library exposes no exit of its own.
#cfg(any(target="native", target="llvm"))
extern "c" fn exit(code : Int) -> Unit = "exit"

///|
/// Seeds alongside the clock, which resolves to whole seconds on this backend
/// and so cannot tell two runs in one second apart.
#cfg(any(target="native", target="llvm"))
extern "c" fn getpid() -> Int = "getpid"

///|
/// The trailing `panic` is never reached; it only gives the function a return
/// type that fits wherever a value is expected.
fn[T] die(message : String) -> T {
  println(message)
  exit(2)
  panic()
}

///|
fn main {
  let matches = @lib.command().parse() catch { error => die(error.to_string()) }
  let word = matches.values.get("schedule").unwrap()[0]
  match @lib.parse_schedule(word) {
    Some(schedule) => {
      let generator = @random.Rand::chacha8(
        seed=@lib.seed(@env.now(), getpid().to_uint64()),
      )
      println(@lib.generate(schedule, @lib.picker(generator)))
    }
    None => die("unknown schedule: \{word}")
  }
}
