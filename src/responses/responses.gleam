import gleam/dict
import gleam/list
import prng/random
import root.{
  type Model, Credit, EndDmg, Fight, Hub, Model, MovingPixel, StartDmg,
  add_effect, effectless, hub_transition_key, image_columns, image_rows,
}
import responses/hub.{change_volume, level_buttons, volume_buttons}

const command_keys_temp = ["s", "d", "f", "j", "k", "l"]

fn fight_action_responses() {
  use key <- list.map(command_keys_temp)
  #(key, fn(model: Model) {
    case
      model.required_combo |> list.take(1) == [model.latest_key_press],
      model.drawn_pixel_count >= 64
    {
      True, True ->
        Model(
          ..model,
          mod: Hub,
          responses: entering_hub() |> dict.from_list,
          unlocked_levels: model.unlocked_levels + 1,
          hp: 5.0,
        )
        |> add_effect(fn(dispatch) { dispatch(EndDmg) })
      True, _ -> {
        let #(selected_column, seed) =
          random.int(0, image_columns - 1)
          |> random.step(model.seed)
        Model(
          ..model,
          hp: model.hp +. 14.0,
          moving_pixels: model.moving_pixels
            |> list.append([
              MovingPixel(
                list.index_fold(
                  model.drawn_pixels,
                  0,
                  fn(acc, raw_count, column_index) {
                    case
                      column_index == selected_column,
                      raw_count <= image_rows
                    {
                      True, True -> raw_count * image_rows + selected_column
                      True, False -> todo
                      False, _ -> acc
                    }
                  },
                ),
                0.0,
              ),
            ]),
          drawn_pixel_count: model.drawn_pixel_count + 1,
          drawn_pixels: model.drawn_pixels
            |> list.index_map(fn(taken_rows, i) {
              case i == selected_column {
                True -> {
                  taken_rows + 1
                }
                False -> taken_rows
              }
            }),
          seed:,
          required_combo: model.required_combo
            |> list.drop(1)
            |> list.append(model.fight_character_set |> list.sample(1)),
        )
        |> add_effect(fn(_dispatch) { Nil })
      }
      False, _ ->
        Model(..model, hp: model.hp -. 8.0)
        |> add_effect(fn(_dispatch) { Nil })
    }
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
// @external(javascript, "../jsffi.mjs", "indexing")
// fn indexing(list: List(a), index: Int, fun: fn(a) -> b) -> b
