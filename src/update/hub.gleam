import gleam/int
import gleam/list
import update/types.{type Model, FightStart, Model}

pub const hub_transition_key = "z"

pub const volume_buttons = [
  #("q", -25),
  #("w", -10),
  #("e", -5),
  #("r", -1),
  #("t", 1),
  #("y", 5),
  #("u", 10),
  #("i", 25),
]

pub fn actions() {
  volume_buttons
  |> list.map(fn(key_val) { #(key_val.0, change_volume(key_val.1, _)) })
  |> list.append([
    #(hub_transition_key, fn(model) { Model(..model, mod: FightStart) }),
  ])
}

fn change_volume(change, model: Model) {
  Model(
    ..model,
    volume: int.max(int.min(model.volume + change, 100), 0),
    player_combo: "",
  )
}
