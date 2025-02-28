import lustre
import update.{init, update}
import view/view.{view}

pub fn main() {
  let assert Ok(_runtime) =
    lustre.application(init, update, view)
    |> lustre.start("#app", Nil)
}
