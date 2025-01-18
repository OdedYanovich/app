import gleam/dict
import gleam/string
import update/fight
import update/hub
import update/types.{type Model, type Msg, Fight, FightStart, Hub, Key, Model}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Key(key) -> {
      let actions =
        case model.mod {
          Hub -> hub.actions()
          FightStart -> fight.start_actions()
          Fight -> fight.actions()
        }
        |> dict.from_list
      case actions |> dict.get(key |> string.lowercase) {
        Ok(behavior) -> {
          behavior(
            Model(
              ..model,
              player_combo: model.player_combo <> key,
              actions: actions,
            ),
          )
        }
        Error(_) -> model
      }
    }
  }
}

pub fn init(flags) -> Model {
  Model(Hub, flags, "", [], 50, dict.from_list(hub.actions()))
}
