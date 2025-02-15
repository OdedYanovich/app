import gleam/float
import gleam/int
import gleam/list
import lustre/attribute
import root.{type Model, Credit, Fight, Hub, hub_transition_key}

// import sketch/lustre as sketch_lustre
import update/hub.{volume_buttons}

// import sketch/css
// import sketch/css/length.{percent, px, rem, vh, vw}

import lustre/element/html

fn text_to_elements(text: List(String)) {
  use text <- list.map(text)
  html.div([], [html.text(text)])
}

pub fn view(model: Model) {
  // use <- sketch_lustre.render(stylesheet, [sketch_lustre.node()])
  html.div([attribute.id("wrapper")], [
    html.canvas([
      attribute.id("canvas"),
      attribute.style([
        #("position", "absolute"),
        #("background-color", "black"),
        #("left", "0rem"),
        #("top", "0rem"),
        #("width", "700px"),
        #("height", "700px"),
        // #("object-fit", "cover"),
      ]),
    ]),
    html.div(
      [
        attribute.style([
          #("position", "absolute"),
          #("width", "100vw"),
          #("height", "100vh"),
          #("display", "grid"),
          #("grid-template", "repeat(5,1fr) / repeat(2, 1fr)"),
          #("place-items", "center"),
          #("grid-auto-flow", "column"),
          #("color", "white"),
          #("font-size", "1.6rem"),
          #("padding", "1rem"),
          #("box-sizing", "border-box"),
          #(
            "background",
            "linear-gradient(to left, rgba(255, 0, 0,0.8) "
              <> model.hp |> float.round |> int.to_string
              <> "%, rgba(0,0,0,0))",
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
                attribute.id("volume"),
                attribute.style([
                  #("display", "grid"),
                  #("grid-auto-flow", "column"),
                  #("grid-template", "repeat(2, 1fr) / repeat(8, 1fr)"),
                  #("width", "100%"),
                  #("height", "100%"),
                  #("place-items", "center"),
                  #("background-color", case model.timer >. 0.0 {
                    True -> "green"
                    False -> "blue"
                  }),
                ]),
              ],
              volume_buttons
                |> list.flat_map(fn(button__volume_change) {
                  [
                    html.div([], [button__volume_change.0] |> text_to_elements),
                    html.div(
                      [],
                      [button__volume_change.1 |> int.to_string]
                        |> text_to_elements,
                    ),
                  ]
                }),
            ),
            html.div(
              [
                attribute.style([
                  #("display", "grid"),
                  #("grid-template", "1fr / repeat(3, 1fr)"),
                  #("place-items", "center"),
                  #("width", "100%"),
                  #("height", "100%"),
                ]),
              ],
              ["k", model.selected_level |> int.to_string, "l"]
                |> text_to_elements,
            ),
          ])
        }
        Fight -> {
          [
            hub_transition_key <> " Hub",
            "current level: " <> model.unlocked_levels |> int.to_string,
            "required combo: "
              <> model.required_combo
            |> list.fold("", fn(state, addition) { state <> " " <> addition }),
            "relevant buttons: "
              <> model.fight_character_set
            |> list.fold("", fn(state, addition) { state <> " " <> addition }),
          ]
          |> text_to_elements
        }
        Credit -> {
          [hub_transition_key <> " Hub", "todo"]
          |> text_to_elements
          |> list.append([
            html.img([
              attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg"),
            ]),
          ])
        }
      },
    ),
  ])
}
