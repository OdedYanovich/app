import ffi/array
import gleam/bool.{guard}
import gleam/int
import root.{type Image, Image, Pixel, pixel_dimensions}

pub fn new(rows, columns, spawn_offset, stopping_offset) {
  let stationary_pixels = {
    use _ <- array.create(columns)
    use _ <- array.create(rows)
    False
  }
  let moving_pixels = {
    use _ <- array.create(columns)
    use _ <- array.create(0)
    Pixel(existence_time: 0.0, position: #(0.0, 0.0), trajectory: #(0.0, 0.0))
  }
  let available_column_indices = {
    use index <- array.create(columns)
    index
  }
  Image(
    stationary_pixels:,
    moving_pixels:,
    available_column_indices:,
    columns_fullness: array.create(columns, fn(_) { 0 }),
    rows:,
    columns:,
    spawn_offset:,
    stopping_offset:,
  )
}

// pub fn draw_and_update_moving_pixels(image: Image, _time_elapsed) {}

// pub fn add_moving_pixel(image: Image, column_index) {}

// pub fn draw_and_update_moving_pixels_(image: Image, time_elapsed) {}

pub fn draw_stationary_pixels(image: Image) {
  use pixel, index <- array.iter(image.stationary_pixels)
  use <- guard(pixel, Nil)
  let row = index % image.rows
  let column = index / image.columns
  draw(
    to_relative_position(row) +. image.stopping_offset.0,
    to_relative_position(column) +. image.stopping_offset.1,
    row,
    column,
  )
}

@external(javascript, "../jsffi.mjs", "draw")
fn draw(x: Float, y: Float, row: Int, column: Int) -> Nil

fn to_relative_position(val) {
  val * pixel_dimensions |> int.to_float
}
// fn to_relative_position(val) {
//   val * pixel_dimensions |> int.to_float
// }

// fn animation(start, end, time) {
//   // { end -. start } /. { animation_end_time /. { animation_end_time -. time } }
//   start +. end *. { time /. animation_end_time }
// }
