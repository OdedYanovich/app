import gleam/dict
import gleam/option.{None, Some}
import gleam/string
import lustre/effect
import root.{type Model, type Msg, Dmg, EndDmg, Hub, Keydown, Model, StartDmg}
import update/responses.{add_effect, effectless, entering_hub}

import gleam/bool.{guard}
import gleam/dynamic/decode
import gleam/result.{try}

@external(javascript, "../jsffi.mjs", "endHpLose")
fn end_hp_lose(id: Int) -> Nil

@external(javascript, "../jsffi.mjs", "startHpLose")
fn start_hp_lose(handler: fn() -> any) -> Int

pub fn update(model: Model, msg: Msg) {
  use <-
    fn(branches) {
      let #(msg_is_keydown, response_found) = branches()
      use latest_key_press <- msg_is_keydown
      use response <- response_found(latest_key_press)
      response(Model(..model, latest_key_press:))
    }
  #(
    fn(keyboard) {
      case msg {
        Keydown(key) -> keyboard(key)
        Dmg -> #(Model(..model, hp: model.hp -. 0.02), effect.none())
        StartDmg(dispatch) -> #(
          Model(
            ..model,
            interval_id: Some(start_hp_lose(fn() { dispatch(Dmg) })),
          ),
          effect.none(),
        )
        EndDmg -> {
          end_hp_lose(model.interval_id |> option.unwrap(0))
          Model(..model, interval_id: None) |> effectless
        }
      }
    },
    fn(key, response_to_key) {
      case model.responses |> dict.get(key |> string.lowercase) {
        Ok(response) -> response_to_key(response)
        Error(_) -> model |> effectless
      }
    },
  )
}

@external(javascript, "../jsffi.mjs", "keyboardEvents")
fn keyboard_events(handler: fn(decode.Dynamic) -> any) -> Nil

pub fn init(_flags) {
  Model(
    mod: Hub,
    latest_key_press: "F",
    required_combo: [],
    fight_character_set: [],
    volume: 50,
    responses: entering_hub()
      |> dict.from_list,
    hp: 50.0,
    interval_id: None,
    unlocked_levels: 3,
    selected_level: 1,
  )
  |> add_effect(fn(dispatch) {
    use event <- keyboard_events
    use #(key, repeat) <- try(
      decode.run(event, {
        use key <- decode.field("key", decode.string)
        use repeat <- decode.field("repeat", decode.bool)
        decode.success(#(key, repeat))
      }),
    )
    use <- guard(repeat, Ok(Nil))
    dispatch(Keydown(key)) |> Ok
  })
}
