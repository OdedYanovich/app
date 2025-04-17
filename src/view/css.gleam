import gleam/float
import gleam/int
import gleam/list

pub type Position {
  Absolute
}

pub fn position(position: Position) {
  case position {
    Absolute -> #("position", "absolute")
  }
}

pub type Color {
  Black
  White
  Green
  Blue
  RGBA(Length, Length, Length, Length)
}

fn color_to_string(color) {
  case color {
    Black -> "black"
    White -> "white"
    Green -> "green"
    Blue -> "blue"
    RGBA(r, g, b, a) ->
      "rgba("
      <> [r, g, b, a]
      |> list.fold("", fn(state, element) {
        state <> { element |> length_to_string }
      })
  }
}

pub fn color(color) {
  #("color", color |> color_to_string)
}

pub fn background_color(color: Color) {
  #("background-color", color |> color_to_string)
}

pub type Length {
  REM(Float)
  Px(Int)
  VW(Int)
  VH(Int)
  Fr(Int)
  Precent(Int)
}

fn length_to_string(length) {
  case length {
    REM(f) -> float.to_string(f) <> "rem"
    Px(i) -> int.to_string(i) <> "px"
    VW(i) -> int.to_string(i) <> "vw"
    VH(i) -> int.to_string(i) <> "vh"
    Fr(i) -> int.to_string(i) <> "fr"
    Precent(i) -> int.to_string(i) <> "%"
  }
}

pub fn left(length) {
  #("left", length |> length_to_string)
}

pub fn top(length) {
  #("top", length |> length_to_string)
}

pub fn width(length) {
  #("width", length |> length_to_string)
}

pub fn height(length) {
  #("height", length |> length_to_string)
}

pub type Display {
  Grid
}

pub fn display(display) {
  case display {
    Grid -> #("display", "grid")
  }
}

pub type TrackList {
  Repeat(Int, Length)
  Unique(List(Length))
  SubGrid
}

fn track_list_to_string(track_list) {
  case track_list {
    Repeat(repeat_count, length) ->
      "repeat("
      <> repeat_count |> int.to_string
      <> ","
      <> length |> length_to_string
      <> ")"

    Unique(lengths) ->
      list.fold(lengths, "", fn(return, added) {
        return <> " " <> added |> length_to_string
      })
    SubGrid -> "subgrid"
  }
}

pub fn grid_template(grid_template_rows, grid_template_column) {
  #(
    "grid-template",
    grid_template_rows |> track_list_to_string
      <> "/"
      <> grid_template_column |> track_list_to_string,
  )
}

pub fn grid_template_rows(grid_template_rows) {
  #("grid-template-rows", grid_template_rows |> track_list_to_string)
}

pub fn grid_template_columns(grid_template_columns) {
  #("grid-template-columns", grid_template_columns |> track_list_to_string)
}

pub type Area {
  Area(String)
}

pub fn grid_template_areas(areas: List(List(Area))) {
  #(
    "grid-template-areas",
    list.fold(areas, "", fn(areas, row) {
      areas
      <> list.fold(row, "\"", fn(row, area) {
        let Area(area) = area
        row <> " " <> area
      })
      <> "\"\n"
    }),
  )
}

pub fn grid_area(area: Area) {
  let Area(area) = area
  #("grid-area", area)
}

pub type PlaceItems {
  Center
}

/// shorthand for align-items and justify-items
pub fn place_items(place_items) {
  case place_items {
    Center -> #("place-items", "center")
  }
}

pub fn align_items(align_items) {
  case align_items {
    Center -> #("place-items", "center")
  }
}

pub type GridAutoFlow {
  Column
}

pub fn grid_auto_flow(grid_auto_flow) {
  #("grid-auto-flow", case grid_auto_flow {
    Column -> "column"
  })
}

pub fn font_size(length) {
  #("font-size", length |> length_to_string)
}

pub fn padding(length) {
  #("padding", length |> length_to_string)
}

pub type BoxSizing {
  BorderBox
}

pub fn box_sizing(box_sizing) {
  #("box-sizing", case box_sizing {
    BorderBox -> "border-box"
  })
}

pub type Angle {
  Left
}

pub fn animation(str) {
  #("animation", str)
}
// fn direction_to_string(direction) {
//   case direction {
//     Left -> "to left"
//   }
// }

// pub fn background(direction, big_color, small_color) {
//   #("background", "")
// }
