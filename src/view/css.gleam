import gleam/float
import gleam/int

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
  RGBA(Length, Length, Length, Length)
}

fn color_to_string(color) {
  case color {
    Black -> "black"
    White -> "white"
    Green -> "green"
    RGBA(r, g, b, a) ->
      "rgba("
      <> r |> length_to_string
      <> g |> length_to_string
      <> b |> length_to_string
      <> a |> length_to_string
      <> ")"
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

pub type Reapet =
  #(Int, Length)

fn reapet_to_string(reapet: Reapet) {
  "repeat("
  <> reapet.0 |> int.to_string
  <> ","
  <> reapet.1 |> length_to_string
  <> ")"
}

pub fn grid_template(reapet_row, reapet_column) {
  #(
    "grid-template",
    reapet_row |> reapet_to_string <> "/" <> reapet_column |> reapet_to_string,
  )
}

pub type PlaceItems {
  Center
}

pub fn place_items(place_items) {
  case place_items {
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
// fn direction_to_string(direction) {
//   case direction {
//     Left -> "to left"
//   }
// }

// pub fn background(direction, big_color, small_color) {
//   #("background", "")
// }
