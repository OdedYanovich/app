import gleam/dict
import gleam/list
import gleam/string
import update/fight
import update/hub
import update/types.{type Model, type Msg, Hub, Key, Model}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Key(key) -> {
      case model.actions |> dict.get(#(key |> string.lowercase, model.mod)) {
        Ok(behavior) -> {
          behavior(
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
    hub.actions()
      |> list.append([fight.actions()])
      |> list.append([fight.start_actions()])
      |> dict.from_list,
    10,
  )
}
