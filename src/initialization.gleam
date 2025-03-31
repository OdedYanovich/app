import ffi/gleam/damage.{start_damage_event, stop_damage_event}
import ffi/gleam/main.{get_viewport_size}
import gleam/bool.{guard}
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None}
import gleam/string
import level.{levels}
import root.{
  type FightBody, type Identification, type Model, Credit, CreditId, DoNothing,
  Fight, FightBody, FightId, Hub, HubBody, HubId, Model, Phase, ToHub,
}

pub fn init(_flags) {
  Model(
    mod: 0.0 |> HubBody |> Hub,
    volume: 150,
    responses: responses(),
    hp_lose_interval_id: None,
    unlocked_levels: 3,
    selected_level: 2,
    program_duration: 0.0,
    viewport_width: get_viewport_size().0,
    viewport_height: get_viewport_size().1,
    // image: image.new(8, 8, #(400.0, 800.0), #(400.0, 400.0)),
  // seed: seed.random(),
  )
}

fn responses() -> dict.Dict(#(root.Identification, String), fn(Model) -> Model) {
  volume_buttons_and_changes
  |> list.map(fn(key_val) {
    #(#(HubId, key_val.0), change_volume(_, key_val.1))
  })
  |> list.append([
    #(#(HubId, "k"), change_level(_, -1)),
    #(#(HubId, "l"), change_level(_, 1)),
    #(#(HubId, "o"), mute_toggle),
    #(#(HubId, "z"), morph_to(_, FightId)),
    #(#(HubId, "c"), morph_to(_, CreditId)),
    #(#(FightId, "z"), morph_to(_, HubId)),
    #(#(CreditId, "z"), morph_to(_, HubId)),
  ])
  |> dict.from_list
}

pub fn morph_to(model: Model, mod: Identification) -> Model {
  case mod {
    HubId -> {
      stop_damage_event()
      Model(..model, mod: 0.0 |> HubBody |> Hub)
    }
    FightId -> {
      start_damage_event()
      let phases = model.selected_level |> levels
      let all_buttons =
        phases
        |> list.fold("", fn(all_buttons, to_add) {
          all_buttons <> to_add.buttons
        })
      let assert [phase, ..other_phses] = phases
      let assert Ok(#(required_press, other_buttons)) =
        string.pop_grapheme(phase.buttons)
      Model(
        ..model,
        mod: FightBody(
            responses: fight_responses(all_buttons),
            hp: 5.0,
            initial_presses: 20,
            phases: [Phase(..phase, buttons: other_buttons <> required_press)]
              |> list.append(other_phses),
            press_counter: 0,
            required_press:,
          )
          |> Fight,
      )
    }
    CreditId -> Model(..model, mod: Credit)
  }
}

pub const volume_buttons_and_changes = [
  #("q", -25),
  #("w", -10),
  #("e", -5),
  #("r", -1),
  #("t", 1),
  #("y", 5),
  #("u", 10),
  #("i", 25),
]

fn change_volume(model: Model, change) {
  Model(
    ..model,
    mod: model.program_duration +. 500.0 |> HubBody |> Hub,
    volume: int.max(int.min(model.volume + change, 100), 0),
  )
}

fn mute_toggle(model: Model) {
  case model.volume > 100 {
    True -> Model(..model, volume: model.volume - 100)
    False -> Model(..model, volume: model.volume + 100)
  }
}

fn change_level(model, change) {
  Model(..model, selected_level: case model.selected_level + change {
    n if n >= model.unlocked_levels -> model.unlocked_levels
    n if n <= 0 -> 0
    n -> n
  })
}

fn fight_responses(buttons) {
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
