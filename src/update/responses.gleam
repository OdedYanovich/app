import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{Some}
import lustre
import lustre/effect
import root.{type Model, Before, Dmg, During, Fight, Hub, Model}

const command_keys_temp = ["w", "e", "r", "g", "b"]

pub const hub_transition_key = "z"

fn responses_to_enconter_keys() {
  use key <- list.map(command_keys_temp)
  #(key, fn(model: Model) {
    case model.required_combo |> list.take(2) {
      [required_key] if required_key == model.latest_key_press -> {
        Model(
          ..model,
          // latest_key_press: "",
            required_combo: model.fight_character_set |> list.shuffle,
          hp: model.hp +. 8.0,
        )
      }
      [required_key, ..] if required_key == model.latest_key_press -> {
        Model(..model, required_combo: model.required_combo |> list.drop(1))
      }
      _ ->
        Model(
          ..model,
          // latest_key_press: "",
            required_combo: model.fight_character_set |> list.shuffle,
          hp: model.hp -. 8.0,
        )
    }
  })
}

@external(javascript, "../event_listener.mjs", "startHpLose")
fn start_hp_lose(handler: fn() -> any) -> Nil

@external(javascript, "../event_listener.mjs", "endHpLose")
fn end_hp_lose() -> Nil

pub fn fight() {
  #(
    {
      use key_response <- list.map(responses_to_enconter_keys())
      // let _interval_id = start_hp_lose(fn() { runtime(lustre.dispatch(Dmg)) })
      #(key_response.0, fn(model) {
        Model(
          ..key_response.1(model),
          mod: Fight(During),
          responses: fight_during() |> dict.from_list,
          // interval_id: start_hp_lose(fn() { runtime(lustre.dispatch(Dmg)) }),
        // interval_id: Some(start_hp_lose()),
        )
      })
    }
      |> list.append([
        #(hub_transition_key, fn(model) {
          Model(
            ..model,
            mod: Hub,
            // latest_key_press: "",
              responses: hub() |> dict.from_list,
          )
        }),
      ]),
    effect.from(fn(dispatch) { start_hp_lose(fn() { dispatch(Dmg) }) }),
  )
}

fn fight_during() -> List(#(String, fn(Model) -> Model)) {
  responses_to_enconter_keys()
  |> list.append([
    #(hub_transition_key, fn(model) {
      Model(
        ..model,
        mod: Hub,
        // latest_key_press: "",
          responses: hub() |> dict.from_list,
      )
    }),
  ])
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

fn change_volume(change, model: Model) {
  Model(..model, volume: int.max(int.min(model.volume + change, 100), 0))
}

pub fn hub() {
  volume_buttons
  |> list.map(fn(key_val) { #(key_val.0, change_volume(key_val.1, _)) })
  |> list.append([
    #(hub_transition_key, fn(model) {
      Model(
        ..model,
        mod: Fight(Before),
        // latest_key_press: "",
        fight_character_set: command_keys_temp,
        required_combo: command_keys_temp |> list.shuffle,
        responses: fight() |> dict.from_list,
      )
    }),
  ])
}
