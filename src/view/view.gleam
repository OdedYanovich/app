import gleam/float
import gleam/int
import gleam/list
import initialization.{volume_buttons_and_changes}
import lustre/attribute
import lustre/element
import lustre/element/html
import root.{type Model, type Msg, Credit, Fight, Hub}
import view/css.{
  Absolute, Black, Blue, BorderBox, Center, Column, Fr, Green, Grid, Precent,
  REM, Repeat, Unique, VH, VW, White, background_color, display, grid_auto_flow,
  grid_template, height, place_items, width,
}

fn text_to_elements(text: List(String)) {
  use text <- list.map(text)
  html.div([], [html.text(text)])
}

pub fn view(model: Model) {
  let Dependency(mod_elements, mod_attribute_for_canvas) = case model.mod {
    Hub(hub) ->
      Dependency(
        elements: [
          html.div(
            [attribute.style([place_items(Center)])],
            ["made by", "oded yanovich"]
              |> text_to_elements,
          ),
        ]
          |> list.append(
            [
              "z fight",
              "x reset dungeon",
              "c credits",
              "volume: "
                <> case model.volume.val > model.volume.max {
                True -> model.volume.val - { model.volume.max + 1 }
                False -> model.volume.val
              }
              |> int.to_string,
            ]
            |> text_to_elements,
          )
          |> list.append([
            html.div(
              [
                attribute.id("volume"),
                attribute.style([
                  display(Grid),
                  width(Precent(100)),
                  height(Precent(100)),
                  grid_auto_flow(Column),
                  grid_template(Repeat(2, Fr(1)), Repeat(8, Fr(1))),
                  place_items(Center),
                  background_color(
                    case hub.volume_animation_timer >. model.program_duration {
                      True -> Green
                      False -> Blue
                    },
                  ),
                ]),
              ],
              volume_buttons_and_changes
                |> list.map(fn(x) {
                  #(x.0 |> html.text, x.1 |> int.to_string |> html.text)
                })
                |> list.append([
                  #(
                    "o" |> html.text,
                    case model.volume.val > 100 {
                      False -> "mute"
                      True -> "unmute"
                    }
                      |> html.text,
                  ),
                ])
                |> list.flat_map(fn(button_volume_change) {
                  [
                    html.div([], [button_volume_change.0]),
                    html.div([], [button_volume_change.1]),
                  ]
                }),
            ),
            html.div(
              [
                attribute.style([
                  display(Grid),
                  grid_template(Unique([Fr(1)]), Repeat(3, Fr(1))),
                  place_items(Center),
                  width(Precent(100)),
                  height(Precent(100)),
                ]),
              ],
              ["k", model.selected_level.val |> int.to_string, "l"]
                |> text_to_elements,
            ),
          ]),
        canvas_attribute: #("", ""),
      )
    Fight(fight) ->
      Dependency(
        elements: [
          "z go back",
          "required press: " <> fight.required_press,
          "current level: " <> model.selected_level.val |> int.to_string,
        ]
          |> text_to_elements,
        canvas_attribute: #(
          "background",
          "linear-gradient(to left, rgba(0, 255, 0,0.3) "
            <> fight.hp |> float.round |> int.to_string
            <> "%, rgba(0,0,0,0))",
        ),
      )
    Credit ->
      Dependency(
        elements: ["z Hub", "todo"]
          |> text_to_elements
          |> list.append([
            html.img([
              attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg"),
            ]),
          ]),
        canvas_attribute: #("", ""),
      )
  }
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
          css.grid_template(Repeat(4, Fr(1)), Unique([Fr(1), Fr(3)])),
          css.place_items(Center),
          css.grid_auto_flow(Column),
          css.color(White),
          css.font_size(REM(1.6)),
          css.padding(REM(1.0)),
          css.box_sizing(BorderBox),
          css.left(REM(0.0)),
          css.top(REM(0.0)),
          mod_attribute_for_canvas,
        ]),
      ],
      mod_elements,
    ),
  ])
}

type ModDependent {
  Dependency(
    elements: List(element.Element(Msg)),
    canvas_attribute: #(String, String),
  )
}
