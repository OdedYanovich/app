import gleam/bool.{guard}
import gleam/dict
import gleam/list
import prng/random
import responses/hub.{change_volume, level_buttons, volume_buttons}
import root.{
  type Model, Column, Credit, EndDmg, Fight, Hub, Model, MovingPixel, StartDmg,
  add_effect, effectless, hub_transition_key, image_columns, image_rows,
}

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
        let #(drawn_pixels, _) =
          list.index_fold(
            model.drawn_pixels,
            #([], 0),
            fn(drawn_pixels_and_full_columns, column, index) {
              let #(drawn_pixels, full_columns) = drawn_pixels_and_full_columns
              let Column(stationary_pixels, moving_pixels) = column
              use <- guard(
                stationary_pixels + { moving_pixels |> list.length } == 8,
                #(drawn_pixels |> list.append([column]), full_columns + 1),
              )
              use <- guard(selected_column + full_columns == index, #(
                drawn_pixels |> list.append([column]),
                full_columns,
              ))
              todo
            },
          )
        Model(
          ..model,
          hp: model.hp +. 4.0,
          // moving_pixels: model.moving_pixels
            //   |> list.append([
            //     MovingPixel(
            //       list.index_fold(
            //         model.drawn_pixels,
            //         0,
            //         fn(acc, raw_count, column_index) {
            //           case
            //             column_index == selected_column,
            //             raw_count.0 <= image_rows
            //           {
            //             True, True -> raw_count.0 * image_rows + selected_column
            //             True, False -> todo
            //             False, _ -> acc
            //           }
            //         },
            //       ),
            //       0.0,
            //     ),
            //   ]),
            drawn_pixel_count: model.drawn_pixel_count + 1,
          drawn_pixels: model.drawn_pixels.0
            |> list.index_map(fn(column, i) {
              let Column(stationery_pixels, moving_pixels) = column
              case
                i == selected_column
                || stationery_pixels + { moving_pixels |> list.length } <= 7
              {
                True -> #(
                  stationery_pixels,
                  moving_pixels |> list.append([0.0]),
                )
                False -> stationery_and_moving_pixels
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
