import gleam/bool.{guard}
import gleam/dict
import gleam/list
import root.{
  type Model, EndDmg, Hub, Model, add_effect, all_command_keys, effectless,
}

pub fn entering_fight(entering_hub) {
  list.map(all_command_keys, fn(key) {
    #(key, fn(model: Model) {
      use <- guard(
        model.required_combo |> list.take(1) != [model.latest_key_press],
        Model(..model, hp: model.hp -. 8.0)
          |> effectless,
      )
      use <- guard(
        model.hp >. 80.0,
        Model(
          ..model,
          mod: Hub,
          responses: entering_hub() |> dict.from_list,
          unlocked_levels: model.unlocked_levels + 1,
          hp: 5.0,
        )
          |> add_effect(fn(dispatch) { dispatch(EndDmg) }),
      )
      Model(
        ..model,
        hp: model.hp +. 8.0,
        // seed:,
          required_combo: model.required_combo
          |> list.drop(1)
          |> list.append(model.level.phase.buttons |> list.sample(1)),
      )
      |> effectless
    })
  })
  |> list.append([
    #("z", fn(model) {
      Model(..model, mod: Hub, responses: entering_hub() |> dict.from_list)
      |> add_effect(fn(dispatch) { dispatch(EndDmg) })
    }),
  ])
}
