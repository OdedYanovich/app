import level
import root.{
  type FightBody, type Model, Change, Fight, FightBody, HubId, IntroductoryFight,
  Model, NorthEast, NorthWest, SouthEast, SouthWest, Stay, transition,
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
      let choice = case choice {
        Stay -> False
        Change -> True
      }
      case choice == level.get_element(fight.level) {
        False ->
          Model(
            ..model,
            mod: FightBody(
                ..fight,
                hp: fight.hp -. 4.0,
                last_action_group: pressed_group,
              )
              |> mod,
          )
        True ->
          case fight.hp >. 80.0 {
            True -> transition(model, HubId)
            False ->
              Model(
                ..model,
                mod: FightBody(
                    ..fight,
                    hp: fight.hp +. 4.0,
                    level: fight.level |> level.next_element,
                    last_action_group: pressed_group,
                  )
                  |> mod,
              )
          }
      }
    }
    True -> model
  }
}

// Belong to groups
pub fn displayed_button(fight: FightBody) {
  case level.get_element(fight.level) {
    True -> "y"
    False -> "b"
  }
}
