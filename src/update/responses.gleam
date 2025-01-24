import gleam/dict
import gleam/int
import gleam/list
import root.{type Model, Before, Fight, Hub, Model}

const command_keys_temp = ["f", "g", "h"]

pub const hub_transition_key = "z"

pub fn fight() -> List(#(String, fn(Model) -> Model)) {
  command_keys_temp
  |> list.map(fn(key) {
    #(key, fn(model: Model) {
      case
        model.player_combo |> list.length == model.required_combo |> list.length
      {
        True -> {
          Model(
            ..model,
            player_combo: [],
            required_combo: model.fight_character_set |> list.shuffle,
            hp: model.hp
              + case model.player_combo == model.required_combo {
                True -> 4
                False -> -4
              },
          )
        }
        False -> model
      }
    })
  })
  |> list.append([
    #(hub_transition_key, fn(model) {
      Model(
        ..model,
        mod: Hub,
        player_combo: [],
        fight_character_set: [],
        required_combo: [],
        responses: hub() |> dict.from_list,
      )
    }),
  ])
}

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

pub fn hub() {
  volume_buttons
  |> list.map(fn(key_val) { #(key_val.0, change_volume(key_val.1, _)) })
  |> list.append([
    #(hub_transition_key, fn(model) {
      Model(
        ..model,
        mod: Fight(Before),
        player_combo: [],
        fight_character_set: command_keys_temp,
        required_combo: command_keys_temp |> list.shuffle,
        responses: fight() |> dict.from_list,
      )
    }),
  ])
}
