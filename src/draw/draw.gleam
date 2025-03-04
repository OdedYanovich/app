import funtil.{fix}
import gleam/bool.{guard}
import gleam/int
import gleam/list
import root.{
  type Model, Model, animation, animation_end_time, pixel_dimensions,
  pixel_spawn_offset, pixel_stopping_offset,
}
import gleam/bit_array.{to_list}

pub fn draw_frame(model: Model, program_duration) {
  let time_elapsed = program_duration -. model.program_duration
  start_drawing()
  let drawn_pixels = {
    use column, column_index <- list.index_map(model.stationary_pixels)
    use pixel, row_index <- list.index_map(column)
    let Column(stationary_pixels, moving_pixels) = case
      moving_pixels |> list.first
    {
      Ok(oldest_moving_pixel_creation_time)
        if oldest_moving_pixel_creation_time >. animation_end_time
      -> Column(stationary_pixels + 1, moving_pixels |> list.drop(1))
      _ -> Column(stationary_pixels, moving_pixels)
    }
    {
      use draw_stationary_pixels, image_stationary_row <- fix
      use <- guard(image_stationary_row == stationary_pixels, Nil)
      let x = image_column |> to_relative_position
      let y = image_stationary_row |> to_relative_position
      draw(
        pixel_stopping_offset.0 +. x,
        pixel_stopping_offset.1 +. y,
        image_column,
        image_stationary_row,
      )
      draw_stationary_pixels(image_stationary_row + 1)
    }(0)
    let updated_moving_pixels = {
      use time_since_creation, moving_row <- list.index_map(moving_pixels)
      let moving_row = moving_row + stationary_pixels
      let x = image_column |> to_relative_position
      let y = moving_row |> to_relative_position
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
        image_column,
        moving_row,
      )
      time_since_creation +. time_elapsed
    }
    Column(stationary_pixels, updated_moving_pixels)
  }
  Model(..model, drawn_pixels:, program_duration:)
}

@external(javascript, "../jsffi.mjs", "startDrawing")
fn start_drawing() -> Nil

@external(javascript, "../jsffi.mjs", "draw")
fn draw(x: Float, y: Float, row: Int, column: Int) -> Nil

fn to_relative_position(val) {
  val * pixel_dimensions |> int.to_float
}
