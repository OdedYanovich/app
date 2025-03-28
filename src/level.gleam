import funtil
import gleam/option.{None, Some}
import root.{Phase}

pub fn levels(index) {
  let assert Some(phases) =
    [
      [Phase(buttons: "a", max_press_count: -1)],
      [Phase(buttons: "as", max_press_count: -1)],
      [Phase(buttons: "asd", max_press_count: -1)],
      [
        Phase(buttons: "as", max_press_count: 4),
        Phase(buttons: "df", max_press_count: 4),
      ],
    ]
    |> funtil.fix3(fn(find_by_index, list, current_index, index) {
      case list, current_index == index {
        [_first, ..rest], False -> find_by_index(rest, current_index + 1, index)
        [first, ..], True -> Some(first)
        [], _ -> None
      }
    })(0, index)
  phases
}
