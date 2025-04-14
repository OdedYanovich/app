import gleam/bool
import gleam/list
import root.{type FightBody, FightBody}

import gleam/javascript/array

pub fn levels(selected_level) {
  let levels =
    [[0, 1], [0, 1, 1], [0, 1, 2], [0, 1, 2, 2], [0, 1, 1, 2]]
    |> array.from_list
  // let level_indecies = get_by_index(levels, selected_level)
  let assert Ok(level_indecies) = levels |> array.get(selected_level)
  #(
    level_indecies,
    buttons
      |> list.sample(
        level_indecies
        |> list.fold(-1, fn(acc, item) {
          case item + 1 > acc {
            True -> item + 1
            False -> acc
          }
        }),
      ),
  )
}

pub fn next_button(fight: FightBody) {
  let assert [current, ..rest] = fight.indecies
  FightBody(..fight, indecies: rest |> list.append([current]))
}

pub fn required_button(fight: FightBody) {
  let assert Ok(required_index) = fight.indecies |> list.first
  fight.buttons |> get_by_index(required_index)
}

const buttons = [
  "1", "w", "4", "t", "7", "i", "0", "d", "h", "l", "z", "v", "m", "/",
]

fn get_by_index(list, selected_index) {
  let assert [will_not_return, ..] = list
  use acc, item, current_index <- list.index_fold(list, will_not_return)
  use <- bool.guard(current_index != selected_index, acc)
  item
}
