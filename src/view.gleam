import gleam/float

import gleam/int
import gleam/list
import lustre/attribute
import root.{type Model, Fight, Hub, Init}
import sketch/lustre as sketch_lustre
import update/responses.{hub_transition_key, volume_buttons}

import sketch/css
import sketch/css/length.{percent, rem, vh, vw}

import sketch/lustre/element/html

fn text_to_elements(text: List(String)) {
  use text <- list.map(text)
  html.div_([], [html.text(text)])
}

pub fn view(model: Model, stylesheet) {
  use <- sketch_lustre.render(stylesheet, [sketch_lustre.node()])
  html.div(css.class([css.width(vw(100)), css.height(vh(100))]), [], [
    html.canvas(
      css.class([
        css.position("absolute"),
        css.width(vw(100)),
        css.height(vh(100)),
        css.background_color("black"),
      ]),
      [
        attribute.style([#("width", "10"), #("height", "10")]),
        attribute.id("canvas"),
      ],
      [],
    ),
    html.div(
      css.class([
        css.position("absolute"),
        css.width(vw(100)),
        css.height(vh(100)),
        css.display("grid"),
        css.grid_template("repeat(5, 1fr) / repeat(2, 1fr)"),
        css.place_items("center"),
        css.grid_auto_flow("column"),
        css.color("white"),
        css.font_size(rem(1.6)),
        css.padding(rem(1.0)),
        css.box_sizing("border-box"),
        css.background(
          "linear-gradient(to left, rgba(255, 0, 0,0.8) "
          <> model.hp |> float.round |> int.to_string
          <> "%, rgba(0,0,0,0))",
        ),
      ]),
      [],
      case model.mod {
        Init | Hub -> {
          [
            hub_transition_key <> " fight",
            "x reset dungeon",
            "c credits",
            "made by Oded Yanovich",
            "volume: " <> int.to_string(model.volume),
          ]
          |> list.map(fn(text) { html.div_([], [html.text(text)]) })
          |> list.append([
            html.div(
              css.class([
                css.display("grid"),
                css.grid_auto_flow("column"),
                css.grid_template("repeat(2, 1fr) / repeat(8, 1fr)"),
                css.place_items("center"),
                css.width(percent(100)),
                css.height(percent(100)),
              ]),
              [attribute.id("volume")],
              volume_buttons
                |> list.flat_map(fn(button__volume_change) {
                  [
                    html.div_([], [button__volume_change.0] |> text_to_elements),
                    html.div_(
                      [],
                      [button__volume_change.1 |> int.to_string]
                        |> text_to_elements,
                    ),
                  ]
                }),
            ),
            html.div(
              css.class([
                css.display("grid"),
                css.grid_template("1fr / repeat(3, 1fr) "),
                css.place_items("center"),
                css.width(percent(100)),
                css.height(percent(100)),
              ]),
              [],
              ["k", model.unlocked_levels |> int.to_string, "l"]
                |> text_to_elements,
            ),
          ])
        }
        Fight -> {
          [
            hub_transition_key <> " Hub",
            "current level: " <> model.unlocked_levels |> int.to_string,
            "required combo: "
              <> model.required_combo |> list.fold("", fn(a, b) { a <> b }),
          ]
          |> text_to_elements
          |> list.append([
            html.img_([
              attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg"),
            ]),
          ])
        }
      },
    ),
  ])
}
