import gleam/dict
import gleam/list
import gleam/string
import root.{type Model, type Msg, Hub, Keydown, Keyup, Model}
import update/responses.{hub}

pub fn update(model: Model, msg: Msg) -> Model {
  // {
  //   use keyboard, latest_key_press <-
  //     fn(happy_path) {
  //       use latest_key_press <- keyboard
  //       use response <- response_to_key(latest_key_press)
  //       response(
  //         Model(
  //           ..model,
  //           player_combo: model.player_combo |> list.append([latest_key_press]),
  //         ),
  //       )
  //     }
  // }
  let keyboard = fn(happy_path) {
    case msg {
      Keydown(key) -> happy_path(key)
      Keyup -> Model(..model, player_combo: [])
    }
  }
  let response_to_key = fn(key, happy_path) {
    case model.responses |> dict.get(key |> string.lowercase) {
      Ok(response) -> happy_path(response)
      Error(_) -> model
    }
  }
  use latest_key_press <- keyboard
  use response <- response_to_key(latest_key_press)
  response(
    Model(
      ..model,
      player_combo: model.player_combo |> list.append([latest_key_press]),
    ),
  )
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
