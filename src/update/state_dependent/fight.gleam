import gleam/list
import update/root.{type Model, Fight, Model, hub_transition_key}
import update/state_independent/hub

pub fn responses() {
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
