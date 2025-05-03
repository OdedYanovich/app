import gleam/bool
import gleam/int
import gleam/io.{print}
import gleam/list
import gleam/result
import level

pub fn main() {
  let tests = [
    #(level_constructor, "level constructor"),
    #(level_iterator, "level iterator"),
  ]
  use #(test_, name) <- list.map(tests)
  case test_() |> result.all {
    Ok(_) -> Nil
    Error(_) -> {
      print(name <> ":")
      Nil
    }
  }
}

fn level_iterator() {
  let mock_levels = [
    [],
    [True],
    [True, True],
    [False, True, True],
    [True, False, True, False],
    [False, True, False, True, False],
    [True, False, False, True, False, False],
    [False, True, False, False, True, False, False],
    [True, True, False, False, True, True, False, False],
    [False, True, True, False, False, True, True, False, False],
    [True, False, True, False, True, True, False, True, False, True],
    [False, True, False, True, False, True, True, False, True, False, True],
  ]
  use mock_level, mock_level_index <- list.index_map(mock_levels)
  [False, ..mock_level]
  |> list.repeat(7560)
  |> list.flatten
  |> list.index_fold(
    level.get(mock_level_index) |> Ok,
    fn(current_level, required, mock_element_index) {
      use current_level <- result.try(current_level)
      let outcome = case level.get_element(current_level) == required {
        True -> current_level |> level.next_element() |> Ok
        False ->
          msg(
            mock_level_index,
            "    mock_element_index: " <> int.to_string(mock_element_index),
            required |> bool.to_string,
            level.get_element(current_level) |> bool.to_string,
          )
          |> Error
      }
      display(outcome)
    },
  )
  |> result.replace(Nil)
}

fn level_constructor() {
  let levels = [
    #(0b0, 0b1),
    #(0b1, 0b1),
    #(0b00, 0b10),
    #(0b01, 0b10),
    #(0b10, 0b10),
    #(0b11, 0b10),
    #(0b000, 0b100),
    #(0b001, 0b100),
    #(0b010, 0b100),
    #(0b011, 0b100),
    #(0b100, 0b100),
    #(0b101, 0b100),
    #(0b110, 0b100),
    #(0b111, 0b100),
  ]
  use mock_level, mock_level_index <- list.index_map(levels)
  let level = level.get(mock_level_index)
  let msg = fn(i, kind, expect, got) {
    msg(i, kind, expect |> int.to_string, got |> int.to_string)
  }
  let outcome = case
    mock_level.0 == level.repeation_map,
    mock_level.1 == level.msb
  {
    True, True -> Ok(Nil)
    False, True -> {
      msg(mock_level_index, "repeation_map", mock_level.0, level.repeation_map)
      |> Error
    }
    True, False -> {
      msg(mock_level_index, "msb", mock_level.1, level.msb)
      |> Error
    }
    False, False -> {
      [
        msg(
          mock_level_index,
          "repeation_map",
          mock_level.0,
          level.repeation_map,
        ),
        msg(mock_level_index, "msb", mock_level.1, level.msb),
      ]
      |> list.flatten
      |> Error
    }
  }
  display(outcome)
}

fn msg(index, subject, expected, received) {
  [
    "  mock_level_index: " <> index |> int.to_string,
    "    " <> subject <> ":",
    "      expected: " <> expected,
    "      received: " <> received,
  ]
}

fn display(outcome) {
  use msg <- result.try_recover(outcome)
  list.map(msg, fn(line) { io.println(line) })
  Error(Nil)
}
