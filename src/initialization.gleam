import audio.{change_volume, mute_toggle}
import ffi/gleam/main.{get_storage, get_viewport_size}
import gleam/bool.{guard}
import gleam/dict
import gleam/list
import gleam/string
import root.{
  type FightBody, type Model, Before, CreditId, DoNothing, Fight, FightBody,
  FightId, Hub, HubBody, HubId, IntroductoryFight, Model, Phase, Range, Sound,
  StableMod, ToHub, mod_transition_time, update_range,
  volume_buttons_and_changes,
}

pub fn init(_flags) {
  Model(
    mod: FightBody(
      responses: fight_responses("td"),
      hp: 65.0,
      initial_presses: 20,
      phases: [Phase(buttons: "td", max_press_count: -1)],
      press_counter: 0,
      required_press: "t",
    )
      |> Fight,
    mod_transition: StableMod,
    volume: Range(val: 151, min: 0, max: 100),
    responses: responses(),
    selected_level: case get_storage("selected_level") {
      9999 -> 1
      lv -> lv
    }
      |> Range(0, 3),
    program_duration: 0.0,
    viewport_width: get_viewport_size().0,
    viewport_height: get_viewport_size().1,
    sounds: [
      Sound(id: 0, timer: 0.0, interval: 0.5),
      Sound(id: 1, timer: 0.0, interval: 0.8),
    ],
    // image: image.new(8, 8, #(400.0, 800.0), #(400.0, 400.0)),
  // seed: seed.random(),
  )
}

fn responses() -> dict.Dict(#(root.Identification, String), fn(Model) -> Model) {
  let change_level = fn(model, change) {
    Model(..model, selected_level: update_range(model.selected_level, change))
  }
  let transition = fn(model, id) {
    Model(
      ..model,
      mod_transition: Before(model.program_duration +. mod_transition_time, id),
    )
  }
  volume_buttons_and_changes
  |> list.map(fn(key_val) {
    #(#(HubId, key_val.0), change_volume(_, key_val.1))
  })
  |> list.append([
    #(#(HubId, "k"), change_level(_, -1)),
    #(#(HubId, "l"), change_level(_, 1)),
    #(#(HubId, "o"), mute_toggle),
    #(#(HubId, "z"), transition(_, FightId)),
    #(#(HubId, "c"), transition(_, CreditId)),
    #(#(CreditId, "c"), transition(_, HubId)),
    //#(#(FightId, "z"), transition(_, HubId)),
  ])
  |> dict.from_list
  |> dict.insert(#(FightId, "z"), fn(model) {
    Model(
      ..model,
      mod_transition: Before(
        model.program_duration +. mod_transition_time,
        HubId,
      ),
    )
  })
}

pub fn fight_responses(buttons) {
  list.map(buttons |> string.to_graphemes, fn(key) {
    #(key, fn(fight: FightBody, latest_key_press: String) {
      use <- guard(
        fight.required_press != latest_key_press,
        FightBody(..fight, hp: fight.hp -. 8.0) |> pair(DoNothing),
      )
      use <- guard(fight.hp >. 80.0, FightBody(..fight, hp: 5.0) |> pair(ToHub))
      let #(phases, required_press, press_counter) = case fight.phases {
        [current, next, ..rest]
          if fight.press_counter + 1 == current.max_press_count
        -> {
          let assert Ok(#(required_press, rest_of_buttons)) =
            string.pop_grapheme(next.buttons)
          #(
            [Phase(..next, buttons: rest_of_buttons <> required_press)]
              |> list.append(rest)
              |> list.append([current]),
            required_press,
            0,
          )
        }
        [current, ..rest] -> {
          let assert Ok(#(required_press, rest_of_buttons)) =
            string.pop_grapheme(current.buttons)
          #(
            [Phase(..current, buttons: rest_of_buttons <> required_press)]
              |> list.append(rest),
            required_press,
            fight.press_counter + 1,
          )
        }
        _ -> panic
      }
      FightBody(
        ..fight,
        hp: fight.hp +. 8.0,
        required_press:,
        press_counter:,
        phases:,
      )
      |> pair(DoNothing)
    })
  })
  |> dict.from_list
}

fn pair(a, b) {
  #(a, b)
}
