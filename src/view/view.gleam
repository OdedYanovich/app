import audio.{get_val, pass_the_limit}
import gleam/float
import gleam/int
import gleam/list
import level.{displayed_button}
import lustre/attribute
import lustre/element
import lustre/element/html
import root.{
  type FightBody, type Model, type Msg, After, Before, Credit, Fight, Hub,
  IntroductoryFight, StableMod, mod_transition_time, volume_buttons_and_changes,
}
import view/css.{
  type Area, Absolute, Area, Black, Blue, BorderBox, Center, Column, Fr, Green,
  Grid, Precent, REM, Repeat, SubGrid, White, animation, background_color,
  display, grid_area, grid_auto_flow, grid_template, grid_template_areas,
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
    After(_) ->
      animation(
        "entrance "
        <> mod_transition_time /. 1000.0 |> float.to_string
        <> "s ease-out",
      )
    Before(_, _) ->
      animation(
        "exiting "
        <> mod_transition_time /. 1000.0 |> float.to_string
        <> "s ease-out"
        <> " forwards",
      )
    StableMod -> #("", "")
  }
  let fight_area = Area("b")
  let fight_main_body = fn(fight: FightBody) {
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
              grid_area(fight_area),
              transition_animation,
            ],
            grid_standard,
          ]
          |> list.flatten,
        ),
      ],
      [
        "required press: " <> displayed_button(fight),
        fight.hp |> float.to_string,
      ]
        |> text_to_elements([attribute.style([transition_animation])]),
    )
  }

  let Dependency(content, areas) = case model.mod {
    Hub(hub) -> {
      let options = Area("a")
      let volume = Area("c")
      let level_picker = Area("d")
      let level_selector = Area("b")
      let level_selector_buttons = ["a", "s", "d", "f", "z", "x", "c", "v"]
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
                  [
                    grid_area(level_selector),
                    grid_auto_flow(Column),
                    grid_template(Repeat(4, Fr(1)), Repeat(4, Fr(1))),
                    transition_animation,
                  ],
                  grid_standard,
                ]
                |> list.flatten,
              ),
            ],
            [[""] |> list.append(level_selector_buttons |> list.take(3))]
              |> list.append(
                list.range(1, 3)
                |> list.map(fn(_row) {
                  [""]
                  |> list.append(
                    list.range(1, 3)
                    |> list.map(fn(n) { n |> int.to_string }),
                  )
                }),
              )
              |> list.flatten
              |> list.flat_map(fn(level) {
                [
                  html.div([attribute.style([transition_animation])], [
                    level |> html.text,
                  ]),
                ]
              }),
          ),
          html.div(
            [
              attribute.style(
                [
                  grid_standard,
                  [grid_area(level_picker), grid_template_columns(SubGrid)],
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
              "] fight",
              "x reset dungeon",
              "[ credits",
              "volume: " <> model.volume |> get_val |> int.to_string,
            ]
              |> text_to_elements([attribute.style([transition_animation])]),
          ),
        ],
        areas: {
          let line = fn(area) { [options] |> list.append([area, area, area]) }
          [
            line(volume),
            line(level_selector),
            line(level_selector),
            line(level_picker),
          ]
        },
      )
    }
    Fight(fight) -> {
      let options = Area("a")
      Dependency(
        content: [
          fight_main_body(fight),
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
              "] hub",
              "required press: " <> displayed_button(fight),
              "current level: " <> model.selected_level.val |> int.to_string,
            ]
              |> text_to_elements([attribute.style([transition_animation])]),
          ),
        ],
        areas: {
          let line = [options, fight_area, fight_area, fight_area]
          [line, line, line]
        },
      )
    }
    Credit -> {
      let options = Area("a")
      let credit = Area("b")
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
            ["[ Hub", "todo"]
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
    IntroductoryFight(fight) ->
      Dependency(content: [fight_main_body(fight)], areas: [[fight_area]])
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
