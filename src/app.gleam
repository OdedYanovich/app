import behavior.{Key, init, update}
import gleam/dynamic.{type Dynamic}
import gleam/result
import lustre
import view.{view}

@external(javascript, "./event_listener.mjs", "initialize")
fn initialize(handler: fn(Dynamic) -> any) -> Nil

pub fn main() {
  let assert Ok(runtime) =
    lustre.simple(init, update, view) |> lustre.start("#app", "F")

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
