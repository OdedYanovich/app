import gleam/dynamic.{type Dynamic}
import gleam/result
import lustre
import update/types.{Key}
import update/update.{init, update}
import view.{view}

@external(javascript, "./event_listener.mjs", "initialize")
fn initialize(handler: fn(Dynamic) -> any) -> Nil

pub fn main() {
  let assert Ok(runtime) =
    lustre.simple(init, update, view) |> lustre.start("#app", Nil)

  use handler <- initialize
  use key <- result.try(dynamic.field("key", dynamic.string)(handler))
  use repeat <- result.try(dynamic.field("repeat", dynamic.bool)(handler))
  case repeat {
    False -> {
      runtime(lustre.dispatch(Key(key)))
      Ok(Nil)
    }
    _ -> Ok(Nil)
  }
}
