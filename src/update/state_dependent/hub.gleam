import gleam/int
import gleam/list
import update/root.{type Model, Hub, Model}

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

fn change_volume(change, model: Model) {
  Model(
    ..model,
    volume: int.max(int.min(model.volume + change, 100), 0),
    player_combo: [],
  )
}

pub fn actions() {
  volume_buttons
  |> list.map(fn(key_val) { #(#(key_val.0, Hub), change_volume(key_val.1, _)) })
}
