import gleam/dict
import update/root.{Fight, Hub, Irrelevant, Model}
import update/state_dependent/fight
import update/state_dependent/hub

pub fn transition(model, new_mod) {
  let all_responses =
    [#(Hub, hub.responses()), #(Fight(Irrelevant), fight.responses())]
    |> dict.from_list
  Model(
    ..model,
    player_combo: [],
    mod: new_mod,
    responses: model.responses
      |> dict.drop(case
        all_responses
        |> dict.get(model.mod)
      {
        Ok(responses) -> responses |> dict.from_list |> dict.keys
        Error(_) -> panic
      })
      |> dict.merge(case
        all_responses
        |> dict.get(new_mod)
      {
        Ok(responses) -> responses |> dict.from_list
        Error(_) -> panic
      }),
  )
}
