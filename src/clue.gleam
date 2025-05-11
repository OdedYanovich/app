import funtil
import gleam/bool
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import level
import root.{type Level}

pub fn make_clue(level: Level, level_length) {
  let #(updated_level, pattern) =
    funtil.fix3(fn(f, level, i, pattern) {
      use <- bool.guard(i == 0, #(level, pattern))
      f(
        level |> level.next_element,
        i - 1,
        pattern |> list.append([level |> level.get_element()]),
      )
    })(level, level_length, [])
  funtil.fix3(fn(f, updated_level, counters, clue) {
    use <- bool.guard(updated_level == level, counters)
    let assert [_, ..clue] =
      clue |> list.append([updated_level |> level.get_element])
    f(
      updated_level |> level.next_element,
      counters
        |> dict.upsert(clue, fn(pattern_counter) {
          case pattern_counter {
            Some(_pattern_counter) -> todo
            None -> todo
          }
        }),
      clue,
    )
  })(updated_level, [#(pattern, 1)] |> dict.from_list, pattern)
  |> dict.values
  |> list.fold(0, fn(_biggest, _counter) { todo })
}
