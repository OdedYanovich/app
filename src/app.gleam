import gleam/dynamic/decode
import lustre
import update/update.{init, update}
import view.{view}

@external(javascript, "./event_listener.mjs", "keyboardEvents")
pub fn keyboard_events(handler: fn(decode.Dynamic) -> any) -> Nil

pub fn main() {
  let assert Ok(_runtime) =
    lustre.application(init, update, view) |> lustre.start("#app", Nil)
}
