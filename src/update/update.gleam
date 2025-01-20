import gleam/dict
import gleam/list
import gleam/string
import update/root.{type Model, type Msg, Hub, Keyboard, Model}
import update/state_dependent/hub
import update/state_independent/fight as init_fight
import update/state_independent/hub as init_hub

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Keyboard(key) -> {
      case model.responses |> dict.get(#(key |> string.lowercase, model.mod)) {
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
    init_hub.responses()
      |> list.append(init_fight.responses())
      |> list.append(hub.responses())
      |> dict.from_list,
    10,
  )
}
