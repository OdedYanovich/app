import gleam/list
import gleam/string
import update/hub.{hub_transition_key}
import update/types.{type Model, Hub, Model}

const command_keys_temp = ["f", "g", "h"]

fn list_to_string(list, combo) {
  case list {
    [first, ..rest] -> list_to_string(rest, combo <> first)
    [] -> combo
  }
}

pub fn start_actions() {
  [
    #(hub_transition_key, fn(model) {
      Model(
        ..model,
        mod: Hub,
        required_combo: command_keys_temp
          |> list.shuffle
          |> list_to_string(""),
        fight_character_set: command_keys_temp,
      )
    }),
  ]
}

pub fn actions() {
  [
    #(hub_transition_key, fn(model: Model) {
      case
        model.player_combo |> string.length
        == model.required_combo |> string.length
      {
        True -> {
          todo
        }
        False -> {
          todo
        }
      }
      Model(
        ..model,
        required_combo: model.fight_character_set
          |> list.shuffle
          |> list_to_string(""),
      )
    }),
  ]
}
