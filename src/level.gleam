import ffi/main
import funtil
import gleam/bool
import gleam/int
import root.{type Level, Level}

pub fn get(id) {
  let #(repeation_map, msb) =
    {
      use f, mask, excess <- funtil.fix2
      let next_mask = mask |> int.bitwise_shift_left(1)
      let next_excess = excess + next_mask
      use <- bool.guard(next_excess > id, #(id - excess, mask))
      f(next_mask, next_excess)
    }(1, 0)
  Level(
    repeation_map:,
    msb:,
    current_index: 1,
    loop_map: 0,
    repeation_accrued: False,
  )
}

pub fn next_element(level: Level) {
  let index_is_maxed = level.current_index >= level.msb
  let repeation_required =
    level.repeation_map
    |> int.bitwise_and(level.current_index)
    != 0
    && !level.repeation_accrued
  let level = case repeation_required, index_is_maxed {
    True, False -> level
    False, True -> {
      let #(loop_map, current_index) =
        funtil.fix2(fn(f, index_map, loop_index) {
          // use <- bool.guard(index_map |> int.bitwise_and(1) != 0, #(0, 1))
          case index_map |> int.bitwise_and(loop_index) {
            0 -> #(index_map |> int.bitwise_or(loop_index), loop_index)
            _ ->
              f(
                index_map - loop_index,
                loop_index |> int.bitwise_shift_right(1),
              )
          }
        })(level.loop_map, level.msb)
      Level(..level, loop_map:, current_index:)
    }
    False, False | True, True ->
      Level(
        ..level,
        current_index: level.current_index |> int.bitwise_shift_left(1),
      )
  }
  Level(..level, repeation_accrued: repeation_required)
}

pub fn get_element(level: Level) {
  main.log2(level.current_index) % 2 != 0
}
