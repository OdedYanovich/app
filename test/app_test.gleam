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
  let levels = [
    [False],
    [False, True],
    [False, True, True],
    [False, False, True, True],
    [False, True, False, True, False],
    [False, False, True, False, True, False],
    [False, True, False, False, True, False, False],
    [False, False, True, False, False, True, False, False],
    [False, True, True, False, False, True, True, False, False],
    [False, False, True, True, False, False, True, True, False, False],
    [False, True, False, True, False, True, True, False, True, False, True],
    [
      False,
      False,
      True,
      False,
      True,
      False,
      True,
      True,
      False,
      True,
      False,
      True,
    ],
  ]
  use lv, i <- list.index_map(levels)
  list.index_fold(
    lv,
    Ok(level.get(i)),
    fn(current_level, required, repeation_index) {
      use current_level <- result.try(current_level)
      let outcome = case level.get_element(current_level) == required {
        True -> level.next_element(current_level) |> Ok
        False -> {
          msg(
            i,
            "required action",
            required |> bool.to_string,
            level.get_element(current_level) |> bool.to_string,
          )
          |> list.append(["repeation_index: " <> int.to_string(repeation_index)])
          |> Error
        }
      }
      use msg <- result.try_recover(outcome)
      list.map(msg, fn(line) { io.println(line) })
      Error(Nil)
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
  use lv, i <- list.index_map(levels)
  let level = level.get(i)
  let outcome = case lv.0 == level.repeation_map, lv.1 == level.msb {
    True, True -> Ok(Nil)
    False, True -> {
      msg(
        i,
        "repeation_map",
        lv.0 |> int.to_string,
        level.repeation_map |> int.to_string,
      )
      |> Error
    }
    True, False -> {
      msg(i, "msb", lv.1 |> int.to_string, level.msb |> int.to_string)
      |> Error
    }
    False, False -> {
      [
        msg(
          i,
          "repeation_map",
          lv.0 |> int.to_string,
          level.repeation_map |> int.to_string,
        ),
        msg(i, "msb", lv.1 |> int.to_string, level.msb |> int.to_string),
      ]
      |> list.flatten
      |> Error
    }
  }
  use msg <- result.try_recover(outcome)
  list.map(msg, fn(line) { io.println(line) })
  Error(Nil)
}

fn msg(index, subject, expected, received) {
  [
    "  index: " <> index |> int.to_string,
    "    " <> subject <> ":",
    "      expected: " <> expected,
    "      received: " <> received,
  ]
}
