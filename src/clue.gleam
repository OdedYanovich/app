import funtil
import gleam/bool
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import level
import root.{type Level}

pub fn make_clue(level: Level) {
  let original_level = level
  let #(level, clue) =
    {
      use f, level, i, clue <- funtil.fix3
      use <- bool.guard(i == 3, #(level, clue))
      f(
        level |> level.next_element,
        i + 1,
        clue |> list.append([level |> level.get_element()]),
      )
    }(level, 0, [])
  let counters = [#(clue, 1)] |> dict.from_list
  funtil.fix3(fn(f, level, counters, clue) {
    use <- bool.guard(level == original_level, counters)
    let assert [_, ..clue] = clue |> list.append([level |> level.get_element])
    f(
      level |> level.next_element,
      counters
        |> dict.upsert(clue, fn(sequence_counter) {
          case sequence_counter {
            Some(sequence_counter) -> todo
            None -> todo
          }
        }),
      clue,
    )
  })(level, counters, clue)
  |> dict.values
  |> list.fold(0, fn(biggest, counter) { todo })
}
