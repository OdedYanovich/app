import gleam/bool.{guard}
import gleam/dynamic/decode
import gleam/result.{try}
import lustre
import root.{Keydown}
import update/update.{init, update}
import view.{view}

@external(javascript, "./event_listener.mjs", "keyboardEvents")
fn keyboard_events(handler: fn(decode.Dynamic) -> any) -> Nil

pub fn main() {
  let assert Ok(runtime) =
    lustre.simple(init, update, view) |> lustre.start("#app", Nil)
  use event <- keyboard_events
  use #(key, repeat) <- try(
    decode.run(event, {
      use key <- decode.field("key", decode.string)
      use repeat <- decode.field("repeat", decode.bool)
      decode.success(#(key, repeat))
    }),
  )
  use <- guard(repeat, Ok(Nil))
  runtime(lustre.dispatch(Keydown(key)))
  Ok(Nil)
}
