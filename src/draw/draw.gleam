import gleam/list
import root.{
  type Model, Model, MovingPixel, animation, animation_end_time, effectless,
  pixel_general_spawn_point, pixel_general_stopping_point, relative_position,
}

pub fn draw_frame(model: Model, program_duration) {
  let time_elapsed = program_duration -. model.program_duration
  let #(stationary_pixels, moving_pixels) = case
    list.first(model.moving_pixels)
  {
    Ok(MovingPixel(pixel_id, time_since_creation))
      if time_since_creation >. animation_end_time
    -> {
      #(
        model.stationary_pixels
          |> list.append([root.StationaryPixel(pixel_id)]),
        model.moving_pixels |> list.drop(1),
      )
    }
    _ -> #(model.stationary_pixels, model.moving_pixels)
  }
  start_drawing()

  model.stationary_pixels
  |> list.map(fn(pixel) {
    let #(x, y) = relative_position(pixel.id)
    draw(
      pixel_general_stopping_point.0 +. x,
      pixel_general_stopping_point.1 +. y,
      pixel.id,
    )
  })

  model.moving_pixels
  |> list.map(fn(pixel) {
    let assert MovingPixel(id, time_since_creation) = pixel
    let #(x, y) = relative_position(id)
    draw(
      x
        +. pixel_general_stopping_point.0
        -. animation(
        pixel_general_spawn_point.0,
        pixel_general_stopping_point.0,
        time_since_creation,
      ),
      y
        +. pixel_general_stopping_point.1
        -. animation(
        pixel_general_spawn_point.1,
        pixel_general_stopping_point.1,
        time_since_creation,
      ),
      id,
    )
  })
  Model(
    ..model,
    stationary_pixels:,
    moving_pixels: moving_pixels
      |> list.map(fn(pixel) {
        let assert MovingPixel(id, time_since_creation) = pixel
        MovingPixel(id, time_since_creation +. time_elapsed)
      }),
    timer: model.timer -. time_elapsed,
    program_duration:,
  )
  |> effectless
}

@external(javascript, "../jsffi.mjs", "startDrawing")
fn start_drawing() -> Nil

@external(javascript, "../jsffi.mjs", "draw")
fn draw(x: Float, y: Float, pixel_id: Int) -> Nil
