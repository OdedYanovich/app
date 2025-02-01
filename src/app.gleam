import gleam/dynamic/decode
import lustre
import sketch
import update/update.{init, update}
import view.{view}

@external(javascript, "./jsffi.mjs", "keyboardEvents")
pub fn keyboard_events(handler: fn(decode.Dynamic) -> any) -> Nil

pub fn main() {
  let assert Ok(stylesheet) = sketch.stylesheet(strategy: sketch.Ephemeral)
  let assert Ok(_runtime) =
    lustre.application(init, update, view(_, stylesheet))
    |> lustre.start("#app", Nil)
}
