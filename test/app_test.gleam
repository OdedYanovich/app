import gleam/io

// import update/update.{init}
import gleam/dynamic/decode.{type Dynamic}

pub fn main() {
  io.debug(new_array(3, 3))
  // let volume_command_model = init(Nil)
  // case volume_command_model.volume == 50 {
  //   True -> Nil
  //   _ -> panic as "expected 50: got ?"
  // }
}

@external(javascript, "./ffi.mjs", "newArray")
fn new_array(rows: Int, columns: Int) -> Dynamic
