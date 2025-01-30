import gleam/dict
import gleam/option.{None, Some}
import gleam/string
import lustre/effect
import root.{type Model, type Msg, Dmg, EndDmg, Hub, Keydown, Model, StartDmg}
import update/responses.{entering_hub}

import gleam/bool.{guard}
import gleam/dynamic/decode
import gleam/result.{try}

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
        Dmg -> #(Model(..model, hp: model.hp -. 0.01), effect.none())
        StartDmg(id) -> #(Model(..model, interval_id: Some(id)), effect.none())
        EndDmg -> {
          end_hp_lose(model.interval_id |> option.unwrap(0))
          #(Model(..model, interval_id: None), effect.none())
        }
      }
    },
    fn(key, response_to_key) {
      case model.responses |> dict.get(key |> string.lowercase) {
        Ok(response) -> response_to_key(response)
        Error(_) -> #(model, effect.none())
      }
    },
  )
}

@external(javascript, "../event_listener.mjs", "keyboardEvents")
pub fn keyboard_events(handler: fn(decode.Dynamic) -> any) -> Nil

@external(javascript, "../event_listener.mjs", "endHpLose")
fn end_hp_lose(id: Int) -> Nil

pub fn init(_flags) {
  #(
    Model(
      Hub,
      "F",
      [],
      [],
      50,
      entering_hub()
        |> dict.from_list,
      50.0,
      None,
    ),
    effect.from(fn(dispatch) {
      use event <- keyboard_events
      use #(key, repeat) <- try(
        decode.run(event, {
          use key <- decode.field("key", decode.string)
          use repeat <- decode.field("repeat", decode.bool)
          decode.success(#(key, repeat))
        }),
      )
      use <- guard(repeat, Ok(Nil))
      dispatch(Keydown(key))
      Ok(Nil)
    }),
  )
}
