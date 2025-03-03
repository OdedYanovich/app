import funtil.{fix}
import gleam/bool.{guard}
import gleam/int
import gleam/list
import root.{
  type Model, Column, Model, animation, animation_end_time, effectless,
  pixel_dimensions, pixel_spawn_offset, pixel_stopping_offset,
}

// image_columns, image_rows,

pub fn draw_frame(model: Model, program_duration) {
  let time_elapsed = program_duration -. model.program_duration
  start_drawing()
  let drawn_pixels = {
    use Column(stationary_pixels, moving_pixels), column <- list.index_map(
      model.drawn_pixels,
    )
    let Column(stationary_pixels, moving_pixels) = case
      moving_pixels |> list.first
    {
      Ok(oldest_moving_pixel_creation_time)
        if oldest_moving_pixel_creation_time >. animation_end_time
      -> Column(stationary_pixels + 1, moving_pixels |> list.drop(1))
      _ -> Column(stationary_pixels, moving_pixels)
    }
    {
      use draw_stationary_pixels, row <- fix
      use <- guard(row == 0, Nil)
      // let #(x, y) = relative_position(row)
      let #(x, y) = #(
        row |> to_relative_position,
        column |> to_relative_position,
      )
      draw(
        pixel_stopping_offset.0 +. x,
        pixel_stopping_offset.1 +. y,
        row,
        column,
      )
      draw_stationary_pixels(row - 1)
    }(stationary_pixels)
    let updated_moving_pixels = {
      use time_since_creation, row <- list.index_map(moving_pixels)
      // let #(x, y) = relative_position(row + stationary_pixels)
      let #(x, y) = #(
        { row } |> to_relative_position,
        column |> to_relative_position,
      )
      draw(
        x
          +. pixel_stopping_offset.0
          -. animation(
          pixel_spawn_offset.0,
          pixel_stopping_offset.0,
          time_since_creation,
        ),
        y
          +. pixel_stopping_offset.1
          -. animation(
          pixel_spawn_offset.1,
          pixel_stopping_offset.1,
          time_since_creation,
        ),
        row,
        column,
      )
      time_since_creation +. time_elapsed
    }
    Column(stationary_pixels, updated_moving_pixels)
  }
  Model(
    ..model,
    timer: model.timer -. time_elapsed,
    drawn_pixels:,
    program_duration:,
  )
  |> effectless
}

@external(javascript, "../jsffi.mjs", "startDrawing")
fn start_drawing() -> Nil

@external(javascript, "../jsffi.mjs", "draw")
fn draw(x: Float, y: Float, row: Int, column: Int) -> Nil

// fn relative_position(pixel_id) {
//   #(
//     { pixel_id % image_columns } * pixel_dimensions |> int.to_float,
//     { pixel_id / image_rows } * pixel_dimensions |> int.to_float,
//   )
// }

fn to_relative_position(val) {
  val * pixel_dimensions |> int.to_float
}
