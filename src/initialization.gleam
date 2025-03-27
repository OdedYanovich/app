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
  type FightBody, type Identification, type Model, Credit, CreditId, Fight,
  FightBody, FightId, Hub, HubBody, HubId, Model, Phase,
}

pub fn init(_flags) {
  Model(
    mod: 0.0 |> HubBody |> Hub,
    volume: 50,
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
    #(#(HubId, key_val.0), change_volume(key_val.1, _))
  })
  |> list.append([
    #(#(HubId, "z"), fn(model) {
      model
      |> morph_to(FightId)
    }),
    #(#(HubId, "c"), fn(model) { model |> morph_to(CreditId) }),
    #(#(HubId, "k"), change_level(_, -1)),
    #(#(HubId, "l"), change_level(_, 1)),
    #(#(FightId, "z"), fn(model) {
      model
      |> morph_to(HubId)
    }),
    #(#(CreditId, "z"), fn(model) {
      model
      |> morph_to(HubId)
    }),
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
      let phases = levels(model.selected_level)
      let assert Ok(phase) = phases |> list.first
      let assert Ok(required_press) = phase.buttons |> string.last
      Model(
        ..model,
        mod: FightBody(
            responses: fight_responses(phase.buttons),
            hp: 5.0,
            initial_presses: 20,
            phases:,
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

fn change_volume(change, model: Model) {
  let assert Hub(hub) = model.mod
  Model(
    ..model,
    mod: hub.timer +. 500.0 |> HubBody |> Hub,
    volume: int.max(int.min(model.volume + change, 100), 0),
  )
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
    #(key, fn(mod: FightBody, latest_key_press: String) {
      use <- guard(mod.required_press != latest_key_press, #(
        FightBody(..mod, hp: mod.hp -. 8.0),
        False,
      ))
      use <- guard(mod.hp >. 80.0, #(FightBody(..mod, hp: 5.0), True))
      let assert Ok(phase) = mod.phases |> list.first
      let assert Ok(#(required_press, rest)) =
        string.pop_grapheme(phase.buttons)
      #(
        FightBody(
          ..mod,
          hp: mod.hp +. 8.0,
          required_press:,
          phases: [Phase(buttons: rest <> required_press, max_press_count: -1)]
            |> list.append(mod.phases |> list.drop(1)),
        ),
        False,
      )
    })
  })
  |> dict.from_list
}
