import array
import gleam/bool.{guard}
import gleam/dynamic/decode.{type Dynamic}
import gleam/int
import gleam/list
import root.{
  type Array, type Image, type MovingPixel, Image, Pixel, animation_end_time,
  pixel_dimensions,
}

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

pub fn draw_and_update_moving_pixels(image: Image, time_elapsed) {
  use column, column_index <- array.map(image.moving_pixels)
  // let first: MovingPixel = column |> array.get(0)
  // let #(stationary_pixels_column, moving_pixels_column) = case
  //   first.existence_time >=. animation_end_time
  // {
  //   True -> {
  //     let stationary_pixels =
  //       image.stationary_pixels
  //       |> array.set(
  //         column_index,
  //         array.get(image.stationary_pixels, column_index)
  //           |> array.set(
  //             image.columns_fullness |> array.get(column_index),
  //             True,
  //           ),
  //       )
  //     #(stationary_pixels, array.pop_back(image.moving_pixels).0)
  //   }
  //   False -> #(image.stationary_pixels |> array.get(column_index), column)
  // }
  use pixel, row_index <- array.map(column)
  let Pixel(existence_time, position, trajectory) = pixel
}

pub fn add_moving_pixel(image: Image, column_index) {
  case image.columns_fullness |> array.get(column_index) == image.rows - 1 {
    _ -> Nil
  }
  Image(
    ..image,
    // full_columns: image.full_columns + 1,
  // columns_fullness: array.add_one(image.columns_fullness, column_index),
  )
}

pub fn draw_and_update_moving_pixels_(image: Image, time_elapsed) {
  let moving_pixels = {
    // use column, index <- array.map(image.moving_pixels)
    // case column |> array.last {
    //   Ok(moving_pixel) if moving_pixel.existence_time >=. animation_end_time ->
    //     Image(
    //       ..image,
    //       stationary_pixels: moving_pixels_column_index
    //         |> first_empty_pixel_on_column(image)
    //         |> real_dimensions_to_real_index(image)
    //         |> pixel_on(image.stationary_pixels),
    //     )
    //   moving_pixel -> moving_pixel
    // }
    todo
  }
  use column, column_index <- array.iter(moving_pixels)
  use moving_pixel, row_index <- array.iter(column)
  let Pixel(existence_time, #(x, y), #(tx, ty)) = moving_pixel
  draw(x, y, 4, 4)

  let image = {
    todo
    // use image, moving_pixels_column, moving_pixels_column_index <- list.index_fold(
    //   image.moving_pixels,
    //   image,
    // )
    // case moving_pixels_column |> list.first {
    //   Ok(moving_pixel) if moving_pixel.existence_time >=. animation_end_time ->
    //     Image(
    //       ..image,
    //       stationary_pixels: moving_pixels_column_index
    //         |> first_empty_pixel_on_column(image)
    //         |> real_dimensions_to_real_index(image)
    //         |> pixel_on(image.stationary_pixels),
    //     )
    //   _ -> image
    // }
  }
  {
    todo
    // use column <- list.map(image.moving_pixels)
    // use moving_pixel <- list.map(column)
    // let Pixel(existence_time, #(x, y), #(tx, ty)) = moving_pixel
    // draw(x, y, 4, 4)
    // Pixel(
    //   ..moving_pixel,
    //   existence_time: existence_time +. time_elapsed,
    //   position: #(x +. tx *. time_elapsed, y +. ty *. time_elapsed),
    // )
  }
  image
}

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
  //   use column, column_index <- list.index_map(image.stationary_pixels)
  //   use pixel, row_index <- list.index_map(column)

  //   let x = to_relative_position(row_index) +. pixel_stopping_offset.0
  //   let y = to_relative_position(column_index) +. pixel_stopping_offset.1
  //   draw(x, y, column_index, row_index)
  //   pixel
}

// fn real_to_imaginary_index(index, image: Image) -> ImaginaryImageIndex {
//   index + image.columns * { 3 * image.rows - 1 }
// }

@external(javascript, "../jsffi.mjs", "draw")
fn draw(x: Float, y: Float, row: Int, column: Int) -> Nil

// fn animation(start, end, time) {
//   // { end -. start } /. { animation_end_time /. { animation_end_time -. time } }
//   start +. end *. { time /. animation_end_time }
// }

fn to_relative_position(val) {
  val * pixel_dimensions |> int.to_float
}

fn first_empty_pixel_on_column(column_index, image: Image) {
  todo
  // let assert Ok(filled_rows_count) =
  //   image.columns_fullness
  //   |> array.get(column_index)
  //   |> decode.run(decode.int)
  // Dimension(filled_rows_count, column_index)
}
// type RealImageIndex =
//   Int

// type RealImageDimensions {
//   Dimension(row: Int, column: Int)
// }

// fn real_dimensions_to_real_index(
//   dimensions: RealImageDimensions,
//   image: Image,
// ) -> RealImageIndex {
//   { dimensions.column - 1 } * image.rows + image.rows - 1
// }

// type ImaginaryImageIndex =
//   Int
