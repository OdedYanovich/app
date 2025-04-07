import audio.{get_val, pass_the_limit}
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
  grid_template, grid_template_columns, grid_template_rows, height, place_items,
  width,
}

fn text_to_elements(text: List(String), attributes) {
  use text <- list.map(text)
  html.div(attributes, [html.text(text)])
}

pub fn view(model: Model) {
  let grid_standard = [
    display(Grid),
    width(Precent(100)),
    height(Precent(100)),
    place_items(Center),
  ]
  let Dependency(main_screen, side_screen) = case model.mod {
    Hub(hub) -> {
      let side_screen_content =
        [
          "z fight",
          "x reset dungeon",
          "c credits",
          "volume: " <> model.volume |> get_val |> int.to_string,
        ]
        |> text_to_elements([
          attribute.style([#("animation", "growAndFade 3s infinite ease-out")]),
        ])
      Dependency(
        main_screen: html.div(
          [
            attribute.style(
              [grid_standard, [grid_template_rows(Unique([Fr(2), Fr(1)]))]]
              |> list.flatten,
            ),
          ],
          [
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
                      grid_template(Repeat(2, Fr(1)), Repeat(8, Fr(1))),
                    ],
                    grid_standard,
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
                    case model.volume |> pass_the_limit {
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
                attribute.style(
                  [grid_standard, [grid_template_columns(Repeat(3, Fr(1)))]]
                  |> list.flatten,
                ),
              ],
              ["k", model.selected_level.val |> int.to_string, "l"]
                |> text_to_elements([]),
            ),
          ],
        ),
        side_screen: html.div(
          [
            attribute.style(
              [
                grid_standard,
                [
                  grid_template_rows(Repeat(
                    side_screen_content |> list.length,
                    Fr(1),
                  )),
                ],
              ]
              |> list.flatten,
            ),
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
        |> text_to_elements([])

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
                  grid_template_rows(Repeat(
                    side_screen_content |> list.length,
                    Fr(1),
                  )),
                ],
                grid_standard,
              ]
              |> list.flatten,
            ),
          ],
          [],
        ),
        side_screen: html.div(
          [
            attribute.style(
              [
                grid_standard,
                [
                  grid_template_rows(Repeat(
                    side_screen_content |> list.length,
                    Fr(1),
                  )),
                ],
              ]
              |> list.flatten,
            ),
          ],
          side_screen_content,
        ),
      )
    }
    Credit -> {
      let side_screen_content =
        ["z Hub", "todo"]
        |> text_to_elements([])
        |> list.append([
          html.div(
            [attribute.style([place_items(Center)])],
            ["made by", "oded yanovich"]
              |> text_to_elements([]),
          ),
        ])
      Dependency(
        main_screen: html.div(
          [
            attribute.style(
              [grid_standard, [grid_template_rows(Repeat(2, Fr(1)))]]
              |> list.flatten,
            ),
          ],
          [
            html.img([
              attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg"),
            ]),
          ],
        ),
        side_screen: html.div(
          [
            attribute.style(
              [
                grid_standard,
                [
                  grid_template_rows(Repeat(
                    side_screen_content |> list.length,
                    Fr(1),
                  )),
                ],
              ]
              |> list.flatten,
            ),
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
              css.grid_template(Repeat(1, Fr(1)), Unique([Fr(1), Fr(3)])),
              css.grid_auto_flow(Column),
              css.color(White),
              css.font_size(REM(1.6)),
              css.padding(REM(1.0)),
              css.box_sizing(BorderBox),
              css.left(REM(0.0)),
              css.top(REM(0.0)),
            ],
            grid_standard,
            // attribute.style([#("transition", "700ms")])
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
