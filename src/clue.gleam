import funtil
import gleam/bool
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import root.{type SequenceProvider}
import sequence_provider.{get_element}

pub fn make_clue(sequence_provider: SequenceProvider, final_sequence_length) {
  let #(updated_provider, pattern) =
    {
      use make_first_pattern, sequence_provider, i, pattern <- funtil.fix3
      use <- bool.guard(i == 0, #(sequence_provider, pattern))
      make_first_pattern(
        sequence_provider |> sequence_provider.next_element,
        i - 1,
        pattern
          |> list.append([sequence_provider |> get_element()]),
      )
    }(sequence_provider, final_sequence_length, [])
  // let potential_repeation
  {
    use make_pattern_list, updated_level, pattern_lists, pattern <- funtil.fix3
    use <- bool.guard(updated_level == sequence_provider, pattern_lists)
    let assert [_, ..pattern] =
      pattern |> list.append([updated_level |> sequence_provider.get_element])
    make_pattern_list(
      updated_level |> sequence_provider.next_element,
      pattern_lists
        |> dict.upsert(pattern, fn(pattern_counter) {
          case pattern_counter {
            Some(pattern_counter) -> pattern_counter + 1
            None -> 1
          }
        }),
      pattern,
    )
  }(updated_provider, [#(pattern, 1)] |> dict.from_list, pattern)
  |> dict.values
  |> list.fold(0, fn(_biggest, _counter) { todo })
}
