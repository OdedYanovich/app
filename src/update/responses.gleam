import gleam/dict
import gleam/int
import gleam/list
import lustre/effect
import root.{type Model, EndDmg, Fight, Hub, Model, StartDmg}

const command_keys_temp = ["w", "e", "r", "g", "b"]

pub const hub_transition_key = "z"

@external(javascript, "../jsffi.mjs", "t")
fn t(a: fn(a) -> Nil) -> Nil

fn fight_action_responses() {
  use key <- list.map(command_keys_temp)
  #(key, fn(model: Model) {
    let #(mod, responses, effect) = case model.hp {
      hp if hp >. 92.0 -> #(Hub, entering_hub() |> dict.from_list, fn(dispatch) {
        dispatch(EndDmg)
      })
      _ -> #(model.mod, model.responses, fn(_dispatch) { Nil })
    }
    Model(
      ..model,
      hp: model.hp
        +. case model.required_combo |> list.take(1) {
          [key] if key == model.latest_key_press -> 8.0
          _ -> -8.0
        },
      required_combo: model.required_combo
        |> list.drop(1)
        |> list.append(model.fight_character_set |> list.sample(1)),
      mod:,
      responses:,
    )
    |> add_effect(effect)
  })
}

fn entering_fight() {
  fight_action_responses()
  |> list.append([
    #(hub_transition_key, fn(model) {
      Model(..model, mod: Hub, responses: entering_hub() |> dict.from_list)
      |> add_effect(fn(dispatch) { dispatch(EndDmg) })
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
  |> add_effect(t)
}

pub fn entering_hub() {
  volume_buttons
  |> list.map(fn(key_val) { #(key_val.0, change_volume(key_val.1, _)) })
  |> list.append([
    #(hub_transition_key, fn(model) {
      Model(
        ..model,
        mod: Fight,
        fight_character_set: command_keys_temp,
        required_combo: command_keys_temp |> list.shuffle,
        responses: entering_fight() |> dict.from_list,
      )
      |> add_effect(fn(dispatch) {
        dispatch(StartDmg(
          dispatch,
          //start_hp_lose(fn() { dispatch(Dmg) })
        ))
      })
    }),
  ])
}

pub fn add_effect(responses, effect) {
  #(responses, effect.from(effect))
}

pub fn effectless(responses) {
  #(responses, effect.none())
}
