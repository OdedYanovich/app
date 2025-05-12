import funtil
import gleam/bool
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import root.{type SequenceProvider}
import sequence_provider

pub fn make_clue(sequence_provider: SequenceProvider, level_length) {
  let #(updated_level, pattern) =
    funtil.fix3(fn(f, sequence_provider, i, pattern) {
      use <- bool.guard(i == 0, #(sequence_provider, pattern))
      f(
        sequence_provider |> sequence_provider.next_element,
        i - 1,
        pattern
          |> list.append([sequence_provider |> sequence_provider.get_element()]),
      )
    })(sequence_provider, level_length, [])
  funtil.fix3(fn(f, updated_level, pattern_lists, pattern) {
    use <- bool.guard(updated_level == sequence_provider, pattern_lists)
    let assert [_, ..pattern] =
      pattern |> list.append([updated_level |> sequence_provider.get_element])
    f(
      updated_level |> sequence_provider.next_element,
      pattern_lists
        |> dict.upsert(pattern, fn(pattern_counter) {
          case pattern_counter {
            Some(_pattern_counter) -> todo
            None -> todo
          }
        }),
      pattern,
    )
  })(updated_level, [#(pattern, 1)] |> dict.from_list, pattern)
  |> dict.values
  |> list.fold(0, fn(_biggest, _counter) { todo })
}
