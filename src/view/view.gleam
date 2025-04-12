import audio.{get_val, pass_the_limit}
import gleam/float
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html
import root.{
  type Model, type Msg, After, Before, Credit, Fight, Hub, IntroductoryFight,
  StableMod, mod_transition_time, volume_buttons_and_changes,
}
import view/css.{
  type Area, Absolute, Area, Black, Blue, BorderBox, Center, Column, Fr, Green,
  Grid, Precent, REM, Repeat, SubGrid, White, background_color, display,
  grid_area, grid_auto_flow, grid_template, grid_template_areas,
  grid_template_columns, grid_template_rows, height, place_items, width,
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
  let transition_animation = case model.mod_transition {
    After(_) -> #(
      "animation",
      "entrance "
        <> mod_transition_time /. 1000.0 |> float.to_string
        <> "s ease-out",
    )
    Before(_, _) -> #(
      "animation",
      "exiting "
        <> mod_transition_time /. 1000.0 |> float.to_string
        <> "s ease-out",
    )
    StableMod -> #("", "")
  }
  let Dependency(content, areas) = case model.mod {
    Hub(hub) -> {
      let options = Area("side")
      let volume = Area("volume")
      let level_selector = Area("level_selector")
      Dependency(
        content: [
          html.div(
            [
              attribute.id("volume"),
              attribute.style(
                [
                  [
                    grid_area(volume),
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
                    transition_animation,
                  ],
                  grid_standard,
                ]
                |> list.flatten,
              ),
            ],
            volume_buttons_and_changes
              |> list.map(fn(x) { #(x.0, x.1 |> int.to_string) })
              |> list.append([
                #("o", case model.volume |> pass_the_limit {
                  False -> "mute"
                  True -> "unmute"
                }),
              ])
              |> list.flat_map(fn(button_volume_change) {
                [
                  html.div([attribute.style([transition_animation])], [
                    button_volume_change.0 |> html.text,
                  ]),
                  html.div([attribute.style([transition_animation])], [
                    button_volume_change.1 |> html.text,
                  ]),
                ]
              }),
          ),
          html.div(
            [
              attribute.style(
                [
                  grid_standard,
                  [grid_area(level_selector), grid_template_columns(SubGrid)],
                ]
                |> list.flatten,
              ),
            ],
            ["k", model.selected_level.val |> int.to_string, "l"]
              |> text_to_elements([attribute.style([transition_animation])]),
          ),
          html.div(
            [
              attribute.style(
                [
                  grid_standard,
                  [grid_area(options), grid_template_rows(SubGrid)],
                ]
                |> list.flatten,
              ),
            ],
            [
              "z fight",
              "x reset dungeon",
              "c credits",
              "volume: " <> model.volume |> get_val |> int.to_string,
            ]
              |> text_to_elements([attribute.style([transition_animation])]),
          ),
        ],
        areas: {
          let line = fn(area) { [options] |> list.append([area, area, area]) }
          [line(volume), line(volume), line(volume), line(level_selector)]
        },
      )
    }
    Fight(fight) -> {
      let options = Area("options")
      let action = Area("action")
      Dependency(
        content: [
          html.div(
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
                    grid_area(action),
                  ],
                  [transition_animation],
                  grid_standard,
                ]
                |> list.flatten,
              ),
            ],
            [],
          ),
          html.div(
            [
              attribute.style(
                [
                  grid_standard,
                  [grid_area(options), grid_template_rows(SubGrid)],
                ]
                |> list.flatten,
              ),
            ],
            [
              "z go back",
              "required press: " <> fight.required_press,
              "current level: " <> model.selected_level.val |> int.to_string,
            ]
              |> text_to_elements([attribute.style([transition_animation])]),
          ),
        ],
        areas: {
          let line = [options, action, action, action]
          [line, line, line]
        },
      )
    }
    Credit -> {
      let options = Area("options")
      let credit = Area("credit")
      Dependency(
        content: [
          html.img([
            attribute.style([grid_area(credit), transition_animation]),
            attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg"),
          ]),
          html.div(
            [
              attribute.style(
                [
                  grid_standard,
                  [grid_area(options), grid_template_rows(SubGrid)],
                ]
                |> list.flatten,
              ),
            ],
            ["c Hub", "todo"]
              |> text_to_elements([attribute.style([transition_animation])])
              |> list.append([
                html.div(
                  [attribute.style([place_items(Center), transition_animation])],
                  ["made by", "oded yanovich"]
                    |> text_to_elements([]),
                ),
              ]),
          ),
        ],
        areas: {
          let line = [options, credit, credit, credit]
          [line, line, line]
        },
      )
    }
    IntroductoryFight(fight) -> {
      let action = Area("action")
      Dependency(
        content: [
          html.div(
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
                    grid_area(action),
                  ],
                  [transition_animation],
                  grid_standard,
                ]
                |> list.flatten,
              ),
            ],
            ["required press: " <> fight.required_press]
              |> text_to_elements([attribute.style([transition_animation])]),
          ),
        ],
        areas: {
          let line = [action, action, action]
          [line, line, line]
        },
      )
    }
  }
  [
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
              css.grid_auto_flow(Column),
              css.color(White),
              css.font_size(REM(1.6)),
              css.padding(REM(1.0)),
              css.box_sizing(BorderBox),
              css.left(REM(0.0)),
              css.top(REM(0.0)),
              grid_template_areas(areas),
            ],
            grid_standard,
            // attribute.style([#("transition", "700ms")])
          ]
          |> list.flatten,
        ),
      ],
      content,
    ),
  ]
  |> html.div([], _)
}

type ModDependent {
  Dependency(content: List(element.Element(Msg)), areas: List(List(Area)))
}
