// import funtil.{fix}
// import gleam/bool.{guard}
// import gleam/int
// import gleam/list
import root.{type Model, Model}

//  Pixel, animation_end_time, image_columns, image_rows,

// moving_pixel_spawn_offset, pixel_dimensions, pixel_stopping_offset,
import view/image.{draw_and_update_moving_pixels, draw_stationary_pixels}

pub fn draw_frame(model: Model, program_duration) {
  start_drawing()
  let time_elapsed = program_duration -. model.program_duration
  let image = draw_and_update_moving_pixels(model.image, time_elapsed)
  let image=todo
  draw_stationary_pixels(image)
  Model(..model, image:, program_duration:)
  // let stationary_pixels =
  //   Image(
  //     {
  //       use column, column_index <- list.index_map(
  //         model.image.stationary_pixels,
  //       )
  //       use pixel, row_index <- list.index_map(column)

  //       use <- guard(
  //         !pixel || row_index + column_index * image_rows == stopped_pixel,
  //         False,
  //       )
  //       let x = to_relative_position(row_index) +. pixel_stopping_offset.0
  //       let y = to_relative_position(column_index) +. pixel_stopping_offset.1
  //       draw(x, y, column_index, row_index)
  //       True
  //     },
  //     model.stationary_pixels.full_columns,
    // )
}

@external(javascript, "./jsffi.mjs", "startDrawing")
fn start_drawing() -> Nil
// @external(javascript, "../jsffi.mjs", "draw")
// fn draw(x: Float, y: Float, row: Int, column: Int) -> Nil

// fn to_relative_position(val) {
//   val * pixel_dimensions |> int.to_float
// }

// fn animation(start, end, time) {
//   // { end -. start } /. { animation_end_time /. { animation_end_time -. time } }
//   start +. end *. { time /. animation_end_time }
// }
