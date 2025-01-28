// import gleam/io
import update/update.{init}

pub fn main() {
  let volume_command_model = init(Nil)
  case volume_command_model.volume == 50 {
    True -> Nil
    _ -> panic as "expected 50: got ?"
  }
}
