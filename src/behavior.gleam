import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

pub type Mods {
  Hub
  FightStart
  Fight
}

pub type Model {
  Model(
    mod: Mods,
    player_combo: String,
    required_combo: String,
    volume: Int,
    actions: Dict(String, fn(Model) -> Model),
  )
}

pub type Msg {
  Key(String)
}

fn change_volume(change, model: Model) {
  Model(
    ..model,
    volume: int.max(int.min(model.volume + change, 100), 0),
    player_combo: "",
  )
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

fn list_to_string(list, combo) {
  case list {
    [first, ..rest] -> list_to_string(rest, combo <> first)
    [] -> combo
  }
}

pub const hub_transition_key = "z"

fn hub_actions() {
  volume_buttons
  |> list.map(fn(key_val) { #(key_val.0, change_volume(key_val.1, _)) })
  |> list.append([
    #(hub_transition_key, fn(model) { Model(..model, mod: FightStart) }),
  ])
}

const command_keys_temp = ["f", "g", "h"]

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Key(key) -> {
      let actions =
        case model.mod {
          Hub -> hub_actions()
          Fight | FightStart -> [
            #(hub_transition_key, fn(model) {
              Model(
                ..model,
                mod: Hub,
                required_combo: command_keys_temp
                  |> list.shuffle
                  |> list_to_string(""),
              )
            }),
          ]
        }
        |> dict.from_list
      case actions |> dict.get(string.lowercase(key)) {
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
  Model(Hub, flags, "", 50, dict.from_list(hub_actions()))
}
