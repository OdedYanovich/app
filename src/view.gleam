import gleam/float

import gleam/int
import gleam/list
import lustre/attribute
import root.{type Model, Fight, Hub}
import sketch/lustre as sketch_lustre
import update/responses.{hub_transition_key, volume_buttons}

import sketch/css
import sketch/css/length.{percent, rem, vh}

import sketch/lustre/element/html

fn text_to_elements(text: List(String)) {
  use text <- list.map(text)
  html.div_([], [html.text(text)])
}

pub fn view(model: Model, stylesheet) {
  use <- sketch_lustre.render(stylesheet, [sketch_lustre.node()])
  html.div(
    css.class([
      css.display("grid"),
      css.grid_template("repeat(5, 1fr) / repeat(2, 1fr)"),
      css.place_items("center"),
      css.grid_auto_flow("column"),
      css.height(vh(100)),
      css.color("white"),
      css.font_size(rem(1.6)),
      css.padding(rem(1.0)),
      css.box_sizing("border-box"),
      css.background(
        "linear-gradient(to left, rgb(255, 0, 0) "
        <> model.hp |> float.round |> int.to_string
        <> "%, rgba(0,0,0,1))",
      ),
    ]),
    [attribute.id("canvas")],
    [
      html.canvas(
        css.class([
          css.background_color("blue"),
          css.width(rem(20.0)),
          css.height(rem(20.0)),
        ]),
        [],
        [],
      ),
    ]
      |> list.append(case model.mod {
        Hub -> {
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
                |> list.flat_map(fn(button_and_volume_change_paired) {
                  [
                    html.div_(
                      [attribute.class("ripple")],
                      [button_and_volume_change_paired.0] |> text_to_elements,
                    ),
                    html.div_(
                      [attribute.class("ripple")],
                      [button_and_volume_change_paired.1 |> int.to_string]
                        |> text_to_elements,
                    ),
                  ]
                }),
            ),
          ])
        }
        Fight -> {
          [
            hub_transition_key <> " Hub",
            "latest key press: " <> model.latest_key_press,
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
      }),
  )
}
