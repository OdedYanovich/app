import gleam/dict
import gleam/list
import root.{
  type Model, Credit, EndDmg, Fight, Hub, MovingP, Model, StartDmg, add_effect,
  effectless, hub_transition_key, 
}
import update/hub.{change_volume, level_buttons, volume_buttons}

const command_keys_temp = ["s", "d", "f", "j", "k", "l"]

fn fight_action_responses() {
  use key <- list.map(command_keys_temp)
  #(key, fn(model: Model) {
    let #(
      mod,
      responses,
      effect,
      unlocked_levels,
      hp,
      moving_pixels,
      drawn_pixel_count,
    ) = case
      model.required_combo |> list.take(1) == [model.latest_key_press],
      model.hp
    {
      True, hp if hp >. 96.0 -> #(
        Hub,
        entering_hub() |> dict.from_list,
        fn(dispatch) { dispatch(EndDmg) },
        model.unlocked_levels + 1,
        5.0,
        model.moving_pixels,
        model.drawn_pixel_count,
      )
      True, _ -> #(
        model.mod,
        model.responses,
        fn(_dispatch) { Nil },
        model.unlocked_levels,
        model.hp +. 4.0,
        model.moving_pixels
          |> list.append([MovingP(model.drawn_pixel_count, 0.0)]),
        model.drawn_pixel_count + 1,
      )
      False, _ -> #(
        model.mod,
        model.responses,
        fn(_dispatch) { Nil },
        model.unlocked_levels,
        model.hp -. 8.0,
        model.moving_pixels,
        model.drawn_pixel_count,
      )
    }
    Model(
      ..model,
      hp:,
      required_combo: model.required_combo
        |> list.drop(1)
        |> list.append(model.fight_character_set |> list.sample(1)),
      mod:,
      responses:,
      unlocked_levels:,
      moving_pixels:,
      drawn_pixel_count:,
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
        fight_character_set: command_keys_temp
          |> level_buttons(model.selected_level),
        required_combo: command_keys_temp
          |> level_buttons(model.selected_level)
          |> list.shuffle,
        responses: entering_fight() |> dict.from_list,
      )
      |> add_effect(fn(dispatch) { dispatch(StartDmg(dispatch)) })
    }),
    #("c", fn(model) {
      Model(..model, mod: Credit, responses: entering_credit()) |> effectless
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

fn entering_credit() {
  [
    #(hub_transition_key, fn(model) {
      Model(..model, mod: Hub, responses: entering_hub() |> dict.from_list)
      |> effectless
    }),
  ]
  |> dict.from_list
}
