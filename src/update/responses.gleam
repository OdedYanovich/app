import gleam/dict
import gleam/int
import gleam/list
import lustre/effect
import root.{
  type Model, Before, Dmg, During, EndDmg, Fight, Hub, Model, StartDmg,
}

const command_keys_temp = ["w", "e", "r", "g", "b"]

pub const hub_transition_key = "z"

fn models_from_enconter_keys() {
  use key <- list.map(command_keys_temp)
  #(key, fn(model: Model) {
    case model.required_combo |> list.take(2) {
      [required_key] if required_key == model.latest_key_press -> {
        Model(
          ..model,
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
          required_combo: model.fight_character_set |> list.shuffle,
          hp: model.hp -. 8.0,
        )
    }
  })
}

@external(javascript, "../jsffi.mjs", "startHpLose")
fn start_hp_lose(handler: fn() -> any) -> Int

fn entering_fight() {
  {
    use key_response <- list.map(models_from_enconter_keys())
    #(key_response.0, fn(model) {
      Model(
        ..key_response.1(model),
        mod: Fight(During),
        responses: fight_during() |> dict.from_list,
      )
      |> add_effect(fn(dispatch) {
        dispatch(StartDmg(start_hp_lose(fn() { dispatch(Dmg) })))
      })
    })
  }
  |> list.append([
    #(hub_transition_key, fn(model) {
      Model(..model, mod: Hub, responses: entering_hub() |> dict.from_list)
      |> effectless
    }),
  ])
}

fn fight_during() {
  models_from_enconter_keys()
  |> list.map(fn(key_fn) { #(key_fn.0, fn(a) { key_fn.1(a) |> effectless }) })
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
  |> effectless
}

pub fn entering_hub() {
  volume_buttons
  |> list.map(fn(key_val) { #(key_val.0, change_volume(key_val.1, _)) })
  |> list.append([
    #(hub_transition_key, fn(model) {
      Model(
        ..model,
        mod: Fight(Before),
        fight_character_set: command_keys_temp,
        required_combo: command_keys_temp |> list.shuffle,
        responses: entering_fight() |> dict.from_list,
      )
      |> effectless
    }),
  ])
}

pub fn add_effect(responses, effect) {
  #(responses, effect.from(effect))
}

pub fn effectless(responses) {
  #(responses, effect.none())
}
