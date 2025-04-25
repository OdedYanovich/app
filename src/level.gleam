import funtil.{fix2}
import gleam/bool
import gleam/int
import root.{type FightBody, type Level, Change, Level, Stay}

// import gleam/javascript/array
pub fn get_level(id) {
  let #(repeation_map, finale_index) =
    {
      use f, mask, excess <- fix2
      let new_excess = excess + mask
      use <- bool.guard(new_excess > id, #(id - excess, mask))
      f(mask |> int.bitwise_shift_left(1), new_excess)
    }(2, 0)
  Level(
    // Level constants
    repeation_map:,
    finale_index:,
    // Level variables
    current_index: 1,
    loop_index: 2,
    repeated: 1 % 2 == 0,
  )
}

pub fn next_element(level: Level) {
  let out_of_indices =
    level.current_index == level.finale_index
    && {
      level.repeation_map |> int.bitwise_and(level.finale_index) != 0
      || level.current_index == level.finale_index + 1
    }
  let out_of_loops = level.loop_index == level.finale_index
  let repeation_required =
    level.repeation_map |> int.bitwise_and(level.current_index)
    != 0
    != level.repeated

  Level(
    ..level,
    repeated: repeation_required != level.repeated,
    loop_index: case !repeation_required && out_of_indices {
      True -> 2
      False -> level.loop_index
    },
    current_index: case repeation_required {
      True -> level.current_index
      False ->
        case out_of_indices {
          False -> level.current_index + 1
          True ->
            case out_of_loops {
              False -> level.loop_index
              True -> 1
            }
        }
    },
  )
  // select next bit (current, next or looping bit)
}

pub fn get_element(level: Level) {
  level.current_index % 2 == 0
}

// Belong to groups
pub fn displayed_button(fight: FightBody) {
  case fight.wanted_choice {
    Stay -> "down"
    Change -> "up"
  }
}
