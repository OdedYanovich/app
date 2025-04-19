import gleam/bool
import gleam/list
import root.{type FightBody, FightBody}

import gleam/javascript/array

pub fn gevels(selected_level) {
  let levels =
    [
      Level(1, []),
      Level(2, []),
      Level(3, [2]),
      Level(3, []),
      Level(4, [3]),
      Level(4, []),
      Level(5, [4]),
    ]
    |> array.from_list
  let assert Ok(level) = levels |> array.get(selected_level)
  use #(counters, group_length), group <- list.fold(level.groups, #([], 0))
  #(counters, group_length + 1)
}

pub type Level {
  Level(length: Int, groups: List(Int))
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
