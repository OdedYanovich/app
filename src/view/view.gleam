import audio.{get_val, pass_the_limit}
import ffi/main
import fight.{get_bpm}
import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import initialization
import lustre/attribute
import lustre/element
import lustre/element/html
import root.{
  type FightBody, type Model, type Msg, After, Before, Credit, Fight, Hub,
  IntroductoryFight, None, NorthEast, NorthWest, SouthEast, SouthWest, StableMod,
  mod_transition_time, volume_buttons_and_changes,
}
import sequence_provider.{get_element}
import view/css.{
  type Area, Absolute, Area, Black, BorderBox, Center, Column, Fr, Grid, Precent,
  REM, RGB, RGBA, Repeat, SubGrid, White, animation, background,
  background_color, display, grid_area, grid_auto_flow, grid_template,
  grid_template_areas, grid_template_columns, grid_template_rows, height,
  padding, place_items, width,
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
              grid_area(fight_area),
              grid_template(Repeat(2, Fr(1)), Repeat(2, Fr(1))),
              #("gap", "4rem 4rem"),
            ],
            grid_standard,
          ]
          |> list.flatten,
        ),
      ],
      {
        use group <- list.map([
          initialization.north_west,
          initialization.north_east,
          initialization.south_west,
          initialization.south_east,
        ])
        let group_is_ignored = group.1 == fight.last_action_group
        #(
          group.0
            |> string.to_graphemes
            |> text_to_elements([
              attribute.style([
                case group_is_ignored, model.mod_transition {
                  True, _ | _, Before(_, _) ->
                    animation(
                      "exiting "
                      <> mod_transition_time /. 1000.0 |> float.to_string
                      <> "s ease-out"
                      <> " forwards",
                    )
                  False, _ | _, After(_) ->
                    animation(
                      "entrance "
                      <> mod_transition_time /. 1000.0 |> float.to_string
                      <> "s ease-out",
                    )
                },
              ]),
            ]),
          case
            {
              fight.sequence_provider
              |> get_element
              == case group.1 {
                NorthWest | NorthEast -> True
                SouthWest | SouthEast -> False
                _ -> panic
              }
              |> bool.exclusive_or(fight.direction_randomizer)
            }
            && { !group_is_ignored }
          {
            True -> None
            False -> group.1
          },
        )
      }
        |> list.map(fn(group) {
          html.div(
            [
              attribute.style(
                [
                  [
                    grid_template(Repeat(2, Fr(1)), Repeat(5, Fr(1))),
                    grid_auto_flow(Column),
                    #(
                      "text-shadow",
                      "-1px -1px 0 #000,  
                    1px -1px 0 #000,
                    -1px 1px 0 #000,
                    1px 1px 0 #000;",
                    ),
                    // #("font-size", "1.2rem"),
                    background_color(case group.1 {
                      NorthWest -> RGB(255, 255, 1)
                      NorthEast -> RGB(102, 0, 102)
                      SouthWest -> RGB(0, 140, 0)
                      SouthEast -> RGB(232, 0, 0)
                      _ -> White
                    }),
                  ],
                  grid_standard,
                ]
                |> list.flatten,
              ),
            ],
            group.0,
          )
        }),
    )
  }

  let Dependency(content, areas) = case model.mod {
    Hub(_hub) -> {
      let options = Area("a")
      let volume = Area("c")
      let level_picker = Area("d")
      let level_picker_text = [
        "h",
        "j",
        model.selected_level.val |> int.to_string,
        "k",
        "l",
      ]
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
                    grid_template(Repeat(2, Fr(1)), Repeat(8, Fr(1))),
                  ],
                  grid_standard,
                ]
                |> list.flatten,
              ),
            ],
            volume_buttons_and_changes
              |> list.map(fn(x) { #(x.0, x.1 |> int.to_string) })
              |> list.append([
                // Change to an icon
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
                  ],
                  grid_standard,
                ]
                |> list.flatten,
              ),
            ],
            [
              [""],
              level_selector_buttons |> list.take(3),
              ..list.range(1, 3)
              |> list.map(fn(_row) {
                [""]
                |> list.append(
                  list.range(1, 3)
                  |> list.map(fn(n) { n |> int.to_string }),
                )
              })
            ]
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
            level_picker_text
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
              "[ credits",
              "volume: " <> model.volume |> get_val |> int.to_string,
            ]
              |> text_to_elements([attribute.style([transition_animation])]),
          ),
        ],
        areas: {
          let line = fn(area) {
            let len = level_picker_text |> list.length
            [
              options
                |> list.repeat(len / 3),
              area |> list.repeat(len),
            ]
            |> list.flatten
          }
          [line(volume), line(level_selector), line(level_picker)]
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
              "current level: " <> model.selected_level.val |> int.to_string,
              fight.progress.timestemps |> get_bpm |> float.to_string,
              fight.progress.timestemps |> list.length |> int.to_string,
            ]
              |> text_to_elements([attribute.style([transition_animation])]),
          ),
        ],
        areas: [options, fight_area, fight_area, fight_area] |> list.repeat(4),
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
      attribute.width(main.get_viewport_size().0),
      attribute.height(main.get_viewport_size().1),
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
              padding(REM(1.0)),
              css.box_sizing(BorderBox),
              css.left(REM(0.0)),
              css.top(REM(0.0)),
              grid_template_areas(areas),
              // background_color(case )
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
