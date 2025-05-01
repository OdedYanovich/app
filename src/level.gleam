import ffi/main
import funtil
import gleam/bool
import gleam/int
import root.{type FightBody, type Level, Level}

const loop_first_index = 2

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
    loop_index: loop_first_index,
    repeation_accrued: False,
  )
}

// fn index_is_maxed(level: Level) {
//   level.current_index
//   == case level.repeation_map |> int.bitwise_and(level.msb) != 0 {
//     False -> level.msb
//     True -> level.msb |> int.bitwise_shift_left(1)
//   }
// }

pub fn next_element(level: Level) {
  let index_is_maxed = level.current_index >= level.msb
  //   case level.repeation_map |> int.bitwise_and(level.msb) != 0 {
  //   False -> level.msb
  //   True -> level.msb |> int.bitwise_shift_left(1)
  // }

  let out_of_nestead_loops = level.loop_index > level.msb
  let repeation_required =
    {
      {
        level.repeation_map
        |> int.bitwise_and(level.current_index)
      }
      != 0
    }
    && !level.repeation_accrued

  Level(
    ..level,
    repeation_accrued: repeation_required,
    loop_index: case !repeation_required && index_is_maxed {
      True ->
        case out_of_nestead_loops {
          True -> loop_first_index
          False -> level.loop_index |> int.bitwise_shift_left(1)
        }
      False -> level.loop_index
    },
    current_index: case repeation_required, index_is_maxed {
      True, False -> level.current_index
      True, True | False, False ->
        level.current_index |> int.bitwise_shift_left(1)
      False, True ->
        case out_of_nestead_loops {
          False -> level.loop_index
          True -> 1
        }
    },
    // current_index: case repeation_required {
  //   True -> level.current_index
  //   False ->
  //     case index_is_maxed(level) {
  //       False -> level.current_index |> int.bitwise_shift_left(1)
  //       True ->
  //         case out_of_nestead_loops {
  //           False -> level.loop_index
  //           True -> 1
  //         }
  //     }
  // },
  )
}

pub fn get_element(level: Level) {
  main.log2(level.current_index) % 2 != 0
  // case index_is_maxed(level) && level.repeation_accrued {
  //   False -> 0
  //   True -> 1
  // }
}

// Belong to groups
pub fn displayed_button(_fight: FightBody) {
  "text"
}
