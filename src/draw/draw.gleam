// import funtil.{fix}
import gleam/bool.{guard}
import gleam/int
import gleam/list
import root.{
  type Model, Model, Pixel, animation_end_time, image_columns, image_rows,
  moving_pixel_spawn_offset, pixel_dimensions, pixel_spawn_offset,
  pixel_stopping_offset,
}

pub fn draw_frame(model: Model, program_duration) {
  start_drawing()
  let time_elapsed = program_duration -. model.program_duration
  // optimization: Index the stopped index
  let #(moving_pixels, stopped_pixel) = case model.moving_pixels |> list.first {
    Ok(moving_pixel) if moving_pixel.existence_time >=. animation_end_time -> #(
      model.moving_pixels |> list.drop(1),
      moving_pixel.changing_point
        - { image_rows * 3 * image_columns + image_rows + 1 },
    )

    _ -> #(model.moving_pixels, 999_999_999)
  }

  let moving_pixels = {
    use moving_pixel <- list.map(moving_pixels)
    let #(x, y) = moving_pixel_spawn_offset()
    draw(
      x
        +. animation(
        moving_pixel.spawn_point % { image_rows * 3 } |> to_relative_position,
        moving_pixel.changing_point % { image_rows * 3 } |> to_relative_position,
        moving_pixel.existence_time,
      ),
      y
        +. animation(
        moving_pixel.spawn_point / { image_columns * 3 } |> to_relative_position,
        moving_pixel.changing_point / { image_columns * 3 }
          |> to_relative_position,
        moving_pixel.existence_time,
      ),
      4,
      4,
      // { moving_pixel.changing_point - image_rows * 3 - image_rows - 1 }
    //   / image_rows,
    // { moving_pixel.changing_point - image_rows * 3 - image_rows - 1 }
    //   % image_rows,
    )
    Pixel(
      ..moving_pixel,
      existence_time: moving_pixel.existence_time +. time_elapsed,
    )
  }
  let stationary_pixels = {
    use column, column_index <- list.index_map(model.stationary_pixels)
    use pixel, row_index <- list.index_map(column)

    use <- guard(
      !pixel || row_index + column_index * image_rows == stopped_pixel,
      False,
    )
    let x = to_relative_position(row_index) +. pixel_stopping_offset.0
    let y = to_relative_position(column_index) +. pixel_stopping_offset.1
    draw(x, y, column_index, row_index)
    True
  }
  Model(..model, stationary_pixels:, moving_pixels:, program_duration:)
}

@external(javascript, "../jsffi.mjs", "startDrawing")
fn start_drawing() -> Nil

@external(javascript, "../jsffi.mjs", "draw")
fn draw(x: Float, y: Float, row: Int, column: Int) -> Nil

fn to_relative_position(val) {
  val * pixel_dimensions |> int.to_float
}

fn animation(start, end, time) {
  // { end -. start } /. { animation_end_time /. { animation_end_time -. time } }
  start +. end *. { time /. animation_end_time }
}
