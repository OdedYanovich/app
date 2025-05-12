import gleam/bool
import gleam/int
import gleam/io.{print}
import gleam/list
import gleam/result
import sequence_provider

pub fn main() {
  let tests = [
    #(sequence_provider_constructor, "sequence_provider constructor"),
    #(sequence_provider_iterator, "sequence_provider iterator"),
    #(clue_constructor, "clue_constructor"),
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

fn sequence_provider_iterator() {
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
    sequence_provider.get(mock_level_index).0 |> Ok,
    fn(current_level, required, mock_element_index) {
      use current_level <- result.try(current_level)
      let outcome = case
        sequence_provider.get_element(current_level) == required
      {
        True -> current_level |> sequence_provider.next_element() |> Ok
        False ->
          msg(
            mock_level_index,
            "    mock_element_index: " <> int.to_string(mock_element_index),
            required |> bool.to_string,
            sequence_provider.get_element(current_level) |> bool.to_string,
          )
          |> Error
      }
      display(outcome)
    },
  )
  |> result.replace(Nil)
}

fn sequence_provider_constructor() {
  let mock_sequence_providers = [
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
  use mock_sequence_provider, mock_sequence_provider_index <- list.index_map(
    mock_sequence_providers,
  )
  let sequence_provider = sequence_provider.get(mock_sequence_provider_index).0
  let msg = fn(i, kind, expect, got) {
    msg(i, kind, expect |> int.to_string, got |> int.to_string)
  }
  let outcome = case
    mock_sequence_provider.0 == sequence_provider.repeation_map,
    mock_sequence_provider.1 == sequence_provider.msb
  {
    True, True -> Ok(Nil)
    False, True -> {
      msg(
        mock_sequence_provider_index,
        "repeation_map",
        mock_sequence_provider.0,
        sequence_provider.repeation_map,
      )
      |> Error
    }
    True, False -> {
      msg(
        mock_sequence_provider_index,
        "msb",
        mock_sequence_provider.1,
        sequence_provider.msb,
      )
      |> Error
    }
    False, False -> {
      [
        msg(
          mock_sequence_provider_index,
          "repeation_map",
          mock_sequence_provider.0,
          sequence_provider.repeation_map,
        ),
        msg(
          mock_sequence_provider_index,
          "msb",
          mock_sequence_provider.1,
          sequence_provider.msb,
        ),
      ]
      |> list.flatten
      |> Error
    }
  }
  display(outcome)
}

fn clue_constructor() {
  let mock_clue = [
    [0b0],
    [0b0, 0b1],
    [0b11, 0b10],
    [0b11, 0b10, 0b00],
    [0b10, 0b01],
    [0b10, 0b01],
    [0b010, 0b001],
    [0b010, 0b001, 0b100],
    [0b001, 0b011, 0b110],
    [0b001, 0b011, 0b100, 0b110],
    [0b010, 0b101],
    [0b010, 0b101],
    [0b101, 0b011, 0b010, 0b110],
    [0b101, 0b011, 0b010, 0b110],
  ]
  use _mock_clue, i <- list.index_map(mock_clue)
  let #(_level, _clue) = sequence_provider.get(i)
  Ok(Nil)
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
