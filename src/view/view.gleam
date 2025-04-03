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
  REM, Repeat, Unique, White, background_color, display, grid_auto_flow,
  grid_template, height, place_items, width,
}

fn text_to_elements(text: List(String)) {
  use text <- list.map(text)
  html.div([], [html.text(text)])
}

pub fn view(model: Model) {
  let grid_standard = fn(rows, columns) {
    [
      display(Grid),
      grid_template(Repeat(rows, Fr(1)), Repeat(columns, Fr(1))),
      width(Precent(100)),
      height(Precent(100)),
      place_items(Center),
    ]
  }
  let Dependency(main_screen, side_screen) = case model.mod {
    Hub(hub) -> {
      let side_screen_content =
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
        |> text_to_elements
      Dependency(
        main_screen: html.div([attribute.style(grid_standard(2, 1))], [
          html.div(
            [
              attribute.id("volume"),
              attribute.style(
                [
                  [
                    grid_auto_flow(Column),
                    background_color(
                      case
                        hub.volume_animation_timer >. model.program_duration
                      {
                        True -> Green
                        False -> Blue
                      },
                    ),
                  ],
                  grid_standard(2, 8),
                ]
                |> list.flatten,
              ),
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
            [attribute.style(grid_standard(1, 3))],
            ["k", model.selected_level.val |> int.to_string, "l"]
              |> text_to_elements,
          ),
        ]),
        side_screen: html.div(
          [
            attribute.style(grid_standard(side_screen_content |> list.length, 1)),
          ],
          side_screen_content,
        ),
      )
    }
    Fight(fight) -> {
      let side_screen_content =
        [
          "z go back",
          "required press: " <> fight.required_press,
          "current level: " <> model.selected_level.val |> int.to_string,
        ]
        |> text_to_elements

      Dependency(
        main_screen: html.div(
          [
            attribute.style(
              [
                [
                  #(
                    "background",
                    "linear-gradient(to left, rgba(0, 255, 0,0.3) "
                      <> fight.hp |> float.round |> int.to_string
                      <> "%, rgba(0,0,0,0))",
                  ),
                ],
                grid_standard(side_screen_content |> list.length, 1),
              ]
              |> list.flatten,
            ),
          ],
          [],
        ),
        side_screen: html.div(
          [
            attribute.style(grid_standard(side_screen_content |> list.length, 1)),
          ],
          side_screen_content,
        ),
      )
    }
    Credit -> {
      let side_screen_content =
        ["z Hub", "todo"]
        |> text_to_elements
        |> list.append([
          html.div(
            [attribute.style([place_items(Center)])],
            ["made by", "oded yanovich"]
              |> text_to_elements,
          ),
        ])
      Dependency(
        main_screen: html.div([attribute.style(grid_standard(2, 1))], [
          html.img([attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg")]),
        ]),
        side_screen: html.div(
          [
            attribute.style(grid_standard(side_screen_content |> list.length, 1)),
          ],
          side_screen_content,
        ),
      )
    }
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
        attribute.style(
          [
            [
              css.position(Absolute),
              css.width(Precent(100)),
              css.height(Precent(100)),
              css.display(Grid),
              css.grid_template(Repeat(1, Fr(1)), Unique([Fr(1), Fr(3)])),
              css.place_items(Center),
              css.grid_auto_flow(Column),
              css.color(White),
              css.font_size(REM(1.6)),
              css.padding(REM(1.0)),
              css.box_sizing(BorderBox),
              css.left(REM(0.0)),
              css.top(REM(0.0)),
            ],
            // grid_standard(1,2)
          ]
          |> list.flatten,
        ),
      ],
      [side_screen, main_screen],
    ),
  ])
}

type ModDependent {
  Dependency(
    main_screen: element.Element(Msg),
    side_screen: element.Element(Msg),
  )
}
