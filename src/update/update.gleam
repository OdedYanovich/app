import gleam/dict
import gleam/list
import gleam/string
import root.{type Model, type Msg, Hub, Keyboard, Model}

import update/responses.{hub}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Keyboard(key) -> {
      case model.responses |> dict.get(key |> string.lowercase) {
        Ok(response) -> {
          response(
            Model(
              ..model,
              player_combo: model.player_combo |> list.append([key]),
            ),
          )
        }
        Error(_) -> model
      }
    }
  }
}

pub fn init(_flags) -> Model {
  Model(
    Hub,
    ["F"],
    [],
    [],
    50,
    hub()
      |> dict.from_list,
    10,
  )
}
