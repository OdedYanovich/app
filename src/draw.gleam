// import funtil.{fix}
// import gleam/bool.{guard}
import root.{type Model, Model}
import ffi/gleam/main.{start_drawing}

pub fn draw_frame(model: Model, program_duration) {
  start_drawing()
  // let time_elapsed = program_duration -. model.program_duration
  Model(..model, program_duration:)
}
