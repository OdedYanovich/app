import gleam/dict
import gleam/int
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

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Key(key) -> {
      case
        dict.from_list([
          #(
            #("q", Hub),
            #(None, fn(model, _change, _key) { Model(..model, mod: FightStart) }),
          ),
          #(#("l", Hub), #(Some(-25), change_volume)),
          #(#("k", Hub), #(Some(-10), change_volume)),
          #(#("j", Hub), #(Some(-5), change_volume)),
          #(#("h", Hub), #(Some(-1), change_volume)),
          #(#("y", Hub), #(Some(1), change_volume)),
          #(#("u", Hub), #(Some(5), change_volume)),
          #(#("i", Hub), #(Some(10), change_volume)),
          #(#("o", Hub), #(Some(25), change_volume)),
          #(
            #("a", FightStart),
            #(None, fn(model, _change, _key) { Model(..model, mod: Hub) }),
          ),
        ])
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
