import gleam/dict
import gleam/int
import gleam/list
import root.{type Model, Before, Fight, Hub, Model}

const command_keys_temp = ["w", "e", "r", "g", "b"]

pub const hub_transition_key = "z"

pub fn fight() -> List(#(String, fn(Model) -> Model)) {
  {
    use key <- list.map(command_keys_temp)
    #(key, fn(model: Model) {
      case model.required_combo |> list.take(2) {
        [required_key] if required_key == model.latest_key_press -> {
          Model(
            ..model,
            latest_key_press: "",
            required_combo: model.fight_character_set |> list.shuffle,
            hp: model.hp +. 4.0,
          )
        }
        [required_key, ..] if required_key == model.latest_key_press -> {
          Model(..model, required_combo: model.required_combo |> list.drop(1))
        }

        _ ->
          Model(
            ..model,
            latest_key_press: "",
            required_combo: model.fight_character_set |> list.shuffle,
            hp: model.hp -. 4.0,
          )
      }
    })
  }
  |> list.append([
    #(hub_transition_key, fn(model) {
      Model(
        ..model,
        mod: Hub,
        latest_key_press: "",
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
  Model(..model, volume: int.max(int.min(model.volume + change, 100), 0))
}

pub fn hub() {
  volume_buttons
  |> list.map(fn(key_val) { #(key_val.0, change_volume(key_val.1, _)) })
  |> list.append([
    #(hub_transition_key, fn(model) {
      Model(
        ..model,
        mod: Fight(Before),
        latest_key_press: "",
        fight_character_set: command_keys_temp,
        required_combo: command_keys_temp |> list.shuffle,
        responses: fight() |> dict.from_list,
      )
    }),
  ])
}
