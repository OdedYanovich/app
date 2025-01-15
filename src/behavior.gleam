import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub type Mods {
  Hub
  FightStart
  Fight
}

pub type Model {
  Model(mod: Mods, key: String, volume: Int)
}

pub type Msg {
  Key(String)
}

fn change_volume(model: Model, change, key) {
  Model(Hub, key, int.max(int.min(model.volume + change, 100), 0))
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

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Key(key) -> {
      case
        dict.from_list(
          [
            #(
              #("z", Hub),
              #(None, fn(model, _change, _key) {
                Model(..model, mod: FightStart)
              }),
            ),
            #(
              #("z", FightStart),
              #(None, fn(model, _change, _key) { Model(..model, mod: Hub) }),
            ),
          ]
          |> list.append(
            volume_buttons
            |> list.map(fn(key_val) {
              #(#(key_val.0, Hub), #(Some(key_val.1), change_volume))
            }),
          ),
        )
        |> dict.get(#(string.lowercase(key), model.mod))
      {
        Ok(choice) -> {
          choice.1(model, choice.0 |> option.unwrap(999), key)
        }
        Error(_) -> model
      }
    }
  }
}

pub fn init(flags) -> Model {
  Model(Hub, flags, 50)
}
