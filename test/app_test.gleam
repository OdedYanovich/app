import gleam/bool
import gleam/int
import gleam/io.{println}
import gleam/list
import root.{type SequenceProvider}
import sequence_provider.{next_element}

pub fn main() {
  println("sequence_provider constructor")
  sequence_provider_constructor()
  println("sequence_provider iterator")
  sequence_provider_iterator()
}

fn sequence_provider_iterator() {
  let mock_providers = [
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
  use mock_provider, mock_provider_index <- list.index_map(mock_providers)
  let new_provider = sequence_provider.get(mock_provider_index).0
  let current_provider = {
    use current_provider, required, mock_element_index <- list.index_fold(
      [False, ..mock_provider] |> list.repeat(2) |> list.flatten,
      new_provider,
    )
    // echo current_provider
    use <- bool.guard(
      sequence_provider.get_element(current_provider) == required,
      current_provider |> next_element,
    )
    msg(
      mock_provider_index,
      "    mock_element_index: " <> int.to_string(mock_element_index),
      required |> bool.to_string,
      sequence_provider.get_element(current_provider) |> bool.to_string,
    )
    |> display
    current_provider
  }
  use <- bool.guard(current_provider != new_provider, Nil)
  [
    ["wanted sequence_provider: "],
    new_provider |> sequence_provider_to_massage,
    [" given sequence_provider: "],
    current_provider |> sequence_provider_to_massage,
  ]
  |> list.flatten
  |> display
  Nil
}

fn sequence_provider_to_massage(provider: SequenceProvider) {
  [
    "	repeation_map: " <> provider.repeation_map |> int.to_string,
    "	msb: " <> provider.repeation_map |> int.to_string,
    "		current_index: " <> provider.repeation_map |> int.to_string,
    "		loop_map: " <> provider.repeation_map |> int.to_string,
    "		repeation_accrued: " <> provider.repeation_map |> int.to_string,
  ]
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
  use mock_provider, mock_provider_index <- list.index_map(
    mock_sequence_providers,
  )
  let provider = sequence_provider.get(mock_provider_index).0
  let msg = fn(i, kind, expect, got) {
    msg(i, kind, expect |> int.to_string, got |> int.to_string)
  }
  let outcome = case mock_provider.0 != provider.repeation_map {
    True ->
      msg(
        mock_provider_index,
        "repeation_map",
        mock_provider.0,
        provider.repeation_map,
      )
    False -> []
  }
  case mock_provider.1 != provider.msb {
    True ->
      outcome
      |> list.append(msg(
        mock_provider_index,
        "msb",
        mock_provider.1,
        provider.msb,
      ))
    False -> outcome
  }
  |> display
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
    "  mock_sequence_provider_index: " <> index |> int.to_string,
    "    " <> subject <> ":",
    "      expected: " <> expected,
    "      received: " <> received,
  ]
}

fn display(msg) {
  use line <- list.map(msg)
  io.println(line)
}
