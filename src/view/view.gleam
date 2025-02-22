import gleam/float
import gleam/int
import gleam/list
import lustre/attribute
import root.{type Model, Credit, Fight, Hub, hub_transition_key}
import update/hub.{volume_buttons}
import view/css.{
  Absolute, Black, BorderBox, Center, Column, Fr, Grid, REM, VH, VW, White,
}

import lustre/element/html

fn text_to_elements(text: List(String)) {
  use text <- list.map(text)
  html.div([], [html.text(text)])
}

pub fn view(model: Model) {
  [
    html.canvas([
      attribute.id("canvas"),
      attribute.width(model.viewport_x),
      attribute.height(model.viewport_y),
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
