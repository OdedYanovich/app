import gleam/float
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element/html
import responses/hub.{volume_buttons}
import root.{type Model, Credit, Fight, Hub}
import view/css.{
  Absolute, Black, BorderBox, Center, Column, Fr, Grid, REM, VH, VW, White,
}

fn text_to_elements(text: List(String)) {
  use text <- list.map(text)
  html.div([], [html.text(text)])
}

pub fn view(model: Model) {
  html.div([], [
    html.canvas([
      attribute.id("canvas"),
      attribute.width(model.viewport_width),
      attribute.height(model.viewport_height),
      attribute.style([
        css.position(Absolute),
        css.background_color(Black),
        css.left(REM(0.0)),
        css.top(REM(0.0)),
      ]),
    ]),
    html.div(
      [
        attribute.style([
          css.position(Absolute),
          css.width(VW(100)),
          css.height(VH(100)),
          css.display(Grid),
          css.grid_template(#(5, Fr(1)), #(2, Fr(1))),
          css.place_items(Center),
          css.grid_auto_flow(Column),
          css.color(White),
          css.font_size(REM(1.6)),
          css.padding(REM(1.0)),
          css.box_sizing(BorderBox),
          css.left(REM(0.0)),
          css.top(REM(0.0)),
          #(
            "background",
            "linear-gradient(to left, rgba(0, 255, 0,0.3) "
              <> model.hp |> float.round |> int.to_string
              <> "%, rgba(0,0,0,0))",
          ),
        ]),
      ],
      case model.mod {
        Hub -> {
          [
            "z fight",
            "x reset dungeon",
            "c credits",
            "made by Oded Yanovich",
            "volume: " <> model.volume |> int.to_string,
          ]
          |> text_to_elements
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
                  #(
                    "background-color",
                    case model.timer >. model.program_duration {
                      True -> "green"
                      False -> "blue"
                    },
                  ),
                ]),
              ],
              volume_buttons
                |> list.flat_map(fn(button__volume_change) {
                  [
                    html.div([], [button__volume_change.0 |> html.text]),
                    html.div([], [
                      button__volume_change.1
                      |> int.to_string
                      |> html.text,
                    ]),
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
            "z Hub",
            "required combo: "
              <> model.required_combo
            |> list.fold("", fn(state, addition) { state <> " " <> addition }),
            "current level: " <> model.selected_level |> int.to_string,
            "relevant buttons: "
              <> model.level.buttons
            |> list.fold("", fn(state, addition) { state <> " " <> addition }),
          ]
          |> text_to_elements
        }
        Credit -> {
          ["z Hub", "todo"]
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
