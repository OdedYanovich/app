import level
import root.{
  type Model, Change, Fight, FightBody, HubId, IntroductoryFight, Model,
  NorthEast, NorthWest, SouthEast, SouthWest, Stay, transition,
}

pub fn progress(model: Model, pressed_group) {
  let #(mod, fight) = case model.mod {
    Fight(fight) -> #(Fight, fight)
    IntroductoryFight(fight) -> #(IntroductoryFight, fight)
    _ -> panic
  }
  case fight.last_action_group == pressed_group {
    False -> {
      let choice = case pressed_group {
        NorthWest | NorthEast -> Change
        SouthWest | SouthEast -> Stay
        _ -> panic
      }
      case fight.wanted_choice == choice {
        True ->
          case fight.hp >. 80.0 {
            False ->
              Model(
                ..model,
                mod: FightBody(
                    ..fight,
                    level: fight.level |> level.next_element,
                  )
                  |> mod,
              )
            True -> model |> transition(HubId)
          }
        False ->
          Model(
            ..model,
            mod: FightBody(..fight, hp: fight.hp -. 8.0)
              |> mod,
          )
      }
    }
    True -> model
  }
}
// fn fight_response(fight: FightBody, latest_key_press: String) {
//   use <- guard(level.displayed_button(fight) != latest_key_press, #(
//     FightBody(..fight, hp: fight.hp -. 8.0),
//     DoNothing,
//   ))
//   let fight = level.next_action(fight, fight.last_button_group)
//   use <- guard(fight.hp >. 80.0, #(fight, ToHub))
//   #(FightBody(..fight, hp: fight.hp +. 8.0), DoNothing)
// ,}
