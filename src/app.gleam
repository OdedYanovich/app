import lustre
// import sketch
import update/update.{init, update}
import view.{view}

pub fn main() {
  // let assert Ok(stylesheet) = sketch.stylesheet(strategy: sketch.Ephemeral)
  let assert Ok(_runtime) =
    lustre.application(init, update, view)
    |> lustre.start("#app", Nil)
}
