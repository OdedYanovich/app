import gleam/int
import gleam/list
import root.{type Model, Model, effectless}

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

pub fn change_volume(change, model: Model) {
  Model(
    ..model,
    timer: 500.0,
    volume: int.max(int.min(model.volume + change, 100), 0),
  )
  |> effectless()
}

pub fn level_buttons(buttons, current_level) {
  buttons |> list.take(current_level + 1)
}
