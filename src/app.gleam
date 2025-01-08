import gleam/int
import lustre
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event

pub fn main() {
  let assert Ok(_) =
    lustre.simple(init, update, view) |> lustre.start("#app", Nil)

  Nil
}

type Model =
  Int

fn init(_flags) -> Model {
  0
}

type Msg {
  Increment
  Decrement
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Increment -> model + 1
    Decrement -> model - 1
  }
}

fn view(model: Model) -> element.Element(Msg) {
  html.div(
    [
      event.on_keypress(fn(key) {
        case key {
          "r" -> Increment

          _ -> Decrement
        }
      }),
      event.on_mouse_enter(Decrement),
    ],
    [
      html.button([attribute.autofocus(True)], []),
      // html.button([event.on_mouse_enter(Decrement)], [element.text("-")]),
      int.to_string(model) |> element.text,
    ],
  )
}
