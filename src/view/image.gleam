import array
import gleam/bool.{guard}
import gleam/dynamic/decode.{type Dynamic}
import gleam/int
import gleam/list
import root.{
  type Array, type Image, type MovingPixel, Image, Pixel, animation_end_time,
  pixel_dimensions,
}

pub fn finished(image: Image) {
  image.full_columns >= image.rows
}

pub fn draw_and_update_moving_pixels(image: Image, time_elapsed) {
  let image = {
    use image, moving_pixels_column, moving_pixels_column_index <- list.index_fold(
      image.moving_pixels,
      image,
    )
    case moving_pixels_column |> list.first {
      Ok(moving_pixel) if moving_pixel.existence_time >=. animation_end_time ->
        Image(
          ..image,
          stationary_pixels: moving_pixels_column_index
            |> first_empty_pixel_on_column(image)
            |> real_dimensions_to_real_index(image)
            |> pixel_on(image.stationary_pixels),
        )
      _ -> image
    }
  }
  {
    use column <- list.map(image.moving_pixels)
    use moving_pixel <- list.map(column)
    let Pixel(existence_time, #(x, y), #(tx, ty)) = moving_pixel
    draw(x, y, 4, 4)
    Pixel(
      ..moving_pixel,
      existence_time: existence_time +. time_elapsed,
      position: #(x +. tx *. time_elapsed, y +. ty *. time_elapsed),
    )
  }
  image
  //   let #(x, y) = moving_pixel_spawn_offset()
  //   draw(
  //     x
  //       +. animation(
  //       moving_pixel.spawn_point % { image_rows * 3 } |> to_relative_position,
  //       moving_pixel.changing_point % { image_rows * 3 } |> to_relative_position,
  //       moving_pixel.existence_time,
  //     ),
  //     y
  //       +. animation(
  //       moving_pixel.spawn_point / { image_columns * 3 } |> to_relative_position,
  //       moving_pixel.changing_point / { image_columns * 3 }
  //         |> to_relative_position,
  //       moving_pixel.existence_time,
  //     ),
  //     4,
  //     4,
  //     // { moving_pixel.changing_point - image_rows * 3 - image_rows - 1 }
  //   //   / image_rows,
  //   // { moving_pixel.changing_point - image_rows * 3 - image_rows - 1 }
  //   //   % image_rows,
  //   )
}

pub fn draw_stationary_pixels(image: Image) {
  use pixel, row_index, column_index <- iter(image.stationary_pixels)
  use <- guard(pixel, Nil)
  draw(
    to_relative_position(row_index) +. image.stopping_offset.0,
    to_relative_position(column_index) +. image.stopping_offset.1,
    column_index,
    row_index,
  )
  //   use column, column_index <- list.index_map(image.stationary_pixels)
  //   use pixel, row_index <- list.index_map(column)

  //   let x = to_relative_position(row_index) +. pixel_stopping_offset.0
  //   let y = to_relative_position(column_index) +. pixel_stopping_offset.1
  //   draw(x, y, column_index, row_index)
  //   pixel
}

pub fn add_moving_pixel(column_index, image: Image) {
  use <- guard(
    first_empty_pixel_on_column(column_index, image).row == 8,
    Image(
      ..image,
      full_columns: image.full_columns + 1,
      columns_fullness: array.add_one(image.columns_fullness, column_index),
    ),
  )
  Image(..image)
  //   |> real_dimensions_to_real_index(image)
  //   |> real_to_imaginary_index(image)
}

fn real_to_imaginary_index(index, image: Image) -> ImaginaryImageIndex {
  index + image.columns * { 3 * image.rows - 1 }
}

@external(javascript, "../jsffi.mjs", "draw")
fn draw(x: Float, y: Float, row: Int, column: Int) -> Nil

@external(javascript, "../jsffi.mjs", "iter")
fn iter(
  array: Dynamic,
  callback: fn(pixel, row_index, column_index) -> Nil,
) -> Nil

// fn animation(start, end, time) {
//   // { end -. start } /. { animation_end_time /. { animation_end_time -. time } }
//   start +. end *. { time /. animation_end_time }
// }

fn to_relative_position(val) {
  val * pixel_dimensions |> int.to_float
}

@external(javascript, "../jsffi.mjs", "pixelOn")
fn pixel_on(index: Int, array: Array) -> Array

fn first_empty_pixel_on_column(column_index, image: Image) {
  let assert Ok(filled_rows_count) =
    image.columns_fullness
    |> array.get(column_index)
    |> decode.run(decode.int)
  Dimension(filled_rows_count, column_index)
}

type RealImageIndex =
  Int

type RealImageDimensions {
  Dimension(row: Int, column: Int)
}

fn real_dimensions_to_real_index(
  dimensions: RealImageDimensions,
  image: Image,
) -> RealImageIndex {
  { dimensions.column - 1 } * image.rows + image.rows - 1
}

type ImaginaryImageIndex =
  Int
