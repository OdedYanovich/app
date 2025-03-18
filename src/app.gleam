import initialization.{init}
import lustre
import update.{update}
import view/view.{view}

pub fn main() {
  let assert Ok(_runtime) =
    lustre.application(init, update, view)
    |> lustre.start("#app", Nil)
}
