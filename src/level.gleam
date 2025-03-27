import gleam/option.{None, Some}
import root.{Phase}

pub fn levels(index) {
  [
    [Phase(buttons: "as", max_press_count: -1)],
    [Phase(buttons: "asd", max_press_count: -1)],
    [Phase(buttons: "das", max_press_count: -1)],
  ]
  |> find_by_index(index)
  |> option.unwrap([])
}

fn find_by_index(list: List(a), index: Int) {
  find_by_index_inside(list, 0, index)
}

fn find_by_index_inside(list, current_index, index) {
  case list, current_index == index {
    [first, ..], True -> Some(first)
    [_first, ..rest], False ->
      find_by_index_inside(rest, current_index + 1, index)
    [], _ -> None
  }
}
