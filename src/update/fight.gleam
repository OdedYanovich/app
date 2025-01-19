import gleam/list
import update/hub.{hub_transition_key}
import update/types.{type Model, Fight, FightStart, Hub, Model}

const command_keys_temp = ["f", "g", "h"]

pub fn start_actions() {
  #(#(hub_transition_key, FightStart), fn(model) {
    Model(
      ..model,
      mod: Hub,
      player_combo: [],
      required_combo: command_keys_temp
        |> list.shuffle,
      fight_character_set: command_keys_temp,
    )
  })
}

pub fn actions() {
  #(#(hub_transition_key, Fight), fn(model: Model) {
    case
      model.player_combo |> list.length == model.required_combo |> list.length
    {
      True -> {
        Model(
          ..model,
          required_combo: model.fight_character_set |> list.shuffle,
          hp: case model.player_combo == model.required_combo {
            True -> 10
            False -> -10
          },
        )
      }
      False -> model
    }
  })
}
