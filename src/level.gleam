import funtil.{fix2}
import gleam/bool
import gleam/int
import gleam/list
import root.{
  type FightBody, type Level, Change, Empty, FightBody, Full, Level, NorthWest,
  Stay,
}

// import gleam/javascript/array
pub fn get_level(id) {
  // let pow = fn(v, pow) {
  //   {
  //     use f, acc, left_loops <- fix2
  //     use <- bool.guard(left_loops > 0, acc)
  //     f(acc * v, left_loops - 1)
  //   }(0, pow)
  // }
  // let #(value_divergence, length) =
  //   {
  //     use f, sum, power <- fix2
  //     let next_power = power + 1
  //     let next_sum = sum + pow(2, next_power)
  //     use <- bool.guard(next_sum > selected_level, #(sum, next_power))
  //     f(next_sum, next_power)
  //   }(0, 0)
  // let sequence_map = selected_level - value_divergence
  // Level(
  //   sequence_map:,
  //   length:,
  //   current_map: sequence_map,
  //   curent_counter: sequence_map
  //   |> int.bitwise_and(int.bitwise_shift_left(1, length))
  //     != 0,
  //   current_index: length,
  // )

  // Make a level
  // use <- bool.guard(id < 2, id)
  let #(sequence_map, finale_bit) =
    {
      use f, mask, excess <- fix2
      let new_excess = excess + mask
      use <- bool.guard(new_excess > id, #(id - excess, mask))
      f(mask |> int.bitwise_shift_left(1), new_excess)
    }(2, 0)
  Level(
    sequence_map:,
    finale_bit:,
    current_index: 1,
    current_counter: case sequence_map |> int.is_odd {
      True -> Full
      False -> Empty
    },
  )
}

pub fn next_action(level: Level) {
  // Is counter full 
  use <- bool.guard(level.current_counter == Full, level)
  case
    level.current_index == level.finale_bit,
    level.sequence_map |> int.bitwise_and(level.current_index) != 0
  {
    _, _ -> todo
    _, _ -> todo
  }

  // use <- bool.guard(
  //   level.current_index == level.length,
  //   Level(..level, current_index: 1),
  // )
  // use <- bool.guard(level.current_index == 1, level)
  #(level, Stay)
}

pub fn displayed_button(fight: FightBody) {
  case fight.wanted_choice {
    Stay -> "down"
    Change -> "up"
  }
}
