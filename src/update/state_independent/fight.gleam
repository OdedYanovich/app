import gleam/list
import update/root.{Fight, Hub, Irrelevant, Model, hub_transition_key}
import update/state_dependent/fight

const command_keys_temp = ["f", "g", "h"]

pub fn responses() {
  [
    #(#(hub_transition_key, Fight(Irrelevant)), fn(model) {
      Model(
        ..model,
        mod: Hub,
        player_combo: [],
        fight_character_set: command_keys_temp,
        required_combo: command_keys_temp |> list.shuffle,
      )
    }),
  ]
}
