import gleam/dict
import update/root.{Before, Fight, Hub, Model, hub_transition_key}
import update/state_dependent/fight.{responses}

pub fn responses() {
  [
    #(#(hub_transition_key, Hub), fn(model) {
      Model(
        ..model,
        mod: Fight(Before),
        player_combo: [],
        responses: responses() |> dict.from_list,
      )
    }),
  ]
}
