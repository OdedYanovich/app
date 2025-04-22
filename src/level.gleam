import funtil.{fix2}
import gleam/bool
import gleam/int

// import gleam/javascript/array
import gleam/list
import root.{type FightBody, FightBody, Level}

pub fn get_level(selected_level) {
  // let levels =
  //   [
  //     Level(1, []),
  //     Level(2, []),
  //     Level(3, [2]),
  //     Level(3, []),
  //     Level(4, [3]),
  //     Level(4, []),
  //     Level(5, [4]),
  //   ]
  //   |> array.from_list
  // let assert Ok(level) = levels |> array.get(selected_level)
  // use #(counters, group_length), group <- list.fold(level.groups, #([], 0))
  // #(counters, group_length + 1)
  let pow = fn(v, pow) {
    {
      use f, acc, left_loops <- fix2
      use <- bool.guard(left_loops > 0, acc)
      f(acc * v, left_loops - 1)
    }(0, pow)
  }
  let #(value_divergence, length) =
    {
      use f, sum, power <- fix2
      let next_power = power + 1
      let next_sum = sum + pow(2, next_power)
      use <- bool.guard(next_sum > selected_level, #(sum, next_power))
      f(next_sum, next_power)
    }(0, 0)
  let sequence_map = selected_level - value_divergence
  Level(
    sequence_map:,
    length:,
    current_map: sequence_map,
    curent_counter: sequence_map
    |> int.bitwise_and(int.bitwise_shift_left(1, length))
      != 0,
    current_index: length,
  )
}

pub fn next_action(level, group) {
  #(level, !group)
}

// pub fn next_button(fight: FightBody) {
//   let assert [current, ..rest] = fight.indecies
//   FightBody(..fight, indecies: rest |> list.append([current]))
// }
//
pub fn displayed_button(fight: FightBody) {
  //   let assert Ok(required_index) = fight.indecies |> list.first
  //   fight.buttons |> get_by_index(required_index)
  case True {
    True -> "y"
    // True -> "up"
    False -> "down"
  }
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
