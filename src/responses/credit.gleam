import gleam/dict
import root.{Hub, Model, effectless}

pub fn entering_credit(entering_hub) {
  [
    #("z", fn(model) {
      Model(..model, mod: Hub, responses: entering_hub() |> dict.from_list)
      |> effectless
    }),
  ]
  |> dict.from_list
}
