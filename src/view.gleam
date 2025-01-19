import gleam/int
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html
import update/root.{type Model, type Msg, Fight, Hub, hub_transition_key}
import update/state_dependent/hub

fn text_to_elements(text: List(String)) {
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
        #(
          "background",
          "linear-gradient(to right, rgba(0,0,0,1) "
            <> model.hp |> int.to_string
            <> "%, rgba(255,0,0,1))",
        ),
      ]),
    ],
    case model.mod {
      Hub -> {
        [
          hub_transition_key <> " fight",
          "x reset dungeon",
          "c credits",
          "made by Oded Yanovich",
          "volume: " <> int.to_string(model.volume),
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
              attribute.id("volume"),
            ],
            hub.volume_buttons
              |> list.flat_map(fn(button_and_volume_change_paired) {
                [
                  html.div(
                    [attribute.class("ripple")],
                    [button_and_volume_change_paired.0] |> text_to_elements(),
                  ),
                  html.div(
                    [attribute.class("ripple")],
                    [button_and_volume_change_paired.1 |> int.to_string]
                      |> text_to_elements,
                  ),
                ]
              }),
          ),
        ])
      }
      Fight(_) -> {
        [
          hub_transition_key <> " Hub",
          "player combo: "
            <> model.player_combo |> list.fold("", fn(a, b) { a <> b }),
          "required combo: "
            <> model.required_combo |> list.fold("", fn(a, b) { a <> b }),
        ]
        |> text_to_elements
        |> list.append([
          html.img([attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg")]),
        ])
      }
    },
  )
}
