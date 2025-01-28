import gleam/dict
import gleam/option.{None}
import gleam/string
import root.{type Model, type Msg, Dmg, Hub, Keydown, Model}
import update/responses.{hub}

pub fn update(model: Model, msg: Msg) {
  use <-
    fn(branches) {
      let #(keydown, response) = branches()
      use latest_key_press <- keydown
      use response <- response(latest_key_press)
      response(Model(..model, latest_key_press:))
    }
  #(
    fn(keyboard) {
      case msg {
        Keydown(key) -> keyboard(key)
        Dmg -> Model(..model, hp: model.hp -. 0.01)
      }
    },
    fn(key, response_to_key) {
      case model.responses |> dict.get(key |> string.lowercase) {
        Ok(response) -> response_to_key(response)
        Error(_) -> model
      }
    },
  )
}

pub fn init(_flags) {
  Model(
    Hub,
    "F",
    [],
    [],
    50,
    hub()
      |> dict.from_list,
    50.0,
    None,
  )
}
