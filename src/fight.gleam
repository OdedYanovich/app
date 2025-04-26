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
  case echo fight.last_action_group == pressed_group {
    False -> {
      let choice =
        echo case pressed_group {
          NorthWest | NorthEast -> Change
          SouthWest | SouthEast -> Stay
          _ -> panic
        }
      let choice = case choice {
        Stay -> True
        Change -> False
      }
      case choice == { fight.level |> level.get_element() } {
        False ->
          Model(
            ..model,
            mod: FightBody(
                ..fight,
                hp: fight.hp -. 8.0,
                last_action_group: pressed_group,
              )
              |> mod,
          )
        True ->
          case fight.hp >. 80.0 {
            False ->
              Model(
                ..model,
                mod: FightBody(
                    ..fight,
                    hp: fight.hp +. 8.0,
                    level: fight.level |> level.next_element,
                    last_action_group: pressed_group,
                  )
                  |> mod,
              )
            True -> model |> transition(HubId)
          }
      }
    }
    True -> model
  }
}
