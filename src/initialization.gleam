import ffi/gleam/main.{get_viewport_size}
import gleam/bool.{guard}
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None}

import gleam/result
import root.{
  type Identification, type Model, Credit, CreditId, EndDmg, Fight, FightId, Hub,
  HubId, Model, Phase, StartDmg, add_effect, all_command_keys, effectless,
}

pub fn init(_flags) {
  Model(
    mod: Hub(0.0),
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
  |> effectless
}

fn responses() {
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

fn morph_to(model: Model, mod: Identification) {
  case mod {
    HubId ->
      Model(..model, mod: Hub(0.0))
      |> add_effect(case model.mod {
        Fight(_, _, _, _, _, _, _) -> fn(dispatch) { dispatch(EndDmg) }
        _ -> fn(_dispatch) { Nil }
      })
    FightId -> {
      Model(
        ..model,
        mod: Fight(
          responses: fight_responses(),
          hp: 5.0,
          buttons: all_command_keys
            |> level_buttons(model.selected_level),
          initial_presses: 20,
          phases: [
            Phase(
              buttons: all_command_keys
                |> level_buttons(model.selected_level),
              press_per_minute: 2,
              press_per_mistake: 8,
              time: 1000.0,
              next_phase: fn(_) { 0 },
            ),
          ],
          press_counter: 0,
          required_press: all_command_keys
            |> level_buttons(model.selected_level)
            |> list.sample(1)
            |> list.first
            |> result.unwrap("s"),
        ),
        // hp_lose_interval_id: Some(start_hp_lose(fn() { lustre.dispatch(Dmg) })),
      )
      |> add_effect(fn(dispatch) { dispatch(StartDmg(dispatch)) })
    }
    CreditId -> Model(..model, mod: Credit) |> effectless
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
  let assert Hub(timer) = model.mod
  Model(
    ..model,
    mod: Hub(timer +. 500.0),
    volume: int.max(int.min(model.volume + change, 100), 0),
  )
  |> effectless
}

fn change_level(model, change) {
  Model(..model, selected_level: case model.selected_level + change {
    n if n >= model.unlocked_levels -> model.unlocked_levels
    n if n <= 0 -> 0
    n -> n
  })
  |> effectless
}

fn level_buttons(buttons, current_level) {
  buttons |> list.take(current_level + 1)
}

fn fight_responses() {
  list.map(all_command_keys, fn(key) {
    #(key, fn(model: Model, latest_key_press: String) {
      let assert Fight(
        responses,
        hp,
        required_press,
        initial_presses,
        buttons,
        phases,
        press_counter,
      ) = model.mod
      let mod =
        Fight(
          responses:,
          hp:,
          required_press:,
          initial_presses:,
          buttons:,
          phases:,
          press_counter:,
        )
      use <- guard(
        required_press != latest_key_press,
        Model(..model, mod: Fight(..mod, hp: hp -. 8.0)) |> effectless,
      )
      use <- guard(
        hp >. 80.0,
        Model(
          ..model,
          unlocked_levels: model.unlocked_levels + 1,
          mod: Fight(..mod, hp: 5.0),
        )
          |> morph_to(HubId),
      )
      Model(
        ..model,
        mod: Fight(
          ..mod,
          hp: hp +. 8.0,
          required_press: buttons
            |> list.sample(1)
            |> list.first
            |> result.unwrap("s"),
        ),
        // seed:,
      )
      |> effectless
    })
  })
  |> dict.from_list
}
