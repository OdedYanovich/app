import behavior.{
  type Model, type Msg, Fight, FightStart, Hub, hub_transition_key,
  volume_buttons,
}
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html

fn text_to_element(text: List(String)) {
  use text <- list.map(text)
  html.div([], [html.text(text)])
}

pub fn view(model: Model) -> element.Element(Msg) {
  html.div(
    [
      attribute.style([
        #("display", "grid"),
        #("grid-template", "repeat(5, 1fr) / repeat(2, 1fr)"),
        #("place-items", "center;"),
        #("grid-auto-flow", "column"),
        #("height", "100vh"),
        #("background-color", "black"),
        #("color", "white"),
        #("font-size", "1.6rem"),
        #("padding", "1rem"),
        #("box-sizing", "border-box"),
      ]),
    ],
    case model.mod {
      Hub -> {
        [
          hub_transition_key <> " fight",
          "x reset dungeon",
          "c credits",
          "made by Oded Yanovich",
          int.to_string(model.volume),
        ]
        |> list.map(fn(text) { html.div([], [html.text(text)]) })
        |> list.append([
          html.div(
            [
              attribute.style([
                #("display", "grid"),
                #("grid-auto-flow", "column"),
                #("grid-template", "repeat(2, 1fr) / repeat(8, 1fr)"),
                #("place-items", "center;"),
                #("width", "100%;"),
                #("height", "100%;"),
              ]),
              attribute.class("t"),
            ],
            volume_buttons
              |> list.flat_map(fn(key_val) {
                [key_val.0, int.to_string(key_val.1)]
              })
              |> text_to_element,
          ),
        ])
      }
      Fight | FightStart -> {
        [hub_transition_key <> " Hub", model.player_combo, model.required_combo]
        |> text_to_element
        |> list.append([
          html.img([attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg")]),
        ])
      }
    },
  )
}
