import gleam/dynamic.{type Dynamic, any}
import gleam/int
import gleam/result
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event

// import lustre/event

// @external(javascript, "./event_listener.mjs", "initialize")
// fn initialize() -> Nil

@external(javascript, "./event_listener.mjs", "initialize")
fn initialize(handler: fn(Dynamic) -> any) -> Nil

@external(javascript, "./event_listener.mjs", "getCurrentKey")
fn get_currant_key() -> String

pub fn bar() {
  "bar"
}

pub fn main() {
  let assert Ok(runtime) =
    lustre.application(init, update, view) |> lustre.start("#app", Nil)

  use handler <- initialize
  use key <- result.try(dynamic.field("key", dynamic.string)(handler))
  case key {
    "t" | "T" -> {
      runtime(lustre.dispatch(Increment))
      Ok(Nil)
    }
    _ -> Ok(Nil)
  }
}

type Model =
  Int

fn init(_flags) {
  #(0, effect.none())
}

type Msg {
  Increment
  Decrement
  Key
}

fn endpoint(dispatch) {
  case get_currant_key() {
    "r" -> Increment
    _ -> Decrement
  }
  |> dispatch
}

fn update(model: Model, msg: Msg) {
  case msg {
    Increment -> #(model + 1, effect.none())
    Decrement -> #(model - 1, effect.none())
    Key -> #(model, effect.from(endpoint))
  }
}

// fn view(model: Model) -> element.Element(Msg) {
//   html.div([], [
//     html.img([attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg")]),
//     [event.on_click(Increment)] |> html.button([element.text("+")]),
//     int.to_string(model) |> element.text,
//     // [event.on("k", fn(event) -> Msg { Decrement })]
//     //   |> html.button([element.text("-")]),
//     [event.on_click(Decrement)] |> html.button([element.text("-")]),
//     [event.on_click(Key)] |> html.button([element.text("temp")]),
//   ])
// }

fn view(model: Model) -> element.Element(Msg) {
  html.body([], [
    html.div([attribute.id("app")], [
      html.div([], [
        html.img([attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg")]),
        [event.on_click(Increment)] |> html.button([element.text("+")]),
        int.to_string(model) |> element.text,
        // [event.on("k", fn(event) -> Msg { Decrement })]
        //   |> html.button([element.text("-")]),
        [event.on_click(Decrement)] |> html.button([element.text("-")]),
        [event.on_click(Key)] |> html.button([element.text("temp")]),
      ]),
    ]),
  ])
}
