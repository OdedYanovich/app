// import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Dynamic}
import gleam/result
import lustre
import root.{Keydown, Keyup}
import update/update.{init, update}
import view.{view}

@external(javascript, "./event_listener.mjs", "initialize")
fn initialize(
  key_up_event_handler: fn(Dynamic) -> any,
  key_down_event_handler: fn(Dynamic) -> any,
) -> Nil

// @external(javascript, "./event_listener.mjs", "initialize")
// fn initialize(
//   key_up_event_handler: fn(Dynamic) -> any,
//   key_down_event_handler: fn(Dynamic) -> any,
// ) -> Nil

pub fn main() {
  let assert Ok(runtime) =
    lustre.simple(init, update, view) |> lustre.start("#app", Nil)

  initialize(fn(_handler) { runtime(lustre.dispatch(Keyup)) }, fn(handler) {
    let key = decode.run(handler, decode.string)
    use key <- result.try(dynamic.field("key", dynamic.string)(handler))
    use repeat <- result.try(dynamic.field("repeat", dynamic.bool)(handler))
    case repeat {
      False -> {
        runtime(lustre.dispatch(Keydown(key)))
        Ok(Nil)
      }
      _ -> Ok(Nil)
    }
  })
  // initialize(fn(_handler) { runtime(lustre.dispatch(Keyup)) }, fn(handler) {
  //   use key <- result.try(dynamic.field("key", dynamic.string)(handler))
  //   use repeat <- result.try(dynamic.field("repeat", dynamic.bool)(handler))
  //   case repeat {
  //     False -> {
  //       runtime(lustre.dispatch(Keydown(key)))
  //       Ok(Nil)
  //     }
  //     _ -> Ok(Nil)
  //   }
  // })
  // 
  // use handler <- initialize()
  // // use handler <- initialize(fn(_handler) { runtime(lustre.dispatch(Keyup)) })
  // use key <- result.try(dynamic.field("key", dynamic.string)(handler))
  // use repeat <- result.try(dynamic.field("repeat", dynamic.bool)(handler))
  // case repeat {
  //   False -> {
  //     runtime(lustre.dispatch(Keydown(key)))
  //     Ok(Nil)
  //   }
  //   _ -> Ok(Nil)
  // }
  //
}
