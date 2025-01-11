import gleam/dynamic.{type Dynamic}
import gleam/int
import gleam/result
import gleam/string
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event

@external(javascript, "./event_listener.mjs", "initialize")
fn initialize(handler: fn(Dynamic) -> any) -> Nil

pub fn main() {
  let assert Ok(runtime) =
    lustre.application(init, update, view) |> lustre.start("#app", 0)

  use handler <- initialize
  use key <- result.try(dynamic.field("key", dynamic.string)(handler))
  use repeat <- result.try(dynamic.field("repeat", dynamic.bool)(handler))
  let key = string.lowercase(key)
  case key, repeat {
    "t", False -> {
      runtime(lustre.dispatch(Key))
      Ok(Nil)
    }
    _, _ -> Ok(Nil)
  }
}

type Model =
  Int

fn init(flags) {
  #(flags, effect.none())
}

type Msg {
  Key
}

fn update(model: Model, msg: Msg) {
  #(
    case msg {
      Key -> model + 1
    },
    effect.none(),
  )
}

fn view(model: Model) -> element.Element(Msg) {
  html.div([], [
    [event.on_click(Key)] |> html.button([element.text("+")]),
    int.to_string(model) |> element.text,
    html.img([attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg")]),
  ])
}
