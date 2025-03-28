import gleam/float
import gleam/int
import gleam/list
import initialization.{volume_buttons_and_changes}
import lustre/attribute
import lustre/element/html
import root.{type Model, Credit, Fight, Hub}
import view/css.{
  Absolute, Black, BorderBox, Center, Column, Fr, Grid, REM, VH, VW, White,
}

fn text_to_elements(text: List(String)) {
  use text <- list.map(text)
  html.div([], [html.text(text)])
}

pub fn view(model: Model) {
  let #(mod_elements, canvas_mod_attribute) = case model.mod {
    Hub(hub) -> #(
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
                  case hub.volume_animation_timer >. model.program_duration {
                    True -> "green"
                    False -> "blue"
                  },
                ),
              ]),
            ],
            volume_buttons_and_changes
              |> list.flat_map(fn(button_volume_change) {
                [
                  html.div([], [button_volume_change.0 |> html.text]),
                  html.div([], [
                    button_volume_change.1
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
        ]),
      #("", ""),
    )
    Fight(fight) -> #(
      [
        "z go back",
        "required press: " <> fight.required_press,
        "current level: " <> model.selected_level |> int.to_string,
      ]
        |> text_to_elements,
      #(
        "background",
        "linear-gradient(to left, rgba(0, 255, 0,0.3) "
          <> fight.hp |> float.round |> int.to_string
          <> "%, rgba(0,0,0,0))",
      ),
    )
    Credit -> #(
      ["z Hub", "todo"]
        |> text_to_elements
        |> list.append([
          html.img([attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg")]),
        ]),
      #("", ""),
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
          css.grid_template(#(5, Fr(1)), #(2, Fr(1))),
          css.place_items(Center),
          css.grid_auto_flow(Column),
          css.color(White),
          css.font_size(REM(1.6)),
          css.padding(REM(1.0)),
          css.box_sizing(BorderBox),
          css.left(REM(0.0)),
          css.top(REM(0.0)),
          canvas_mod_attribute,
        ]),
      ],
      mod_elements,
    ),
  ])
}
