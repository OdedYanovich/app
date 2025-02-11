import gleam/dict
import gleam/list
import root.{
  type Model, EndDmg, Fight, Hub, Model, StartDmg, add_effect, effectless,
  hub_transition_key,
}
import update/hub.{change_volume, volume_buttons}

const command_keys_temp = ["w", "e", "r", "g", "b"]

fn fight_action_responses() {
  use key <- list.map(command_keys_temp)
  #(key, fn(model: Model) {
    let #(mod, responses, effect, unlocked_levels) = case model.hp {
      hp if hp >. 92.0 -> #(
        Hub,
        entering_hub() |> dict.from_list,
        fn(dispatch) { dispatch(EndDmg) },
        model.unlocked_levels + 1,
      )
      _ -> #(
        model.mod,
        model.responses,
        fn(_dispatch) { Nil },
        model.unlocked_levels,
      )
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
      unlocked_levels:,
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
      |> add_effect(fn(dispatch) { dispatch(StartDmg(dispatch)) })
    }),
  ])
  |> list.append([
    #("k", fn(model) {
      Model(..model, selected_level: case model.selected_level {
        1 -> 1
        n -> n - 1
      })
      |> effectless
    }),
  ])
  |> list.append([
    #("l", fn(model) {
      Model(..model, selected_level: case model.selected_level {
        n if n == model.unlocked_levels -> n
        n -> n + 1
      })
      |> effectless
    }),
  ])
}
