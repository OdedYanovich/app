import gleam/int
import lustre
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event

@external(javascript, "./event_listener.mjs", "initialize")
fn initialize(_: fn(a) -> Nil) -> Nil

// @external(javascript, "./event_listener.mjs", "getCurrentKey")
// fn get_currant_key() -> String

@external(javascript, "./event_listener.mjs", "getCurrentKey")
fn get_currant_key(_t: fn(a) -> Nil) -> Nil

pub fn bar() {
  "foo"
}

pub fn main() {
  let assert Ok(_) =
    lustre.application(init, update, view) |> lustre.start("#app", Nil)

  Nil
}

type Model =
  Int

fn init(_flags) {
  #(0, effect.from(initialize))
}

type Msg {
  Increment
  Decrement
}

fn update(model: Model, msg: Msg){
  #(case msg {
    Increment -> model + 1
    Decrement -> model - 1
  },effect.from(get_currant_key)
  )
}

fn view(model: Model) -> element.Element(Msg) {
  // case get_curreant_key() {
  //   "r" -> Increment

  //   _ -> Decrement
  // }

  html.div(
    [
      // case get_currant_key() {
      //   "r" -> Increment

      //   _ -> Decrement
      // },
      event.on_input(fn(key) {
        case key {
          "r" -> Increment

          _ -> Decrement
        }
      }),
      // event.on_mouse_enter(Decrement),
    ],
    [html.text("r"), int.to_string(model) |> element.text],
  )
}
